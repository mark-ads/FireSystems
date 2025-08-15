from controls.dvrip_controller import DvripController
from PyQt5.QtCore import QObject, pyqtSignal, pyqtSlot, pyqtProperty, QVariant
from models import Command
from typing import Literal


class DvripVM(QObject):
    '''
    ViewModel для экрана Systems и протокола DVRIP.
    Передает актуальные параметры настроек в QML.
    Хранит в себе актуальные данные для отображения.
    Содержит в себе два DVRIP контроллера.
    '''

    frontBrightnessChanged = pyqtSignal()
    frontContrastChanged = pyqtSignal()
    frontSaturationChanged = pyqtSignal()
    backBrightnessChanged = pyqtSignal()
    backContrastChanged = pyqtSignal()
    backSaturationChanged = pyqtSignal()

    def __init__(self, front: DvripController, back: DvripController):
        super().__init__()
        self.front = front
        self.back = back

        self._front_brightness = None
        self._front_contrast = None
        self._front_saturation = None
        self._back_brightness = None
        self._back_contrast = None
        self._back_saturation = None

        self.front.dvripChangeNotification.connect(self.update_current_params)
        self.back.dvripChangeNotification.connect(self.update_current_params)

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

    @pyqtSlot()
    def connect(self):
        print(f'[DVRIP VM]: CONNECTION trying...')
        cmd_front = Command(target='front', command='connect')
        self.front.commands.put(cmd_front)
        cmd_back = Command(target='back', command='connect')
        self.back.commands.put(cmd_back)

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
            f, e, g, ag, ae, m, f = self.front.get_current_params()
            #self.frontBrightness = b
            print('[DVRIP VM]front:', f, e, g, ag, ae, m, f)
        else:
            f, e, g, ag, ae, m, f = self.back.get_current_params()
            #self.backBrightness = b
            print('[DVRIP VM]back:', f, e, g, ag, ae, m, f)