local SecondTimer = require("app.game.ui.modules.SecondTimer")
local RobotManager = class("RobotManager")

local this = nil

local kActionEnum = {
	hu = 1,
	dgang = 2,
	gang = 3,
	peng = 4
}

function RobotManager:ctor(layer, seat)
	this = layer
	self._seat = seat

	self._thinkTime = SecondTimer.new()

	self._recordAction = 0  -- 记录可做的操作是什么
end

--ai思考时间(延缓一个动作)
function RobotManager:_start(listener)
	local params = {
		time = 1,
		total_seconds = 1,
		end_listener = listener
	}
	self._thinkTime:start(params)
end

function RobotManager:waitPlayCard(card)
	self:_start(function() 
		--print("___________________出牌1")
		UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kPlayCard, card)
		end)
end

--todo:  在做检测的时候就自动出牌了
--检测到暗杠
function RobotManager:checkDarkGang(ret)
	if ret then
		self._recordAction = kActionEnum.dgang
	end
end

function RobotManager:checkGang(ret)
	if ret then
		self._recordAction = kActionEnum.gang
	end
end

function RobotManager:checkPeng(ret)
	if ret then
		self._recordAction = kActionEnum.peng
	end
end

--==================
function RobotManager:doAction()
	local listeners = {
		[kActionEnum.dgang] = handler(self, self._doDarkGang),
		[kActionEnum.gang] = handler(self, self._doGang),
		[kActionEnum.peng] = handler(self, self._doPeng)
	}
	if listeners[self._recordAction] then
		listeners[self._recordAction]()
		self._recordAction = nil
		ww.printFormat("-----ai%d操作了-----", self._seat)
		GDataManager:getInstance():removeActionSeat(self._seat)
	end
end

function RobotManager:_doDarkGang()
	local gangzi = this:getHandCardsBySeat(self._seat):getGangzi()  --所有杠子
	this:getHandCardsBySeat(self._seat):doDarkGang(gangzi[1])
	this:getHandCardsBySeat(self._seat):mineFeelCard()  --再次上牌
end

function RobotManager:_doGang()
	this:getHandCardsBySeat(self._seat):doGang()
	this:getHandCardsBySeat(self._seat):mineFeelCard()  --再次上牌
end

function RobotManager:_doPeng()
	this:getHandCardsBySeat(self._seat):doPeng()
	local cards = this:getHandCardsBySeat(self._seat):getCardWall()
	--print("___________________出牌2")
	print("----card_name----", cards[1]:getName())
	UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kPlayCard, cards[1])
end

function RobotManager:checkHu()

end

return RobotManager