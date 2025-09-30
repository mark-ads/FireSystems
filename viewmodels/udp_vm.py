from controls.udp_controller import UdpController
from PyQt5.QtCore import QObject, pyqtSignal, pyqtSlot, pyqtProperty, QVariant
from models import Command
from typing import Dict, Literal
from collections import deque



class UdpVM(QObject):
    '''
    ViewModel для экрана Systems и протокола UDP.
    Передает актуальные параметры настроек в QML.
    Хранит в себе актуальные данные для отображения.
    Содержит в себе 2 UDP контроллера.
    '''

    frontBrightnessChanged = pyqtSignal()
    frontSettingsChanged = pyqtSignal()
    frontStateChanged = pyqtSignal()
    frontLogsChanged = pyqtSignal()
    frontAngleChanged = pyqtSignal()
    frontLimitSwitchChanged = pyqtSignal()
    frontTempsChanged = pyqtSignal()
    frontPressChanged = pyqtSignal()
    frontTempChartChanged = pyqtSignal()
    frontPressChartChanged = pyqtSignal()

    frontTempHistoryAdded = pyqtSignal()
    frontPressHistoryAdded = pyqtSignal()

    backBrightnessChanged = pyqtSignal()
    backSettingsChanged = pyqtSignal()
    backStateChanged = pyqtSignal()
    backLogsChanged = pyqtSignal()
    backAngleChanged = pyqtSignal()
    backLimitSwitchChanged = pyqtSignal()
    backTempsChanged = pyqtSignal()
    backPressChanged = pyqtSignal()
    backTempChartChanged = pyqtSignal()
    backPressChartChanged = pyqtSignal()

    backTempHistoryAdded = pyqtSignal()
    backPressHistoryAdded = pyqtSignal()

    def __init__(self, front: UdpController, back: UdpController):
        super().__init__()
        self.front = front
        self.back = back

        self.front.udpChangeNotification.connect(self.update_settings)
        self.back.udpChangeNotification.connect(self.update_settings)

        self._front_settings = {}
        self._front_state = -1
        self._front_angle = 0
        self._front_logs = deque()
        self._front_temps = [0.0, 0.0, 0.0, 0.0]
        self._front_press = [0.0, 0.0]
        self._front_limit_switch = 0

        self._front_temp_chart = []
        self._front_press_chart = []
        self._front_temp_history = []
        self._front_press_history = []

        self._back_settings = {}
        self._back_state = -1
        self._back_angle = 0
        self._back_logs = deque()
        self._back_temps = [0.0, 0.0, 0.0, 0.0]
        self._back_press = [0.0, 0.0]
        self._back_limit_switch = 0

        self._back_temp_chart = []
        self._back_press_chart = []
        self._back_temp_history = []
        self._back_press_history = []

    @pyqtSlot()
    def send_params_to_gui(self):
        self.frontStateChanged.emit()
        self.backStateChanged.emit()
        self.update_settings('front')
        self.update_settings('back')

    # -----------
    @pyqtProperty(QVariant, notify=frontSettingsChanged)
    def frontSettings(self):
        return self._front_settings

    @frontSettings.setter
    def frontSettings(self, value: dict):
        self._front_settings = value
        self.frontSettingsChanged.emit()

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

    @pyqtProperty(QVariant, notify=frontTempsChanged)
    def frontTemps(self):
        return self._front_temps

    @frontTemps.setter
    def frontTemps(self, value):
        #if self._front_temps != value:
        self._front_temps = value
        self.frontTempsChanged.emit()

    @pyqtProperty(QVariant, notify=frontPressChanged)
    def frontPress(self):
        return self._front_press

    @frontPress.setter
    def frontPress(self, value):
        if self._front_press != value:
            self._front_press = value
            self.frontPressChanged.emit()

    @pyqtProperty(int, notify=frontLimitSwitchChanged)
    def frontLimitSwitch(self):
        return self._front_limit_switch

    @frontLimitSwitch.setter
    def frontLimitSwitch(self, value):
        if self._front_limit_switch != value:
            self._front_limit_switch = value
            self.frontLimitSwitchChanged.emit()

    @pyqtProperty(list, notify=frontTempChartChanged)
    def frontTempChart(self):
        return self._front_temp_chart

    @frontTempChart.setter
    def frontTempChart(self, value):
        self._front_temp_chart = value
        self.frontTempChartChanged.emit()

    @pyqtProperty(list, notify=frontPressChartChanged)
    def frontPressChart(self):
        return self._front_press_chart

    @frontPressChart.setter
    def frontPressChart(self, value):
        self._front_press_chart = value
        self.frontPressChartChanged.emit()

    @pyqtProperty(QVariant, notify=frontTempHistoryAdded)
    def frontTempHistory(self):
        return self._front_temp_history

    @frontTempHistory.setter
    def frontTempHistory(self, value):
        self._front_temp_history = value
        self.frontTempHistoryAdded.emit()

    @pyqtProperty(QVariant, notify=frontPressHistoryAdded)
    def frontPressHistory(self):
        return self._front_press_history

    @frontPressHistory.setter
    def frontPressHistory(self, value):
        self._front_press_history = value
        self.frontPressHistoryAdded.emit()

    @pyqtProperty(QVariant, notify=frontBrightnessChanged)
    def frontBrightness(self):
        return self._front_brightness

    @frontBrightness.setter
    def frontBrightness(self, value):
        if self._front_brightness != value:
            self._front_brightness = value
            self.frontBrightnessChanged.emit()

    # -----------
    @pyqtProperty(QVariant, notify=backSettingsChanged)
    def backSettings(self):
        return self._back_settings

    @backSettings.setter
    def backSettings(self, value: dict):
        self._back_settings = value
        self.backSettingsChanged.emit()

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

    @pyqtProperty(QVariant, notify=backTempsChanged)
    def backTemps(self):
        return self._back_temps

    @backTemps.setter
    def backTemps(self, value):
        if self._back_temps != value:
            self._back_temps = value
            self.backTempsChanged.emit()

    @pyqtProperty(QVariant, notify=backPressChanged)
    def backPress(self):
        return self._back_press

    @backPress.setter
    def backPress(self, value):
        if self._back_press != value:
            self._back_press = value
            self.backPressChanged.emit()

    @pyqtProperty(int, notify=backLimitSwitchChanged)
    def backLimitSwitch(self):
        return self._back_limit_switch

    @backLimitSwitch.setter
    def backLimitSwitch(self, value):
        if self._back_limit_switch != value:
            self._back_limit_switch = value
            self.backLimitSwitchChanged.emit()

    @pyqtProperty(QVariant, notify=backTempChartChanged)
    def backTempChart(self):
        return self._back_temp_chart

    @backTempChart.setter
    def backTempChart(self, value):
        self._back_temp_chart = value
        self.backTempChartChanged.emit()
            
    @pyqtProperty(list, notify=backPressChartChanged)
    def backPressChart(self):
        return self._back_press_chart

    @backPressChart.setter
    def backPressChart(self, value):
        self._back_press_chart = value
        self.backPressChartChanged.emit()

        ###
    @pyqtProperty(QVariant, notify=backTempHistoryAdded)
    def backTempHistory(self):
        return self._back_temp_history

    @backTempHistory.setter
    def backTempHistory(self, value):
        self._back_temp_history = value
        self.backTempHistoryAdded.emit()
            
    @pyqtProperty(QVariant, notify=backPressHistoryAdded)
    def backPressHistory(self):
        return self._back_press_history

    @backPressHistory.setter
    def backPressHistory(self, value):
        self._back_press_history = value
        self.backPressHistoryAdded.emit()
        ###
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

    @pyqtSlot(str, dict)
    def update_mod_params(self, slot: Literal['front', 'back'], data: Dict):
        if slot == 'front':
            self.frontState = data['status']
            self.frontLogs = data['logs']
            self.frontAngle = data['angle']
            self.frontTemps = data['temps']
            self.frontPress = data['pressures']
        else:
            self.backState = data['status']
            self.backLogs = data['logs']
            self.backAngle = data['angle']
            self.backTemps = data['temps']
            self.backPress = data['pressures']


    @pyqtSlot(str, list)
    def update_temp_chart(self, slot: Literal['front', 'back'], data: list):
        if slot == 'front':
            self.frontTempChart = data
        else:
            self.backTempChart = data
        

    @pyqtSlot(str, list)
    def update_press_chart(self, slot: Literal['front', 'back'], data: list):
        if slot == 'front':
            self.frontPressChart = data
        else:
            self.backPressChart = data




    @pyqtSlot(str, dict)
    def update_temp_history(self, slot: Literal['front', 'back'], data: Dict[str, list]):
        if slot == 'front':
            self.frontTempHistory = data
        else:
            self.backTempHistory = data
        

    @pyqtSlot(str, dict)
    def update_press_history(self, slot: Literal['front', 'back'], data: Dict[str, list]):
        if slot == 'front':
            self.frontPressHistory = data
        else:
            self.backPressHistory = data

    @pyqtSlot(str)
    def update_settings(self, slot: Literal['front', 'back']):
        if slot == 'front':
            ip, sys_ip, water_pressure, air_pressure, air_temp, water_temp, out_temp, wp_temp = self.front.get_current_params()
            self.frontSettings = {
                'ip': ip,
                'sys_ip': sys_ip,
                'water_pressure': water_pressure,
                'air_pressure': air_pressure,
                'air_temp': air_temp,
                'water_temp': water_temp,
                'out_temp': out_temp,
                'wp_temp': wp_temp
                }
        else:
            ip, sys_ip, water_pressure, air_pressure, air_temp, water_temp, out_temp, wp_temp = self.back.get_current_params()
            self.backSettings = {
                'ip': ip,
                'sys_ip': sys_ip,
                'water_pressure': water_pressure,
                'air_pressure': air_pressure,
                'air_temp': air_temp,
                'water_temp': water_temp,
                'out_temp': out_temp,
                'wp_temp': wp_temp
                }