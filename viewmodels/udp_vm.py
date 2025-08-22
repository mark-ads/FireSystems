from controls.udp_controller import UdpController
from PyQt5.QtCore import QObject, pyqtSignal, pyqtSlot, pyqtProperty, QVariant
from models import Command
from typing import Dict, List, Literal
from collections import deque



class UdpVM(QObject):
    '''
    ViewModel для экрана Systems и протокола UDP.
    Передает актуальные параметры настроек в QML.
    Хранит в себе актуальные данные для отображения.
    Содержит в себе 2 UDP контроллера.
    '''

    frontBrightnessChanged = pyqtSignal()
    frontStateChanged = pyqtSignal()
    frontLogsChanged = pyqtSignal()
    frontAngleChanged = pyqtSignal()

    backBrightnessChanged = pyqtSignal()
    backStateChanged = pyqtSignal()
    backLogsChanged = pyqtSignal()
    backAngleChanged = pyqtSignal()

    def __init__(self, front: UdpController, back: UdpController):
        super().__init__()
        self.front = front
        self.back = back

        self._front_state = -1
        self._front_angle = 0
        self._front_logs = deque()

        self._back_state = -1
        self._back_logs = deque()
        self._back_angle = 0

        self.front.udpChangeNotification.connect(self.update_params_from_controller)
        self.back.udpChangeNotification.connect(self.update_params_from_controller)

    @pyqtSlot()
    def send_params_to_gui(self):
        self.frontStateChanged.emit()
        self.frontStateChanged.emit()

    # -----------
    @pyqtProperty(int, notify=frontStateChanged)
    def frontState(self):
        return self._front_state

    @frontState.setter
    def frontState(self, value: int):
        self._front_state = value
        self.frontStateChanged.emit()

    @pyqtProperty(QVariant, notify=frontLogsChanged)
    def frontLogs(self):
        logs = list(self._front_logs)
        logs.reverse()
        return logs

    @frontLogs.setter
    def frontLogs(self, logs):
        if isinstance(logs, deque):
            self._front_logs = logs
        self.frontLogsChanged.emit()

    @pyqtProperty(int, notify=frontAngleChanged)
    def frontAngle(self):
        return self._front_angle

    @frontAngle.setter
    def frontAngle(self, value):
        if self._front_angle != value:
            self._front_angle = value
            self.frontAngleChanged.emit()

    @pyqtProperty(QVariant, notify=frontBrightnessChanged)
    def frontBrightness(self):
        return self._front_brightness

    @frontBrightness.setter
    def frontBrightness(self, value):
        if self._front_brightness != value:
            self._front_brightness = value
            self.frontBrightnessChanged.emit()

    # -----------
    @pyqtProperty(int, notify=backStateChanged)
    def backState(self):
        return self._back_state

    @backState.setter
    def backState(self, value: int):
        self._back_state = value
        self.backStateChanged.emit()

    @pyqtProperty(QVariant, notify=backLogsChanged)
    def backLogs(self):
        logs = list(self._back_logs)
        logs.reverse()
        return logs

    @backLogs.setter
    def backLogs(self, logs):
        if isinstance(logs, deque):
            self._back_logs = logs
        self.backLogsChanged.emit()

    @pyqtProperty(int, notify=backAngleChanged)
    def backAngle(self):
        return self._back_angle

    @backAngle.setter
    def backAngle(self, value):
        if self._back_angle != value:
            self._back_angle = value
            self.backAngleChanged.emit()

    @pyqtProperty(QVariant, notify=backBrightnessChanged)
    def backBrightness(self):
        return self._back_brightness

    @backBrightness.setter
    def backBrightness(self, value):
        if self._back_brightness != value:
            self._back_brightness = value
            self.backBrightnessChanged.emit()

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

    @pyqtSlot(str)
    def update_params_from_controller(self, slot: Literal['front', 'back']):
        if slot == 'front':
            wp, ap, at, wt, ot, wpt = self.front.get_current_params()
            self.frontBrightness = wp
        else:
            wp, ap, at, wt, ot, wpt = self.back.get_current_params()
            self.backBrightness = wp

    @pyqtSlot(str, dict)
    def update_mod_params(self, slot: Literal['front', 'back'], data: Dict):
        if slot == 'front':
            self.frontState = data['status']
            self.frontLogs = data['logs']
            self.frontAngle = data['angle']
        else:
            self.backState = data['status']
            self.backLogs = data['logs']
            self.backAngle = data['angle']
