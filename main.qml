import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 1.5
import QtQuick.Extras 1.4
import QtQuick.Layouts 1.3

Window {
    id: window
    visible: true
    width: 1024
    height: 600
    title: qsTr("TS-7990 Balloon Demo")

    Connections {
        target: Imx6

        onTemperatureUpdate: {
            currentTemperatureText.text = currentTemperature
        }

        onPercentFilledUpdate: {
            percentFillGuage.value = currentPercentFilled
        }

        onCalibrateEvent: {
            percentFillGuage.value = 0
        }

        onInflatingEvent: {
            deflateButton.enabled = false
            timer1.running = true
            timerStop.running = true
        }

        onDeflatingEvent: {
            inflateButton.enabled = false
            timer1.running = true
            timerStop.running = true
        }

        onHoldingEvent: {
            inflateButton.enabled = true
            inflateButton.checked = false
            deflateButton.enabled = true
            deflateButton.checked = false
            timer1.running = false
            timerStop.running = false
        }

        onBalloonPopWarningEvent: {
            // For flashing light, use:
            // statusIndicator.active = !statusIndicator.active;
            statusIndicator.active = true;
        }

        onBalloonNormalEvent: {
            statusIndicator.active = false
        }
    }


    Timer {
        id: timer
        interval: 1000
        repeat: true
        running: true

        onTriggered:
        {
            Imx6.getCurrentTemperature()
        }
    }

    Timer {
        id: timer100
        interval: 100
        repeat: true
        running: true

        onTriggered:
        {
            Imx6.getCurrentPercentFilled()
        }
    }

    Timer {
        id: timer1
        interval: 1
        repeat: true
        running: false

        onTriggered:
        {
            Imx6.updatePumpVacTime()
        }
    }

    Timer {
        id: timerStop
        interval: 20000
        repeat: true
        running: false

        onTriggered:
        {
            Imx6.hold()
        }
    }

    Column {
        id: column
        width: 512
        height: 600
        smooth: false
        visible: true
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0

        CircularGauge {
            id: percentFillGuage
            anchors.top: parent.top
            anchors.topMargin: 100
            anchors.horizontalCenter: parent.horizontalCenter
            value: 0
            stepSize: 0
            maximumValue: 100
        }

        Button {
            id: calibrateButton
            width: 100
            text: qsTr("Calibrate")
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 50
            onClicked: {
                Imx6.calibrate();
            }
        }

        Label {
            id: percentFillLabel
            color: "#898989"
            text: qsTr("% Fill")
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: percentFillGuage.bottom
            anchors.topMargin: -25
            font.pixelSize: 18
        }

        StatusIndicator {
            id: statusIndicator
            active: false
            anchors.top: percentFillGuage.bottom
            anchors.topMargin: 25
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Row {
            id: row
            width: 120
            height: 20
            smooth: false
            anchors.top: calibrateButton.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter

            Label {
                id: currentTemperatureLabel
                height: 21
                text: qsTr("CPU Temp:")
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 12
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: currentTemperatureText
                text: qsTr("--")
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 12
            }
        }

    }


    Column {
        id: column1
        x: -9
        width: 512
        height: 600
        enabled: true
        smooth: false
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0

        Button {
            id: inflateButton
            width: 200
            height: 150
            text: qsTr("Inflate")
            antialiasing: false
            smooth: false
            enabled: true
            anchors.verticalCenterOffset: -100
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            isDefault: false
            checkable: true

            onClicked:
            {
                Imx6.toggleInflate()
            }
        }

        Button {
            id: deflateButton
            width: 200
            height: 150
            text: qsTr("Deflate")
            opacity: 0.8
            antialiasing: true
            smooth: true
            enabled: true
            anchors.verticalCenterOffset: 100
            anchors.horizontalCenterOffset: 0
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            isDefault: false
            checkable: true

            onClicked:
            {
                Imx6.toggleDeflate()
            }
        }
    }


}
