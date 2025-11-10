from queue import Queue
from onvif import ONVIFCamera
from PyQt5.QtCore import QThread, pyqtSignal
from config import Config
from logs import MultiLogger
from models import Command, Slot, System


class OnvifController(QThread):
    '''
    Класс для управления камерой через протокол ONVIF.
    В начале приложения создается 2 потока данного класса, на каждую сторону.
    После создания, потоки начинают ждать комманду.
    Когда GUI готов - OnvifVM помещает команду на подключение в очередь.
    Класс подключается по протоколу к камере и получает актуальную RTSP-ссылку.
    При подключении отправляет на камеру настройки из конфига.
    
    После подключения пользователь может управлять настройками камеры через протокол ONVIF.
    '''

    onvifChangeNotification = pyqtSignal(str)
    connectionEstablished = pyqtSignal(str)
    def __init__(self, config: Config, logger: MultiLogger, slot: Slot):
        super().__init__()
        self.config = config
        self.system_id = 'system_1'
        self.slot = slot
        self.logger = logger.get_logger(f'onvif_{self.slot}')
        self.camera = None
        self.ip = None
        self.test_mode = self.config.get_sys_settings_bool('test_mode')
        self.disconnect()

        self.commands = Queue()
        self._running = False

        self.wait_for_command()

    def connect(self):
        self._update_settings()
        if self.test_mode:
            self._mock_connect()
            return
        self.disconnect()
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
                self._get_rtsp()
                self._send_change_notification()
                self.logger.add_log('INFO', f'УСПЕШНОЕ ПОДКЛЮЧЕНИЕ')
        except Exception as e:
            self.disconnect()
            self.logger.add_log('DEBUG', f'Подключение к не удалось: {e}')

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

    def _get_rtsp(self):
        '''Метод для получения rtsp ссылки через протокол ONFIV. 
        Благодаря этому методу, нам нужно знать только айпи адрес камеры.'''
        try:
            profiles = self.media_service.GetProfiles()
            if not profiles:
                self.logger.add_log('ERROR', f'No profiles returned from media_service')
                return
            profile = profiles[0]
            stream_setup = {
                'Stream': 'RTP-Unicast',
                'Transport': {'Protocol': 'RTSP'}
            }

            uri_data = self.media_service.GetStreamUri({'StreamSetup': stream_setup, 'ProfileToken': profile.token})
            if isinstance(uri_data, dict):
                uri = uri_data.get('Uri')
            else:
                uri = getattr(uri_data, 'Uri', None)
            if not uri:
                self.logger.add_log('ERROR', f'Invalid RTSP URI response: {uri_data}')
                return
            uri = uri.strip()
            self.logger.add_log('INFO', f'RTSP recieved from ONVIF.')
            self.logger.add_log('DEBUG', f'RTSP = "{uri}"')
            self.config.set(self.system_id, self.slot, 'camera', 'rtsp', value = uri)
            self.connectionEstablished.emit(self.slot)
        except Exception as e:
            self.logger.add_log('ERROR', f'_get_rtsp(): {e}')


    def switch_system(self, new_system: System):
        self.system_id = new_system
        self.connect()

    def _check_ready(self):
        if self.test_mode:
            return
        if not self.is_online or not self.image_settings:
            self.disconnect()
            raise RuntimeError("Камера недоступна или не готова к работе.")

    def _send_image_settings(self):
        '''Основной метод передачи настроек через протокол ONVIF.
        Подгатавливаем настройки в _update_param() и отправляем отсюда.'''
        if self.test_mode:
            return
        try:
            set_req = self.imaging_service.create_type('SetImagingSettings')
            set_req.VideoSourceToken = self.video_source_token
            set_req.ImagingSettings = self.image_settings
            set_req.ForcePersistence = True
            self.imaging_service.SetImagingSettings(set_req)

            get_req = self.imaging_service.create_type('GetImagingSettings')
            get_req.VideoSourceToken = self.video_source_token
            self.image_settings = self.imaging_service.GetImagingSettings(get_req)
            return True
        except Exception as e:
            self.logger.add_log('ERROR', f'Ошибка при отправке настроек: {e}')
            return False

    def _update_param(self, name: str, value: float = None):
        '''Метод для подготовки настроек (self.image_settings) к отправке.'''
        if self.test_mode and value:    
            self.config.set(self.system_id, self.slot, 'camera', name.lower(), value=value)
            return
        try:
            self._check_ready()
            if value > 100.0 or value < 0.0:
                self.logger.add_log('ERROR', f'Значение вне диапазона ({value})')
                return
            if hasattr(self.image_settings, name):
                if name == 'Brightness':
                    self.brightness = value
                elif name == 'Contrast':
                    self.contrast = value
                elif name == 'ColorSaturation':
                    self.saturation = value
                setattr(self.image_settings, name, value)
                result = self._send_image_settings()
                if result:
                    self.config.set(self.system_id, self.slot, 'camera', name.lower(), value=value)
                    return
                self.disconnect()
                raise AttributeError(f'[ONVIF].{self.slot}: настройка {name} отсутствует.')
        except Exception as e:
            self.logger.add_log('ERROR', f'Не удалось изменить параметр {name}.\n{e}')

    def set_ip(self, value: str):
        self.logger.add_log('INFO', f'command = set_ip({value})')
        self.config.set(self.system_id, self.slot, 'camera', 'ip', value=value)
        self.connect()

    def set_brightness(self, value: float):
        '''Данные методы подключены к ползункам в GUI.'''
        self._update_param('Brightness', value)

    def set_contrast(self, value: float):
        self._update_param('Contrast', value)

    def set_saturation(self, value: float):
        self._update_param('ColorSaturation', value)

    def check_changes(self):
        '''Метод вызывается из onvif_vm.py по таймеру после каждой смены настроек изображения камеры.
        Нужно, чтобы не было рассинхронизации реальных параметров и ползунка в GUI.'''
        if self.test_mode:
            return
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
        '''Если параметры в check_changes не совпали - onvif_vm обновит показатели в GUI.'''
        self.logger.add_log('WARN', f'Сигнал об изменениях отправлен')
        self.onvifChangeNotification.emit(self.slot)

    def get_current_params(self):
        '''Метод для onvif_vm, получает текущие параметры камеры.'''
        self.logger.add_log('INFO', f'brightness = {self.brightness}, contrast = {self.contrast}, saturation = {self.saturation}')
        return self.ip, self.brightness, self.contrast, self.saturation

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

    def _mock_connect(self):
        self.brightness = self.config.get_onvif_settings(self.system_id, self.slot, 'brightness')
        self.contrast = self.config.get_onvif_settings(self.system_id, self.slot, 'contrast')
        self.saturation = self.config.get_onvif_settings(self.system_id, self.slot, 'colorsaturation')
        self._send_change_notification()
