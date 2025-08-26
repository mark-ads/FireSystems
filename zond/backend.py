from collections import deque
from PyQt5.QtCore import QObject, pyqtSlot, pyqtSignal, QThread
from typing import Literal, Dict
from config import Config
from logs import MultiLogger
from signal_hub import SignalHub
from .dicts import errors_map, mods, limit_switch, temperature_map, pressure_map
from datetime import datetime
import random
import time


def get_time():
    return datetime.now().strftime("%H:%M:%S")

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
        self.config = config
        self.hub = hub
        self.system_id = system_id
        self.slot = slot
        self.ip = ''
        self.update_settings()
        
        self.zond_status = -1
        self.errors = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        self.limit_switch_status = 0
        self.temperatures = []
        self.angle = 0
        self.pressures = []
        self.wp_temp = 0
        self.time_online = 0


        self.avg_temps = {
            'air' : [],
            'water' : [],
            'out' : [],
            'wp' : []
        }

        self.temps_charts = {
            'air' : deque(maxlen=360),
            'water' : deque(maxlen=360),
            'out' : deque(maxlen=360),
            'wp' : deque(maxlen=360)
        }

        self.avg_press = {
            'water' : [],
            'air' : []
        }

        self.press_charts = {
            'water' : deque(maxlen=360),
            'air' : deque(maxlen=360)
        }

        self.logs = deque(maxlen=35)
        
        self.logger.add_log('INFO', f'{self.system_id}.[{self.slot}] создан. ip = {self.ip}')


    @pyqtSlot()
    def update_settings(self):
        self.ip = self.config.get_str(self.system_id, self.slot, 'arduino', 'ip')
        self.test_mode = self.config.get_sys_settings_bool('test_mode')
        self.logger.add_log('DEBUG', f'[{self.slot}] Настройки  изменены. Новое значение {self.ip}')

    def handle_arduino_message(self, data: str) -> None:
        '''Получение и перенаправление дальше строки от Ардуино'''
        if data.startswith('MOD:'):
            #self.logger.add_log('INFO', f'[{self.slot}]{data}')
            self._process_mod_message(data)
        else:
            self.logger.add_log('WARN', f'[{self.slot}] Принят пакет: {data}')

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
            self.logs.append(f'[{get_time()}] {mods[mod]}')

    def _process_mod_errors(self, data: str) -> None:
        '''Обработка блока ошибок'''
        data = data.split(',')
        for i, bit in enumerate(data):
            bit = int(bit)
            if bit != self.errors[i]:
                self.errors[i] = bit
                if bit == 1:
                    self.logger.add_log('ERROR', f'[{self.slot}] ОШИБКА зонда: {errors_map[i]}')
                    self.logs.append(f'[{get_time()}][❌ОШИБКА] {errors_map[i]}')
                else:
                    self.logger.add_log('INFO', f'[{self.slot}] ошибка сброшена: {errors_map[i]}')
                    self.logs.append(f'[{get_time()}][❌ОШИБКА] {errors_map[i]}')
                    self.logs.append(f'[{get_time()}] ошибка сброшена: {errors_map[i]}')

    def _process_limit_switch(self, data: str) -> None:
        '''Обаботка концевого бита (зонд запаркован или в топке)'''
        data = int(data)
        if data != self.limit_switch_status:
            self.limit_switch_status = data
            self.logger.add_log('INFO', f'[{self.slot}] {limit_switch[data]}')
            self.logs.append(f'[{get_time()}] {errors_map[i]}')

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
        data['logs'] = self.logs
        data['temps'] = self.temperatures
        data['angle'] = self.angle
        data['pressures'] = self.pressures
        self.hub.forward_to_vm(self.system_id, self.slot, data)
        self._proccess_for_chart()

    def _proccess_for_chart(self):
        self.avg_temps['air'].append(self.temperatures[0])
        self.avg_temps['water'].append(self.temperatures[1])
        self.avg_temps['out'].append(self.temperatures[2])
        self.avg_temps['wp'].append(self.temperatures[3])

        self.avg_press['water'].append(self.pressures[0])
        self.avg_press['air'].append(self.pressures[1])

        if len(self.avg_temps['air']) == 20:

            current_avg_air = sum(self.avg_temps['air']) / 20
            current_avg_water = sum(self.avg_temps['water']) / 20
            current_avg_out = sum(self.avg_temps['out']) / 20
            current_avg_wp = sum(self.avg_temps['wp']) / 20

            self.temps_charts['air'].append(current_avg_air)
            self.temps_charts['water'].append(current_avg_water)
            self.temps_charts['out'].append(current_avg_out)
            self.temps_charts['wp'].append(current_avg_wp)

            temp_for_gui = []
            temp_for_gui.append(current_avg_air)
            temp_for_gui.append(current_avg_water)
            temp_for_gui.append(current_avg_out)
            temp_for_gui.append(current_avg_wp)
            


            self.avg_temps['air'] = []
            self.avg_temps['water'] = []
            self.avg_temps['out'] = []
            self.avg_temps['wp'] = []

            current_avg_water = sum(self.avg_press['water']) / 20
            current_avg_air = sum(self.avg_press['air']) / 20

            self.press_charts['water'].append(current_avg_air)
            self.press_charts['air'].append(current_avg_water)
            self.avg_press['water'] = []
            self.avg_press['air'] = []

            press_for_gui = []
            press_for_gui.append(current_avg_water)
            press_for_gui.append(current_avg_air)

            try:
                self.send_air_chart(temp_for_gui)
                self.send_press_chart(press_for_gui)
                self.logger.add_log('DEBUG', f'[{self.slot}] отправлен график')
            except Exception as e:
                self.logger.add_log('ERROR', f'[{self.slot}] ОШИБКА {e}')


    def send_air_chart(self, data):
        self.hub.forward_temp_chart(self.system_id, self.slot, data)

    def send_press_chart(self, data):
        self.hub.forward_press_chart(self.system_id, self.slot, data)

    def send_history(self, temp: Dict[str, float], press: Dict[str, list]):
        self.hub.forward_history(self.system_id, self.slot, temp, press)


    @pyqtSlot()
    def init_after_gui(self):
        if self.test_mode:
            self.add_random()

    def add_random(self):
        for i in range(360):
            self.temps_charts['air'].append(round(random.uniform(25, 35), 2))
            self.temps_charts['water'].append(round(random.uniform(25, 35), 2))
            self.temps_charts['out'].append(round(random.uniform(25, 35), 2))
            self.temps_charts['wp'].append(round(random.uniform(25, 35), 2))
            self.press_charts['water'].append(round(random.uniform(11, 12), 2))
            self.press_charts['air'].append(round(random.uniform(11, 12), 2))


    @pyqtSlot()
    def send_test_left(self):
        for i in range(len(self.temps_charts['air'])):
            temp = []
            temp.append(self.temps_charts['air'][i])
            temp.append(self.temps_charts['water'][i])
            temp.append(self.temps_charts['out'][i])
            temp.append(self.temps_charts['wp'][i])
            self.send_air_chart(temp)
            press = []
            press.append(self.press_charts['water'][i])
            press.append(self.press_charts['air'][i])
            self.send_press_chart(press)

    @pyqtSlot()
    def send_test_right(self):
        temps = {}
        for key in self.temps_charts:
            temps[key] = list(self.temps_charts[key])
        press = {}
        for key in self.press_charts:
            press[key] = list(self.press_charts[key])
        self.send_history(temps, press)


'''  MOD:0|0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0|0|31.46,30.82,30.88,31.01|0|10.96,11.09|31.13|171\r\n '''

