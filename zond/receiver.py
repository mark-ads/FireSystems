import socket
from PyQt5.QtCore import QThread, pyqtSlot
from config import Config
from logs import MultiLogger
from .backend import Backend
from typing import Dict, Literal, Tuple, TypedDict

IpMapType = Dict[str, Tuple[Backend, str, Literal['front', 'back']]]

class Receiver(QThread):
    '''
    Класс приёмника UDP-строк от контроллеров Arduino.

    Принимает пакеты от устройств с заданными IP.
    различает отправителей,
    передаёт строки в зависимости от адреса отправителя,
    запускается в отдельном потоке.
    '''

    def __init__(self, config: Config, logger: MultiLogger,ip_map: IpMapType):
        super().__init__()
        self.logger = logger.get_logger('reciever')
        if not isinstance(ip_map, dict):
            raise TypeError("Receiver: ip_map должен быть словарём")
        for ip, value in ip_map.items():
            if not isinstance(ip, str):
                self.logger.add_log('ERROR', f'ip_map содержит нестроковый ключ: {ip}')
            if not isinstance(value[0], Backend):
                self.logger.add_log('ERROR', f'Первый элемент кортежа должен быть объект Backend')
            if not (isinstance(value, tuple) and len(value) == 3):
                self.logger.add_log('ERROR', f'ip_map[{ip}] должен быть кортежем из 3 элементов')

        self.config = config
        self.ip_map = ip_map
        self.sys_ip = self.config.get_sys_settings('ip')
        self.port = 80
        self.running = False

    def run(self):
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        try:
            sock.bind((self.sys_ip, self.port))
            self.logger.add_log('INFO', f'Слушаем UDP на {self.sys_ip}:{self.port}')
        except Exception as e:
            self.logger.add_log('ERROR', f'❌ Ошибка bind: {e}')
            return #  подумать над тем, что делать если айпи не совпадет с системным

        while self.running:
            try:
                data, addr = sock.recvfrom(1024)
                data = data.decode()
                sender_ip = addr[0]
                if sender_ip in self.ip_map:
                    self.logger.add_log('DEBUG', f'Принят пакет контроллера: {sender_ip}')
                    self.ip_map[sender_ip][0].handle_arduino_message(data)
                else:
                    self.logger.add_log('WARN', f'Принят НЕИЗВЕСТНЫЙ отправитель. {sender_ip}')
            except Exception as e:
                self.logger.add_log('ERROR', f'❌ Ошибка при приёме пакета: {e}')

    def start_receiving(self):
        self.running = True
        self.start()

    def stop_receiving(self):
        self.running = False
        self.wait()

    def rebuild_ip_map(self):
        '''Функция пересоздания карты айпи при смене настроек'''
        new_ip_map: IpMapType = {}
        for old_ip, (backend, system_id, slot) in self.ip_map.items():
            try:
                ip = self.config.get_str(system_id, slot, 'arduino', 'ip')
            except KeyError as e:
                self.logger.add_log('WARN', f'⚠️ Ошибка получения IP из настроек для {system_id}.{slot}: {e}')
                continue

            new_ip_map[ip] = (backend, system_id, slot)
            self.logger.add_log('INFO', f'🔁 Обновлён IP: {system_id}.{slot} = {ip}')

        self.ip_map = new_ip_map

    def update_settings(self):
        self.stop_receiving()
        self.rebuild_ip_map()
        self.sys_ip = self.config.get_sys_settings('ip')
        self.start_receiving()


    @pyqtSlot()
    def on_settings_updated(self):
        self.update_settings()