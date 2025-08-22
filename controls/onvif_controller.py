from queue import Queue
from onvif import ONVIFCamera
from PyQt5.QtCore import QThread, pyqtSignal, QTimer
from zeep import xsd
from typing import Literal
from config import Config
from logs import MultiLogger
from models import Command


class OnvifController(QThread):
    '''
    Класс для управления камерой через протокол ONVIF.
    В начале приложения создается 2 потока данного класса, на каждую сторону.
    После создания, потоки начинают ждать комманду.
    Когда GUI готов - OnvifVM помещает команду на подключение в очередь.
    При подключении применяет начальные настройки из конфиг.
    Содержит в себе таймер для отложенной проверки и синхронизации параметров с камерой.
    '''

    onvifChangeNotification = pyqtSignal(str)

    def __init__(self, config: Config, logger: MultiLogger, system_id: str, slot: Literal['front', 'back']):
        super().__init__()
        self.config = config
        self.system_id = system_id
        self.slot = slot
        self.logger = logger.get_logger(f'onvif_{self.slot}')
        self.camera = None
        self.disconnect()

        self.commands = Queue()
        self._running = False

        self.wait_for_command()

    def connect(self):
        self.disconnect()
        self._update_settings()
        try:
            self.camera = ONVIFCamera(self.ip, self.port, self.login, self.password)
            self.media_service = self.camera.create_media_service()
            self.imaging_service = self.camera.create_imaging_service()
            self.video_sources = self.media_service.GetVideoSources()
            self.video_source_token = self.video_sources[0].token
            get_req = self.imaging_service.create_type('GetImagingSettings')
            get_req.VideoSourceToken = self.video_source_token
            self.image_settings = self.imaging_service.GetImagingSettings(get_req)
            if self.image_settings:
                self.is_online = True
                self._set_initial_camera_settings()
                self._send_change_notification()
                self.logger.add_log('INFO', f'УСПЕШНОЕ ПОДКЛЮЧЕНИЕ')
        except Exception as e:
            self.disconnect()
            self.logger.add_log('CRITICAL', f'Подключение к не удалось: {e}')

    def disconnect(self):
        self.is_online = False
        self.brightness = None
        self.contrast = None
        self.saturation = None
        self.image_settings = None
        if self.camera:
            self.logger.add_log('INFO', f'Сработал disconnect()')
            self.camera = None
            self.media_service = None
            self.imaging_service = None
            self.video_sources = None
            self.video_source_token = None
            self._send_change_notification()

    def _update_settings(self):
        self.ip = self.config.get_str(self.system_id, self.slot, 'camera', 'ip')
        self.port = self.config.get_str(self.system_id, self.slot, 'camera', 'onvif_port')
        self.login = self.config.get_str(self.system_id, self.slot, 'camera', 'login')
        self.password = self.config.get_str(self.system_id, self.slot, 'camera', 'password')

    def _set_initial_camera_settings(self):
        if not self.is_online:
            return
        brightness = self.config.get_onvif_settings(self.system_id, self.slot, 'brightness')
        contrast = self.config.get_onvif_settings(self.system_id, self.slot, 'contrast')
        saturation = self.config.get_onvif_settings(self.system_id, self.slot, 'colorsaturation')

        if hasattr(self.image_settings, 'Brightness'):
            self.image_settings.Brightness = brightness
            self.brightness = brightness
        if hasattr(self.image_settings, 'Contrast'):
            self.image_settings.Contrast = contrast
            self.contrast = contrast
        if hasattr(self.image_settings, 'ColorSaturation'):
            self.image_settings.ColorSaturation = saturation
            self.saturation = saturation

        self._send_image_settings()


    def switch_system(self, new_system):
        self.system_id = new_system
        self.connect()

    def _check_ready(self):
        if not self.is_online or not self.image_settings:
            self.disconnect()
            raise RuntimeError("Камера недоступна или не готова к работе.")

    def _send_image_settings(self):
        try:
            set_req = self.imaging_service.create_type('SetImagingSettings')
            set_req.VideoSourceToken = self.video_source_token
            set_req.ImagingSettings = self.image_settings
            set_req.ForcePersistence = True
            self.imaging_service.SetImagingSettings(set_req)

            get_req = self.imaging_service.create_type('GetImagingSettings')
            get_req.VideoSourceToken = self.video_source_token
            self.image_settings = self.imaging_service.GetImagingSettings(get_req)
            #self.logger.add_log('DEBUG', f'Настройки подтверждены и обновлены')
            return True
        except Exception as e:
            self.logger.add_log('ERROR', f'Ошибка при отправке настроек: {e}')
            return False

    def _update_param(self, name: str, value: float = None):
        try:
            self._check_ready()
            if value > 100.0 or value < 0.0:
                self.logger.add_log('ERROR', f'начение вне диапазона ({value})')
                return
            if hasattr(self.image_settings, name):
                if name == 'Brightness':
                    self.brightness = value
                elif name == 'Contrast':
                    self.contrast = value
                elif name == 'ColorSaturation':
                    self.saturation = value
                #current = getattr(self.image_settings, name)
                setattr(self.image_settings, name, value)
                result = self._send_image_settings()
                if result:
                    self.config.set(self.system_id, self.slot, 'camera', name.lower(), value=value)
                    return
                self.disconnect()
                raise AttributeError(f'[ONVIF].{self.slot}: настройка {name} отсутствует.')
        except Exception as e:
            self.logger.add_log('ERROR', f'Не удалось изменить параметр {name}.\n{e}')

    def set_brightness(self, value: float):
        self._update_param('Brightness', value)

    def set_contrast(self, value: float):
        self._update_param('Contrast', value)

    def set_saturation(self, value: float):
        self._update_param('ColorSaturation', value)

    def check_changes(self):
        self.logger.add_log('DEBUG', f'Сработала проверка')
        last_values = [self.brightness, self.contrast, self.saturation]
        new_values = [getattr(self.image_settings, 'Brightness', None), 
                      getattr(self.image_settings, 'Contrast', None), 
                      getattr(self.image_settings, 'ColorSaturation', None)]
        for last, new in zip(last_values, new_values):
            if last != new:
                self._sync_from_camera()
                self._send_change_notification()
                return

    def _sync_from_camera(self):
        if hasattr(self.image_settings, 'Brightness'):
            self.brightness = self.image_settings.Brightness
        else:
            self.brightness = None
        if hasattr(self.image_settings, 'Contrast'):
            self.contrast = self.image_settings.Contrast
        else:
            self.contrast = None
        if hasattr(self.image_settings, 'ColorSaturation'):
            self.saturation = self.image_settings.ColorSaturation
        else:
            self.saturation = None

    def _send_change_notification(self):
        self.logger.add_log('WARN', f'Сигнал об изменениях отправлен')
        self.onvifChangeNotification.emit(self.slot)

    def get_current_params(self):
        self.logger.add_log('INFO', f'brightness = {self.brightness}, contrast = {self.contrast}, saturation = {self.saturation}')
        return self.brightness, self.contrast, self.saturation

    def add_command(self, cmd: Command):
        self.commands.put(cmd)

    def _exec_command(self, cmd: Command):
        method = getattr(self, cmd.command, None)
        if not callable(method):
            self.logger.add_log('ERROR', f'Метод {cmd.command} не найден')
            return
        if cmd.value is not None:
            method(cmd.value)
        else:
            method()
    
    def wait_for_command(self):
        self._running = True
        self.start()

    def stop(self):
        self._running = False
        self.commands.put(None)
    
    def run(self):
        while self._running:
            command = self.commands.get()
            self.logger.add_log('DEBUG', f'command = {command}')
            if command is not None:
                self._exec_command(command)