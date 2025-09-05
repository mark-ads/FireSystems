import sys
import faulthandler
faulthandler.enable()
from app import create_app
from PyQt5.QtWidgets import QApplication


def main():
    app = QApplication(sys.argv)
    engine = create_app(app)
    sys.exit(app.exec_())

if __name__ == '__main__':
    main()