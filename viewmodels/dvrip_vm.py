from controls.dvrip_controller import DvripController
from PyQt5.QtCore import QObject, pyqtSignal, pyqtSlot, pyqtProperty, QVariant, QTimer
from models import Command
from typing import Literal


class DvripVM(QObject):
    '''
    ViewModel для экрана Systems и протокола DVRIP.
    Передает актуальные параметры настроек в QML.
    Хранит в себе актуальные данные для отображения.
    Содержит в себе два DVRIP контроллера.
    '''

    frontFpsChanged = pyqtSignal()
    frontExpoChanged = pyqtSignal()
    frontGainChanged = pyqtSignal()
    frontAutoGainChanged = pyqtSignal()
    frontAutoExpoChanged = pyqtSignal()
    frontMirrorChanged = pyqtSignal()
    frontFlipChanged = pyqtSignal()

    backFpsChanged = pyqtSignal()
    backExpoChanged = pyqtSignal()
    backGainChanged = pyqtSignal()
    backAutoGainChanged = pyqtSignal()
    backAutoExpoChanged = pyqtSignal()
    backMirrorChanged = pyqtSignal()
    backFlipChanged = pyqtSignal()


    def __init__(self, front: DvripController, back: DvripController):
        super().__init__()
        self.front = front
        self.back = back

        self._front_fps = None
        self._front_expo = None
        self._front_gain = None
        self._front_auto_gain = None
        self._front_auto_expo = None
        self._front_mirror = None
        self._front_flip = None

        self._back_fps = None
        self._back_expo = None
        self._back_gain = None
        self._back_auto_gain = None
        self._back_auto_expo = None
        self._back_mirror = None
        self._back_flip = None

        self.front.dvripChangeNotification.connect(self.update_current_params)
        self.back.dvripChangeNotification.connect(self.update_current_params)

        self.feedback_timer_front = QTimer(self)
        self.feedback_timer_front.timeout.connect(self._check_changes_front)
        self.feedback_timer_back = QTimer(self)
        self.feedback_timer_back.timeout.connect(self._check_changes_back)

    # -----------
    @pyqtProperty(QVariant, notify=frontFpsChanged)
    def frontFps(self):
        return self._front_fps

    @frontFps.setter
    def frontFps(self, value):
        self._front_fps = value
        self.frontFpsChanged.emit()

    @pyqtProperty(QVariant, notify=frontExpoChanged)
    def frontExpo(self):
        return self._front_expo

    @frontExpo.setter
    def frontExpo(self, value):
        self._front_expo = value
        self.frontExpoChanged.emit()

    @pyqtProperty(QVariant, notify=frontGainChanged)
    def frontGain(self):
        return self._front_gain

    @frontGain.setter
    def frontGain(self, value):
        self._front_gain = value
        self.frontGainChanged.emit()

    @pyqtProperty(QVariant, notify=frontAutoGainChanged)
    def frontAutoGain(self):
        return self._front_auto_gain

    @frontAutoGain.setter
    def frontAutoGain(self, value):
        self._front_auto_gain = value
        self.frontAutoGainChanged.emit()

    @pyqtProperty(QVariant, notify=frontAutoExpoChanged)
    def frontAutoExpo(self):
        return self._front_auto_expo

    @frontAutoExpo.setter
    def frontAutoExpo(self, value):
        self._front_auto_expo = value
        self.frontAutoExpoChanged.emit()

    @pyqtProperty(QVariant, notify=frontMirrorChanged)
    def frontMirror(self):
        return self._front_mirror

    @frontMirror.setter
    def frontMirror(self, value):
        self._front_mirror = value
        self.frontMirrorChanged.emit()

    @pyqtProperty(QVariant, notify=frontFlipChanged)
    def frontFlip(self):
        return self._front_flip

    @frontFlip.setter
    def frontFlip(self, value):
        self._front_flip = value
        self.frontFlipChanged.emit()

    # -----------
    @pyqtProperty(QVariant, notify=backFpsChanged)
    def backFps(self):
        return self._back_fps

    @backFps.setter
    def backFps(self, value):
        self._back_fps = value
        self.backFpsChanged.emit()

    @pyqtProperty(QVariant, notify=backExpoChanged)
    def backExpo(self):
        return self._back_expo

    @backExpo.setter
    def backExpo(self, value):
        self._back_expo = value
        self.backExpoChanged.emit()

    @pyqtProperty(QVariant, notify=backGainChanged)
    def backGain(self):
        return self._back_gain

    @backGain.setter
    def backGain(self, value):
        self._back_gain = value
        self.backGainChanged.emit()

    @pyqtProperty(QVariant, notify=backAutoGainChanged)
    def backAutoGain(self):
        return self._back_auto_gain

    @backAutoGain.setter
    def backAutoGain(self, value):
        self._back_auto_gain = value
        self.backAutoGainChanged.emit()

    @pyqtProperty(QVariant, notify=backAutoExpoChanged)
    def backAutoExpo(self):
        return self._back_auto_expo

    @backAutoExpo.setter
    def backAutoExpo(self, value):
        self._back_auto_expo = value
        self.backAutoExpoChanged.emit()

    @pyqtProperty(QVariant, notify=backMirrorChanged)
    def backMirror(self):
        return self._back_mirror

    @backMirror.setter
    def backMirror(self, value):
        self._back_mirror = value
        self.backMirrorChanged.emit()

    @pyqtProperty(QVariant, notify=backFlipChanged)
    def backFlip(self):
        return self._back_flip

    @backFlip.setter
    def backFlip(self, value):
        self._back_flip = value
        self.backFlipChanged.emit()

    @pyqtSlot(str)
    def connect(self, system: Literal['system_1', 'system_2', 'system_3', 'system_4']):
        cmd_front = Command(target='front', command='switch_system', value=system)
        self.front.commands.put(cmd_front)
        cmd_back = Command(target='back', command='switch_system', value=system)
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
        self._start_feedback_timer(slot)

    @pyqtSlot(str, str, int)
    def forward_int_command(self, slot: Literal['front', 'back'], command: str, value: int):
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
    def forward_str_command(self, slot: Literal['front', 'back'], command: str, value: str):
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

    @pyqtSlot(str, str, bool)
    def forward_bool_command(self, slot: Literal['front', 'back'], command: str, value: bool):
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
    def update_current_params(self, slot: Literal['front', 'back']):
        if slot == 'front':
            fps, e, g, ag, ae, m, f = self.front.get_current_params()
            self.frontFps = fps
            self.frontExpo = e
            self.frontGain = g
            self.frontAutoGain = ag
            self.frontAutoExpo = ae
            self.frontMirror = m
            self.frontFlip = f
        else:
            fps, e, g, ag, ae, m, f = self.back.get_current_params()
            self.backFps = fps
            self.backExpo = e
            self.backGain = g
            self.backAutoGain = ag
            self.backAutoExpo = ae
            self.backMirror = m
            self.backFlip = f