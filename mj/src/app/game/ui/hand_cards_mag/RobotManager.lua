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

	self._recordAction = 0  -- 记录可做的操作是什么
end

function RobotManager:waitPlayCard(card)
	UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kPlayCard, card)
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
	local card = this:getHandCardsBySeat(self._seat):getDarkList()[1]
	UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kPlayCard, card)
end

function RobotManager:checkHu()

end

return RobotManager