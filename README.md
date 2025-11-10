# FireSystems

## Краткое описание проекта

Приложение нужно для подключения к зондам, состоящих из Ардуино и айпикамер, и мониторинга горения внутри промышленных котлов. 
К каждому котлу подключено по два зонда, с передней и задней стороны. Ардуино управляет сервоприводами, заслонками и т.д., а камера погружается внутрь котла. Приложение одновременно подключается к двум зондам одного котла, но поддерживает одновременное подключение до четырёх котлов.

## Интерфейс приложения
<p align="center">
  <img src="https://raw.githubusercontent.com/mark-ads/Firesystems/refs/heads/master/screenshots/SystemScreen.png" width="24%" />
  <img src="https://raw.githubusercontent.com/mark-ads/Firesystems/refs/heads/master/screenshots/TechScreen.png" width="24%" />
  <img src="https://raw.githubusercontent.com/mark-ads/Firesystems/refs/heads/master/screenshots/SettingsScreen.png" width="24%" />
  <img src="https://raw.githubusercontent.com/mark-ads/Firesystems/refs/heads/master/screenshots/NavPanelScreen.png" width="24%" />
</p>

Интерфейс разрабатывался под разрешение 1920×1080.

## Ключевые технологии

 - Python 3.12
 - PyQt5
 - VLC
 - VLC-Qt
 - Pydantic
 - DVRip
 - ONVIF

## Сборка

Приложение рассчитано для Windows x64.

1. Установите Python 3.12 или более новую версию.

2. Скачайте VLC и скопируйте в папку vlc/ следующие файлы:
 - libvlc.dll
 - libvlccore.dll
 - папку plugins/

3. Установите зависимости: "pip install -r requirements.txt".

4. При необходимости измените параметры в `settings.yaml`:
 - test_mode: true - запускает приложение в тестовом режиме, для работы без оборудования. 
 - log_level: INFO - уровень логгирования (DEBUG, WARN, ERROR, CRITICAL) .
 - console_on: true - вывод логов в консоль.

5. Запустите приложение: "python main.py".

Готовое к работе приложение доступно в Releases.


## Описание проекта

Сделано по паттерну MVVM.
GUI приложения сделан на QML. Фреймворк PyQt-5.

Основные компоненты приложения:

 - Config — потокобезопасный объект, загружает настройки из `settings.yaml`. Используется другими компонентами для получения и сохранения настроек.

 - MultiLogger / SingleLogger — система логирования с ротацией. Каждый компонент создаёт собственный логгер через фабрику MultiLogger. Настройки уровня логирования и вывода в консоль задаются в `settings.yaml`.

 - Backend — экземпляр для каждого сохраненного адреса Arduino. Получает телеметрию от Receiver, сохраняет историю значений и передаёт данные в SignalHub (статус зонда, данные показателей, графики и т.д.), для дальнейшей отправки в GUI.

 - SignalHub — маршрутизатор данных от всех Backend. Пересылает во ViewModel только данные от выбранного котла.

 - Receiver — принимает UDP-пакеты на локальном IP (порт 80), фильтрует по IP и направляет в нужный Backend.

 - SystemsController / SystemFactory — управляют созданием Backend и Receiver, работают в отдельном потоке для предотвращения потери UDP-пакетов.

 - UdpController (front/back) — принимает команды из ViewModel и отправляет их через Sender на Arduino.

 - Sender — отправляет UDP-команды. В тестовом режиме создаёт мок-объект для имитации работы.

 - OnvifController (front/back) — потоки для управления камерами по протоколу ONVIF. Работают в собственных потоках для предотвращения блокировок, синхронизируют настройки с Config, поддерживают очередь команд от ViewModel, отправляют команды на камеры.

 - DvripController (front/back) — аналогично Onvif, но для DVRIP-протокола.

 - ViewModel — мост между QML и Python. Получает данные от контроллеров, передаёт сигналы и параметры интерфейсу и обратно.

 - VLC — воспроизводит видеопотоки на GPU. Встраивается в QML с помощью VLC-Qt. Управление реализовано через ctypes и обёртку `vlcqtqmlwrapper.dll`.


## Обработка видеопотоков

Самая сложная часть приложения, так как нужно было перевести обработку видео с ЦПУ на ГПУ. 

Были протестированы:

 - ffmpeg — не удалось добиться GPU-ускорения;

 - OpenCV — работает только на CPU;

 - GStreamer — производителен, но декодирует H.264/H.265 только через d3d11/d3d12, несовместимые с QML.

В итоге был выбран VLC и библиотека VLC-Qt. Была реализована собственная обертка на Python для управления VLC через ctypes.


## Лицензия

FireSystems распространяется под лицензией GPL v3.  

Автор проекта: [Mark Ads](https://github.com/mark-ads)

FireSystems использует следующие сторонние библиотеки:

- PyQt5 (GPL v3) — https://www.riverbankcomputing.com/software/pyqt/
- PyQtChart-Qt5 (GPL v3) — https://www.riverbankcomputing.com/software/pyqtchart/
- VLC-Qt 1.1 (GPL v3) — https://vlc-qt.tano.si/reference/1.1/
- VLC (GPL v2+) — https://www.videolan.org/vlc/
- onvif_zeep (MIT) — https://pypi.org/project/onvif-zeep/
- pydantic (MIT) — https://pypi.org/project/pydantic/
- ruamel.yaml (MIT) — https://pypi.org/project/ruamel.yaml/

- файл `dvrip.py` из проекта [OpenIPC/python-dvr](https://github.com/OpenIPC/python-dvr), лицензия MIT.
В проекте FireSystems он используется в модифицированном виде как `dvrip_lib.py`.


Дополнительные транзитивные зависимости, которые устанавливаются автоматически вместе с указанными библиотеками, имеют лицензии, совместимые с MIT и GPL.
