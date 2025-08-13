from PyQt5.QtCore import QObject, pyqtSlot, pyqtSignal
from config import Config
from .system_factory import SystemFactory
from .receiver import Receiver
import time

class SystemsController(QObject):

    firstSignal = pyqtSignal()

    def __init__(self, config: Config):
        super().__init__()
        if not isinstance(config, Config):
            raise TypeError(f"SystemController: config не является объектом класса Config")
        self.config = config
        self.factory = SystemFactory(self.config)

        self.systems = {
            name: self.factory.create_system(name)
            for name in self.config.systems
            }
        
        for name in self.systems:
            system = self.systems[name]
            setattr(self, name, system)
        
        self.receiver = Receiver(self.config, self.create_ip_map())
        self.receiver.start_receiving()

    def create_ip_map(self):
        ip_map = {}
        for system_id, system in self.systems.items():
            ip_map[system.front.ip] = (system.front, system_id, system.front.slot)
            ip_map[system.back.ip] = (system.back, system_id, system.back.slot)
        return ip_map





'''
ip_map
{'192.168.1.14': (<backend.Backend object at 0x0780F7C8>, 'system_1', 'front'), 
'192.168.1.13': (<backend.Backend object at 0x0780F780>, 'system_1', 'back'), 
'192.168.1.16': (<backend.Backend object at 0x0780F8A0>, 'system_2', 'front'), 
'192.168.1.15': (<backend.Backend object at 0x0780F8E8>, 'system_2', 'back')}
'''