import logging
from typing import Literal
from config import Config
from logging.handlers import RotatingFileHandler
from pathlib import Path

log_levels = {
    "CRITICAL": logging.CRITICAL,
    "ERROR": logging.ERROR,
    "WARN": logging.WARN,
    "INFO": logging.INFO,
    "DEBUG": logging.DEBUG,
}

class SingleLogger:
    """
    Экземпляр логгера. Каждый логгер пишет в свой файл.
    Обычно, на один объект - один логгер.
    Берет уровень логов из settings.yaml.
    :param log_dir: Папка для логов.
    :param max_bytes: Максимальный размер файла до ротации.
    :param backup_count: Количество резервных файлов.
    """

    def __init__(self, config: Config, name: str, log_dir: Path):
        self.config = config
        self.console_on = self.config.get_sys_settings_bool('console_on')
        self.level = self.config.get_sys_settings('log_level')
        self.name = name
        self.log_dir = log_dir
        self.max_bytes= 2000000
        self.backup_count = 2

        self.logger = logging.getLogger(self.name)
        self.logger.setLevel(log_levels.get(self.level, logging.DEBUG))
        self.logger.propagate = False

        if not self.logger.handlers:
            log_file = self.log_dir / f"{name.lower()}.log"
            file_handler = RotatingFileHandler(
                log_file, 
                maxBytes=self.max_bytes, 
                backupCount=self.backup_count, 
                encoding='utf-8'
            )
            file_handler.setLevel(log_levels.get(self.level, logging.DEBUG))
            file_handler.setFormatter(logging.Formatter(
                '[%(asctime)s][%(name)s][%(levelname)s]: %(message)s'
            ))
            self.logger.addHandler(file_handler)
        
            if self.console_on:
                console_handler = logging.StreamHandler()
                console_handler.setLevel(log_levels.get(self.level, logging.DEBUG))
                console_handler.setFormatter(logging.Formatter(
                    '[%(name)s][%(levelname)s]: %(message)s'
                ))
                self.logger.addHandler(console_handler)

    def add_log(self, level: Literal['DEBUG', 'INFO', 'WARN', 'ERROR', 'CRITICAL'], data: str):
        log_level = log_levels.get(level, logging.INFO)        
        self.logger.log(log_level, data)

class MultiLogger:
    """
    Фабрика логгеров.
    Создает новый SingleLogger или возвращает готовый.
    """

    def __init__(self, config: Config):
        self.config = config
        self.log_dir = Path('logs')
        self.log_dir.mkdir(parents=True, exist_ok=True)
        
        self.loggers = {}

    def get_logger(self, name: str) -> SingleLogger:
        name = name.upper()
        if name not in self.loggers:
            self.loggers[name] = SingleLogger(self.config, name, self.log_dir)
        return self.loggers[name]


