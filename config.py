from ruamel.yaml import YAML
from pathlib import Path
from PyQt5.QtCore import QObject, pyqtSignal, QReadWriteLock
from models import ArduinoConfig, Settings
from pydantic import ValidationError
from collections import OrderedDict
from models import ZondPair, CameraConfig
from typing import Union


yaml = YAML()
yaml.indent(mapping=2, sequence=4, offset=2)
yaml.default_flow_style = False

class Config(QObject):

    settingsChanged = pyqtSignal()

    def __init__(self, path='settings.yaml'):
        super().__init__()
        self._lock = QReadWriteLock()
        self.path = Path(path)
        self.settings = {}
        self.load()
        self.logger = None
        print('Конфиг загружен')

    def load(self):
        self._lock.lockForWrite()
        try:
            if self.path.exists():
                with self.path.open("r", encoding="utf-8") as f:
                    raw = yaml.load(f)

                if raw is None:
                    print("⚠️ Файл настроек пуст, используем стандартные настройки.")
                    self.use_defaults()
                    return

                try:
                    self.settings = Settings.parse_obj(raw)
                except ValidationError as e:
                    print("❌ Ошибка валидации настроек:", e)
                    print("⚠️ Используем стандартные настройки.")
                    self.use_defaults()

            else:
                print("⚠️ Файл настроек не найден. Используем и сохраняем стандартные настройки.")
                self.use_defaults()
        finally:
            self._save_unlocked()
            self._lock.unlock()

    def save(self):
        self._lock.lockForWrite()
        try:
            with open(self.path, 'w', encoding="utf-8") as f:
                yaml.dump(self.settings.model_dump(mode="json"), f)
        finally:
            self._lock.unlock()

    def _save_unlocked(self):
        with open(self.path, 'w', encoding="utf-8") as f:
            yaml.dump(self.settings.model_dump(mode="json"), f)

    def use_defaults(self):
        self.settings = Settings()

    @property
    def systems(self) -> OrderedDict[str, ZondPair]:
        return self.settings.zond_pairs

    def __getitem__(self, key: str) -> ZondPair:
        return self.systems[key]

    def add_logger(self, logger):
        from logs import MultiLogger
        self.logger = logger.get_logger('app')

    def get_str(self, sys_key: str, *path: str) -> str:
        '''Получить настройки. Вводим путь через аргументы path.
        (hint: system_id, slot, device, field)
        '''
        try:
            node = self.settings.zond_pairs[sys_key]
            for part in path:
                node = getattr(node, part)
            return str(node)
        except AttributeError:
            self.logger.add_log('ERROR', f'Нет поля {'->'.join((sys_key,) + path)} в настройках')
        except KeyError:
            self.logger.add_log('ERROR', f'Нет системы с ключом "{sys_key}"')

    def get_onvif_settings(self, sys_key: str, slot: str, field: str) -> float:
        '''Получить числовую настройку камеры (float)'''
        try:
            zond_pair = self.settings.zond_pairs[sys_key]
            pair = getattr(zond_pair, slot)
            camera: CameraConfig = pair.camera
            result = getattr(camera, field)

            if isinstance(result, float):
                return result
            else:
                self.logger.add_log('ERROR', f'Поле {field} не является float (тип: {type(result).__name__})')

        except AttributeError:
            self.logger.add_log('ERROR', f'Нет поля {field} в настройках камеры')
        except KeyError:
            self.logger.add_log('ERROR', f'Нет системы с ключом "{sys_key}"')

    def get_arduino_settings(self, sys_key: str, slot: str, field: str) -> Union[float, bool]:
        '''Получить числовую настройку ардуино (float | bool)'''
        try:
            zond_pair = self.settings.zond_pairs[sys_key]
            pair = getattr(zond_pair, slot)
            arduino: ArduinoConfig = pair.arduino
            result = getattr(arduino, field)

            if isinstance(result, float) or isinstance(result, bool):
                return result
            else:
                self.logger.add_log('ERROR', f'Поле {field} не является float или bool (тип: {type(result).__name__})')

        except AttributeError:
            self.logger.add_log('ERROR', f'Нет поля {field} в настройках ардуино')
        except KeyError:
            self.logger.add_log('ERROR', f'Нет системы с ключом "{sys_key}"')

    def get(self, sys_key: str, *path: str) -> Union[int, float, str]:
        '''Получить настройку не меняя и не проверяя тип
        (hint: system_id, slot, device, field)
        '''
        try:
            node = self.settings.zond_pairs[sys_key]
            for part in path:
                node = getattr(node, part)
            return node
        except AttributeError:
            self.logger.add_log('ERROR', f"Нет поля {'->'.join((sys_key,) + path)} в настройках")
        except KeyError:
            self.logger.add_log('ERROR', f'Нет системы с ключом "{sys_key}"')

    def get_sys_settings(self, *path: str) -> str:
        '''Получить настроки программы
        (hint: field)'''
        try:
            node = self.settings.program_settings
            for part in path:
                node = getattr(node, part)
                return str(node)
        except AttributeError:
            self.logger.add_log('ERROR', f'Нет поля {path} в настройках')

    def get_sys_settings_bool(self, *path: str) -> bool:
        '''Получить настроки программы'''
        try:
            node = self.settings.program_settings
            for part in path:
                node = getattr(node, part)
            if isinstance(node, bool):
                return node
        except AttributeError:
            self.logger.add_log('ERROR', f'Нет поля {path} в настройках')

    def set(self, sys_key: str, *path: str, value: Union[int, float, bool]):
        '''
        Устанавливает новое значение по указанному пути и сохраняет конфиг
        '''
        self._lock.lockForWrite()
        try:
            node = self.settings.zond_pairs[sys_key]
            for part in path[:-1]:
                node = getattr(node, part)
            setattr(node, path[-1], value)
            self._save_unlocked()
            self.logger.add_log('DEBUG', f'Изменения сохранены: {node}{path[-1]} = {value}')
        finally:
            self._lock.unlock()

    def set_sys(self, param: str, value: Union[int, float, bool, str]):
        '''
        Устанавливает новое значение для системных настроек
        '''
        self._lock.lockForWrite()
        try:
            if hasattr(self.settings.program_settings, param):
                setattr(self.settings.program_settings, param, value)
                self._save_unlocked()
                if self.logger:
                    self.logger.add_log('DEBUG', f'Изменения сохранены: program_settings.{param} = {value}')
            else:
                if self.logger:
                    self.logger.add_log('ERROR', f'Нет параметра "{param}" в program_settings')
        finally:
            self._lock.unlock()
