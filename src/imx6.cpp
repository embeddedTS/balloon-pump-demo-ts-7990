#include <cstdio>
#include <fstream>
#include <math.h>
#include <string>
#include <sstream>
#include <QObject>
#include <QFile>
#include <QProcess>
#include <QTextStream>
#include <QtDebug>
#include "imx6.h"

#include "sys/types.h"
#include "sys/sysinfo.h"

using namespace std;

Imx6::Imx6(QObject *parent) : QObject(parent)
{
    this->fill_tot = 0.00;
    this->queue_tot = 0.00;
    this->last_val = 0.00;
    this->running = false;
    this->init();
}

Imx6::~Imx6()
{
}


void Imx6::init()
{
    char buf[16];

    this->dioExport(PUMP_DIO);
    this->dioExport(VALVE_DIO);
    this->dioDirectionSet(PUMP_DIO, "out");
    this->dioDirectionSet(VALVE_DIO, "out");

    snprintf(buf, sizeof(buf), "100%% (%.02f L)", (double)(LITRES_FULL));
    emit hundredTextUpdateSig(buf);

    snprintf(buf, sizeof(buf), "50%% (%.02f L)", (double)(LITRES_FULL * 0.5));
    emit fiftyTextUpdateSig(buf);

    snprintf(buf, sizeof(buf), "25%% (%.02f L)", (double)(LITRES_FULL * 0.25));
    emit twentyFiveTextUpdateSig(buf);

}

void Imx6::fillTotalUpdate()
{
    char total_buf[10], queue_buf[10];
    double val, val_q = 0, queue_pre_update;
    static int pump_stall_check;

    /* If the pump is not running, then clear the stall check. We still
     * want to run this function as the system does have leakage when trying
     * to hold air.
     */
    if (!this->running) {
        pump_stall_check = 0;
    }

    /* We don't want to update ANYTHING in here if there is an error cond
     * currently set on the fill total. e.g. Pump error, sensor not found,
     * etc.
     */
    if (this->fill_tot_error_condition)
        return;

    /* NOTE: The following link is highly specific to both this platform
     * and the actual airflow sensor device. This is not portable.
     *
     * Additionally, the following code assumes the measured_value is in sl/min.
     * This is again specific to this sensor device and is not portable.
     *
     * Even still, the math heavily relies on this function being run at 100 ms
     * intervals. Any delays will cause readings to be too slow and the math to
     * be incorrect.
     *
     * The correct way to do the math here is to timestamp each read to use as
     * the interval for the integration calculation. This is a future TODO if
     * the overall accuracy needs work, the timing changes (the sensor updates
     * every 500 us, so we can read faster than 100 ms), etc.
     */
    std::ifstream airflowFile ("/sys/bus/i2c/devices/i2c-1/1-0040/measured_value");
    if (airflowFile.good()) {
        airflowFile >> val;
        /* When idle with zero airflow, there is still a ~1 LSB error that
         * can show up. If this happens, force it to 0.00 but continue
         * normally.
         * This doesn't show up in normal pump operation, but, in the case of
         * a pump failure (e.g. disconnected for testing), this can swing the
         * total volume measurement around 0 so it might show -0.00 L which
         * looks bad more than anything.
         */
        if (fabs(val) < 0.005)
            val = 0;
        val_q = (this->last_val + val) / 2 / 600;
        this->fill_tot += val_q;
        this->last_val = val;

        /* Check for how much air volume has moved over the last measure of time.
         * Testing shows that even in a complete blockage, the measured rate of
         * airflow can vary wildly from -5 to +5, whereas normal operation can
         * see immediate rates around +-3 to +-4. The more accurate measure for
         * checking for a stall seems to be the integral of air moved.
         */
        if (fabs(val_q) < 0.006) {
            pump_stall_check++;
            //qDebug() << "Pump stalled!";
        } else {
            pump_stall_check = 0;
        }

        //qDebug() << val_q << val;
        airflowFile.close();
    } else {
        this->pumpStop();
        emit fillTotalUpdateSig("No Sensor");
        emit fillTotalColorSig("red");
        emit errorSig(true);
        this->fill_tot_error_condition = true;
        return;
    }

    /* Buffer to emit to fill total text box */
    snprintf(total_buf, sizeof(total_buf), "%.2f L", this->fill_tot);

    /* Adjust queue total, stop the pump if the queue empties. The empty
     * check is the queue crossing zero, so this means the total will always
     * over fill/vacuum a tiny amount. We use zero crossing as there is never
     * a guarantee that the queue will be exactly zero, and defining "close enough"
     * seems overkill since crossing over fill/vacuum is ~10 mL or so.
     *
     * We only want to have the total adjust if the pump is running. Otherwise,
     * we just want to track the total volume as there is leakage over time.
     */
    if (this->running) {
        queue_pre_update = this->queue_tot;
        this->queue_tot -= val_q;

        /* Buffer to emit to queue value text box */
        snprintf(queue_buf, sizeof(queue_buf), "%.02f L", this->queue_tot);

        /* Determine if the value change has crossed zero */
        if (((queue_pre_update < 0) && (this->queue_tot > 0)) ||
            ((queue_pre_update > 0) && (this->queue_tot < 0))) {

            this->pumpStop();
            this->queue_tot = 0;
            emit fillQueueUpdateSig("0.00 L");
        } else {
            emit fillQueueUpdateSig(queue_buf);
        }
    }

    if (pump_stall_check > 10) {
        this->pumpStop();
        emit fillTotalUpdateSig("Pump Err");
        emit fillTotalColorSig("red");
        emit errorSig(true);
        this->fill_tot_error_condition = true;
    } else {
        emit fillTotalUpdateSig(total_buf);
        if (this->fill_tot > (double)(LITRES_FULL * 1.15)) {
            emit fillTotalColorSig("red");
        }
        else if (this->fill_tot > (double)(LITRES_FULL * 1.04)) {
            emit fillTotalColorSig("yellow");
        }
        else if (this->fill_tot > (double)(LITRES_FULL * 0.96)) {
            emit fillTotalColorSig("green");
        }
        else {
            emit fillTotalColorSig("white");
        }
    }
}

