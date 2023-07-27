#ifndef IMX6_H
#define IMX6_H
#endif // IMX6_H

#define LITRES_FULL 11

#define PUMP_DIO 245
#define VALVE_DIO 244

#include <QObject>
#include <QProcess>

class Imx6 : public QObject
{
    bool running;
    bool fill_tot_error_condition;
    double fill_tot;
    double last_val;
    double queue_tot;
    QProcess stressProc;
    Q_OBJECT
public:
    explicit Imx6(QObject *parent = 0);
    ~Imx6();

    Q_INVOKABLE void init();
    Q_INVOKABLE void temperatureGet();
    Q_INVOKABLE void cpuLoadGet();
    Q_INVOKABLE void uptimeGet();
    Q_INVOKABLE void memUseGet();
    Q_INVOKABLE void stressRun();
    Q_INVOKABLE void stressFinishedCB(int, QProcess::ExitStatus);
    Q_INVOKABLE void fillTotalUpdate();
    Q_INVOKABLE void fillTotalReset();
    Q_INVOKABLE void fillQueueUpdate(double val);
    Q_INVOKABLE void fillQueueReset();
    Q_INVOKABLE void quickFillGo(float percent);
    Q_INVOKABLE void pumpRun();
    Q_INVOKABLE void pumpStop();
    Q_INVOKABLE void pumpToggle();
    Q_INVOKABLE void dioExport(int dio);
    Q_INVOKABLE void dioDirectionSet(int dio, QString direction);
    Q_INVOKABLE void dioValueSet(int dio, int val);
    Q_INVOKABLE int dioValueGet(int dio);

signals:
    void temperatureUpdateSig(QString currentTemperature);
    void loadUpdateSig(QString currentLoad);
    void uptimeUpdateSig(QString currentUptime);
    void memUseUpdateSig(QString currentMemUse);
    void stressUpdateSig(bool running);
    void fillTotalUpdateSig(QString currentFillTotal);
    void fillTotalColorSig(QString currentColor);
    void fillQueueUpdateSig(QString currentFillQueueTotal);
    void pumpSig(bool running);
    void errorSig(bool error);
    void hundredTextUpdateSig(QString litres);
    void fiftyTextUpdateSig(QString litres);
    void twentyFiveTextUpdateSig(QString litres);
public slots:
};
