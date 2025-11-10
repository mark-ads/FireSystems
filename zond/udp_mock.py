from functools import partial
from PyQt5.QtCore import QTimer, pyqtSignal, QObject, pyqtSlot
from PyQt5.QtNetwork import QUdpSocket, QHostAddress
from config import Config
import random

class UdpMocker(QObject):
    sendMockTelemetry = pyqtSignal(str)

    def __init__(self, config: Config):
        super().__init__()
        self.config = config
        self.socket = QUdpSocket(self)
        self.host = QHostAddress('127.0.0.1')
        self.socket.bind(self.host, 81)
        self.socket.readyRead.connect(self._on_ready_read_mock)
        self.telemetry_timer = QTimer(self)
        self.telemetry_timer.timeout.connect(self._send_mods_mock)
        self.ips = {}
        self.update_settings()
        self.telemetry_timer.start(500)

    @pyqtSlot()
    def update_settings(self):
        zond_pairs = self.config.settings.zond_pairs
        for system, zond in zond_pairs.items():
            ip = str(zond.front.arduino.ip)
            if ip not in self.ips:
                self.ips[ip] = {'MOD' : 0, "angle" : 0, 'dir' : 0}
            ip = str(zond.back.arduino.ip)
            if ip not in self.ips:
                self.ips[ip] = {'MOD' : 0, "angle" : 0, 'dir' : 0}

    def _send_mock(self, data, ip):
        data = f'{data}*{ip}'.encode()
        self.socket.writeDatagram(data, self.host, 80)

    def _send_mods_mock(self):
        for ip in self.ips:
            message = self._form_mods_mock(ip)
            data = f'{message}*{ip}'.encode()
            self.socket.writeDatagram(data, self.host, 80)


    def _form_mods_mock(self, ip: str) -> str:
        air_temp = round(random.uniform(35, 37), 2)
        water_temp = round(random.uniform(24, 26), 2)
        water_out = round(random.uniform(29, 31), 2)
        wp_temp = round(random.uniform(53, 55), 2)
        water_press = round(random.uniform(3, 4), 2)
        air_press = round(random.uniform(3, 4), 2)
        mod = self.ips[ip]['MOD']
        end = 1 if mod == 3 else 0
        angle = self.ips[ip]['angle']
        message = f'MOD:{mod}|0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0|{end}|{air_temp},{water_temp},{water_out},{wp_temp}|{angle}|{water_press},{air_press}|51.11|0'
        return message

    def _on_ready_read_mock(self):
        while self.socket.hasPendingDatagrams():
            datagram, host, port = self.socket.readDatagram(self.socket.pendingDatagramSize())
            data = datagram.decode("utf-8", errors="ignore")
            ip = data.split('*')[0]
            cmd = data.split('*')[1]

            if ip not in self.ips:
                return

            if cmd == 'startZ':
                self._set_mods_on(ip)

            elif cmd == 'stopZ':
                self.ips[ip]['MOD'] = 5

            elif cmd == 'resetZ':
                self.ips[ip]['MOD'] = 0

            elif cmd.startswith('r_'):
                cmd = cmd.split('_')
                if cmd[2] == 'r':
                    self.ips[ip]['angle'] += int(cmd[1])
                else:
                    self.ips[ip]['angle'] -= int(cmd[1])

                if self.ips[ip]['angle'] >= 360 or self.ips[ip]['angle'] < 0:
                    self.ips[ip]['angle'] = 0

            elif cmd.startswith('MKsetIP'):
                new_ip = cmd.split('_')[1]
                data = new_ip.replace('.', '')
                msg = f'IP_changed-{data}'
                self._send_mock(msg, new_ip)
                self.ips[new_ip] = self.ips[ip]
                del(self.ips[ip])

            elif cmd.startswith('PCsetIP'):
                new_ip = cmd.split('_')[1]
                data = new_ip.replace('.', '')
                msg = f'PC_IP_changed-{data}'
                self._send_mock(msg, ip)

            elif cmd.startswith('Apressure'):
                data = cmd.split('_')[1]
                msg = f'OK_P1_0_{data}'
                self._send_mock(msg, ip)

            elif cmd.startswith('Bpressure'):
                data = cmd.split('_')[1]
                msg = f'OK_P2_0_{data}'
                self._send_mock(msg, ip)

            elif cmd.startswith('Atemp'):
                data = cmd.split('_')[1]
                msg = f'OK_T1_0_{data}'
                self._send_mock(msg, ip)

            elif cmd.startswith('Btemp'):
                data = cmd.split('_')[1]
                msg = f'OK_T2_0_{data}'
                self._send_mock(msg, ip)

            elif cmd.startswith('Ctemp'):
                data = cmd.split('_')[1]
                msg = f'OK_T3_0_{data}'
                self._send_mock(msg, ip)

            elif cmd.startswith('Dtemp'):
                data = cmd.split('_')[1]
                msg = f'OK_T4_0_{data}'
                self._send_mock(msg, ip)

            elif cmd == 'ch_motor_DIR':
                self.ips[ip]['dir'] = 1 - self.ips[ip]['dir']

                if self.ips[ip]['dir']:
                    msg = 'Right'
                else:
                    msg = 'Left'

                self._send_mock(msg, ip)

    def _set_mods_on(self, ip):
        if 'timer' not in self.ips[ip]:
            timer = QTimer(self)
            timer.setSingleShot(True)
            timer.timeout.connect(partial(self._set_mods_on, ip))
            self.ips[ip]['timer'] = timer

        mod = self.ips[ip]['MOD']
        if mod < 3:
            self.ips[ip]['MOD'] += 1
            self.ips[ip]['timer'].start(1600)