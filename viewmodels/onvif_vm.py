from controls.onvif_controller import OnvifController
from PyQt5.QtCore import QObject, pyqtSignal, pyqtSlot, pyqtProperty, QVariant, QTimer
from models import Command, Slot, System

class OnvifVM(QObject):
    '''
    ViewModel для экрана Systems и протокола ONVIF.
    Передает актуальные параметры настроек в QML.
    Хранит в себе актуальные данные для отображения.
    Содержит в себе 2 ONVIF контроллера.
    '''

    frontIpChanged = pyqtSignal()
    frontBrightnessChanged = pyqtSignal()
    frontContrastChanged = pyqtSignal()
    frontSaturationChanged = pyqtSignal()

    backIpChanged = pyqtSignal()
    backBrightnessChanged = pyqtSignal()
    backContrastChanged = pyqtSignal()
    backSaturationChanged = pyqtSignal()

    def __init__(self, front: OnvifController, back: OnvifController):
        super().__init__()
        self.front = front
        self.back = back

        self._front_ip = None
        self._front_brightness = None
        self._front_contrast = None
        self._front_saturation = None

        self._back_ip = None
        self._back_brightness = None
        self._back_contrast = None
        self._back_saturation = None

        self.front.onvifChangeNotification.connect(self.update_current_params)
        self.back.onvifChangeNotification.connect(self.update_current_params)

        self.feedback_timer_front = QTimer(self)
        self.feedback_timer_front.timeout.connect(self._check_changes_front)
        self.feedback_timer_back = QTimer(self)
        self.feedback_timer_back.timeout.connect(self._check_changes_back)

    @pyqtSlot(str)
    def connect(self, system: System):
        cmd_front = Command(target='front', command='switch_system', value=system)
        self.front.commands.put(cmd_front)
        cmd_back = Command(target='back', command='switch_system', value=system)
        self.back.commands.put(cmd_back)

    # -----------
    @pyqtProperty(str, notify=frontIpChanged)
    def frontIp(self):
        return self._front_ip

    @frontIp.setter
    def frontIp(self, value):
        self._front_ip = value
        self.frontIpChanged.emit()

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
    @pyqtProperty(str, notify=backIpChanged)
    def backIp(self):
        return self._back_ip

    @backIp.setter
    def backIp(self, value):
        if self._back_ip != value:
            self._back_ip = value
            self.backIpChanged.emit()

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
    def forward_command(self, slot: Slot, command: str):
        cmd = Command(
            target=slot,
            command=command
            )
        if slot == 'front':
            self.front.add_command(cmd)
        elif slot == 'back':
            self.back.add_command(cmd)

    @pyqtSlot(str, str, float)
    def forward_float_command(self, slot: Slot, command: str, value: float):
        cmd = Command(
            target=slot,
            command=command,
            value=value
            )

        if slot == 'front':
            self.front.add_command(cmd)
        elif slot == 'back':
            self.back.add_command(cmd)
        self._start_feedback_timer(slot)

    @pyqtSlot(str, str, int)
    def forward_int_command(self, slot: Slot, command: str, value: int):
        cmd = Command(
            target=slot,
            command=command,
            value=value
            )
        if slot == 'front':
            self.front.add_command(cmd)

        elif slot == 'back':
            self.back.add_command(cmd)
        self._start_feedback_timer(slot)

    @pyqtSlot(str, str, str)
    def forward_str_command(self, slot: Slot, command: str, value: str):
        cmd = Command(
            target=slot,
            command=command,
            value=value
            )
        if slot == 'front':
            self.front.add_command(cmd)

        elif slot == 'back':
            self.back.add_command(cmd)
        self._start_feedback_timer(slot)

    def _start_feedback_timer(self, slot: str):
        if slot == 'front':
            self.feedback_timer_front.stop()
            self.feedback_timer_front.start(1500)
        if slot == 'back':
            self.feedback_timer_back.stop()
            self.feedback_timer_back.start(1500)

    def _check_changes_front(self):
        self.feedback_timer_front.stop()
        self.front.commands.put(Command(target='front', command='check_changes'))

    def _check_changes_back(self):
        self.feedback_timer_back.stop()
        self.back.commands.put(Command(target='back', command='check_changes'))

    @pyqtSlot(str)
    def update_current_params(self, slot: Slot):
        if slot == 'front':
            ip, b, c, s = self.front.get_current_params()
            self.frontIp = ip
            self.frontBrightness = b
            self.frontContrast = c
            self.frontSaturation = s
        else:
            ip, b, c, s = self.back.get_current_params()
            self.backIp = ip
            self.backBrightness = b
            self.backContrast = c
            self.backSaturation = s