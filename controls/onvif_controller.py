from onvif import ONVIFCamera
from PyQt5.QtCore import QObject, QTimer, pyqtSignal
from zeep import xsd
from typing import Literal
from config import Config


class OnvifController(QObject):
    '''
    Класс для управления камерой через протокол ONVIF.
    Так же, имеет в себе таймер, чтобы отложено обновлять (синхронизировать) показатели после нажатия кнопок.
    '''

    onvifChangeNotification = pyqtSignal(str)

    def __init__(self, config: Config, system_id: str, slot: Literal['front', 'back']):
        super().__init__()
        self.config = config
        self.system_id = system_id
        self.slot = slot
        self.is_online = False
        self.ip = ''
        self.port = 0
        self.login = ''
        self.password = ''
        self.camera = None
        self.image_settings = None
        self.brightness = None
        self.contrast = None
        self.saturation = None

        self.update_settings()
        self._set_initial_camera_settings()
        self._send_change_notification()

    def update_settings(self):
        self.disconnect()
        self.ip = self.config.get(self.system_id, self.slot, 'camera', 'ip')
        self.port = self.config.get(self.system_id, self.slot, 'camera', 'onvif_port')
        self.login = self.config.get(self.system_id, self.slot, 'camera', 'login')
        self.password = self.config.get(self.system_id, self.slot, 'camera', 'password')
        self._connect()

    def _connect(self):
        if self.camera:
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
        except Exception as e:
            print(f'[ONVIF].{self.slot}: подключение к не удалось: {e}')

    def disconnect(self):
        if self.camera:
            print(f'[ONVIF].{self.slot}: Сработал disconnect()')
            self.camera = None
            self.media_service = None
            self.imaging_service = None
            self.video_sources = None
            self.video_source_token = None
            self.image_settings = None
            self.is_online = False
            self.brightness = None
            self.contrast = None
            self.saturation = None
            self._send_change_notification()

    def _set_initial_camera_settings(self):
        if not self.is_online:
            return
        brightness = self.config.get_camera_settings(self.system_id, self.slot, 'brightness')
        contrast = self.config.get_camera_settings(self.system_id, self.slot, 'contrast')
        saturation = self.config.get_camera_settings(self.system_id, self.slot, 'colorsaturation')

        self.brightness = None
        self.contrast = None
        self.saturation = None

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
        self.update_settings()
        self._connect()
        self._set_initial_camera_settings()

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
            print(f'[ONVIF].{self.slot}: Настройки подтверждены и обновлены')
            return True
        except Exception as e:
            print(f'[ONVIF].{self.slot}: Ошибка при отправке настроек: {e}')
            return False

    def _update_param(self, name: str, value: float = None):
        try:
            self._check_ready()
            if value > 100.0 or value < 0.0:
                print(f'[ONVIF].{self.slot}: значение вне диапазона ({value})')
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
            print(f'[ONVIF].{self.slot}: не удалось изменить параметр {name}.\n{e}')

    def set_brightness(self, value: float):
        self._update_param('Brightness', value)

    def set_contrast(self, value: float):
        self._update_param('Contrast', value)

    def set_saturation(self, value: float):
        self._update_param('ColorSaturation', value)

    def check_changes(self):
        print('сработала проверка')
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
        print(f'[ONVIF].{self.slot}: сигнал об изменениях отправлен')
        self.onvifChangeNotification.emit(self.slot)

    def get_current_params(self):
        return self.brightness, self.contrast, self.saturation