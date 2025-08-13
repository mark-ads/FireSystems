from PyQt5.QtCore import QThread, QTimer, pyqtSignal
from PyQt5.QtGui import QImage
import cv2
from .image_provider import CameraImageProvider

class VideoStream(QThread):
    frameReady = pyqtSignal()
    def __init__(self, url, provider: "CameraImageProvider", side: str):
        super().__init__()
        self.url = url
        self.provider = provider
        self.side = side
        self.cap = None
        self.timer = None

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
            self.provider.update_image(self.side, img)
            #print(f'получен кадр для {self.side}')
            self.frameReady.emit()


    def update(self):
        if self.cap is None:
            return

        ret, frame = self.cap.read()
        if ret:
            rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            h, w, ch = rgb.shape
            img = QImage(rgb.data, w, h, ch * w, QImage.Format_RGB888)
            #print(f'передаем изображение для {self.side}')
            self.provider.update_image(self.side, img)
