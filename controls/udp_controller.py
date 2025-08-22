from queue import Queue
from onvif import ONVIFCamera
from PyQt5.QtCore import QObject, pyqtSignal, QTimer
from PyQt5.QtNetwork import QUdpSocket, QHostAddress
from zeep import xsd
from typing import Literal
from config import Config
from logs import MultiLogger
from models import Command


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

    def __init__(self, config: Config, logger: MultiLogger, system_id: str, slot: Literal['front', 'back']):
        super().__init__()
        self.config = config
        self.system_id = system_id
        self.slot = slot
        self.logger = logger.get_logger(f'upd_{self.slot}')
        self.disconnect()
        self.socket = QUdpSocket(self)
        result = self.socket.bind(QHostAddress.Any, 80)
        self.logger.add_log('WARN', f'[{self.slot}]: BIND = {result}')

        self.feedback_timer = QTimer(self)
        self.feedback_timer.timeout.connect(self._check_changes)

        self.connect()

    def connect(self):
        self.disconnect()
        self._update_settings()

    def disconnect(self):
        self.is_online = None
        pass

    def _update_settings(self):
        ip = self.config.get_str(self.system_id, self.slot, 'arduino', 'ip')
        self.ip = QHostAddress(ip)
        self.port = 80

    def _set_initial_camera_settings(self):
        if not self.is_online:
            return
        self.water_pressure = self.config.get_arduino_settings(self.system_id, self.slot, 'water_pressure_limit')
        self.air_pressure = self.config.get_arduino_settings(self.system_id, self.slot, 'air_pressure_limit')
        self.air_temp = self.config.get_arduino_settings(self.system_id, self.slot, 'air_temp_limit')
        self.water_temp = self.config.get_arduino_settings(self.system_id, self.slot, 'water_temp_limit')
        self.out_temp = self.config.get_arduino_settings(self.system_id, self.slot, 'out_temp_limit')
        self.wp_temp = self.config.get_arduino_settings(self.system_id, self.slot, 'wp_temp_limit')

        #ToDO: дописать отправку


    def switch_system(self, new_system):
        self.system_id = new_system
        self.connect()

    def _check_ready(self):
        if not self.is_online:
            self.disconnect()
            self.logger.add_log('ERROR', f'Контроллер не в сети или не готов к работе.')

    def _send_command(self, data: str):
        print(data)
        data = data.encode()
        self.socket.writeDatagram(data, self.ip, self.port)

    def _update_param(self, name: str, value: float = None):
        pass

    def _check_changes(self):
        self.feedback_timer.stop()
        self.logger.add_log('DEBUG', f'Вызвана проверка')

    def _sync_from_arduino(self):
        pass

    def _send_change_notification(self):
        self.logger.add_log('WARN', f'Сигнал об изменениях отправлен')
        self.udpChangeNotification.emit(self.slot)

    def get_current_params(self):
        return self.water_pressure, self.air_pressure, self.air_temp, self.water_temp, self.out_temp, self.wp_temp

    def add_command(self, cmd: Command):
        self._exec_command(cmd)
        self.feedback_timer.stop()
        self.feedback_timer.start(1500)

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
