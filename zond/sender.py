from PyQt5.QtCore import QObject
from PyQt5.QtNetwork import QUdpSocket, QHostAddress
from logs import MultiLogger

class UdpSender(QObject):
    def __init__(self, logger: MultiLogger):
        super().__init__()
        self.logger = logger.get_logger('app')
        self.socket = QUdpSocket(self)
        result = self.socket.bind(QHostAddress.Any, 80)
        if not result:
            self.logger.add_log('ERROR', '[UdpSender]: Не удалась привязка к порту.')


    def send(self, ip: QHostAddress, cmd: str):
        cmd = cmd.encode()
        self.socket.writeDatagram(cmd, ip, 80)