import os
import sys
import traceback
from PyQt5.QtWidgets import QWidget, QVBoxLayout
from PyQt5.QtCore import QThread, QTimer, pyqtSignal, pyqtProperty
from config import Config
from logs import MultiLogger
from models import Slot, System

# --- GStreamer Environment ---
gst_root = os.path.join(os.getcwd(), "gstreamer")
os.environ["PATH"] = os.path.join(gst_root, "bin") + ";" + os.environ.get("PATH", "")
os.environ["GST_PLUGIN_PATH"] = os.path.join(gst_root, "lib", "gstreamer-1.0")
os.environ["GST_PLUGIN_SYSTEM_PATH"] = os.environ["GST_PLUGIN_PATH"]
os.environ["GST_REGISTRY"] = os.path.join(gst_root, "registry.bin")
os.environ["PYGI_DLL_DIRS"] = ";".join([os.path.join(gst_root, "bin")])

import gi
gi.require_version("Gst", "1.0")
gi.require_version("GstVideo", "1.0")
from gi.repository import Gst, GstVideo

Gst.init(None)


# --- VideoItem ---
class VideoItem(QThread):
    streamStateChanged = pyqtSignal()
    RECONNECT_DELAY_MS = 2000
    STOP_TIMEOUT_SEC = 5

    def __init__(self, config: Config, logger: MultiLogger, slot: Slot):
        super().__init__()
        self.rtsp_url = None
        self.system_id = "system_1"
        self.slot = slot
        self.config = config
        self.logger = logger.get_logger(f"GSTREAMER_{self.slot}")
        self._current_pipeline = None
        self._running = False

        # создаём собственное окно
        self._window = QWidget()
        self._window.setFixedSize(960, 540)

        if self.slot == "front":
            self._window.move(0, 0)
            self._window.setWindowTitle("Фронт")
        elif self.slot == "back":
            self._window.move(960, 0)
            self._window.setWindowTitle("Тыл")
        else:
            self._window.setWindowTitle(f"Видео: {self.slot}")

        layout = QVBoxLayout(self._window)
        self._window.setLayout(layout)
        self._window.show()

        # таймер переподключения будет жить в этом же потоке
        self._reconnect_timer = None

        # стартуем поток
        self.start()

    @pyqtProperty(bool, notify=streamStateChanged)
    def online(self):
        return bool(self._current_pipeline)

    def switch_system(self, system: System):
        self.system_id = system
        self._schedule_connect()

    # --- QThread run ---
    def run(self):
        # таймер создаём внутри потока
        self._reconnect_timer = QTimer()
        self._reconnect_timer.setSingleShot(True)
        self._reconnect_timer.timeout.connect(self._connect_pipeline)

        # сразу подключаемся
        self._connect_pipeline()

        # запуск цикла событий QThread
        self.exec_()

    # ---------------- Pipeline ----------------
    def _schedule_connect(self):
        if self._reconnect_timer:
            self._reconnect_timer.start(self.RECONNECT_DELAY_MS)

    def _update_settings(self):
        if self.config and self.slot:
            self.rtsp_url = self.config.get_str(self.system_id, self.slot, "camera", "rtsp")
            if self.logger:
                self.logger.add_log("DEBUG", f"RTSP URL: {self.rtsp_url}")

    def _stop_pipeline(self):
        if self._current_pipeline:
            try:
                self._current_pipeline.set_state(Gst.State.NULL)
            except Exception:
                if self.logger:
                    self.logger.add_log("ERROR", traceback.format_exc())
            finally:
                self._current_pipeline = None

    def _connect_pipeline(self):
        # остановить предыдущий, если есть
        self._stop_pipeline()

        self._update_settings()

        if not self.rtsp_url:
            if self.logger:
                self.logger.add_log("WARN", "RTSP url not set, retrying...")
            self._schedule_connect()
            return

        self._running = True
        self._run_pipeline()

    def _run_pipeline(self):
        try:
            pipeline_desc = f"""
                rtspsrc location={self.rtsp_url} protocols=tcp latency=300 timeout=20000000 !
                rtph265depay ! h265parse ! d3d12h265dec !
                d3d12videosink name=videosink
            """
            pipeline = Gst.parse_launch(pipeline_desc)
            self._current_pipeline = pipeline
            sink = pipeline.get_by_name("videosink")

            if sink:
                win_id = int(self._window.winId())
                GstVideo.VideoOverlay.set_window_handle(sink, win_id)

            pipeline.set_state(Gst.State.PLAYING)
            if self.logger:
                self.logger.add_log("INFO", f"Pipeline started for {self.slot}")

            bus = pipeline.get_bus()
            while self._running:
                msg = bus.timed_pop_filtered(
                    Gst.SECOND,
                    Gst.MessageType.ERROR | Gst.MessageType.EOS
                )
                if msg:
                    if msg.type == Gst.MessageType.ERROR:
                        err, dbg = msg.parse_error()
                        if self.logger:
                            self.logger.add_log("ERROR", f"{err}, {dbg}")
                        break
                    elif msg.type == Gst.MessageType.EOS:
                        if self.logger:
                            self.logger.add_log("WARN", "End of stream")
                        break
        except Exception:
            if self.logger:
                self.logger.add_log("ERROR", traceback.format_exc())
        finally:
            self._stop_pipeline()
            if self._running and self._reconnect_timer:
                self._schedule_connect()
