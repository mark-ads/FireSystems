from PyQt5.QtQuick import QQuickImageProvider
from PyQt5.QtGui import QImage
from PyQt5.QtCore import QSize

class CameraImageProvider(QQuickImageProvider):
    def __init__(self):
        super().__init__(QQuickImageProvider.Image)
        self.images = {}  # {"front": QImage, "back": QImage}

    def update_image(self, key: str, image: QImage):
        #print(f"[update_image] key={key} image size={image.size()}")
        self.images[key] = image

    def clear_image(self, key: str):
        """Очистка изображения для данного слота."""
        if key in self.images:
            del self.images[key]

    def requestImage(self, id, requestedSize):
        image = self.images.get(id)
        if image:
            return image, image.size()
        return QImage(), QSize(0, 0)