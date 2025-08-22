from PyQt5.QtCore import QObject, pyqtSlot, pyqtSignal
from config import Config
from logs import MultiLogger
from signal_hub import SignalHub
from viewmodels.viewmodel import Viewmodel
from .backend import Backend
from .receiver import Receiver
import time

class ZondSystem(QObject):
    def __init__(self, config: Config, logger: MultiLogger, hub: SignalHub, system_id: str):
        super().__init__()
        self.id = system_id
        self.config = config
        self.logger = logger.get_logger(f'backend_{system_id}')
        self.hub = hub
        self.name = self.config.get_str(self.id, 'name')
        self.front = Backend(self.config, self.logger, self.hub, self.id, 'front')
        self.back = Backend(self.config, self.logger, self.hub, self.id, 'back')

class SystemFactory:
    '''
    Класс для создания систем.
    Создаёт системы (пара верх + низ для зонд + камера).
    Принимает конфиг и из него создает необходимое количество систем (столько, сколько в settings.yaml).
    '''

    def __init__(self, config: Config, logger: MultiLogger, hub: SignalHub):
        super().__init__()
        self.config = config
        self.logger = logger
        self.hub = hub
        self.zond_systems = []

    def create_system(self, system_id: str) -> ZondSystem:
        if system_id in self.config.systems:
            return ZondSystem(self.config, self.logger, self.hub, system_id)


class SystemsController(QObject):

    firstSignal = pyqtSignal()

    def __init__(self, config: Config, logger: MultiLogger, hub: SignalHub):
        super().__init__()
        self.config = config
        self.factory = SystemFactory(self.config, logger, hub)

        self.systems = {
            name: self.factory.create_system(name)
            for name in self.config.systems
            }
        
        for name in self.systems:  # создание атрибутов по ключам для облегченного доступа
            system = self.systems[name]
            setattr(self, name, system)
        
        self.receiver = Receiver(self.config, logger, self.create_ip_map())
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