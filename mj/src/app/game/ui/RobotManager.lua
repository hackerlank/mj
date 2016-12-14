local SecondTimer = require("app.game.ui.modules.SecondTimer")
local RobotManager = class("RobotManager")

local this = nil

local kActionEnum = {
	hu = 1,
	dgang = 2,
	mgang = 3,
	gang = 4,
	peng = 5
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

--暗杠dgang 碰杠mgang 自摸是不需要延缓的


--todo:  在做检测的时候就自动出牌了
--检测到暗杠
function RobotManager:checkDarkGang(ret)
	if ret then
		--self._recordAction = kActionEnum.dgang
		self:_doDarkGang()
	end
end

function RobotManager:checkMGang(ret)
	if ret then
		--self._recordAction = kActionEnum.mgang
		self:_doMGang()
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

--==================暂缓执行
function RobotManager:doAction()
	local listeners = {
		--[kActionEnum.dgang] = handler(self, self._doDarkGang),
		--[kActionEnum.mgang] = handler(self, self._doMGang),
		[kActionEnum.gang] = handler(self, self._doGang),
		[kActionEnum.peng] = handler(self, self._doPeng)
	}

	self:_start(function() 
		if listeners[self._recordAction] then
			listeners[self._recordAction]()
			self._recordAction = nil
			ww.printFormat("-----ai%d操作了-----", self._seat)
		end
	end)
	
end

function RobotManager:_doDarkGang()
	--local gangzi = this:getHandCardsBySeat(self._seat):getGangzi()  --所有杠子
	--this:getHandCardsBySeat(self._seat):doDarkGang(gangzi[1])
	this:getHandCardsBySeat(self._seat):doDarkGang()
	this:getHandCardsBySeat(self._seat):mineFeelCard()  --再次上牌
end

function RobotManager:_doMGang()
	this:getHandCardsBySeat(self._seat):doMGang()
	this:getHandCardsBySeat(self._seat):mineFeelCard()  --再次上牌
end

function RobotManager:_doGang()
	this:getHandCardsBySeat(self._seat):doGang()
	this:getHandCardsBySeat(self._seat):mineFeelCard()  --再次上牌
end

function RobotManager:_doPeng()
	this:getHandCardsBySeat(self._seat):doPeng()
	local cards = this:getHandCardsBySeat(self._seat):getDrakCards()
	UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kPlayCard, cards[1])
end

function RobotManager:checkHu()

end

return RobotManager