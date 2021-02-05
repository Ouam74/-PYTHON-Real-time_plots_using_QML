import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.2
import QtCharts 2.3


ApplicationWindow {
    width: 1200
    height: 700
    visible: true
    title: qsTr("Hello World")
    
    property var xySeries;   

//    MessageDialog {
//        id: messageDialogQuit
//        title: "Question:"
//        icon: StandardIcon.Question
//        text: "Quit program?"
//        standardButtons: StandardButton.Yes |StandardButton.No
//        //        Component.onCompleted: visible = true
//        onYes: {
//            Qt.quit()
//            close.accepted = true
//        }
//        onNo: {
//            close.accepted = false
//        }
//     }
//    onClosing: {
//        close.accepted = true
//        onTriggered: messageDialogQuit.open()
//    }

    MenuBar {
        id: menuBar
        width: Window.width

        Menu {
            title: qsTr("&File")
            Action { text: qsTr("&New...") }
            Action { text: qsTr("&Open...") }
            Action { text: qsTr("&Save") }
            Action { text: qsTr("Save &As...") }
            MenuSeparator { }
            Action { text: qsTr("&Quit") }
        }
        Menu {
            title: qsTr("&Edit")
            Action { text: qsTr("Cu&t") }
            Action { text: qsTr("&Copy") }
            Action { text: qsTr("&Paste") }
        }
        Menu {
            title: qsTr("&Help")
            Action { text: qsTr("&About") }
        }
    }

    SplitView {
        id: splitView
        y: menuBar.height
        width: Window.width
        height: Window.height-(menuBar.height+infoBar.height)
        orientation: Qt.Horizontal
        Rectangle {
            id: leftitem
            height: Window.height
            implicitWidth: 200
            color: "red"
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 0
            anchors.bottomMargin: 0
            anchors.topMargin: 0

            Button {
                //id: startbutton
                signal startclicked
                objectName: "startbutton"
                y: 40
                height: 40
                text: qsTr("Start")
                anchors.left: parent.left
                anchors.right: parent.right
                checkable: false
                anchors.rightMargin: 30
                anchors.leftMargin: 30
                onClicked: startclicked("START")
                //onClicked: backend.text = "Button was pressed"
            }

            Button {
                //id: stopbutton
                signal stopclicked
                objectName: "stopbutton"
                y: 100
                height: 40
                text: qsTr("Stop")
                anchors.left: parent.left
                anchors.right: parent.right
                checked: false
                checkable: false
                anchors.rightMargin: 30
                anchors.leftMargin: 30
                onClicked: stopclicked("STOP")
            }

        }
        Rectangle {
            id: rightitem
            height: Window.height
            color: "green"
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: 0
            anchors.rightMargin: 0
            anchors.bottomMargin: 0

            Rectangle {
                id: rectangle
                color: "#ffffff"
                anchors.fill: parent
                anchors.rightMargin: 30
                anchors.leftMargin: 30
                anchors.bottomMargin: 30
                anchors.topMargin: 30

                ChartView {
                    id: line
                    anchors.fill: parent
                    
                    ValueAxis {
                        id: axisX
                        min: 0
                        max: 1000
                    }

                    ValueAxis {
                        id: axisY
                        min: 0
                        max: 1
                    }

//                    LineSeries {
//                       id: xySeries
//                       name: "my_Serie"
//                       axisX: axisX
//                       axisY: axisY
//                       useOpenGL: true
//                       XYPoint { x: 0.0; y: 0.0 }
//                       XYPoint { x: 1.1; y: 2.1 }
//                       XYPoint { x: 1.9; y: 3.3 }
//                       XYPoint { x: 2.1; y: 2.1 }
//                       XYPoint { x: 2.9; y: 4.9 }
//                       XYPoint { x: 3.4; y: 3.0 }
//                       XYPoint { x: 4.1; y: 3.3 }
//                    }
                    
                    Component.onCompleted: {
                        xySeries = line.createSeries(ChartView.SeriesTypeLine, "my_plot", axisX, axisY);  
                        xySeries.useOpenGL = true                    
                        backend.exposeserie(xySeries) // expose the serie to Python (QML to Python)
                    }
                    
                }
            }
        }
    }

    MenuBar {
        id: infoBar
        x: 0
        y: 440
        width: Window.width
        height: 30
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
    }
    
   
    
    Connections {
        target: backend
        
        function onSetval(serie) {  // "serie" is calculated in python (Python to QML)
            xySeries = serie;       // progressbar.value = val  
//            console.log(serie);
        }
    }
}