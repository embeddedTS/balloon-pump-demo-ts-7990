#ifndef IMX6_H
#define IMX6_H
#endif // IMX6_H

#define EMPTY 0
#define POP_WARNING_PERCENTAGE 105
#define LITERS_PER_MINUTE 10
#define LITERS_FULL 7.65

#define PUMP_DIO 245
#define VALVE_DIO 244

#include <QObject>

class Imx6 : public QObject
{
    unsigned int filled;
    unsigned int time;
    Q_OBJECT
public:
    explicit Imx6(QObject *parent = 0);
    ~Imx6();

    Q_INVOKABLE void init();
    Q_INVOKABLE void getCurrentTemperature();
    Q_INVOKABLE void exportDio(int dio);
    Q_INVOKABLE void setDioDirection(int dio, QString direction);
    Q_INVOKABLE void setDio(int dio, int val);
    Q_INVOKABLE int getDioStatus(int dio);
    Q_INVOKABLE void calibrate();
    Q_INVOKABLE void toggleInflate();
    Q_INVOKABLE void toggleDeflate();
    Q_INVOKABLE void hold();
    Q_INVOKABLE void getCurrentPercentFilled();
    Q_INVOKABLE void updatePumpVacTime();

signals:
    void temperatureUpdate(QString currentTemperature);
    void percentFilledUpdate(int currentPercentFilled);
    void redLedStatusUpdate(QString currentRedLedStatus);
    void inflatingEvent();
    void deflatingEvent();
    void holdingEvent();
    void calibrateEvent();
    void balloonPopWarningEvent();
    void balloonNormalEvent();

public slots:
};
