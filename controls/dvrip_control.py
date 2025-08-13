from .dvrip_lib import DVRIPCam
from config import Config
from typing import Literal
from time import sleep

class DvripController:
    '''
    Класс для управления параметрами камеры по протоколу DVRIP.
    '''
    def __init__(self, config: Config, system_id: str, slot: Literal['front', 'back']):
        self.config = config
        self.system_id = system_id
        self.slot = slot
        self.ip = ''
        self.login = ''
        self.password = ''
        self.camera = None
        self.update_settings()

    def update_settings(self):
        self.ip = self.config.get(self.system_id, self.slot, 'camera', 'ip')
        self.login = self.config.get(self.system_id, self.slot, 'camera', 'login')
        self.password = self.config.get(self.system_id, self.slot, 'camera', 'password')
        self.connect()

    def connect(self):
        if self.camera:
            self.camera.close()
        try:
            self.camera = DVRIPCam(self.ip, user=self.login, password=self.password)
            if self.camera.login():
                print(f'Successful login. IP: {self.ip}')
                fps = self.config.get(self.system_id, self.slot, 'camera', 'fps')
                self.encode_params = self.camera.get_info('Simplify.Encode')
                self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'AudioEnable' : False}})
                self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'Video' : { 'BitRate' : 4096}}})
                self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'Video' : { 'BitRateControl' : 'CBR'}}})
                self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'Video' : { 'Compression' : 'H.264'}}})
                self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'Video' : { 'FPS' : fps}}})
                self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'Video' : { 'GOP' : 10}}})
                self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'Video' : { 'Quality' : 4}}})
                self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'Video' : { 'Resolution' : '1080P'}}})
                self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'Video' : { 'VirtualGOP' : 0}}})
                self.camera.set_info('Simplify.Encode.[0]', { 'MainFormat' : { 'VideoEnable' : True}})
                self.camera.set_time()
                self.camera_params = self.camera.get_info('Camera')
                self.camera.set_info('Camera.Param.[0]', {'IrcutSwap' : 1})
        except Exception as e:
                print(f'Login failure. IP: {self.ip}. \n {e}')

    def switch_system(self, new_system):
        self.system_id = new_system
        self.update_settings()

    






