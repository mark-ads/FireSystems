from controls.onvif_controller import OnvifController
from controls.dvrip_controller import DvripController
from PyQt5.QtCore import QObject, pyqtSlot, pyqtProperty, pyqtSignal
from models import Command
from typing import Literal
from .onvif_vm import OnvifVM
from .dvrip_vm import DvripVM


class Viewmodel(QObject):
    '''
    Общий Viewmodel. Передаётся в QML как контекст.
    Содержит в себе все остальные VM.
    '''
    guiIsReady = pyqtSignal()

    def __init__(self, onvif_front: OnvifController, onvif_back: OnvifController, dvrip_front: DvripController, dvrip_back: DvripController):
        super().__init__()
        self._onvif = OnvifVM(onvif_front, onvif_back)
        self._dvrip = DvripVM(dvrip_front, dvrip_back)

        self.guiIsReady.connect(self._onvif.connect)
        self.guiIsReady.connect(self._dvrip.connect)

    @pyqtProperty(QObject, constant=True)
    def onvif(self):
        return self._onvif

    @pyqtProperty(QObject, constant=True)
    def dvrip(self):
        return self._dvrip

    @pyqtSlot()
    def onGuiReady(self):
        self.guiIsReady.emit()