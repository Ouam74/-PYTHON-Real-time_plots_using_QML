import sys
import os
# import time
import random
from PySide2.QtCore import Qt, QUrl, QThread, QPoint, QPointF, Slot, Signal, QObject, QProcess, Property, qInstallMessageHandler, QtInfoMsg, QtWarningMsg, QtCriticalMsg, QtFatalMsg
from PySide2.QtQuick import QQuickView
from PySide2.QtWidgets import QApplication, QMainWindow, QMessageBox
# from PySide2.QtGui import QGuiApplication
from PySide2.QtQml import QQmlApplicationEngine
from PySide2.QtCharts import QtCharts
# import pdb

print(chr(27) + "[2J")

def qt_message_handler(mode, context, message):
    if mode == QtInfoMsg:
        mode = 'Info'
    elif mode == QtWarningMsg:
        mode = 'Warning'
    elif mode == QtCriticalMsg:
        mode = 'critical'
    elif mode == QtFatalMsg:
        mode = 'fatal'
    else:
        mode = 'Debug'
    print("%s: %s (%s:%d, %s)" % (mode, message, context.file, context.line, context.file))
    

class Worker1(QObject):
    set_val = Signal(QtCharts.QXYSeries)
    finished = Signal()
    
    def __init__(self, serie, parent=None):
        QObject.__init__(self, parent)
        self._serie = serie
        self._isRunning = True 
        
    def run(self):
        measure(self)    
        
    def stop(self):
        self._isRunning = False
        
        
def measure(self): # Called inside Thread1
    while 1:
        if self._isRunning == True:
            createserie(self)
            self.set_val.emit(self._serie)
            # time.sleep(0.002)
        else:
            print("QUITING LOOP")
            break
    self.finished.emit()
    return


def createserie(self):
    points = []
    for i in range(1001):
        points.append(QPointF(i, random.random()))
    self._serie.replace(points)
    

class Backend(QObject):
    setval = Signal(QtCharts.QXYSeries)  
    
    def __init__(self, parent=None):
        QObject.__init__(self, parent)
        self._serie = None
    
    @Slot(QtCharts.QXYSeries) # expose QML serie to Python
    def exposeserie(self, serie):
        self._serie = serie
        # print(serie)
        # print("QML serie exposed to Python")
        
    @Slot(str)
    def startthread(self, text):
        self.WorkerThread = QThread()
        self.worker = Worker1(self._serie)
        self.WorkerThread.started.connect(self.worker.run)
        self.worker.finished.connect(self.end)
        self.worker.set_val.connect(self.setval)
        self.worker.moveToThread(self.WorkerThread)  # Move the Worker object to the Thread object
        self.WorkerThread.start()
        
    @Slot(str)     
    def stopthread(self, text):
        self.worker.stop()
        print("CLOSING THREAD")
               
    def end(self):
        self.WorkerThread.quit()
        self.WorkerThread.wait()
        msgBox = QMessageBox() 
        msgBox.setText("THREAD CLOSED")
        msgBox.exec()
        

class MainWindow(QObject):
    def __init__(self, parent = None):
        # Initialization of the superclass
        super(MainWindow, self).__init__(parent)
        
        qInstallMessageHandler(qt_message_handler)
        
        self.backend = Backend()

        # Expose the Python "Backend" object to QML
        self.engine = QQmlApplicationEngine()  
        self.context = self.engine.rootContext()
        self.context.setContextProperty("backend", self.backend)
        
        # Load the GUI
        self.engine.load(os.path.join(os.path.dirname(__file__), "SpecPXA_QML.qml"))
        if not self.engine.rootObjects():
            sys.exit(-1)
        
        self.win = self.engine.rootObjects()[0]
        
        # Execute a function if "Start" button clicked
        startbutton = self.win.findChild(QObject, "startbutton")
        startbutton.startclicked.connect(self.startclicked)
        
        # Execute a function if "Stop" button clicked
        stopbutton = self.win.findChild(QObject, "stopbutton")
        stopbutton.stopclicked.connect(self.stopclicked)
        
    def startclicked(self):
        print("START")
        self.backend.startthread("test")
        
    def stopclicked(self):
        print("STOP")
        self.backend.stopthread("test")

        
if __name__ == "__main__":
    
    if not QApplication.instance():
        app = QApplication(sys.argv)
    else:
        app = QApplication.instance()
    app.setStyle('Fusion') # 'Breeze', 'Oxygen', 'QtCurve', 'Windows', 'Fusion'
    w = MainWindow()
    sys.exit(app.exec_())
