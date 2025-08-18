from PyQt5.QtCore import QObject
from config import Config
from .backend import Backend

class ZondSystem(QObject):
    def __init__(self, config: Config, system_id: str):
        super().__init__()
        if not isinstance(config, Config):
            raise TypeError(f"ZondSystem: config не является объектом класса Config")
        self.id = system_id
        self.config = config
        self.name = self.config.get_str(self.id, 'name')
        self.front = Backend(self.config, self.id, 'front')
        self.back = Backend(self.config, self.id, 'back')