from PyQt5.QtCore import QObject, pyqtSlot, pyqtSignal
from typing import Literal
from config import Config
from .dicts import errors, mods, limit_switch, temperatures, pressures

class Backend(QObject):
    '''
    Класс для получения и обработки строк принятых в Receiver.
    
    Принимает строку, парсит и обрабатывает результат.
    '''

    firstSignal = pyqtSignal(str)

    def __init__(self, config: Config, system_id: str, slot: Literal['front', 'back']):
        super().__init__()
        if slot not in ('front', 'back'):
            raise ValueError(f"Не правильный ключ: {slot}")
        if not isinstance(config, Config):
            raise TypeError(f"config не является объектом класса Config")
        self.config = config
        self.system_id = system_id
        self.slot = slot
        self.ip = ''
        self.update_settings()
        self.zond_status = None
        self.limit_switch_status = None #  статус концевого
        #print(f'{self.system_id}.{self.position} создан. ip = {self.ip}')

    def update_settings(self):
        self.ip = self.config.get(self.system_id, self.slot, 'arduino', 'ip')
        #print(f'Настройки {self.system_id}.{self.position} изменены. Новое значение {self.ip}')

    @pyqtSlot()
    def on_config_updated(self):
        self.update_settings()

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
            print(mods[mod]) #  сделать реакцию на смену статуса

    def _process_mod_errors(self, data: str) -> None:
        '''Обработка блока ошибок'''
        data = data.split(',')
        for i, bit in enumerate(data):
            if bit == '1':
                print(f'{errors[i]}') #  сделать реакцию на ошибки

    def _process_limit_switch(self, data: str) -> None:
        '''Обаботка концевого бита (зонд запаркован или в топке)'''
        data = int(data)
        if data != self.limit_switch_status:
            self.limit_switch_status = data
            print(limit_switch[data]) #  сделать реакцию на смену концевого

    def _process_mod_temperatures(self, data: str) -> None:
        '''Обработка блока с температурами'''
        data = data.split(',')
        for i, temp in enumerate(data):
            print(temperatures[i] + ' = ' + temp + '°C') #  сделать реакцию на температуры

    def _process_mod_angle(self, data: str) -> None:
        '''Обработка данных об угле поворота зонда'''
        print(f'Угол поворота зонда: {data}')

    def _process_mod_pressures(self, data: str) -> None:
        '''Обработка данных о давлениях в системе'''
        data = data.split(',')
        for i, press in enumerate(data):
            print(f'{pressures[i]} = {press}кгс/см2') #  сделать реакцию на давление

    def _process_mod_arduino_temp(self, data: str) -> None:
        '''Обработка температуры микроконтроллера'''
        print(f'Температура платы микроконтроллера = {data}°C') #  сделать реакцию на температуру МК

    def _process_mod_worktime(self, data: str) -> None:
        data = data.strip()
        print(f'Зонд в сети уже {data} секунд.')


'''  MOD:0|0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0|0|31.46,30.82,30.88,31.01|0|10.96,11.09|31.13|171\r\n '''