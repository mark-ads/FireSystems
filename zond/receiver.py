import socket
from PyQt5.QtCore import QObject, pyqtSignal, pyqtSlot
from PyQt5.QtNetwork import QUdpSocket, QHostAddress
from config import Config
from logs import MultiLogger
from models import Telemetry
from .backend import Backend
from typing import Dict, Literal, Tuple, TypedDict

IpMapType = Dict[str, Tuple[Backend, str, Literal['front', 'back']]]

class Receiver(QObject):
    '''
    Класс приёмника UDP-строк от контроллеров Arduino.

    Принимает пакеты от устройств с заданными IP.
    различает отправителей,
    передаёт строки в зависимости от адреса отправителя.
    '''
    forwardTelemetry = pyqtSignal(Telemetry)

    def __init__(self, config: Config, logger: MultiLogger):
        super().__init__()
        self.logger = logger.get_logger('reciever')
        self.config = config
        self.socket = None
        self.update_settings()

    def _bind_socket(self):
        if self.socket:
            self.socket.close()
            self.socket.deleteLater()
        self.socket = QUdpSocket(self)
        if not self.socket.bind(QHostAddress(self.sys_ip), 80):
            self.logger.add_log('ERROR', f"❌ Ошибка bind {self.sys_ip}:80")
        else:
            self.logger.add_log('INFO', f"✅ Слушаем {self.sys_ip}:80")
            self.socket.readyRead.connect(self._on_ready_read)


    def _on_ready_read(self):
        while self.socket.hasPendingDatagrams():
            datagram, host, port = self.socket.readDatagram(self.socket.pendingDatagramSize())
            data = datagram.decode("utf-8", errors="ignore")
            sender_ip = host.toString()
        
            matches = [key for key, ip in self.ip_map.items() if ip == sender_ip]
            if matches:
                for system_id, slot in matches:
                    self.logger.add_log('DEBUG', f'📩Принят пакет контроллера: {sender_ip}')
                    tel = Telemetry(system_id, slot, data)
                    self.forwardTelemetry.emit(tel)
            else:
                self.logger.add_log('WARN', f'Принят НЕИЗВЕСТНЫЙ отправитель. {sender_ip}')

    def update_settings(self):
        self.sys_ip = self.config.get_sys_settings('ip')
        self._rebuild_ip_map()
        self._bind_socket()


    def _rebuild_ip_map(self):
        '''Функция создания карты айпи при смене настроек'''
        new_map: IpMapType = {}
        for system_id, zond_pair in self.config.systems.items():
            for slot in ('front', 'back'):
                try:
                    ip = self.config.get_str(system_id, slot, 'arduino', 'ip')
                    if ip:
                        new_map[(system_id, slot)] = ip
                        self.logger.add_log('INFO', f'🔁 IP: {system_id}.{slot} = {ip}')
                except Exception as e:
                    self.logger.add_log('WARN', f'⚠️ Ошибка получения IP {system_id}.{slot}: {e}')
        self.ip_map = new_map