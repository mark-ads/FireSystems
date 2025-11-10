import os
import sys
import ctypes
from zond.dicts import vlc_states
from PyQt5.QtCore import QObject, QMetaObject, QTimer, pyqtSlot, pyqtProperty, pyqtSignal
from config import Config
from logs import MultiLogger
from models import Slot, System

class VlcQtRegistrator:
    def __init__(self, logger: MultiLogger):
        self.logger = logger.get_logger('app')
        self.vlc_qt_path = os.path.join(os.getcwd(), "vlc")
        self.plugins_path = os.path.join(self.vlc_qt_path, "plugins")
        os.environ["PATH"] = self.vlc_qt_path + ";" + self.plugins_path + ";" + os.environ.get("PATH", "")
        self.logger.add_log('DEBUG', f'Пути VLC-Qt установлены: {self.vlc_qt_path}, plugins: {self.plugins_path}')

        self.dlls = {}

    def load_dll(self, name: str):
        path = os.path.join(self.vlc_qt_path, name)
        if not os.path.exists(path):
            self.logger.add_log('ERROR', f'DLL {name} не найдена по пути: {path}')
            return None
        try:
            lib = ctypes.CDLL(path)
            self.logger.add_log('DEBUG', f'Загружена DLL: {name}')
            self.dlls[name] = lib
            return lib
        except OSError as e:
            self.logger.add_log('ERROR', f'Не удалось загрузить DLL {name}: {e}')
            return None

    def register_vlc_qt(self):
        """Загружает все необходимые DLL и вызывает регистрацию QML-плагина"""
        required_dlls = ["libvlc.dll", "libvlccore.dll", "VlcQtCore.dll", "VlcQtWidgets.dll"]
        for dll in required_dlls:
            if not self.load_dll(dll):
                self.logger.add_log('CRITICAL', 'Ошибка загрузки основных DLL. Прекращаем.')
                sys.exit(-1)

        wrapper_path = os.path.join(self.vlc_qt_path, "vlcqtqml_wrapper.dll")
        if not os.path.exists(wrapper_path):
            self.logger.add_log('CRITICAL', f'DLL обёртки не найдена: {wrapper_path}')
            sys.exit(-1)

        vlcqt_wrapper = ctypes.CDLL(wrapper_path)
        vlcqt_wrapper.registerVlcQmlPlugin.argtypes = [ctypes.c_char_p]
        vlcqt_wrapper.registerVlcQmlPlugin.restype = None

        vlcqt_wrapper.registerVlcQmlPlugin(self.plugins_path.encode('utf-8'))
        self.logger.add_log('DEBUG', 'registerVlcQmlPlugin вызван успешно через обёртку')
        return vlcqt_wrapper

class VlcPlayer(QObject):
    '''
    VLC

    Сам плеер инициализируется в QML, затем извлекается оттуда и передаётся в этот объект для управления.
    Работает в главном потоке. После того как плеер запущен - он сам управляет видимостью виджета в GUI,
    а так же при смене состояния плеера пробует переподключиться.
    '''
    onlineChanged = pyqtSignal()

    def __init__(self, config: Config, logger: MultiLogger, slot: Slot):
        super().__init__()
        self.player = None
        self.config = config
        self.logger = logger.get_logger(f'player_{slot}')
        self.system_id = 'system_1'
        self.slot = slot
        self._online_status = False
        self.state = 0
        self.test_mode = self.config.get_sys_settings_bool('test_mode')

        self.timer = QTimer(self)
        self.timer.setInterval(7000)
        self.timer.timeout.connect(self.connect)


    @pyqtProperty(bool, notify=onlineChanged)
    def onlineStatus(self):
        return self._online_status

    @onlineStatus.setter
    def onlineStatus(self, value):
        if self._online_status != value:
            self._online_status = value
            self.onlineChanged.emit()

    def set_player(self, player: QObject):
        self.player = player
        self.player.stateChanged.connect(self.get_state)
        self.connect()
        self._start_timer()

    @pyqtSlot(str)
    def switch_systems(self, system: System):
        self.system_id = system
        self.logger.add_log("DEBUG", f"Выбрана система {system}")
        self.connect()

    def _start_timer(self):
        if not self.timer.isActive():
            self.timer.start()

    def connect(self):
        if not self.test_mode and self.player:
            try:
                QMetaObject.invokeMethod(self.player, "stop")
                self.rtsp = self.config.get_str(self.system_id, self.slot, 'camera', 'rtsp')
                self.logger.add_log("DEBUG", f"RTSP: {self.rtsp}")
                self.player.setProperty('url', self.rtsp)
                QMetaObject.invokeMethod(self.player, "play")
            except Exception as e:
                self.logger.add_log("ERROR", f"Ошибка в connect(): {e}")
                self._start_timer()

            
    def get_state(self):
        '''
        Данная функция подключена к сигналу stateChange из VlcQt.
        Получить текущий стейт от VLC. 
        Если 3 - значит видео идет, показываем картинку.
        Если 4-7 - переподключаемся.
        '''
        try:
            state = self.player.property("state")
            if self.state == state:
                return
            self.state = state
            self.logger.add_log("DEBUG", f"State = [{state}]. {vlc_states[state]}")
            if state == 3:
                self.onlineStatus = True
                self.timer.stop()
                return
            self.onlineStatus = False
            if state == 2:
                QMetaObject.invokeMethod(self.player, "play")
            elif state in [4, 5, 6, 7]:
                self._start_timer()
        except Exception as e:
            self.logger.add_log("ERROR", f"Ошибка в get_state(): {e}")
            self._start_timer()
