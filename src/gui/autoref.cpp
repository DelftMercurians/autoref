/***************************************************************************
 *   Copyright 2015 Michael Eischer, Philipp Nordhus                       *
 *   Robotics Erlangen e.V.                                                *
 *   http://www.robotics-erlangen.de/                                      *
 *   info@robotics-erlangen.de                                             *
 *                                                                         *
 *   This program is free software: you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation, either version 3 of the License, or     *
 *   any later version.                                                    *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>. *
 ***************************************************************************/

#include "config/config.h"
#include "mainwindow.h"
#include <clocale>
#include <QApplication>
#include <QDir>
#include <QIcon>
#include <QCommandLineParser>

int main(int argc, char* argv[])
{
    QApplication app(argc, argv);
    app.setApplicationName("Autoref");
    app.setOrganizationName("ER-Force");
// available starting with Qt 5.1
#if (QT_VERSION >= QT_VERSION_CHECK(5, 1, 0))
    qApp->setAttribute(Qt::AA_UseHighDpiPixmaps);
#endif
#ifdef Q_OS_OSX
    if (QDir::currentPath() == "/") {
        QDir::setCurrent(QDir::homePath());
    }
#endif

    std::setlocale(LC_NUMERIC, "C");

    QDir::addSearchPath("icon", QString(ERFORCE_DATADIR) + "/icons");
    QDir::addSearchPath("icon", QString(AUTOREF_DATADIR) + "/icons");
    QDir::addSearchPath("logo", QString(AUTOREF_DATADIR) + "/ssl-refbox/scoreboard/logos");

    QCommandLineParser parser;
    parser.setApplicationDescription("Autoref");
    parser.addHelpOption();
    QCommandLineOption infoBoardOption({"i", "info"}, "Show the info board");
    parser.addOption(infoBoardOption);
    parser.process(app);

    MainWindow window(parser.isSet(infoBoardOption));
    window.show();

    return app.exec();
}
