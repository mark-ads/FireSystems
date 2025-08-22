from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtCore import QUrl
from PyQt5.QtGui import QIcon
from config import Config
from logs import MultiLogger
from zond.backend import SignalHub
from zond.systems_controller import SystemsController
from camera.camera_stream import VideoStream
from camera.image_provider import CameraImageProvider
from controls.onvif_controller import OnvifController
from controls.dvrip_controller import DvripController
from controls.udp_controller import UdpController
from viewmodels.viewmodel import Viewmodel

streams = []

def create_app(app):
    config = Config()
    logger = MultiLogger(config)
    config.add_logger(logger)
    '''
    print('system 1 = ' + systems_controller.system_1.id)
    print('system 2 = ' + systems_controller.system_2.name)

    print('ip ip ip = ' + config.get('system_1', 'front', 'arduino', 'ip'))
    print('ip ip ip = ' + config.get('system_2', 'back', 'camera', 'ip'))
    print('program ip = ' + config.get_sys_settings('ip'))

    '''
    onvif_front = OnvifController(config, logger, 'system_1', 'front')
    onvif_back = OnvifController(config, logger, 'system_1', 'back')
    dvrip_front = DvripController(config, logger, 'system_1', 'front')
    dvrip_back = DvripController(config, logger, 'system_1', 'back')
    udp_front = UdpController(config, logger, 'system_1', 'front')
    udp_back = UdpController(config, logger, 'system_1', 'back')
    viewmodel = Viewmodel(onvif_front, onvif_back, dvrip_front, dvrip_back, udp_front, udp_back)
    hub = SignalHub(viewmodel)
    systems_controller = SystemsController(config, logger, hub)
    globals()["viewmodel"] = viewmodel

    engine = QQmlApplicationEngine()
    image_provider = CameraImageProvider()
    engine.addImageProvider("camera", image_provider)

    global streams
    streams.append(VideoStream("rtsp://admin:@192.168.1.101:554/ch1/main/av_stream", image_provider, "front"))
    streams.append(VideoStream("rtsp://admin:@192.168.1.101:554/ch1/main/av_stream", image_provider, "back"))

    context = engine.rootContext()

    engine.rootContext().setContextProperty("viewmodel", viewmodel)
    context.setContextProperty("stream_front", streams[0])
    context.setContextProperty("stream_back", streams[1])

    engine.load(QUrl("design/App.qml"))
    if not engine.rootObjects():
        exit(-1)
    window = engine.rootObjects()[0]
    screen_geometry = app.primaryScreen().availableGeometry()
    app.setWindowIcon(QIcon("design/images/icoo.ico"))
    streams[0].start()
    streams[1].start()

    max_height = 1080
    width = 1920
    height = min(screen_geometry.height(), max_height)

    window.setWidth(width)
    window.setHeight(height)

    #window_x = screen_geometry.x() + (screen_geometry.width() - width) // 2
    #window_y = screen_geometry.y()
    #window.setPosition(window_x, window_y)


    window.show()

    '''
    context.setContextProperty('backend_front', backend_front)
    context.setContextProperty('backend_back', backend_back)
    '''

    #controller.system_1.front.handle_arduino_message('MOD:3|0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0|1|31.46,30.82,30.88,31.01|0|10.96,11.09|31.13|171\r\n')
    return engine

