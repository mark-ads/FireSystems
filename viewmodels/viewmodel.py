from PyQt5.QtQuick import QQuickItem
from camera.camera_stream import VideoStream
from camera.vlc import VlcPlayer
from config import Config
from controls.onvif_controller import OnvifController
from controls.dvrip_controller import DvripController
from controls.udp_controller import UdpController
from PyQt5.QtCore import QObject, QVariant, pyqtSlot, pyqtProperty, pyqtSignal

from .onvif_vm import OnvifVM
from .dvrip_vm import DvripVM
from .udp_vm import UdpVM


class Viewmodel(QObject):
    '''
    Общий Viewmodel. Передаётся в QML как контекст.
    Содержит в себе все остальные VM.
    '''
    switchSystems = pyqtSignal(str)
    namesUpdated = pyqtSignal()
    currentNameChanged = pyqtSignal()

    def __init__(self, config: Config,
                 onvif_front: OnvifController, onvif_back: OnvifController, 
                 dvrip_front: DvripController, dvrip_back: DvripController,
                 udp_front: UdpController, udp_back: UdpController,
                 front_player: VlcPlayer, back_player: VlcPlayer
                 ):
        super().__init__()
        self.config = config
        self.current_system = 'system_1'

        self._onvif = OnvifVM(onvif_front, onvif_back)
        self._dvrip = DvripVM(dvrip_front, dvrip_back)
        self._udp = UdpVM(udp_front, udp_back)

        self._system_names = {}
        self._current_name = None

        self._front_player = front_player
        self._back_player = back_player

        self.switchSystems.connect(self._onvif.connect)
        self.switchSystems.connect(self._dvrip.connect)
        self.switchSystems.connect(self._udp.connect)

    @pyqtProperty(QObject, constant=True)
    def onvif(self):
        return self._onvif

    @pyqtProperty(QObject, constant=True)
    def dvrip(self):
        return self._dvrip

    @pyqtProperty(QObject, constant=True)
    def udp(self):
        return self._udp

    @pyqtProperty(QObject, constant=True)
    def frontPlayer(self):
        return self._front_player

    @pyqtProperty(QObject, constant=True)
    def backPlayer(self):
        return self._back_player

    @pyqtSlot()
    def onGuiReady(self):
        self.update_system_names()
        self.choose_system(self.current_system)

    @pyqtProperty(QVariant, notify=namesUpdated)
    def systemNames(self):
        return self._system_names

    @systemNames.setter
    def systemNames(self, value):
        self._system_names = value
        self.namesUpdated.emit()

    @pyqtProperty(str, notify=currentNameChanged)
    def currentName(self):
        return self._current_name

    @currentName.setter
    def currentName(self, value):
        self._current_name = value
        self.currentNameChanged.emit()

    @pyqtSlot()
    def update_system_names(self):
        system_names = {}
        for system in self.config.systems.items():
            system_names[system[0]] = system[1].name
        print(system_names)
        self.systemNames = system_names

    @pyqtSlot(str)
    def choose_system(self, new_system: str):
        if new_system in self.systemNames:
            self.current_system = new_system
            self.currentName = self.systemNames[new_system]
            self.switchSystems.emit(new_system)

    @pyqtSlot(str)
    def rename_system(self, new_name: str):
        self.config.set(self.current_system, 'name', value=new_name)
        self.update_system_names()
        self.choose_system(self.current_system)
