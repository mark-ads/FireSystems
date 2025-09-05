from queue import Queue
from PyQt5.QtCore import QObject, Qt, pyqtSlot, pyqtSignal, QThread
from config import Config
from logs import MultiLogger
from models import Telemetry
from signal_hub import SignalHub
from .backend import Backend
from .receiver import Receiver

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
    Создаёт системы (front и back для контролллеров ардуино).
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


class SystemsController(QThread):
    '''
    Поток для работы всех бекендов для каждого ардуино в настройках.
    Так же содержит Reciever для приема пакетов от ардуино.
    '''
    guiIsReady = pyqtSignal()
    sendHistory = pyqtSignal()

    def __init__(self, config: Config, logger: MultiLogger, hub: SignalHub):
        super().__init__()
        self.config = config
        self.factory = SystemFactory(self.config, logger, hub)
        self.telemetry_queue = Queue()
        self.logger = logger.get_logger('systems_controller')
        self._running = True

        self.systems = {
            name: self.factory.create_system(name)
            for name in self.config.systems
            }
        self.receiver = Receiver(self.config, logger)
        self.receiver.forwardTelemetry.connect(self._forward_to_backend)

        for name in self.systems:  # создание атрибутов по ключам для облегченного доступа
            system = self.systems[name]
            setattr(self, name, system)
            self.guiIsReady.connect(self.systems[name].front.init_on_gui)
            self.guiIsReady.connect(self.systems[name].back.init_on_gui)
            self.systems[name].front.updateSettings.connect(self.receiver.update_settings)
            self.sendHistory.connect(self.systems[name].front.send_history)
            self.sendHistory.connect(self.systems[name].back.send_history)
            self.systems[name].back.updateSettings.connect(self.receiver.update_settings)

        self.start()

    def _forward_to_backend(self, tel: Telemetry):
        try:
            system = getattr(self, tel.system, None)
            backend = getattr(system, tel.slot, None)
            if backend:
                backend.handle_arduino_message(tel.data)
        except Exception as e:
            self.logger.add_log('ERROR', f'Ошибка в _forward_to_backend: {e}')

    @pyqtSlot()
    def onGuiReady(self):
        self.guiIsReady.emit()

    @pyqtSlot()
    def update_settings(self):
        self.receiver.update_settings()

    def run(self):
        self.exec_()

    def stop(self):
        self._running = False
        self.quit()
        self.wait()




'''
ip_map
{'192.168.1.14': (<backend.Backend object at 0x0780F7C8>, 'system_1', 'front'), 
'192.168.1.13': (<backend.Backend object at 0x0780F780>, 'system_1', 'back'), 
'192.168.1.16': (<backend.Backend object at 0x0780F8A0>, 'system_2', 'front'), 
'192.168.1.15': (<backend.Backend object at 0x0780F8E8>, 'system_2', 'back')}
'''