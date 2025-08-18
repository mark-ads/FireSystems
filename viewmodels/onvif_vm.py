from controls.onvif_controller import OnvifController
from PyQt5.QtCore import QObject, pyqtSignal, pyqtSlot, pyqtProperty, QVariant
from models import Command
from typing import Literal


class OnvifVM(QObject):
    '''
    ViewModel для экрана Systems и протокола ONVIF.
    Передает актуальные параметры настроек в QML.
    Хранит в себе актуальные данные для отображения.
    Содержит в себе 2 ONVIF контроллера.
    '''

    frontBrightnessChanged = pyqtSignal()
    frontContrastChanged = pyqtSignal()
    frontSaturationChanged = pyqtSignal()
    backBrightnessChanged = pyqtSignal()
    backContrastChanged = pyqtSignal()
    backSaturationChanged = pyqtSignal()

    def __init__(self, front: OnvifController, back: OnvifController):
        super().__init__()
        self.front = front
        self.back = back

        self._front_brightness = None
        self._front_contrast = None
        self._front_saturation = None
        self._back_brightness = None
        self._back_contrast = None
        self._back_saturation = None

        self.front.onvifChangeNotification.connect(self.update_current_params)
        self.back.onvifChangeNotification.connect(self.update_current_params)

    @pyqtSlot()
    def connect(self):
        cmd_front = Command(target='front', command='connect')
        self.front.commands.put(cmd_front)
        cmd_back = Command(target='back', command='connect')
        self.back.commands.put(cmd_back)

    # -----------
    @pyqtProperty(QVariant, notify=frontBrightnessChanged)
    def frontBrightness(self):
        return self._front_brightness

    @frontBrightness.setter
    def frontBrightness(self, value):
        if self._front_brightness != value:
            self._front_brightness = value
            self.frontBrightnessChanged.emit()

    @pyqtProperty(QVariant, notify=frontContrastChanged)
    def frontContrast(self):
        return self._front_contrast

    @frontContrast.setter
    def frontContrast(self, value):
        if self._front_contrast != value:
            self._front_contrast = value
            self.frontContrastChanged.emit()

    @pyqtProperty(QVariant, notify=frontSaturationChanged)
    def frontSaturation(self):
        return self._front_saturation

    @frontSaturation.setter
    def frontSaturation(self, value):
        if self._front_saturation != value:
            self._front_saturation = value
            self.frontSaturationChanged.emit()
    # -----------
    @pyqtProperty(QVariant, notify=backBrightnessChanged)
    def backBrightness(self):
        return self._back_brightness

    @backBrightness.setter
    def backBrightness(self, value):
        if self._back_brightness != value:
            self._back_brightness = value
            self.backBrightnessChanged.emit()

    @pyqtProperty(QVariant, notify=backContrastChanged)
    def backContrast(self):
        return self._back_contrast

    @backContrast.setter
    def backContrast(self, value):
        if self._back_contrast != value:
            self._back_contrast = value
            self.backContrastChanged.emit()

    @pyqtProperty(QVariant, notify=backSaturationChanged)
    def backSaturation(self):
        return self._back_saturation

    @backSaturation.setter
    def backSaturation(self, value):
        if self._back_saturation != value:
            self._back_saturation = value
            self.backSaturationChanged.emit()
    # -----------
    @pyqtSlot(str, str)
    def forward_command(self, slot: Literal['front', 'back'], command: str):
        cmd = Command(
            target=slot,
            command=command
            )
        if slot == 'front':
            self.front.add_command(cmd)
        elif slot == 'back':
            self.back.add_command(cmd)

    @pyqtSlot(str, str, float)
    def forward_float_command(self, slot: Literal['front', 'back'], command: str, value: float):
        cmd = Command(
            target=slot,
            command=command,
            value=value
            )

        if slot == 'front':
            self.front.add_command(cmd)
        elif slot == 'back':
            self.back.add_command(cmd)

    @pyqtSlot(str)
    def update_current_params(self, slot: Literal['front', 'back']):
        if slot == 'front':
            b, c, s = self.front.get_current_params()
            self.frontBrightness = b
            self.frontContrast = c
            self.frontSaturation = s
            print('front:', b, c, s)
        else:
            b, c, s = self.back.get_current_params()
            self.backBrightness = b
            self.backContrast = c
            self.backSaturation = s
            print('back:', b, c, s)