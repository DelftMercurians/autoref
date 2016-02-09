--[[
--- Referee utility functions
module "Referee"
]]--

--[[***********************************************************************
*   Copyright 2015 Alexander Danzer, Michael Eischer, Christian Lobmeier  *
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
*************************************************************************]]

local Referee = {}
local World = require "../base/world"
local vis = require "../base/vis"
local robotRadius = (require "../base/constants").maxRobotRadius -- avoid table lookups for speed reasons

-- states, in which we must keep a dist of 50cm
local stopStates = {
	Stop = true,
	KickoffDefensivePrepare = true,
	KickoffDefensive = true,
	DirectDefensive = true,
	IndirectDefensive = true
}

local friendlyFreeKickStates = {
	DirectOffensive = true,
	IndirectOffensive = true
}

local kickoffStates = {
	KickoffDefensivePrepare = true,
	KickoffDefensive = true,
	KickoffOffensivePrepare = true,
	KickoffOffensive = true
}

local opponentPenaltyStates = {
	PenaltyDefensivePrepare = true,
	PenaltyDefensive = true
}


--- Check whether the stop rules apply
-- @name isStopState
-- @return boolean - True if the current referee state is considered as stop
function Referee.isStopState()
	return stopStates[World.RefereeState]
end

--- Check whether we have a freekick
-- @name isFriendlyFreeKickState
-- @return boolean - True if the current referee state is a freekick for us
function Referee.isFriendlyFreeKickState()
	return friendlyFreeKickStates[World.RefereeState]
end

--- Check whether this is a kickoff
-- @name isKickoffState
-- @return boolean - True if the current referee state is a kickoff
function Referee.isKickoffState()
	return kickoffStates[World.RefereeState]
end

--- Check whether the opponent has a penalty
-- @name isOpponentPenaltyState
-- @return boolean - True if the opponent has a penalty
function Referee.isOpponentPenaltyState()
	return opponentPenaltyStates[World.RefereeState]
end

local rightLine = World.Geometry.FieldWidthHalf
local leftLine = -rightLine
local goalLine = World.Geometry.FieldHeightHalf
local cornerDist = 0.7 -- some tolerance, rules say 10cm
--- Check whether there is a freekick in the opponent corner
-- @name isOffensiveCornerKick
-- @return boolean - True if a corner kick in the opponents corner
function Referee.isOffensiveCornerKick()
	local ballPos = World.Ball.pos
	return World.RefereeState == "DirectOffensive"
		and goalLine - ballPos.y < cornerDist
		and (leftLine - ballPos.x > -cornerDist or rightLine - ballPos.x < cornerDist)
end

--- Draw areas forbidden by the current referee command
-- @name illustrateRefereeStates
function Referee.illustrateRefereeStates()
	if World.RefereeState == "PenaltyYellowPrepare" or World.RefereeState == "PenaltyYellow" then
		vis.addPath("penaltyDistanceAllowed", {Vector(rightLine,World.Geometry.BluePenaltyLine), Vector(leftLine,World.Geometry.BluePenaltyLine)}, vis.colors.red)
	elseif World.RefereeState == "PenaltyBluePrepare" or World.RefereeState == "PenaltyBlue" then
		vis.addPath("penaltyDistanceAllowed", {Vector(rightLine,World.Geometry.YellowPenaltyLine), Vector(leftLine,World.Geometry.YellowPenaltyLine)}, vis.colors.red)
	elseif Referee.isStopState() then
		vis.addCircle("stopstateBallDist", World.Ball.pos, 0.5, vis.colors.redHalf, true)
	end
end

local touchDist = World.Ball.radius+robotRadius
Referee.touchDist = touchDist
local lastTeam, lastRobot, lastTouchPos
--- Update the status of which team touched the ball last
-- @name checkTouching
function Referee.checkTouching()
	local ballPos = World.Ball.pos
	for _, robot in ipairs(World.Robots) do
		if robot.pos:distanceTo(ballPos) <= touchDist then
			lastTeam = robot.isYellow and World.YellowColorStr or World.BlueColorStr
			lastRobot = robot
			lastTouchPos = Vector.createReadOnly(ballPos.x, ballPos.y)
			return
		end
	end
end

--- Get team which touched the ball last
-- @name teamWhichTouchedBallLast
-- @return string - team which touched the ball last
function Referee.teamWhichTouchedBallLast()
	return lastTeam
end

function Referee.robotAndPosOfLastBallTouch()
	return lastRobot, lastTouchPos
end

return Referee
