/***************************************************************************
 *   Copyright 2016 Alexander Danzer, Janine Schneider                     *
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

#ifndef INFOBOARD_H
#define INFOBOARD_H

#include "protobuf/status.h"
#include <QWidget>
#include <QMap>
#include "teamscorewidget.h"
#include <QTimer>

class FieldWidget;

namespace Ui {
class InfoBoard;
}

class InfoBoard : public QWidget
{
    Q_OBJECT

public:
    explicit InfoBoard(QWidget *parent=0);
    ~InfoBoard() override;
    FieldWidget* field;
    void setAutorefIsActive(bool active);

protected:
    void mouseDoubleClickEvent(QMouseEvent *event) override;
    void resizeEvent(QResizeEvent *event) override;

public slots:
    void handleStatus(const Status &status);
    void changeColor();

private:
    Ui::InfoBoard *ui;
    QMap<std::string, QString> m_gameStagesDict;
    QString m_currentStage;
    int m_blinkCounter;
    QTimer *m_blinkTimer;

    qint64 m_eventMsgTime;
    QString m_refState;
    QString m_foulEvent;
    QString m_nextAction;
    bool m_autorefIsActive;
    bool m_autorefMsgInvalidated;

    void updateGameStage(const amun::GameState &game_state);
    void updateTime(const amun::GameState &game_state);
    void updateTeamScores(const amun::GameState &game_state);
    void updateRefstate(const Status &status);
};

#endif // INFOBOARD_H
