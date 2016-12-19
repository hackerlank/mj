local SecondTimer = require("app.game.ui.modules.SecondTimer")
local PlayCardManager = class("PlayCardManager")

local kActionEnum = {
	hu = 1,
	dgang = 2,
	mgang = 3,
	gang = 4,
	peng = 5
}


--共同点
--[[
	1. 自动出牌（1.缺牌直接出， 检测手中缺牌打出）
	2. 自己 杠， 自己胡
]]
local this = nil

function PlayCardManager:ctor(layer, cardWall)
	this = layer
	self._cardWall = cardWall
	self._seat = self._cardWall:getSeat()

	self._thinkTime = SecondTimer.new()
	self._recordAction = 0

	self._actionEnum = {
		hu = 1,
		dgang = 2,
		mgang = 3,
		gang = 4,
		peng = 5
	}
end

function PlayCardManager:_start(listener)
	local params = {
		time = 1,
		total_seconds = 1,
		end_listener = listener
	}
	self._thinkTime:start(params)
end

function PlayCardManager:playCard(card)
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
	--3. 没有缺牌,抓什么打社么
	if card then
		self:_playCurrentCard(card)
	else
		local card_list = self._cardWall:getDrakCards()
		self:_playCurrentCard(card_list[1])
	end
end

function PlayCardManager:_playCurrentCard(card)
	self:_start(function() 
		UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kPlayCard, card)
	end)
end

--todo:  在做检测的时候就自动出牌了
--检测到暗杠
function PlayCardManager:checkDarkGang(ret)
	if ret then
		self._recordAction = self._actionEnum.dgang
	end
end

function PlayCardManager:checkMGang(ret)
	if ret then
		self._recordAction = self._actionEnum.mgang
	end
end

function PlayCardManager:checkGang(ret)
	if ret then
		self._recordAction = self._actionEnum.gang
	end
end

function PlayCardManager:checkPeng(ret)
	if ret then
		self._recordAction = self._actionEnum.peng
	end
end

return PlayCardManager