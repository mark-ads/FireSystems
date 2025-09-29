from PyQt5.QtCore import QThread, QTimer, pyqtSignal, pyqtSlot
from PyQt5.QtGui import QImage
import cv2
from config import Config
from logs import MultiLogger
from models import Slot, System

from .image_provider import CameraImageProvider

class VideoStream(QThread):
    frameReady = pyqtSignal()
    def __init__(self, config: Config, logger: MultiLogger, provider: CameraImageProvider, slot: Slot):
        super().__init__()
        self.config = config
        self.provider = provider
        self.slot = slot
        self.system_id = 'system_1'
        self.logger = logger.get_logger(f"CAMERA_{self.slot}")
        self.cap = None
        self.timer = None
        self._update_settings()

    def _update_settings(self):
        if self.config and self.slot:
            self.url = self.config.get_str(self.system_id, self.slot, 'camera', 'rtsp')
            if self.logger:
                self.logger.add_log("DEBUG", f"RTSP URL: {self.url}")

    @pyqtSlot(str)
    def switch_system(self, system: System):
        self.system_id = system
        self._update_settings()


    def run(self):
        self.cap = cv2.VideoCapture(self.url, cv2.CAP_FFMPEG)
        self.cap.set(cv2.CAP_PROP_BUFFERSIZE, 2)
        for _ in range(10):  # пропускаем кадры
            ret, frame = self.cap.read()
        while True:
            ret, frame = self.cap.read()
            if not ret:
                continue
            rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            h, w, ch = rgb.shape
            img = QImage(rgb.data, w, h, ch * w, QImage.Format_RGB888)
            self.provider.update_image(self.slot, img)
            #print(f'получен кадр для {self.slot}')
            self.frameReady.emit()


    def update(self):
        if self.cap is None:
            return

        ret, frame = self.cap.read()
        if ret:
            rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            h, w, ch = rgb.shape
            img = QImage(rgb.data, w, h, ch * w, QImage.Format_RGB888)
            #print(f'передаем изображение для {self.slot}')
            self.provider.update_image(self.slot, img)