void Imx6::fillTotalReset()
{
    this->fill_tot = this->last_val = 0.00;

    emit fillTotalUpdateSig("0.00 L");
    emit fillTotalColorSig("white");
    emit errorSig(false);
    this->fill_tot_error_condition = false;
}

void Imx6::fillQueueUpdate(double val)
{
    char buf[10];

    this->queue_tot += val;
    if (this->queue_tot > 99.99)
        this->queue_tot = 99.99;
    if (this->queue_tot < -99.99)
        this->queue_tot = -99.99;

    snprintf(buf, sizeof(buf), "%.02f L", this->queue_tot);

    emit fillQueueUpdateSig(buf);
}

void Imx6::fillQueueReset()
{
    char buf[16];
    this->queue_tot = 0;

    emit fillQueueUpdateSig("0.00 L");

    snprintf(buf, sizeof(buf), "100%% (%.02f L)", (double)(LITRES_FULL));

    emit hundredTextUpdateSig(buf);
}

void Imx6::quickFillGo(float percent)
{
    char buf[10];

    this->queue_tot = (percent * LITRES_FULL);
    snprintf(buf, sizeof(buf), "%.02f L", this->queue_tot);

    emit fillQueueUpdateSig(buf);
    this->pumpRun();
}

void Imx6::pumpRun()
{
    if (this->queue_tot != 0 && !this->fill_tot_error_condition) {
        if (this->queue_tot < 0)
            this->dioValueSet(VALVE_DIO, 1);
        else
            this->dioValueSet(VALVE_DIO, 0);

        this->running = true;
        this->dioValueSet(PUMP_DIO, 1);
        emit pumpSig(true);
    }
}

void Imx6::pumpStop()
{
    this->running = false;
    this->dioValueSet(PUMP_DIO, 0);
    emit pumpSig(false);
}

/* Runs the pump if not running, otherwise stops */
void Imx6::pumpToggle()
{
    if (this->running)
        this->pumpStop();
    else
        this->pumpRun();
}

void Imx6::temperatureGet()
{
    string val;
    float temperature;
    char buffer[16];

    /* TODO: Is there a better way to get CPU temp? */
    std::ifstream temperatureFile ("/sys/class/thermal/thermal_zone0/temp");
    if (temperatureFile.good()) {
        temperatureFile >> val;
        temperatureFile.close();

        temperature = std::stof(val);
        temperature /= 1000;

        snprintf(buffer, sizeof(buffer), "%.01f °C", temperature);
    } else {
        // System doesn't have temp available for some reason.
        snprintf(buffer, sizeof(buffer), "--.- °C");
    }

    emit temperatureUpdateSig(buffer);
}

void Imx6::cpuLoadGet()
{
    struct sysinfo memInfo;
    char buf[16];

    sysinfo(&memInfo);
    snprintf(buf, sizeof(buf), "%.02f %.02f %.02f",
        memInfo.loads[0]/(float)(1 << SI_LOAD_SHIFT),
        memInfo.loads[1]/(float)(1 << SI_LOAD_SHIFT),
        memInfo.loads[2]/(float)(1 << SI_LOAD_SHIFT));

    emit loadUpdateSig(buf);
}

void Imx6::uptimeGet()
{
    struct sysinfo memInfo;
    char buf[24];

    sysinfo(&memInfo);
    snprintf(buf, sizeof(buf), "%lu:%02lu:%02lu",
        memInfo.uptime / 3600,
        (memInfo.uptime / 60) % 60,
        memInfo.uptime % 60);

    emit uptimeUpdateSig(buf);
}

void Imx6::memUseGet()
{
    struct sysinfo memInfo;
    unsigned long long physMemTotal, physMemUsed;
    char buf[32];

    sysinfo(&memInfo);
    physMemTotal = memInfo.totalram;
    physMemTotal *= memInfo.mem_unit;
    physMemUsed = memInfo.totalram - memInfo.freeram;
    physMemUsed *= memInfo.mem_unit;

    snprintf(buf, sizeof(buf), "%llu KiB (%llu%%)", physMemUsed/1024,
        ((physMemUsed*100)/physMemTotal));

    emit memUseUpdateSig(buf);
}

void Imx6::stressFinishedCB(int code, QProcess::ExitStatus)
{
    Q_UNUSED(code);
    emit stressUpdateSig(false);
}

void Imx6::stressRun()
{
    if (this->stressProc.processId() == 0) {
        this->stressProc.setProgram("/usr/bin/stress");
        this->stressProc.setArguments(QStringList() << "-c" << " 6" << "--vm"
            << "2" << "--timeout" << "1m");
        this->stressProc.start(QIODevice::ReadOnly);
        QObject::connect(&this->stressProc, SIGNAL(finished(int,QProcess::ExitStatus)),
            this, SLOT(stressFinishedCB(int, QProcess::ExitStatus)));

        emit stressUpdateSig(true);
    }

}

int Imx6::dioValueGet(int dio)
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

void Imx6::dioExport(int dio)
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

void Imx6::dioDirectionSet(int dio, QString direction)
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

void Imx6::dioValueSet(int dio, int value)
{
    QString of;

    of = QString("/sys/class/gpio/gpio%1/value").arg(dio);

    QFile qFile(of);
    if(qFile.open(QIODevice::WriteOnly)) {
        QTextStream out(&qFile);
        out << value;
        qFile.close();
    }
}
