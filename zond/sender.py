from PyQt5.QtCore import QObject
from PyQt5.QtNetwork import QUdpSocket, QHostAddress

class UdpSender(QObject):

    def __init__(self):
        super().__init__()
        self.socket = QUdpSocket(self)
        result = self.socket.bind(QHostAddress.Any, 80)

    def send(self, ip: QHostAddress, cmd: str):
        cmd = cmd.encode()
        self.socket.writeDatagram(cmd, ip, 80)