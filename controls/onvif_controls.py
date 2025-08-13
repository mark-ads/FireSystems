from queue import Queue
from PyQt5.QtCore import QThread, QTimer, pyqtSlot, pyqtSignal
from config import Config
from models import Command, Literal
from .onvif_controller import OnvifController
from .dvrip_control import DvripController

UdpExecutor = None

class OnvifControls(QThread):
    '''
    Объект для управления камерами через ONVIF.
    Содержит в себе по 2 объекта управления на каждую сторону.
    Работает в отдельном потоке, принимает команды от viewmodel.
    Команды пользователя помещает в очередь.
    '''

    onvifChanged = pyqtSignal(str)

    def __init__(self, config: Config, current_system: str):
        super().__init__()
        self.config = config
        self.current_system = current_system
        self.front = OnvifController(self.config, self.current_system, 'front')
        self.back = OnvifController(self.config, self.current_system, 'back')

        self.feedback_timer_front = QTimer(self)
        self.feedback_timer_back = QTimer(self)
        self.feedback_timer_front.timeout.connect(self._check_changes_front)
        self.feedback_timer_back.timeout.connect(self._check_changes_back)
        
        self.front.onvifChangeNotification.connect(self.forward_to_vm)
        self.back.onvifChangeNotification.connect(self.forward_to_vm)

        self.commands = Queue()
        self._running = False

    def update_settings(self):
        pass

    @pyqtSlot(Command)
    def add_command(self, cmd: Command):
        self.commands.put(cmd)
        if cmd.target == 'front':
            if self.feedback_timer_front.isActive():
                self.feedback_timer_front.stop()
            self.feedback_timer_front.start(1500)
        else:
            if self.feedback_timer_back.isActive():
                self.feedback_timer_back.stop()
            self.feedback_timer_back.start(1500)

    def process_command(self, cmd: Command):
        if cmd.target == 'front':
            executor = self.front
        else:
            executor = self.back

        if executor is None:
            print(f"❌ Нет исполнителя для: ({cmd.target})")
            return

        method = getattr(executor, cmd.command, None)
        if not callable(method):
            print(f"❌ Метод {cmd.command} не найден в {executor.__class__.__name__}")
            return
        if cmd.value is not None:
            method(cmd.value)
        else:
            method()

    @pyqtSlot(str)
    def forward_to_vm(self, slot: Literal['front', 'back']):
        self.onvifChanged.emit(slot)

    def _check_changes_front(self):
        self.forward_to_vm('front')
        self.front.check_changes()
        self.feedback_timer_front.stop()

    def _check_changes_back(self):
        self.forward_to_vm('back')
        self.back.check_changes()
        self.feedback_timer_back.stop()

    def get_front_params(self):
        return self.front.get_current_params()

    def get_back_params(self):
        return self.back.get_current_params()

    def wait_for_command(self):
        self._running = True
        self.start()

    def stop(self):
        self._running = False
        self.commands.put(None)

    def run(self):
        while self._running:
            command = self.commands.get()
            self.process_command(command)
            