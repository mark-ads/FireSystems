import os
import threading
import traceback
from PyQt5.QtQuick import QQuickItem
from PyQt5.QtCore import QTimer, pyqtSignal, pyqtProperty
from config import Config
from logs import MultiLogger
'''
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
'''
# --- VideoItem ---
class VideoItem(QQuickItem):
    streamStateChanged = pyqtSignal()
    RECONNECT_DELAY_MS = 2000
    STOP_TIMEOUT_SEC = 5

    def __init__(self, *args):
        super().__init__()
        self.rtsp_url = None
        self.system_id = "system_1"
        self.slot = None
        self.config = None
        self.logger = None
        self._pipeline_thread = None
        self._running = False
        self._current_pipeline = None
        self._thread_lock = threading.Lock()
        self._reconnect_timer = QTimer()
        self._reconnect_timer.setSingleShot(True)
        self._reconnect_timer.timeout.connect(self.connect)
        self.windowChanged.connect(self._on_window_changed)

    def set_links(self, config, logger, slot):
        self.config = config
        print(self.config)
        self.slot = slot
        self.logger = logger.get_logger(f"GSTREAMER_{self.slot}")
        self.connect()

    @pyqtProperty(bool, notify=streamStateChanged)
    def online(self):
        return bool(self._current_pipeline)

    # ---------------- Pipeline ----------------
    def connect(self):
        with self._thread_lock:
            if self._pipeline_thread and self._pipeline_thread.is_alive():
                self._running = False
                self._stop_pipeline()
                self._pipeline_thread.join(timeout=self.STOP_TIMEOUT_SEC)

        self._update_settings()

        if not self.rtsp_url:
            print('no rtsp')
            if self.logger:
                self.logger.add_log("WARN", "RTSP url not set, retrying...")
            self._reconnect_timer.start(self.RECONNECT_DELAY_MS)
            return

        print('COOOOOOOOOOoooooooooooOOOOOOOONNect')
        self._running = True
        self._pipeline_thread = threading.Thread(target=self._run_pipeline, daemon=True)
        self._pipeline_thread.start()

    def _update_settings(self):
        print(f'config = {self.config}, slot = {self.slot}')
        if self.config and self.slot:
            print('settings updated')
            self.rtsp_url = self.config.get_str(self.system_id, self.slot, 'camera', 'rtsp')
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

    def _run_pipeline(self):
        try:
            print('pipeline TRYYYYY')
            pipeline_desc = f"""
                rtspsrc location={self.rtsp_url} latency=100 !
                rtph265depay ! h265parse ! dxvah265dec !
                qmlglsink name=videosink
            """
            print('pipeline started')
            pipeline = Gst.parse_launch(pipeline_desc)
            self._current_pipeline = pipeline
            sink = pipeline.get_by_name("videosink")
            self._bind_sink_to_window(sink)

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
            if self._running:
                self._reconnect_timer.start(self.RECONNECT_DELAY_MS)

    # ---------------- Helpers ----------------
    def _on_window_changed(self, win):
        if not win:
            return
        if self._current_pipeline:
            sink = self._current_pipeline.get_by_name("videosink")
            self._bind_sink_to_window(sink)

    def _bind_sink_to_window(self, sink):
        if self.logger:
            self.logger.add_log("DEBUG", "qml6d3d11sink привязывается автоматически через QML")
