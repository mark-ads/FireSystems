import traceback
from PyQt5.QtCore import QThread
import os
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

class VideoItem(QThread):
    RECONNECT_DELAY_MS = 2000

    def __init__(self, rtsp_url: str, qml_item):
        super().__init__()
        self.rtsp_url = rtsp_url
        self.qml_item = qml_item
        self._running = True
        self._pipeline = None
        self.start()

    def run(self):
        self._connect_pipeline()

    def _stop_pipeline(self):
        if self._pipeline:
            try:
                self._pipeline.set_state(Gst.State.NULL)
            except Exception:
                print(traceback.format_exc())
            finally:
                self._pipeline = None

    def _connect_pipeline(self):
        self._stop_pipeline()
        try:
            pipeline_desc = f"""
                rtspsrc location={self.rtsp_url} protocols=tcp latency=300 !
                rtph265depay ! h265parse ! d3d12h265dec !
                d3d12videosink name=videosink
            """
            self._pipeline = Gst.parse_launch(pipeline_desc)
            sink = self._pipeline.get_by_name("videosink")

            if sink:
                win_id = int(self.qml_item.winId())
                GstVideo.VideoOverlay.set_window_handle(sink, win_id)

            self._pipeline.set_state(Gst.State.PLAYING)

            bus = self._pipeline.get_bus()
            while self._running:
                msg = bus.timed_pop_filtered(
                    Gst.SECOND,
                    Gst.MessageType.ERROR | Gst.MessageType.EOS
                )
                if msg:
                    if msg.type == Gst.MessageType.ERROR:
                        err, dbg = msg.parse_error()
                        print("GStreamer ERROR:", err, dbg)
                        break
                    elif msg.type == Gst.MessageType.EOS:
                        print("GStreamer EOS")
                        break

        except Exception:
            print(traceback.format_exc())
        finally:
            self._stop_pipeline()
