import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

Window {
    id: root
    visible: true
    color: "#4a5fa5"
    width: 1024
    height: 600
    title: qsTr("TS-7990 Balloon Demo")

    property var marketingMode: 0


    ColumnLayout {
        id: columnLayoutTest
        x: 13
        y: 328
        width: 338
        height: 157

        RowLayout {
            Text {
                id: cpuInfoText
                text: qsTr("NXP i.MX6 Quad-Core CPU")
                font.family: "Monospace"
                font.pointSize: 16
                color: "#ffffff"
            }
        }

        RowLayout {
            id: rowlayouttest

            ColumnLayout {

                Text {
                    id: labelTemp
                    text: qsTr("CPU Temp:")
                    font.family: "Monospace"
                    font.pointSize: 15
                }

                Text {
                    id: labelLoad
                    text: qsTr("CPU Load:")
                    font.family: "Monospace"
                    font.pointSize: 15
                }

                Text {
                    id: labelMemUse
                    text: qsTr("Mem Use:")
                    font.family: "Monospace"
                    font.pointSize: 15
                }

                Text {
                    id: labelUptime
                    text: qsTr("Uptime:")
                    font.family: "Monospace"
                    font.pointSize: 15
                }
            }

            ColumnLayout {

                Text {
                    id: valueTemp
                    text: qsTr("--.- °C")
                    font.family: "Monospace"
                    font.pointSize: 15
                }

                Text {
                    id: valueLoad
                    text: qsTr("-.-- -.-- -.--")
                    font.family: "Monospace"
                    font.pointSize: 15
                }

                Text {
                    id: valueMemUse
                    text: qsTr("000000 (000%)")
                    font.family: "Monospace"
                    font.pointSize: 15
                }

                Text {
                    id: valueUptime
                    text: qsTr("0000 s")
                    font.family: "Monospace"
                    font.pointSize: 15
                }

            }


        }
    }

    RoundButton {
        id: queueGoButton
        x: 515
        y: 257
        width: 153
        height: 100
        radius: 10
        background: Rectangle {
            radius: queueGoButton.radius
            color: "green"
        }
        text: qsTr("Run")
        font.family: "Monospace"
        font.pointSize: 25
        onClicked: {
            Imx6.pumpToggle();
        }
    }

    RoundButton {
        id: stressGo
        x: 31
        y: 519
        width: 325
        radius: 10
        background: Rectangle {
            radius: stressGo.radius
            color: stressGo.checked ? "#000000" : "#f5f8fa"
        }
        text: stressGo.checked ? qsTr("Running (1 min)") : qsTr("Run Stress Test")
        font.family: "Monospace"
        font.pointSize: 24
        checkable: true
        onClicked: {
            Imx6.stressRun()
        }
    }

    Image {
        id: image1
        x: -15
        y: 68
        width: 358
        height: 167
        source: "image/embeddedts-color-outline.svg"
        rotation: -25
        fillMode: Image.PreserveAspectFit
    }

    Connections {
        target: Imx6

        function onFillTotalColorSig(currentColor) {
            fillTotal.color = currentColor
        }

        function onFillTotalUpdateSig(currentFillTotal) {
            fillTotal.text = currentFillTotal
        }

        function onFillQueueUpdateSig(currentFillQueueTotal) {
            fillQueue.text = currentFillQueueTotal
        }

        function onTemperatureUpdateSig(currentTemperature) {
            valueTemp.text = currentTemperature
        }

        function onLoadUpdateSig(currentLoad) {
            valueLoad.text = currentLoad
        }

        function onUptimeUpdateSig(currentUptime) {
            valueUptime.text = currentUptime
        }

        function onMemUseUpdateSig(currentMemUse) {
            valueMemUse.text = currentMemUse
        }

        function onStressUpdateSig(running) {
            stressGo.checked = running
            stressGo.enabled = !running
        }

        function onHundredTextUpdateSig(litres) {
            quickHundredFill.text = litres
        }

        function onFiftyTextUpdateSig(litres) {
            quickFiftyFill.text = litres
        }

        function onTwentyFiveTextUpdateSig(litres) {
            quickTwentyFiveFill.text = litres
        }

        function onPumpSig(running) {
            plusOneButton.enabled = !running
            plusTwoButton.enabled = !running
            plusFiveButton.enabled = !running
            minusOneButton.enabled = !running
            minusTwoButton.enabled = !running
            minusFiveButton.enabled = !running
            quickHundredFill.enabled = !running
            quickFiftyFill.enabled = !running
            quickTwentyFiveFill.enabled = !running
            queueGoButton.text = running ? "Stop" : "Run"
            queueGoButton.background.color = running ? "red" : "green"
            queueResetButton.enabled = !running
            openHelp.enabled = !running
            openAbout.enabled = !running
            quickFiftyFill.checked = running ? quickFiftyFill.checked : false
            quickHundredFill.checked = running ? quickHundredFill.checked : false
            quickTwentyFiveFill.checked = running ? quickTwentyFiveFill.checked : false
        }

        function onErrorSig(error) {
            quickHundredFill.enabled = !error
            quickFiftyFill.enabled = !error
            quickTwentyFiveFill.enabled = !error
            queueGoButton.enabled = !error
        }
    }


    Timer {
        id: timer
        interval: 1000
        repeat: true
        running: true

        onTriggered:
        {
            Imx6.temperatureGet()
            Imx6.cpuLoadGet()
            Imx6.uptimeGet()
            Imx6.memUseGet()
        }
    }

    Timer {
        id: timer1
        interval: 1
        repeat: false
        running: true

        onTriggered:
        {
            Imx6.init()
        }
    }

    Timer {
        id: timer100
        interval: 100
        repeat: true
        running: true

        onTriggered:
        {
            Imx6.fillTotalUpdate()
        }
    }

    Rectangle {
        id: rectangle
        x: 403
        y: 519
        width: 220
        height: 63
        radius: 3
        color: "#000000"

        Text {
            id: fillTotal
            x: 14
            y: 8
            text: qsTr("0.00 L")
            font.family: "Monospace"
            font.pointSize: 30
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
        }
    }

    Button {
        id: fillTotalReset
        x: 408
        y: 519
        width: 208
        height: 63
        opacity: 0
        visible: true
        text: qsTr("Button")
        onClicked: {
            Imx6.fillTotalReset();
        }
    }

    Text {
        id: text1
        x: 392
        y: 491
        text: qsTr("Total Filled Volume")
        font.family: "Monospace"
        font.pointSize: 16
        color: "#ffffff"
    }

    Rectangle {
        id: rectangle1
        x: 402
        y: 422
        width: 220
        height: 63
        radius: 3
        color: "#000000"
        Text {
            id: fillQueue
            x: 14
            y: 8
            color: "#ffffff"
            text: qsTr("0.00 L")
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: "Monospace"
            font.pointSize: 30
        }
    }

    Text {
        id: text2
        x: 449
        y: 392
        color: "#ffffff"
        text: qsTr("Fill Queue")
        font.family: "Monospace"
        font.pointSize: 16
    }

    RoundButton {
        id: plusOneButton
        x: 356
        y: 45
        width: 100
        height: 100
        radius: 10
        background: Rectangle {
            radius: plusOneButton.radius
            color: marketingMode ? "#caf0f8" : "#f5f8fa"
        }
        text: qsTr("+1 L")
        font.family: "Monospace"
        font.pointSize: 24
        onClicked: {
            Imx6.fillQueueUpdate(1);
        }
    }

    RoundButton {
        id: plusTwoButton
        x: 462
        y: 45
        width: 100
        height: 100
        radius: 10
        background: Rectangle {
            radius: plusTwoButton.radius
            color: marketingMode ? "#caf0f8" : "#f5f8fa"
        }
        text: qsTr("+2 L")
        font.family: "Monospace"
        font.pointSize: 24
        onClicked: {
            Imx6.fillQueueUpdate(2);
        }
    }

    RoundButton {
        id: plusFiveButton
        x: 568
        y: 45
        width: 100
        height: 100
        radius: 10
        background: Rectangle {
            radius: plusFiveButton.radius
            color: marketingMode ? "#caf0f8" : "#f5f8fa"
        }
        text: qsTr("+5 L")
        font.family: "Monospace"
        font.pointSize: 25
        onClicked: {
            Imx6.fillQueueUpdate(5);
        }
    }

    RoundButton {
        id: minusOneButton
        x: 356
        y: 151
        width: 100
        height: 100
        radius: 10
        background: Rectangle {
            radius: minusOneButton.radius
            color: marketingMode ? "#c0d6df" : "#f5f8fa"
        }
        text: qsTr("-1 L")
        font.family: "Monospace"
        font.pointSize: 25
        onClicked: {
            Imx6.fillQueueUpdate(-1);
        }
    }

    RoundButton {
        id: minusTwoButton
        x: 462
        y: 151
        width: 100
        height: 100
        radius: 10
        background: Rectangle {
            radius: minusTwoButton.radius
            color: marketingMode ? "#c0d6df" : "#f5f8fa"
        }
        text: qsTr("-2 L")
        font.family: "Monospace"
        font.pointSize: 25
        onClicked: {
            Imx6.fillQueueUpdate(-2);
        }
    }

    RoundButton {
        id: minusFiveButton
        x: 568
        y: 151
        width: 100
        height: 100
        radius: 10
        background: Rectangle {
            radius: minusFiveButton.radius
            color: marketingMode ? "#c0d6df" : "#f5f8fa"
        }
        text: qsTr("-5 L")
        font.family: "Monospace"
        font.pointSize: 25
        onClicked: {
            Imx6.fillQueueUpdate(-5);
        }
    }

    RoundButton {
        id: queueResetButton
        x: 356
        y: 257
        width: 153
        height: 100
        radius: 10
        background: Rectangle {
            radius: queueResetButton.radius
            color: "#f77f00"
        }
        text: qsTr("Reset")
        font.family: "Monospace"
        font.pointSize: 25
        onClicked: {
            Imx6.fillQueueReset();
        }
    }

    /* Rerun init() once after QML loads and renders so that we
     * can update the label string on the Quick Fill buttons.
     */
    RoundButton {
        id: quickHundredFill
        x: 710
        y: 58
        width: 300
        height: 75
        radius: 10
        background: Rectangle {
            radius: quickHundredFill.radius
            color: quickHundredFill.checked ? "#000000" : "#f5f8fa"
        }
        text: qsTr("100% (11.00 L)")
        font.family: "Monospace"
        font.pointSize: 24
        checkable: true
        onClicked: {
            Imx6.quickFillGo(1.00);
        }
    }

    RoundButton {
        id: quickFiftyFill
        x: 710
        y: 151
        width: 300
        height: 75
        radius: 10
        background: Rectangle {
            radius: quickFiftyFill.radius
            color: quickFiftyFill.checked ? "#000000" : "#f5f8fa"
        }
        text: qsTr("50% (5.50 L)")
        font.family: "Monospace"
        font.pointSize: 24
        checkable: true
        onClicked: {
            Imx6.quickFillGo(0.50);
        }
    }

    RoundButton {
        id: quickTwentyFiveFill
        x: 710
        y: 240
        width: 300
        height: 75
        radius: 10
        background: Rectangle {
            radius: quickTwentyFiveFill.radius
            color: quickTwentyFiveFill.checked ? "#000000" : "#f5f8fa"
        }
        text: qsTr("25% (2.75 L)")
        font.family: "Monospace"
        font.pointSize: 24
        checkable: true
        onClicked: {
            Imx6.quickFillGo(0.25);
        }
    }

    Text {
        id: text3
        x: 405
        y: 14
        text: qsTr("Modify Fill Queue")
        font.family: "Monospace"
        font.pointSize: 16
        color: "#ffffff"
    }

    Text {
        id: text4
        x: 797
        y: 14
        color: "#ffffff"
        text: qsTr("Quick Fill")
        font.family: "Monospace"
        font.pointSize: 16
    }

    RoundButton {
        id: openHelp
        x: 785
        y: 435
        width: 150
        height: 50
        radius: 10
        background: Rectangle {
            radius: openHelp.radius
            color: "#f5f8fa"
        }
        text: qsTr("Help")
        font.family: "Monospace"
        font.pointSize: 24
        onClicked:
            mouseAreaHelp.visible = true
    }

    RoundButton {
        id: openAbout
        x: 785
        y: 519
        width: 150
        height: 50
        radius: 10
        background: Rectangle {
            radius: openAbout.radius
            color: "#f5f8fa"
        }
        text: qsTr("About")
        font.family: "Monospace"
        font.pointSize: 24
        onClicked: {
            mouseAreaAbout.visible = true
        }
    }



    MouseArea {
        id: mouseAreaHelp
        x: 0
        y: 0
        width: 1024
        height: 600
        opacity: 1
        visible: false
        enabled: true

        Rectangle {
            id: mouseAreaHelpDim
            x: 0
            y: 0
            width: 1024
            height: 600
            color: "#000000"
            opacity: 0.6
            visible: mouseAreaHelp.visible
        }

        RoundButton {
            id: closeHelp
            x: 785
            y: 435
            width: 150
            height: 50
            radius: 10
            background: Rectangle {
                radius: closeHelp.radius
                color: "#ffffff"
            }
            text: qsTr("Close")
            font.family: "Monospace"
            font.pointSize: 24

            onClicked:
                mouseAreaHelp.visible = false
        }

        Rectangle {
            id: helpRectTare
            x: 626
            y: 522
            width: 380
            height: 60
            color: "#ffca3a"
            radius: 20

            Text {
                id: text5
                x: 18
                y: 19
                text: qsTr("Press the volume value to tare")
                font.family: "Monospace"
                font.pointSize: 14
            }
        }

        Rectangle {
            id: helpRectRun
            x: 8
            y: 358
            width: 443
            height: 104
            color: "#ffca3a"
            radius: 20
            Text {
                id: text7
                x: 21
                y: 18
                text: qsTr("Press Reset to clear the Fill Queue\nPress Run to run the pump until the\nFill Queue empties")
                font.family: "Monospace"
                font.pointSize: 14
            }
        }

        Rectangle {
            id: helpRectQueue
            x: 8
            y: 90
            width: 318
            height: 100
            color: "#ffca3a"
            radius: 20

            Text {
                id: text6
                x: 33
                y: 16
                text: qsTr("Press the + and -\nvalue buttons to add\nair to the Fill Queue.")
                font.family: "Monospace"
                font.pointSize: 14
            }
        }


        Rectangle {
            id: helpRectQuick
            x: 640
            y: 325
            width: 366
            height: 81
            color: "#ffca3a"
            radius: 20
            Text {
                id: text8
                x: 29
                y: 18
                text: qsTr("Quick Fill buttons load the\nFill Queue and Run")
                font.family: "Monospace"
                font.pointSize: 14
            }
        }

    }

    MouseArea {
        id: mouseAreaAbout
        x: 0
        y: 0
        width: 1024
        height: 600
        opacity: 1
        visible: false
        enabled: true

        Rectangle {
            id: mouseAreaAboutDim
            x: 0
            y: 0
            width: 1024
            height: 600
            color: "#000000"
            opacity: 0.6
            visible: mouseAreaAbout.visible
        }

        RoundButton {
            id: closeAbout
            x: 785
            y: 519
            width: 150
            height: 50
            radius: 10
            background: Rectangle {
                radius: closeAbout.radius
                color: "#ffffff"
            }
            text: qsTr("Close")
            font.family: "Monospace"
            font.pointSize: 24

            onClicked:
                mouseAreaAbout.visible = false
        }

        Rectangle {
            id: aboutRect
            x: 36
            y: 51
            width: 953
            height: 452
            color: "#ffca3a"
            radius: 20
            Text {
                id: textAboutHeader
                x: 330
                y: 8
                text: qsTr("About This Project")
                font.family: "Monospace"
                font.pointSize: 20
            }

            Text {
                id: textAbout
                x: 33
                y: 54
                width: 888
                height: 345
                text: qsTr("Full project details: https://TS.to/balloon

This project uses embeddedTS' TS-TPC-7990 with TS-CAB799 enclosure.
The exact part number used in this application is: TS-TPC-7990-QMW3E
Which is configured with a Quad-Core i.MX6 CPU @ 1 GHz with 1 GB DDR3 RAM.

Qt is fully hardware accelerated using the Etnaviv open-source GPU driver
for the i.MX6 SoC.

This demo uses Buildroot to compile all tools and create a bootable image.

The whole distribuion is running with the eMMC disk mounted read-only to
prevent filesystem damage from sudden power-off events.

The interface was created with Qt 5.15 and QML Runtime 5.15
")
                font.family: "Monospace"
                font.pointSize: 14
            }
        }
    }

    MouseArea {
        id: mouseAreaMode
        x: 0
        y: 0
        width: 45
        height: 45
        onClicked:
            marketingMode ^= 1;

        Text {
            id: text9
            x: 0
            y: -21
            width: 40
            height: 64
            opacity: 0.05
            text: qsTr("π")
            font.family: "Monospace"
            font.pointSize: 50
        }
    }







}


/*##^##
Designer {
    D{i:0;formeditorZoom:0.9}
}
##^##*/
