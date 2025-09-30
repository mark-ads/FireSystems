from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtCore import QUrl
from PyQt5.QtGui import QIcon
from config import Config
from logs import MultiLogger
from zond.backend import SignalHub
from zond.sender import UdpSender
from zond.systems_controller import SystemsController
from camera.gstreamer import VideoItem
from camera.image_provider import CameraImageProvider
from controls.onvif_controller import OnvifController
from controls.dvrip_controller import DvripController
from controls.udp_controller import UdpController
from viewmodels.viewmodel import Viewmodel

def create_app(app):
    config = Config()
    logger = MultiLogger(config)
    config.add_logger(logger)
    sender = UdpSender()
    image_provider = CameraImageProvider()
    onvif_front = OnvifController(config, logger, 'front')
    onvif_back = OnvifController(config, logger, 'back')
    dvrip_front = DvripController(config, logger, 'front')
    dvrip_back = DvripController(config, logger, 'back')
    udp_front = UdpController(config, logger, sender, 'front')
    udp_back = UdpController(config, logger, sender, 'back')
    stream_front = VideoItem(config, logger, "front")
    stream_back = VideoItem(config, logger, "back")
    viewmodel = Viewmodel(config, onvif_front, onvif_back, dvrip_front, dvrip_back, udp_front, udp_back, stream_front, stream_back)
    hub = SignalHub(viewmodel)
    controller = SystemsController(config, logger, hub)
    viewmodel.switchSystems.connect(hub.switch_system)
    viewmodel.switchSystems.connect(stream_front.switch_system)
    viewmodel.switchSystems.connect(stream_back.switch_system)
    globals()["viewmodel"] = viewmodel
    globals()["controller"] = controller
    engine = QQmlApplicationEngine()
    context = engine.rootContext()

    engine.rootContext().setContextProperty("viewmodel", viewmodel)
    engine.rootContext().setContextProperty("controller", controller)

    engine.load(QUrl("design/App.qml"))
    if not engine.rootObjects():
        exit(-1)
    window = engine.rootObjects()[0]
    screen_geometry = app.primaryScreen().availableGeometry()
    app.setWindowIcon(QIcon("design/images/icoo.ico"))
    
    return engine