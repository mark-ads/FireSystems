from PyQt5.QtCore import QObject, pyqtSlot, pyqtSignal
from typing import Literal
from config import Config
from logs import MultiLogger
from signal_hub import SignalHub
from .dicts import errors_map, mods, limit_switch, temperature_map, pressure_map

class Backend(QObject):
    '''
    Класс для получения и обработки строк принятых в Receiver.
    
    Принимает строку, парсит и обрабатывает результат.
    '''

    firstSignal = pyqtSignal(str)

    def __init__(self, config: Config, logger: MultiLogger, hub: SignalHub, system_id: str, slot: Literal['front', 'back']):
        super().__init__()
        self.logger = logger
        if slot not in ('front', 'back'):
            self.logger.add_log('ERROR', f'Не правильный ключ: {slot}')
        if not isinstance(config, Config):
            self.logger.add_log('ERROR', f'config не является объектом класса Config')
        self.config = config
        self.hub = hub
        self.system_id = system_id
        self.slot = slot
        self.ip = ''
        self.update_settings()
        
        self.zond_status = -1
        self.errors = []
        self.limit_switch_status = 0
        self.temperatures = []
        self.angle = 0
        self.pressures = []
        self.wp_temp = 0
        self.time_online = 0
        
        self.logger.add_log('INFO', f'{self.system_id}.[{self.slot}] создан. ip = {self.ip}')

    @pyqtSlot()
    def update_settings(self):
        self.ip = self.config.get_str(self.system_id, self.slot, 'arduino', 'ip')
        self.logger.add_log('DEBUG', f'[{self.slot}] Настройки  изменены. Новое значение {self.ip}')

    def handle_arduino_message(self, data: str) -> None:
        '''Получение и перенаправление дальше строки от Ардуино'''
        if data.startswith('MOD:'):
            self._process_mod_message(data)

    def _process_mod_message(self, data: str) -> None:
        '''Обработка обычного сообщения от Ардуино'''
        data = data.split('|')
        self._process_mod_status(data[0])
        self._process_mod_errors(data[1])
        self._process_limit_switch(data[2])
        self._process_mod_temperatures(data[3])
        self._process_mod_angle(data[4])
        self._process_mod_pressures(data[5])
        self._process_mod_arduino_temp(data[6])
        self._process_mod_worktime(data[7])

    def _process_mod_status(self, data: str) -> None:
        '''Обработка статуса зонда (MOD:x)'''
        mod = int(data.split(':')[1])
        if mod != self.zond_status:
            self.zond_status = mod
            self.logger.add_log('INFO', f'[{self.slot}] MOD: {str(mod)}, статус: {mods[mod]}')
            

    def _process_mod_errors(self, data: str) -> None:
        '''Обработка блока ошибок'''
        data = data.split(',')
        errors = []
        for i, bit in enumerate(data):
            if bit == '1':
                errors.appernd(f'{errors_map[i]}')
        self.errors = errors

    def _process_limit_switch(self, data: str) -> None:
        '''Обаботка концевого бита (зонд запаркован или в топке)'''
        data = int(data)
        if data != self.limit_switch_status:
            self.limit_switch_status = data
            print(limit_switch[data])

    def _process_mod_temperatures(self, data: str) -> None:
        '''Обработка блока с температурами'''
        data = data.split(',')
        temps = []
        for temp in data:
            temps.append(float(temp))
        self.temperatures = temps

    def _process_mod_angle(self, data: str) -> None:
        '''Обработка данных об угле поворота зонда'''
        self.angle = int(data)

    def _process_mod_pressures(self, data: str) -> None:
        '''Обработка данных о давлениях в системе'''
        data = data.split(',')
        pressures = []
        for press in data:
            pressures.append(float(press))
        self.pressures = pressures

    def _process_mod_arduino_temp(self, data: str) -> None:
        '''Обработка температуры микроконтроллера'''
        self.wp_temp = float(data)

    def _process_mod_worktime(self, data: str) -> None:
        data = data.strip()
        self.time_online = int(data)
        self.send_mod_data()

    def send_mod_data(self):
        data = {}
        data['status'] = self.zond_status
        data['errors'] = self.errors
        data['limit_switch'] = self.limit_switch_status
        data['temps'] = self.temperatures
        data['angle'] = self.angle
        data['pressures'] = self.pressures
        data['wp_temp'] = self.wp_temp
        data['time'] = self.time_online
        self.hub.forward_to_vm(self.system_id, self.slot, data)

'''  MOD:0|0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0|0|31.46,30.82,30.88,31.01|0|10.96,11.09|31.13|171\r\n '''