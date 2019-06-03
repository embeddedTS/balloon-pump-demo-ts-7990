#include <fstream>
#include <string>
#include <QObject>
#include <QFile>
#include <QTextStream>
#include <QtDebug>
#include "imx6.h"

using namespace std;

Imx6::Imx6(QObject *parent) : QObject(parent)
{
    this->filled = -1;
    this->time = 0;
    this->init();
}

Imx6::~Imx6()
{
}

void Imx6::init()
{
    this->exportDio(PUMP_DIO);
    this->exportDio(VALVE_DIO);
    this->setDioDirection(PUMP_DIO, "out");
    this->setDioDirection(VALVE_DIO, "out");
    this->calibrate();
    this->hold();
}

void Imx6::getCurrentTemperature()
{
    string ifile;
    string val;
    string preparedTemp;
    double temperature;
    char buffer [50];

    ifile = "/sys/class/thermal/thermal_zone0/temp";
    ifstream temperatureFile ("/sys/class/thermal/thermal_zone0/temp");
    temperatureFile >> val;
    temperatureFile.close();

    temperature = std::stod(val);
    temperature /= 1000;

    QChar ch(0x00B0);
    QString s="";
    s.append(ch);
    s.append("C");
    string celsius = s.toStdString();

    sprintf(buffer, "%.0f %s", temperature, celsius.c_str());

    emit temperatureUpdate(buffer);
}

void Imx6::getCurrentPercentFilled()
{

    float literPerSec = (float)LITERS_PER_MINUTE / 60;
    float totalLiter = 0;

    //qDebug() << "TIME: " << this->time;
    //qDebug() << "PERCENT FILLED: " << this->filled;

    if (this->time == 0) {
        this->filled = 0;
        emit percentFilledUpdate(0);
    }
    else {
        totalLiter = (this->time / 1000) * literPerSec;

        this->filled = (totalLiter / LITERS_FULL) * 100;

        if(this->filled > POP_WARNING_PERCENTAGE) {
            emit balloonPopWarningEvent();
        }
        else {
            emit balloonNormalEvent();
        }

        emit percentFilledUpdate(this->filled);
    }

}

void Imx6::updatePumpVacTime()
{
    int valveStatus = getDioStatus(VALVE_DIO);

    // Pumping
    if (valveStatus == 0) {
        this->time++;
    }
    else {
        if (this->time != 0) {
            this->time--;
        }
    }

}

int Imx6::getDioStatus(int dio)
{
    QString val;
    QString file;

    file = QString("/sys/class/gpio/gpio%1/value").arg(dio);

    QFile qFile(file);
    if(qFile.open(QIODevice::ReadOnly)) {
        QTextStream in(&qFile);
        val = in.readLine();
        qFile.close();
    }

    return val.toInt();
}

void Imx6::exportDio(int dio)
{
    QString of;

    of = QString("/sys/class/gpio/export");

    QFile qFile(of);
    if(qFile.open(QIODevice::WriteOnly)) {
        QTextStream out(&qFile);
        out << dio;
        qFile.close();
    }
}

void Imx6::setDioDirection(int dio, QString direction)
{
    QString of;

    of = QString("/sys/class/gpio/gpio%1/direction").arg(dio);

    QFile qFile(of);
    if(qFile.open(QIODevice::WriteOnly)) {
        QTextStream out(&qFile);
        out << direction;
        qFile.close();
    }
}

void Imx6::setDio(int dio, int value)
{
    /***
     * Takes 45873 ms to fill up a 9" balloon at 10L/min.
     ***/
    QString of;

    of = QString("/sys/class/gpio/gpio%1/value").arg(dio);

    QFile qFile(of);
    if(qFile.open(QIODevice::WriteOnly)) {
        QTextStream out(&qFile);
        out << value;
        qFile.close();
    }
}

void Imx6::toggleInflate()
{
    qDebug() << "INFLATING!";
    //qDebug() << "PUMP: " << this->getDioStatus(PUMP_DIO);
    //qDebug() << "VALVE: " << this->getDioStatus(VALVE_DIO);

    int status;
    status = this->getDioStatus(PUMP_DIO);
    if(status == 1) {
        this->hold();
    }
    else {
        this->setDio(PUMP_DIO, 1);
        this->setDio(VALVE_DIO, 0);

        emit inflatingEvent();
    }

}

void Imx6::toggleDeflate()
{
    qDebug() << "DEFLATING!";

    int status;
    status = this->getDioStatus(PUMP_DIO);
    if(status == 1) {
        this->hold();
    }
    else {
        this->setDio(PUMP_DIO, 1);
        this->setDio(VALVE_DIO, 1);
        emit deflatingEvent();
    }
}

void Imx6::hold()
{
    qDebug() << "HOLDING!";

    this->setDio(PUMP_DIO, 0);
    this->setDio(VALVE_DIO, 0);

    emit holdingEvent();
}

void Imx6::calibrate()
{
    qDebug() << "CALIBRATING!";

    this->filled = EMPTY;
    this->time = 0;

    // Set percentFill value to 0
    emit calibrateEvent();
    emit balloonNormalEvent();
}
