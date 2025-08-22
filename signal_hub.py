from typing import Dict, List, Literal
from viewmodels.viewmodel import Viewmodel
from PyQt5.QtCore import QObject, pyqtSignal

class SignalHub(QObject):
    '''
    Класс для фильтрации данных от backend'ов и передачи их в UdpVM.
    '''
    forwardModMessage = pyqtSignal(str, dict)
    def __init__(self, vm: Viewmodel):
        super().__init__()
        self.vm = vm.udp
        self.current_system = 'system_1'
        self.forwardModMessage.connect(self.vm.update_mod_params)

    def forward_to_vm(self, system: Literal['system_1', 'system_2', 'system_3', 'system_4'], slot: Literal['front', 'back'], data: Dict):
        if system == self.current_system:
            self.forwardModMessage.emit(slot, data)
