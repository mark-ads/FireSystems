from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtCore import QObject, QUrl, Qt
from PyQt5.QtGui import QIcon
from config import Config
from logs import MultiLogger
from zond.backend import SignalHub
from zond.sender import UdpSender
from zond.systems_controller import SystemsController
from camera.vlc import VlcQtRegistrator, VlcPlayer
from controls.onvif_controller import OnvifController
from controls.dvrip_controller import DvripController
from controls.udp_controller import UdpController
from viewmodels.viewmodel import Viewmodel
import sys

def create_app(app):
    config = Config()
    logger = MultiLogger(config)
    config.add_logger(logger)
    vlc_registrator = VlcQtRegistrator(logger)
    vlc_registrator.register_vlc_qt()
    sender = UdpSender(logger)
    onvif_front = OnvifController(config, logger, 'front')
    onvif_back = OnvifController(config, logger, 'back')
    dvrip_front = DvripController(config, logger, 'front')
    dvrip_back = DvripController(config, logger, 'back')
    udp_front = UdpController(config, logger, sender, 'front')
    udp_back = UdpController(config, logger, sender, 'back')
    front_player = VlcPlayer(config, logger, 'front')
    back_player = VlcPlayer(config, logger, 'back')
    viewmodel = Viewmodel(config, onvif_front, onvif_back, dvrip_front, dvrip_back, udp_front, udp_back, front_player, back_player)
    hub = SignalHub(viewmodel)
    controller = SystemsController(config, logger, hub)
    viewmodel.switchSystems.connect(front_player.switch_systems, Qt.QueuedConnection)
    viewmodel.switchSystems.connect(back_player.switch_systems, Qt.QueuedConnection)
    viewmodel.switchSystems.connect(hub.switch_system, Qt.QueuedConnection)
    viewmodel.switchSystems.connect(controller.switch_system, Qt.QueuedConnection)
    globals()["front_player"] = front_player
    globals()["back_player"] = back_player
    globals()["viewmodel"] = viewmodel
    globals()["controller"] = controller
    engine = QQmlApplicationEngine()
    context = engine.rootContext()

    engine.rootContext().setContextProperty("viewmodel", viewmodel)
    engine.rootContext().setContextProperty("controller", controller)

    engine.load(QUrl("design/App.qml"))
    if not engine.rootObjects():
        sys.exit(-1)
    root = engine.rootObjects()[0]
    front_player.set_player(root.findChild(QObject, "frontPlayer"))
    back_player.set_player(root.findChild(QObject, "backPlayer"))
    screen_geometry = app.primaryScreen().availableGeometry()
    app.setWindowIcon(QIcon("design/images/icoo.ico"))
    
    return engine