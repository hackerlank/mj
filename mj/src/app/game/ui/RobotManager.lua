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

function RobotManager:ctor(layer, cardWall)
	this = layer
	self._cardWall = cardWall
	self._seat = self._cardWall:getSeat()

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

--[[
	1. 定缺（选择最少的一门：{
		level 1: 相同则选择前一门
		level 2: 相同或相差一张牌， 估算权值
	}）

	2.上牌
	
]]

function RobotManager:playCard(card)
	--card: 抓上来的手牌
	if self._recordAction > 0 then
		--有操作执行 跳过执行
		return
	end
	--(碰牌的时候没有抓牌)
	--1.检测杠抓上来的牌是不是缺牌, 是缺牌直接打出 
	if card and card:getIsQue() then
		--直接打出
		self:_playCurrentCard(card)
	end
	--2.检测手牌由没有缺牌， 找到缺牌打出
	local que_card = self._cardWall:findDarkCardsByQue()
	if que_card then
		self:_playCurrentCard(que_card)
	end
	--3.
	local card_list = self._cardWall:getDrakCards()
	self:_playCurrentCard(card_list[1])
end

function RobotManager:_playCurrentCard(card)
	self:_start(function() 
		UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kPlayCard, card)
	end)
	
end

function RobotManager:_checkQueCard(card)
	return card:getIsQue()
end

return RobotManager