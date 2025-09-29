from queue import Queue
from onvif import ONVIFCamera
from PyQt5.QtCore import QObject, pyqtSignal
from PyQt5.QtNetwork import QHostAddress
from zeep import xsd
from typing import Literal
from config import Config
from logs import MultiLogger
from models import Command, Slot
from zond.sender import UdpSender


class UdpController(QObject):
    '''
    Класс для управления ардуино через UPD.
    В начале приложения создается 2 потока данного класса, на каждую сторону.
    После создания, потоки начинают ждать комманду.
    Когда GUI готов - UdpVM помещает команду на подключение в очередь.
    При подключении применяет начальные настройки из конфиг.
    Содержит в себе таймер для отложенной проверки и синхронизации параметров с камерой.
    '''

    udpChangeNotification = pyqtSignal(str)
    ipChanged = pyqtSignal(str, str)

    def __init__(self, config: Config, logger: MultiLogger, socket: UdpSender, slot: Slot):
        super().__init__()
        self.config = config
        self.system_id = 'system_1'
        self.slot = slot
        self.socket = socket
        self.logger = logger.get_logger(f'upd_{self.slot}')
        self.connect()

    def connect(self):
        self._update_settings()
        self._set_initial_arduino_settings()


    def _update_settings(self):
        self.ip_str = self.config.get_str(self.system_id, self.slot, 'arduino', 'ip')
        self.sys_ip = self.config.get_sys_settings('ip')
        self.ip = QHostAddress(self.ip_str)

    def _set_initial_arduino_settings(self):
        self.water_pressure = self.config.get_arduino_settings(self.system_id, self.slot, 'water_pressure_limit')
        self.air_pressure = self.config.get_arduino_settings(self.system_id, self.slot, 'air_pressure_limit')
        self.air_temp = self.config.get_arduino_settings(self.system_id, self.slot, 'air_temp_limit')
        self.water_temp = self.config.get_arduino_settings(self.system_id, self.slot, 'water_temp_limit')
        self.out_temp = self.config.get_arduino_settings(self.system_id, self.slot, 'out_temp_limit')
        self.wp_temp = self.config.get_arduino_settings(self.system_id, self.slot, 'wp_temp_limit')
        self.udpChangeNotification.emit(self.slot)

    def switch_system(self, new_system):
        self.system_id = new_system
        self.connect()

    def _check_ready(self):
        if not self.is_online:
            self.disconnect()
            self.logger.add_log('ERROR', f'Контроллер не в сети или не готов к работе.')

    def _send_command(self, data: str):
        self.socket.send(self.ip, data)

    def _update_arduino_param(self, config_key: str, value: float = None):
        self.config.set(self.system_id, self.slot, 'arduino', config_key, value=value)

    def _update_pc_param(self, config_key: str, value: float = None):
        self.config.set_sys(config_key, value)

    def get_current_params(self):
        return self.ip_str, self.sys_ip, self.water_pressure, self.air_pressure, self.air_temp, self.water_temp, self.out_temp, self.wp_temp

    def add_command(self, cmd: Command):
        self._exec_command(cmd)

    def _exec_command(self, cmd: Command):
        method = getattr(self, cmd.command, None)
        if not callable(method):
            self.logger.add_log('ERROR', f'Метод {cmd.command} не найден')
            return
        if cmd.value is not None:
            method(cmd.value)
        else:
            method()

    def turn_on(self):
        self.logger.add_log('DEBUG', f'Command = turn_on')
        self._send_command('startZ')

    def turn_off(self):
        self.logger.add_log('DEBUG', f'Command = turn_off')
        self._send_command('stopZ')

    def reboot(self):
        self.logger.add_log('DEBUG', f'Command = reboot')
        self._send_command('restartZ')

    def turn_right(self, value: int):
        self.logger.add_log('DEBUG', f'Command = turn_right {value}')
        self._send_command(f'r_{value}_r')

    def turn_left(self, value: int):
        self.logger.add_log('DEBUG', f'Command = turn_left {value}')
        self._send_command(f'r_{value}_l')

    def set_arduino_ip(self, value: str):
        if self.sys_ip == value:
            self.logger.add_log('WARN', f'Попытка присвоить настроить прием Ардуино на свой же айпи: {value}')
            return
        self.logger.add_log('INFO', f'Command = set_arduino_ip: {value}')
        self._send_command(f'MKsetIP_{value}')
        self._update_arduino_param('ip', value)
        self._update_settings()

    def set_system_ip(self, value: str):
        if self.ip_str == value:
            self.logger.add_log('WARN', f'Попытка присвоить настроить прием Ардуино на свой же айпи: {value}')
            return
        self.logger.add_log('INFO', f'Command = set_system_ip: {value}')
        self._send_command(f'PCsetIP_{value}')
        self._update_pc_param('ip', value)
        self._update_settings()

    def set_water_pressure(self, value: float):
        if self.water_pressure == value:
            return
        self.logger.add_log('INFO', f'Command = set_water_pressure: {value}')
        self._send_command(f'Apressure_{value}_Z')
        self.water_pressure = value
        self._update_arduino_param('water_pressure_limit', value)

    def set_air_pressure(self, value: float):
        if self.air_pressure == value:
            return
        self.logger.add_log('INFO', f'Command = set_air_pressure: {value}')
        self._send_command(f'Bpressure_{value}_Z')
        self.air_pressure = value
        self._update_arduino_param('air_pressure_limit', value)

    def set_air_temp(self, value: float):
        if self.air_temp == value:
            return
        self.logger.add_log('INFO', f'Command = set_air_temp: {value}')
        self._send_command(f'Atemp_{value}_Z')
        self.air_temp = value
        self._update_arduino_param('air_temp_limit', value)

    def set_water_temp(self, value: float):
        if self.water_temp == value:
            return
        self.logger.add_log('INFO', f'Command = set_water_temp: {value}')
        self._send_command(f'Btemp_{value}_Z')
        self.water_temp = value
        self._update_arduino_param('water_temp_limit', value)

    def set_out_temp(self, value: float):
        if self.out_temp == value:
            return
        self.logger.add_log('INFO', f'Command = set_out_temp: {value}')
        self._send_command(f'Ctemp_{value}_Z')
        self.out_temp = value
        self._update_arduino_param('out_temp_limit', value)

    def set_wp_temp(self, value: float):
        if self.wp_temp == value:
            return
        self.logger.add_log('INFO', f'Command = set_wp_temp: {value}')
        self._send_command(f'Dtemp_{value}_Z')
        self.wp_temp = value
        self._update_arduino_param('wp_temp_limit', value)

    def change_motor_dir(self):
        self.logger.add_log('INFO', f'Command = change_motor_dir')
        self._send_command(f'ch_motor_DIR')