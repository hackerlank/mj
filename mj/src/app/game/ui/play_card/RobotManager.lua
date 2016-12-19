local RobotManager = class("RobotManager", import(".PlayCardManager"))

local this = nil
function RobotManager:ctor(layer, cardWall)
	RobotManager.super.ctor(self, layer, cardWall)
	this = layer
end

--==================暂缓执行
function RobotManager:doAction()
	local listeners = {
		[self._actionEnum.dgang] = handler(self, self._doDarkGang),
		[self._actionEnum.mgang] = handler(self, self._doMGang),
		[self._actionEnum.gang] = handler(self, self._doGang),
		[self._actionEnum.peng] = handler(self, self._doPeng)
	}

	self:_start(function() 
		if listeners[self._recordAction] then
			this:startGlobalTimer(self._seat, 10)
			listeners[self._recordAction]()
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
	self._recordAction = 0
	self:playCard()
end

function RobotManager:checkHu()

end

--==========================================================

return RobotManager