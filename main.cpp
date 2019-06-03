#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "imx6.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    Imx6 imx6;

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("Imx6", &imx6);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
