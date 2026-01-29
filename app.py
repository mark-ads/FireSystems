import sys

from PyQt5.QtCore import QObject, QUrl
from PyQt5.QtGui import QIcon
from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtWidgets import QApplication

from camera.vlc import VlcPlayer, VlcQtRegistrator
from config import Config
from controls.dvrip_controller import DvripController
from controls.onvif_controller import OnvifController
from controls.udp_controller import UdpController
from logs import MultiLogger
from viewmodels.viewmodel import Viewmodel
from zond.sender import UdpSender
from zond.signal_hub import SignalHub
from zond.systems_controller import SystemsController


class App(QApplication):
    """Класс для создания приложения и хранения движка в рантайме."""

    engine: QQmlApplicationEngine

    def __init__(self, argv):
        super().__init__(argv)
        self.engine = create_app(self)


def create_app(app: QApplication) -> QQmlApplicationEngine:
    """
    Создать приложение, вернуть движок.

    Сначала инициализируются все объекты и потоки.
    Создается движок и контекст. Возвращается QQmlApplicationEngine.
    """
    config = Config()
    logger = MultiLogger(config)
    config.add_logger(logger)
    vlc_registrator = VlcQtRegistrator(logger)
    vlc_registrator.register_vlc_qt()  # добавляем VLC в приложение
    sender = UdpSender(config, logger)  # класс с сокетом для отправки команд
    onvif_front = OnvifController(config, logger, "front")  # По потоку на
    onvif_back = OnvifController(config, logger, "back")  # каждый протокол
    dvrip_front = DvripController(config, logger, "front")
    dvrip_back = DvripController(config, logger, "back")
    udp_front = UdpController(config, logger, sender, "front")
    udp_back = UdpController(config, logger, sender, "back")
    front_player = VlcPlayer(config, logger, "front")
    back_player = VlcPlayer(config, logger, "back")

    viewmodel = Viewmodel(
        config,
        onvif_front,
        onvif_back,
        dvrip_front,
        dvrip_back,
        udp_front,
        udp_back,
        front_player,
        back_player,
    )

    hub = SignalHub(viewmodel)  # класс распределения сигналов от зондов
    controller = SystemsController(config, logger, hub)

    viewmodel.switchSystems.connect(front_player.switch_systems)
    viewmodel.switchSystems.connect(back_player.switch_systems)
    viewmodel.switchSystems.connect(hub.switch_system)
    viewmodel.switchSystems.connect(controller.switch_system)

    if config.get_sys_settings_bool("test_mode"):
        viewmodel.switchSystems.connect(sender.update_mock)

    engine = QQmlApplicationEngine()
    front_player.setParent(engine)  # добавляем объекты в дерево qt
    back_player.setParent(engine)
    viewmodel.setParent(engine)
    controller.setParent(engine)

    context = engine.rootContext()  # добавляем контекст объектов в qml
    context.setContextProperty("viewmodel", viewmodel)  # type: ignore
    context.setContextProperty("controller", controller)  # type: ignore

    engine.load(QUrl("design/App.qml"))
    if not engine.rootObjects():
        sys.exit(-1)
    root = engine.rootObjects()[0]

    # связываем классы управления и VlcQt
    front_player.set_player(root.findChild(QObject, "frontPlayer"))
    back_player.set_player(root.findChild(QObject, "backPlayer"))

    app.setWindowIcon(QIcon("design/images/icoo.ico"))

    return engine

