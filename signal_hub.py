from typing import Dict, List, Literal
from models import Slot, System
from viewmodels.viewmodel import Viewmodel
from PyQt5.QtCore import QObject, Qt, pyqtSignal, QThread, pyqtSlot

class SignalHub(QObject):
    '''
    Класс для фильтрации данных от backend'ов и передачи их в UdpVM.
    '''
    forwardModMessage = pyqtSignal(str, dict)
    forwardTempChart = pyqtSignal(str, list)
    forwardPressChart = pyqtSignal(str, list)
    forwardTempHistory = pyqtSignal(str, dict)
    forwardPressHistory = pyqtSignal(str, dict)

    def __init__(self, vm: Viewmodel):
        super().__init__()
        self.vm = vm.udp
        self.current_system = 'system_1'
        self.forwardModMessage.connect(self.vm.update_mod_params, Qt.QueuedConnection)
        self.forwardTempChart.connect(self.vm.update_temp_chart, Qt.QueuedConnection)
        self.forwardPressChart.connect(self.vm.update_press_chart, Qt.QueuedConnection)
        self.forwardTempHistory.connect(self.vm.update_temp_history, Qt.QueuedConnection)
        self.forwardPressHistory.connect(self.vm.update_press_history, Qt.QueuedConnection)

    @pyqtSlot(str)
    def switch_system(self, system: System):
        self.current_system = system
        print(f'[SIGNAL_HUB] Выбрана новая система: {system}')

    def forward_to_vm(self, system: System, slot: Slot, data: dict):
        if system == self.current_system:
            self.forwardModMessage.emit(slot, data)

    def forward_temp_chart(self, system: System, slot: Slot, data: List):
        if system == self.current_system:
            self.forwardTempChart.emit(slot, data)

    def forward_press_chart(self, system: System, slot: Slot, data: list):
        if system == self.current_system:
            self.forwardPressChart.emit(slot, data)

    def forward_history(self, system, slot, temp_list: Dict[str, list], press_list: Dict[str, list]):
        '''
        Функция для вычисления среднего значения показателей истории за 30 секунд и передачи их в GUI.
        Нужна для того, чтобы не перегружать основной поток отрисовкой графиков при загрузке истории.
        '''
        if system == self.current_system:
            temp = {'air' : [], 'water' : [], 'out' : [], 'wp' : []}
            press = {'water' : [], 'air' : []}
            air_temp_avg = []
            water_temp_avg = []
            out_temp_avg = []
            wp_temp_avg = []
            water_press_avg = []
            air_press_avg = []
            for i in range(len(temp_list['air'])):
                air_temp_avg.append(temp_list['air'][i])
                water_temp_avg.append(temp_list['water'][i])
                out_temp_avg.append(temp_list['out'][i])
                wp_temp_avg.append(temp_list['wp'][i])
                water_press_avg.append(press_list['water'][i])
                air_press_avg.append(press_list['air'][i])

                if i % 3 == 0:
                    air_temp = sum(air_temp_avg) / len(air_temp_avg)
                    water_temp = sum(water_temp_avg) / len(water_temp_avg)
                    out_temp = sum(out_temp_avg) / len(out_temp_avg)
                    wp_temp = sum(wp_temp_avg) / len(wp_temp_avg)
                    water_press = sum(water_press_avg) / len(water_press_avg)
                    air_press = sum(air_press_avg) / len(air_press_avg)
                    temp['air'].append({'x': i, 'y': air_temp})
                    temp['water'].append({'x': i, 'y': water_temp})
                    temp['out'].append({'x': i, 'y': out_temp})
                    temp['wp'].append({'x': i, 'y': wp_temp})
                    press['water'].append({'x': i, 'y': water_press})
                    press['air'].append({'x': i, 'y': air_press})
                    air_temp_avg = []
                    water_temp_avg = []
                    out_temp_avg = []
                    wp_temp_avg = []
                    water_press_avg = []
                    air_press_avg = []
            self.forwardTempHistory.emit(slot, temp)
            self.forwardPressHistory.emit(slot, press)