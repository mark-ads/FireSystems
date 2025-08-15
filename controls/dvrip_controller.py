from .dvrip_lib import DVRIPCam
from config import Config
from typing import Literal
from PyQt5.QtCore import QThread, pyqtSignal
from queue import Queue
from models import Command

class DvripController(QThread):
    '''
    Класс для управления параметрами камеры по протоколу DVRIP.
    
    '''
    dvripChangeNotification = pyqtSignal(str)

    def __init__(self, config: Config, system_id: str, slot: Literal['front', 'back']):
        super().__init__()
        self.config = config
        self.system_id = system_id
        self.slot = slot
        self.commands = Queue()
        self._running = False

        self.camera = None
        self.disconnect()
        self.wait_for_command()

    def update_settings(self):
        self.ip = self.config.get(self.system_id, self.slot, 'camera', 'ip')
        self.login = self.config.get(self.system_id, self.slot, 'camera', 'login')
        self.password = self.config.get(self.system_id, self.slot, 'camera', 'password')

    def connect(self):
        self.disconnect()
        self.update_settings()
        try:
            print(f'[DVRIP].{self.slot}: начало подключения')
            self.camera = DVRIPCam(self.ip, user=self.login, password=self.password)
            if self.camera.login():
                print(f'[DVRIP].{self.slot}: Successful login. IP: {self.ip}')
                self.encode_params = self.camera.get_info('Simplify.Encode')
                self.camera_params = self.camera.get_info('Camera')
                self._set_initial_camera_settings()
        except Exception as e:
                print(f'[DVRIP].{self.slot}: Login failure. IP: {self.ip}. \n {e}')

    def disconnect(self):
        '''Метод для отключения текущего подключения и очистки параметров'''
        self.stop()
        if self.camera:
            print(f'[DVRIP].{self.slot}: вызван disconnect()')
            try:
                self.camera.close()
            except Exception as e:
                print(f'[DVRIP].{self.slot}: ошибка при disconnect(): {e}')
            self.camera = None

        self.fps = None
        self.expo = None
        self.gain = None
        self.auto_gain = None
        self.auto_expo = None
        self.mirror = None
        self.flip = None
        self.ircut = None

    def _set_initial_camera_settings(self):
        '''Метод для применения сохраненных, а так же стандартных настроек при подключении к камере.'''
        if self.camera.login():
            try:

                if 'FPS' in self.encode_params[0]['MainFormat']['Video']:
                    self.fps = self.config.get(self.system_id, self.slot, 'camera', 'fps')
                    if self.encode_params[0]['MainFormat']['Video']['FPS'] != self.fps:
                        self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'Video' : { 'FPS' : self.fps}}})
                    print(f'[DVRIP].{self.slot}: fps = {self.fps}: ГОТОВО!')
                if 'IrcutSwap' in self.camera_params['Param'][0]:
                    self.camera.set_info('Camera.Param.[0]', {'IrcutSwap' : 1})
                    self.ircut = False
                    print(f'[DVRIP].{self.slot}: IrcutSwap = {self.ircut}: ГОТОВО!')
                if 'GainParam' in self.camera_params['Param'][0]:
                    if 'AutoGain' in self.camera_params['Param'][0]['GainParam']:
                        self.auto_gain = self.config.get(self.system_id, self.slot, 'camera', 'auto_gain')
                        self.camera.set_info('Camera.Param.[0]', {'GainParam' : {'AutoGain' : self.auto_gain}})
                        print(f'[DVRIP].{self.slot}: auto_gain = {self.auto_gain}: ГОТОВО!')
                    if 'Gain' in self.camera_params['Param'][0]['GainParam']:
                        self.gain = self.config.get(self.system_id, self.slot, 'camera', 'gain')
                        self.camera.set_info('Camera.Param.[0]', {'GainParam' : {'Gain' : self.auto_gain}})
                        print(f'[DVRIP].{self.slot}: gain = {self.gain}: ГОТОВО!')
                if 'ExposureParam' in self.camera_params['Param'][0]:
                    if 'Level' in self.camera_params['Param'][0]['ExposureParam']:
                        self.auto_expo = self.config.get(self.system_id, self.slot, 'camera', 'auto_exposure')
                        self.expo = self.config.get(self.system_id, self.slot, 'camera', 'exposure')
                        if self.auto_expo:
                            self.camera.set_info('Camera.Param.[0]', {'ExposureParam' : {'Level' : 0}})
                        else:
                            self.camera.set_info('Camera.Param.[0]', {'ExposureParam' : {'Level' : self.expo}})
                        print(f'[DVRIP].{self.slot}: exposure = {self.auto_expo}: ГОТОВО!')
                if 'PictureFlip' in self.camera_params['Param'][0]:
                    self.flip = self.config.get(self.system_id, self.slot, 'camera', 'flip')
                    if self.flip:
                        self.camera.set_info('Camera.Param.[0]', {'PictureFlip' : '0x00000001'})
                    else:
                        self.camera.set_info('Camera.Param.[0]', {'PictureFlip' : '0x00000000'})
                    print(f'[DVRIP].{self.slot}: flip = {self.flip}: ГОТОВО!')
                if 'PictureMirror' in self.camera_params['Param'][0]:
                    self.flip = self.config.get(self.system_id, self.slot, 'camera', 'mirror')
                    if self.mirror:
                        self.camera.set_info('Camera.Param.[0]', {'PictureMirror' : '0x00000001'})
                    else:
                        self.camera.set_info('Camera.Param.[0]', {'PictureMirror' : '0x00000000'})
                    print(f'[DVRIP].{self.slot}: mirror = {self.mirror}: ГОТОВО!')

                self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'AudioEnable' : False}})
                self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'Video' : { 'BitRate' : 4096}}})
                self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'Video' : { 'BitRateControl' : 'CBR'}}})
                self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'Video' : { 'Compression' : 'H.264'}}})
                self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'Video' : { 'GOP' : 10}}})
                self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'Video' : { 'Quality' : 4}}})
                self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'Video' : { 'Resolution' : '1080P'}}})
                self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'Video' : { 'VirtualGOP' : 0}}})
                self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'VideoEnable' : True}})
                self.camera.set_time()
                print(f'[DVRIP].{self.slot}: Начальные настройки применены.')
            except Exception as e:
                print(f'[DVRIP].{self.slot}: ошибка отправки начальных настроек: {e}')


    def switch_system(self, new_system):
        self.system_id = new_system
        self.update_settings()

    def _check_ready(self) -> bool:
        if self.camera:
            return True
        return False

    def add_command(self, cmd: Command):
        self.commands.put(cmd)

    def _exec_command(self, cmd: Command):
        print('CMD :', cmd)
        method = getattr(self, cmd.command, None)
        if not callable(method):
            print(f"❌[DVRIP].{self.slot}: Метод {cmd.command} не найден")
            return
        if cmd.value is not None:
            method(cmd.value)
        else:
            method()

    def _update_param(self, name, value):
        pass

    def check_changes(self):
        pass

    def _sync_from_camera(self):
        pass

    def _send_change_notification(self):
        print(f'[DVRIP].{self.slot}: сигнал изменения настроек отправлен!')
        self.dvripChangeNotification.emit(self.slot)

    def get_current_params(self):
        pass

    def wait_for_command(self):
        self._running = True
        self.start()

    def stop(self):
        self._running = False
        self.commands.put(None)

    def run(self):
        print(f'[DVRIP].{self.slot}: ждем команду')
        while self._running:
            command = self.commands.get()
            if command is not None:
                print(f'[DVRIP].{self.slot}: получена команда {command}')
                self._exec_command(command)



    '''
    Simplify.Encode:
[{
'ExtraFormat': 
{'AudioEnable': False, 
'Video': 
{
'BitRate': 552, 'BitRateControl': 'VBR', 'Compression': 'H.264', 'FPS': 20, 'GOP': 2, 'Quality': 4, 'Resolution': 'HD1', 'VirtualGOP': 1}, 
'VideoEnable': False
}, 
'MainFormat': {'AudioEnable': True, 
'Video': 
{
'BitRate': 4096, 'BitRateControl': 'VBR', 'Compression': 'H.264', 'FPS': 20, 'GOP': 1, 'Quality': 1, 'Resolution': '1080P', 'VirtualGOP': 1}, 'VideoEnable': True
}
}]

Camera:
{'ClearFog': [{'enable': False, 'level': 50}], 
'DistortionCorrect': {'Lenstype': 0, 'Version': 0}, 
'FishLensParam': [{'CenterOffsetX': 500, 'CenterOffsetY': 360, 'ImageHeight': 720, 'ImageWidth': 1280, 'LensType': 0, 'PCMac': '000000000000', 'Radius': 300, 'Version': 0, 'ViewAngle': 0, 'ViewMode': 0, 'Zoom': 100}], 
'Param': [
{'AeSensitivity': 5, 
'ApertureMode': '0x00000001', 
'BLCMode': '0x00000001', 
'DayNightColor': '0x00000000',  №№
'Day_nfLevel': 0,  
'DncThr': 30, 
'ElecLevel': 50, 
'EsShutter': '0x00000006', 
'ExposureParam': {'LeastTime': '0x00000064', 'Level': 0, 'MostTime': '0x00013880'}, 
'GainParam': {'AutoGain': 1, 'Gain': 50}
'IRCUTMode': 1, 
'InfraredSwap': 0, 
'IrcutSwap': 1, 
'Night_nfLevel': 3, 
'PictureFlip': '0x00000001', 
''' #
'''
'PictureMirror': '0x00000001', 
'RejectFlicker': '0x00000000', 
'WhiteBalance': '0x00000001'}
], 
'ParamEx': [
{'AeMeansure': 0, 
'AutomaticAdjustment': 3, 
'BroadTrends': {'AutoGain': 0, 'Gain': 50}, 
'CorridorMode': 0, 
'Dis': 0, 
'ExposureTime': '0x00000100', 
'Ldc': 0, 
'LightRestrainLevel': 0, 
'LowLuxMode': 1, 
'PreventOverExpo': 0, 
'SoftPhotosensitivecontrol': 0, 
'Style': 'type1'}
], 
'WhiteLight': 
{'Brightness': 50, 
'MoveTrigLight': {'Duration': 60, 'Level': 1}, 
'WorkMode': 'Auto', 
'WorkPeriod': {'EHour': 6, 'EMinute': 0, 'Enable': 1, 'SHour': 18, 'SMinute': 0}}}

    '''