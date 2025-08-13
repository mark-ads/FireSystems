from config import Config
from .zond_system import ZondSystem

class SystemFactory:
    '''
    Класс для создания систем.
    Создаёт системы (пара верх + низ для зонд + камера).
    Принимает конфиг и из него создает необходимое количество систем (столько, сколько в settings.yaml).
    '''

    def __init__(self, config: Config):
        super().__init__()
        if not isinstance(config, Config):
            raise TypeError(f"SystemFactory: config не является объектом класса Config")
        self.config = config
        self.zond_systems = []

    def create_system(self, system_id: str) -> ZondSystem:
        if system_id in self.config.systems:
            return ZondSystem(self.config, system_id)