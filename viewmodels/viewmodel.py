from controls.onvif_controls import OnvifControls
from PyQt5.QtCore import QObject, pyqtSlot, pyqtProperty
from models import Command
from typing import Literal
from .onvif_vm import OnvifVM


class Viewmodel(QObject):
    '''
    Общий Viewmodel. Передаётся в QML как контекст.
    Содержит в себе все остальные VM.
    '''

    def __init__(self, onvif_controls: OnvifControls):
        super().__init__()
        self._onvif = OnvifVM(onvif_controls)

    @pyqtProperty(QObject, constant=True)
    def onvif(self):
        return self._onvif

    @pyqtSlot()
    def onGuiReady(self):
        self._onvif.update_current_params('front')
        self._onvif.update_current_params('back')