from controls.onvif_controller import OnvifController
from controls.dvrip_controller import DvripController
from controls.udp_controller import UdpController
from PyQt5.QtCore import QObject, pyqtSlot, pyqtProperty, pyqtSignal
from models import Command
from typing import Literal
from .onvif_vm import OnvifVM
from .dvrip_vm import DvripVM
from .udp_vm import UdpVM


class Viewmodel(QObject):
    '''
    Общий Viewmodel. Передаётся в QML как контекст.
    Содержит в себе все остальные VM.
    '''
    guiIsReady = pyqtSignal()

    def __init__(self, 
                 onvif_front: OnvifController, onvif_back: OnvifController, 
                 dvrip_front: DvripController, dvrip_back: DvripController,
                 udp_front: UdpController, udp_back: UdpController):
        super().__init__()
        self._onvif = OnvifVM(onvif_front, onvif_back)
        self._dvrip = DvripVM(dvrip_front, dvrip_back)
        self._udp = UdpVM(udp_front, udp_back)

        self.guiIsReady.connect(self._onvif.connect)
        self.guiIsReady.connect(self._dvrip.connect)
        self.guiIsReady.connect(self._udp.send_params_to_gui)

    @pyqtProperty(QObject, constant=True)
    def onvif(self):
        return self._onvif

    @pyqtProperty(QObject, constant=True)
    def dvrip(self):
        return self._dvrip

    @pyqtProperty(QObject, constant=True)
    def udp(self):
        return self._udp

    @pyqtSlot()
    def onGuiReady(self):
        self.guiIsReady.emit()