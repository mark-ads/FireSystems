from collections import deque
from PyQt5.QtCore import QObject, pyqtSlot, pyqtSignal, QTimer
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

    updateSettings = pyqtSignal()

    def __init__(self, config: Config, logger: MultiLogger, hub: SignalHub, system_id: str, slot: Literal['front', 'back']):
        super().__init__()
        self.logger = logger
        if slot not in ('front', 'back'):
            self.logger.add_log('ERROR', f'Не правильный ключ: {slot}')
        self.config = config
        self.hub = hub
        self.system_id = system_id
        self.slot = slot
        self.test_mode = self.config.get_sys_settings_bool('test_mode')
        
        self.zond_status = -1
        self.errors = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        self.limit_switch_status = 0
        self.temperatures = [0, 0, 0, 0] 
        self.angle = 0
        self.pressures = [0, 0, 0, 0]
        self.wp_overheat = False
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
        
        self.is_online_timer = QTimer(self)
        self.is_online_timer.setSingleShot(True)
        self.is_online_timer.timeout.connect(self.set_status_offline)


        self.logger.add_log('DEBUG', f'{self.system_id}.[{self.slot}] создан.')

    @pyqtSlot()
    def init_on_gui(self):
        if self.test_mode:
            self.add_random()

    @pyqtSlot()
    def send_data(self):
        self.send_mod_data()
        self.logger.add_log('DEBUG', f'{self.system_id}.[{self.slot}] Свежие данные отправлены.')

    def handle_arduino_message(self, data: str) -> None:
        '''Получение и перенаправление дальше строки от Ардуино'''
        self.is_online_timer.start(2500)
        data = data.strip()
        self.logger.add_log('DEBUG', f'[{self.slot}]: ПАКЕТ: {data}')
        if data.startswith('MOD:'):
            self._process_mod_message(data)
        elif data.startswith('IP_changed'):
            parts = data.split('-', 1)
            right = parts[1].strip()
            ip = right.split()[0]   
            self.logs.append(f'[{get_time()}] Новый адрес контроллера: {ip}')
            self.logger.add_log('INFO', f'[{self.slot}] ({data}) Новый адрес контроллера: {ip}')
        elif data.startswith('PC_IP_changed'):
            parts = data.split('-', 1)
            right = parts[1].strip()
            ip = right.split()[0]   
            self.logs.append(f'[{get_time()}][⚠️Предупреждение] Контроллер теперь настроены на IP {ip}. Поменяйте адрес компьютера в настройках Windows.')
            self.logger.add_log('WARN', f'[{self.slot}] ({data}), новый адрес для приема команд и отправки строк: {ip}')
        elif data.startswith('OK_P1_'):
            parts = data.split('_')
            new = parts[3] 
            self.logs.append(f'[{get_time()}] Новое значение предела давления воды: {new} кг/см²')
            self.logger.add_log('INFO', f'[{self.slot}] ({data}). Новое значение предела давления воды: {new}')
        elif data.startswith('OK_P2_'):
            parts = data.split('_')
            new = parts[3] 
            self.logs.append(f'[{get_time()}] Новое значение предела давления воздуха: {new} кг/см²')
            self.logger.add_log('INFO', f'[{self.slot}] ({data}). Новое значение предела давления воздуха: {new}')
        elif data.startswith('OK_T1_'):
            parts = data.split('_')
            new = parts[3] 
            self.logs.append(f'[{get_time()}] Новое значение предела температуры воздуха: {new}°С')
            self.logger.add_log('INFO', f'[{self.slot}] ({data}). Новое значение предела температуры воздуха: {new}')
        elif data.startswith('OK_T2_'):
            parts = data.split('_')
            new = parts[3] 
            self.logs.append(f'[{get_time()}] Новое значение предела температуры воды: {new}°С')
            self.logger.add_log('INFO', f'[{self.slot}] ({data}). Новое значение предела температуры воды: {new}')
        elif data.startswith('OK_T3_'):
            parts = data.split('_')
            new = parts[3] 
            self.logs.append(f'[{get_time()}] Новое значение предела температуры сброса: {new}°С')
            self.logger.add_log('INFO', f'[{self.slot}] ({data}). Новое значение предела температуры сброса: {new}')
        elif data.startswith('OK_T4_'):
            parts = data.split('_')
            new = parts[3] 
            self.logs.append(f'[{get_time()}] Новое значение предела температуры рабочей части: {new}°С')
            self.logger.add_log('INFO', f'[{self.slot}] ({data}). Новое значение предела температуры рабочей части: {new}')
        elif data == 'Left' or data == 'Right':
            self.logger.add_log('INFO', f'[{self.slot}] ({data}). Смена направления движения к 0.')
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
                    self.logs.append(f'[{get_time()}] ошибка сброшена: {errors_map[i]}')

    def _process_limit_switch(self, data: str) -> None:
        '''Обаботка концевого бита (зонд запаркован или в топке)'''
        data = int(data)
        if data != self.limit_switch_status:
            self.limit_switch_status = data
            self.logger.add_log('INFO', f'[{self.slot}] {limit_switch[data]}')
            self.logs.append(f'[{get_time()}] {limit_switch[data]}')

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
        data = float(data)
        if data >= 65.0 and not self.wp_overheat:
            self.logger.add_log('INFO', f'[{self.slot}][⚠️Предупреждение] Температура контроллера выше 65°С.')
            self.logs.append(f'[{get_time()}][⚠️Предупреждение] Температура контроллера выше 65°С.')
            self.wp_overheat = True
        elif data < 60.0 and self.wp_overheat:
            self.logger.add_log('INFO', f'[{self.slot}] Температура контроллера остыла ниже 60°С.')
            self.logs.append(f'[{get_time()}] Температура контроллера остыла ниже 60°С.')            
            self.wp_overheat = False

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
        data['limit_switch'] = self.limit_switch_status
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

    def add_random(self):
        for i in range(360):
            self.temps_charts['air'].append(round(random.uniform(25, 35), 2))
            self.temps_charts['water'].append(round(random.uniform(25, 35), 2))
            self.temps_charts['out'].append(round(random.uniform(25, 35), 2))
            self.temps_charts['wp'].append(round(random.uniform(25, 35), 2))
            self.press_charts['water'].append(round(random.uniform(11, 12), 2))
            self.press_charts['air'].append(round(random.uniform(11, 12), 2))

    @pyqtSlot()
    def send_history(self):
        if len(self.temps_charts['air']) == 0:
            return
        temps = {}
        for key in self.temps_charts:
            temps[key] = list(self.temps_charts[key])
        press = {}
        for key in self.press_charts:
            press[key] = list(self.press_charts[key])
        self.hub.forward_history(self.system_id, self.slot, temps, press)

    def set_status_offline(self):
        self.is_online_timer.stop()
        self.zond_status = -1
        self.send_mod_data()
        self.logger.add_log('INFO', f'[{self.slot}] status = offline')
        self.logs.append(f'[{get_time()}] Зонд не в сети')


'''  MOD:0|0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0|0|31.46,30.82,30.88,31.01|0|10.96,11.09|31.13|171\r\n '''

