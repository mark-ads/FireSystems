from .dvrip_lib import DVRIPCam
from config import Config
from typing import Dict, Tuple, Union
from PyQt5.QtCore import QThread, pyqtSignal, QTimer
from queue import Queue
from models import Command, Slot
from logs import MultiLogger


class DvripController(QThread):
    '''
    Класс для управления параметрами камеры по протоколу DVRIP.
    В начале приложения создаются два потока данного класса, на каждую сторону.
    После создания, потоки начинают ждать команду.
    Когда GUI готов - DvripVM помещает команду на поключение в очередь.
    При подключении отправляет на камеру настройки из конфига.

    После подключения пользователь может управлять настройками камеры через протокол DVRIP.
    '''
    dvripChangeNotification = pyqtSignal(str)

    def __init__(self, config: Config, logger: MultiLogger, slot: Slot):
        super().__init__()
        self.config = config
        self.system_id = 'system_1'
        self.slot = slot
        self.logger = logger.get_logger(f'dvrip_{self.slot}')
        self.camera = None
        self.test_mode = self.config.get_sys_settings_bool('test_mode')
        self.disconnect()

        self.commands = Queue()
        self._running = False

        self.wait_for_command()

    def update_settings(self):
        self.ip = self.config.get_str(self.system_id, self.slot, 'camera', 'ip')
        self.login = self.config.get_str(self.system_id, self.slot, 'camera', 'login')
        self.password = self.config.get_str(self.system_id, self.slot, 'camera', 'password')

    def connect(self):
        if self.test_mode:
            self._mock_connect()
            self._send_change_notification()
            return

        self.disconnect()
        self.update_settings()
        try:
            self.logger.add_log('DEBUG', f'Начало подключения')
            self.camera = DVRIPCam(self.ip, user=self.login, password=self.password)
            if self.camera.login():
                self.logger.add_log('INFO', f'Successful login. IP: {self.ip}')
                self.encode_params = self.camera.get_info('Simplify.Encode')
                self.camera_params = self.camera.get_info('Camera')
                self._set_initial_camera_settings()
        except Exception as e:
                self.logger.add_log('ERROR', f'Login failure. IP: {self.ip}. \n {e}')
                self.camera = None

    def disconnect(self):
        '''Метод для отключения текущего подключения и очистки параметров'''
        self.logger.add_log('DEBUG', f'Вызван disconnect()')

        self.fps = None
        self.expo = None
        self.gain = None
        self.auto_gain = None
        self.manual_expo = None
        self.mirror = None
        self.flip = None
        self.ircut = None
        self.encode_params = None
        self.camera_params = None
        self._send_change_notification()

        if self.camera:
            try:
                self.camera.close()
                self.logger.add_log('INFO', f'Успешный disconnect()')
            except Exception as e:
                self.logger.add_log('CRITICAL', f'Ошибка при disconnect(): {e}')
            self.camera = None

    def _set_initial_camera_settings(self):
        '''Метод для применения сохраненных, а так же стандартных настроек при подключении к камере.'''
        if self.camera.login():
            try:
                self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'AudioEnable' : False}})
                self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'Video' : { 'BitRate' : 1996}}})
                self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'Video' : { 'BitRateControl' : 'CBR'}}})
                self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'Video' : { 'Compression' : 'H.265'}}})
                self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'Video' : { 'GOP' : 2}}})
                self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'Video' : { 'Quality' : 3}}})
                self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'Video' : { 'Resolution' : '1080P'}}})
                self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'Video' : { 'VirtualGOP' : 0}}})
                self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'VideoEnable' : True}})

                if 'FPS' in self.encode_params[0]['MainFormat']['Video']:
                    self.fps = self.config.get(self.system_id, self.slot, 'camera', 'fps')
                    if self.encode_params[0]['MainFormat']['Video']['FPS'] != self.fps:
                        self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'Video' : { 'FPS' : self.fps}}})
                    self.logger.add_log('DEBUG', f'Fps = {self.fps}: ГОТОВО!')
                if 'IrcutSwap' in self.camera_params['Param'][0]:
                    self.camera.set_info('Camera.Param.[0]', {'IrcutSwap' : 1})
                    self.ircut = False
                    self.logger.add_log('DEBUG', f'IrcutSwap = {self.ircut}: ГОТОВО!')
                if 'GainParam' in self.camera_params['Param'][0]:
                    if 'AutoGain' in self.camera_params['Param'][0]['GainParam']:
                        self.auto_gain = self.config.get(self.system_id, self.slot, 'camera', 'auto_gain')
                        self.camera.set_info('Camera.Param.[0]', {'GainParam' : {'AutoGain' : self.auto_gain}})
                        self.logger.add_log('DEBUG', f'Auto_gain = {self.auto_gain}: ГОТОВО!')
                    if 'Gain' in self.camera_params['Param'][0]['GainParam']:
                        self.gain = self.config.get(self.system_id, self.slot, 'camera', 'gain')
                        self.camera.set_info('Camera.Param.[0]', {'GainParam' : {'Gain' : self.gain}})
                        self.logger.add_log('DEBUG', f'Gain = {self.gain}: ГОТОВО!')
                if 'ExposureParam' in self.camera_params['Param'][0]:
                    if 'Level' in self.camera_params['Param'][0]['ExposureParam']:
                        self.manual_expo = self.config.get(self.system_id, self.slot, 'camera', 'manual_exposure')
                        self.expo = self.config.get(self.system_id, self.slot, 'camera', 'exposure')
                        if self.manual_expo == True:
                            self.camera.set_info('Camera.Param.[0]', {'ExposureParam' : {'Level' : self.expo}})
                        else:
                            self.camera.set_info('Camera.Param.[0]', {'ExposureParam' : {'Level' : 0}})
                        self.logger.add_log('DEBUG', f'Exposure = manual:{self.manual_expo}, expo:{self.expo}: ГОТОВО!')
                if 'PictureFlip' in self.camera_params['Param'][0]:
                    self.flip = self.config.get(self.system_id, self.slot, 'camera', 'flip')
                    if self.flip:
                        self.camera.set_info('Camera.Param.[0]', {'PictureFlip' : '0x00000001'})
                    else:
                        self.camera.set_info('Camera.Param.[0]', {'PictureFlip' : '0x00000000'})
                    self.logger.add_log('DEBUG', f'Flip = {self.flip}: ГОТОВО!')
                if 'PictureMirror' in self.camera_params['Param'][0]:
                    self.mirror = self.config.get(self.system_id, self.slot, 'camera', 'mirror')
                    if self.mirror:
                        self.camera.set_info('Camera.Param.[0]', {'PictureMirror' : '0x00000001'})
                    else:
                        self.camera.set_info('Camera.Param.[0]', {'PictureMirror' : '0x00000000'})
                    self.logger.add_log('DEBUG', f'Mirror = {self.mirror}: ГОТОВО!')

                self.camera.set_time()
                self.encode_params = self.camera.get_info('Simplify.Encode')
                self.camera_params = self.camera.get_info('Camera')
                self._send_change_notification()
                self.logger.add_log('INFO', f'Начальные настройки применены.')
            except Exception as e:
                self.logger.add_log('ERROR', f'Ошибка отправки начальных настроек: {e}')


    def switch_system(self, new_system):
        self.system_id = new_system
        self.update_settings()
        self.connect()

    def _check_ready(self) -> bool:
        if self.camera is None and not self.test_mode:
            self.logger.add_log('DEBUG', f'_check_ready() -> None')
            return False
        return True

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

    def _send_camera_command(self, attr_name: str, section: str, param_path: list, value: Union[int, str], config_key: str = None) -> bool:
        """
        Универсальная отправка команды на камеру DVRIP.
    
        :self.attr: параметр объекта по которому провести проверку и сохранить после обновления
        :param section: строка DVRIP секции, например 'Camera.Param.[0]'
        :param param_path: путь в параметрах камеры, например ['ExposureParam', 'Level']
        :param value: значение, которое нужно установить
        :param config_key: ключ для сохранения в конфиг (например 'exposure')
        """
        if self.test_mode:
            if config_key:
                self.config.set(self.system_id, self.slot, 'camera', config_key, value=value)
            setattr(self, attr_name, value)
            return True

        if getattr(self, attr_name) is None:
            self.logger.add_log('ERROR', f'Не найден параметр в {attr_name} в объекте')
            return False
        try:
            d = value
            for key in reversed(param_path):
                d = {key: d}

            self.logger.add_log('INFO', f'_send_camera_command: ({section} : {d}')
            self.camera.set_info(section, d)

            if config_key:
                self.config.set(self.system_id, self.slot, 'camera', config_key, value=value)

            if section.startswith('Camera.Param'):
                self.camera_params = self.camera.get_info('Camera')
            elif section.startswith('Simplify.Encode'):
                self.encode_params = self.camera.get_info('Simplify.Encode')
            setattr(self, attr_name, value)
            return True
        except Exception as e:
            self.logger.add_log('ERROR', f'Ошибка отправки команды {param_path}: {e}')

    def check_changes(self):
        if not self._check_ready() or self.test_mode:
            return
        last_values = {
            "fps": self.fps,
            "expo": self.expo,
            "gain": self.gain,
            "auto_gain": self.auto_gain,
            "manual_expo": self.manual_expo,
            "mirror": self.mirror,
            "flip": self.flip,
        }
        try:
            camera_param = self.camera_params["Param"][0]
            exposure_param = camera_param.get("ExposureParam", {})
            exposure_level = exposure_param.get("Level")
            paramEx = self.camera_params["ParamEx"][0]
            broad = paramEx.get('BroadTrends', {})
            #gain_param = camera_param.get("GainParam", {})

            new_values = {
                "fps": self.encode_params[0]["MainFormat"]["Video"].get("FPS"),
                "expo": self.expo if exposure_level == 0 else exposure_level,
                #"gain": gain_param.get("Gain"),
                #"auto_gain": gain_param.get("AutoGain"),
                "gain": broad.get("Gain"),
                "auto_gain": broad.get("AutoGain"),
                "manual_expo": exposure_level != 0,
                "mirror": camera_param.get("PictureMirror") == '0x00000001',
                "flip": camera_param.get("PictureFlip") == '0x00000001',
            }
        except Exception as e:
            self.logger.add_log('ERROR', f'check_changes: параметр в self.encode_params или self.camera_params не найден: {e}')
            return

        changes_detected = False  # оставляю цикл дорабатывать до конца для отладки и принтов
        for key in last_values:  # потом можно останавливать после первого несовпадения
            if last_values[key] is not None and last_values[key] != new_values[key]:
                self.logger.add_log('INFO', f'Изменение {key}: {last_values[key]} -> {new_values[key]}')
                changes_detected = True

        if changes_detected:
            self._sync_from_camera(new_values)
            self._send_change_notification()

    def _sync_from_camera(self, new_values: Dict):
        """Обновляет все локальные параметры на основе новых значений с камеры."""
        if new_values.get("auto_expo"):
            new_values["expo"] = self.expo

        for key, value in new_values.items():
            setattr(self, key, value)

        self.logger.add_log('INFO', f'Параметры синхронизированы с камерой')

    def _send_change_notification(self):
        self.logger.add_log('WARN', f'Сигнал изменения настроек отправлен!')
        self.dvripChangeNotification.emit(self.slot)

    def get_current_params(self) -> Tuple:
        '''Метод для DvripVM, возвращает текущие параметры.'''
        self.logger.add_log('INFO', f'fps={self.fps}, expo={self.expo}, gain={self.gain}, auto_gain={self.auto_gain}, auto_expo={self.manual_expo}, mirror={self.mirror}, flip={self.flip}')
        return self.fps, self.expo, self.gain, self.auto_gain, self.manual_expo, self.mirror, self.flip

    def wait_for_command(self):
        self._running = True
        self.start()

    def stop(self):
        self._running = False
        self.commands.put(None)

    def set_ip(self, value: str):
        self.logger.add_log('INFO', f'command = set_ip({value})')
        self.config.set(self.system_id, self.slot, 'camera', 'ip', value=value)
        self.connect()

    def set_fps(self, value: int):
        '''Данный метод подключены к GUI.'''
        if not self._check_ready or self.fps is None:
            self.logger.add_log('WARN', f'self.fps = {self.fps}')
            return
        self._send_camera_command('fps', 'Simplify.Encode.[0]', ['MainFormat', 'Video', 'FPS'], value, 'fps')

    def set_manual_exposure(self, enabled: bool):
        if not self._check_ready() or self.expo is None:
            self.logger.add_log('WARN', f'self.expo = {self.expo}')
            return
        if enabled:
            result = self._send_camera_command(
                'manual_expo', 'Camera.Param.[0]', ['ExposureParam', 'Level'], self.expo, 
            )
        else:
            result = self._send_camera_command(
                'manual_expo', 'Camera.Param.[0]', ['ExposureParam', 'Level'], 0
            )
        if result:
            self.manual_expo = enabled
            self.config.set(self.system_id, self.slot, 'camera', 'manual_exposure', value=enabled)

    def set_exposure(self, value: int):
        if not self._check_ready():
            return
        if self.expo is None or self.manual_expo is False:
            self.logger.add_log('WARN', f'self.expo = {self.expo}, self.manual_expo = {self.manual_expo}')
            return
        if value == 0:
            self._send_change_notification()
            return
        self._send_camera_command('expo', 'Camera.Param.[0]', ['ExposureParam', 'Level'], value, 'exposure')

    def set_auto_gain(self, enabled: bool):
        if not self._check_ready() or self.auto_gain is None:
            self.logger.add_log('WARN', f'self.auto_gain = {self.auto_gain}')
            return
        if enabled:
            #self._send_camera_command('auto_gain', 'Camera.Param.[0]', ['GainParam', 'AutoGain'], 1, 'auto_gain')
            self._send_camera_command('auto_gain', 'Camera.ParamEx.[0]', ['BroadTrends', 'AutoGain'], 1, 'auto_gain')
        else:
            #self._send_camera_command('auto_gain', 'Camera.Param.[0]', ['GainParam', 'AutoGain'], 0, 'auto_gain')
            self._send_camera_command('auto_gain', 'Camera.ParamEx.[0]', ['BroadTrends', 'AutoGain'], 0, 'auto_gain')

    def set_gain(self, value: int):
        if not self._check_ready() or self.gain is None:
            self.logger.add_log('WARN', f'self.auto_gain = {self.auto_gain}, self.gain = {self.gain}')
            return
        #self._send_camera_command('gain', 'Camera.Param.[0]', ['GainParam', 'Gain'], value, 'gain')
        self._send_camera_command('gain', 'Camera.ParamEx.[0]', ['BroadTrends', 'Gain'], value, 'gain')

    def set_mirror(self, enabled: bool):
        if not self._check_ready() or self.mirror is None:
            self.logger.add_log('WARN', f'self.mirror = {self.mirror}')
            return
        if enabled:
            result = self._send_camera_command('mirror', 'Camera.Param.[0]', ['PictureMirror'], '0x00000001')
        else:
            result = self._send_camera_command('mirror', 'Camera.Param.[0]', ['PictureMirror'], '0x00000000')
        if result:
            self.config.set(self.system_id, self.slot, 'camera', 'mirror', value=enabled)
            self.mirror = enabled

    def set_flip(self, enabled: bool):
        if not self._check_ready() and self.flip is None:
            self.logger.add_log('WARN', f'self.flip = {self.flip}')
            return
        if enabled:
            result = self._send_camera_command('flip', 'Camera.Param.[0]', ['PictureFlip'], '0x00000001')
        else:
            result = self._send_camera_command('flip', 'Camera.Param.[0]', ['PictureFlip'], '0x00000000')
        if result:
            self.config.set(self.system_id, self.slot, 'camera', 'flip', value=enabled)
            self.flip = enabled

    def set_ircut(self, value: int):
        if not self._check_ready() and self.ircut is None:
            self.logger.add_log('WARN', f'self.ircut = {self.flip}')
            return
        result = self._send_camera_command('flip', 'Camera.Param.[0]', ['IrcutSwap'], value, 'ircut')

    def run(self):
        self.logger.add_log('DEBUG', f'Ждем команду')
        while self._running:
            command = self.commands.get()
            self.logger.add_log('DEBUG', f'command = {command}')
            if command is not None:
                self._exec_command(command)

    def _mock_connect(self):
        self.logger.add_log('INFO', 'Тестовый режим. _mock_connect()')
        self.fps = self.config.get(self.system_id, self.slot, 'camera', 'fps')
        self.auto_gain = self.config.get(self.system_id, self.slot, 'camera', 'auto_gain')
        self.gain = self.config.get(self.system_id, self.slot, 'camera', 'gain')
        self.manual_expo = self.config.get(self.system_id, self.slot, 'camera', 'manual_exposure')
        self.expo = self.config.get(self.system_id, self.slot, 'camera', 'exposure')
        self.flip = self.config.get(self.system_id, self.slot, 'camera', 'flip')
        self.mirror = self.config.get(self.system_id, self.slot, 'camera', 'mirror')