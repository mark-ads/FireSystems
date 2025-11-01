from PyQt5.QtCore import QObject
from PyQt5.QtNetwork import QUdpSocket, QHostAddress
from config import Config
from logs import MultiLogger
from zond.udp_mock import UdpMocker

class UdpSender(QObject):
    def __init__(self, config: Config, logger: MultiLogger):
        super().__init__()
        self.logger = logger.get_logger('app')
        self.socket = QUdpSocket(self)
        self.test_mode = False
        result = self.socket.bind(QHostAddress.Any, 80)
        if not result:
            self.logger.add_log('ERROR', '[UdpSender]: Не удалась привязка к порту.')
        if config.get_sys_settings_bool('test_mode'):
            self.test_mode = True
            self.mocker = UdpMocker(config)
            self.mock_ip = QHostAddress("127.0.0.1")


    def send(self, ip: QHostAddress, cmd: str):
        if not self.test_mode:
            cmd = cmd.encode()
            self.socket.writeDatagram(cmd, ip, 80)
        else:
            cmd = f'{ip.toString()}*{cmd}'.encode()
            self.socket.writeDatagram(cmd, self.mock_ip, 81) 

    def update_mock(self):
        self.mocker.update_settings()