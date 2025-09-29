import QtQuick 6.5
import QtQuick.Window 6.5
import Custom 1.0

Window {
    visible: true
    width: 1280
    height: 720
    title: "RTSP Video"

    VideoItem {
        anchors.fill: parent
        rtsp_url: "rtsp://192.168.1.101:554/user=admin_password=tlJwpbo6_channel=1_stream=0.sdp?real_stream"
    }
}
