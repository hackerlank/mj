local SecondTimer = require("app.game.ui.modules.SecondTimer")
local PlayCardManager = class("PlayCardManager")

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
	self._huIndex = 0  --胡牌还是自摸

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
	self:autoPlayCard(card)
end

--auto play card
function PlayCardManager:autoPlayCard(card)
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
		return
	end
	--2.检测手牌由没有缺牌， 找到缺牌打出
	local que_card = self._cardWall:findDarkCardsByQue()
	if que_card then
		self:_playCurrentCard(que_card)
		return
	end
	--3. 没有缺牌,抓什么打社
	local play_id = self:baseAIPlayCard()
	if play_id == 0 then
		--没有计算好，填补bug
		if card then
			self:_playCurrentCard(card)
		else
			local card_list = self._cardWall:getDrakCards()
			self:_playCurrentCard(card_list[1])
		end
	else
		self:_playCurrentCard(self:_checkPlayCardById(play_id))
	end
end

function PlayCardManager:_checkPlayCardById(id)
	for _,card in pairs(self._cardWall:getDrakCards()) do
		if card:getId() == id then
			return card
		end
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

function PlayCardManager:checkHu(ret, index, card)
	--index 1: 自摸 2:胡
	if ret then
		self._recordAction = self._actionEnum.hu
		self._huIndex = index
		self._huCard = card
	end
end

--=====================================
------智能出牌---------
--[[
	1. 锁定 顺子
	2. 锁定 刻子
	3. 定级 对子
	4. 相近牌等级
	5. 出散牌
]]

local function dumps(list)
	-- local lockedS = "锁定:"
	-- local nLockeds = "未锁定:"
	-- for _,card in pairs(list) do
	-- 	if not card._isLocked then
	-- 		nLockeds = nLockeds .. card:getName() .. ","
	-- 	else
	-- 		lockedS = lockedS .. card:getName() .. ","
	-- 	end
	-- end
	-- print(lockedS)
	-- print(nLockeds)
end

function PlayCardManager:dumpThree(list)
	local cardsr = ""
	if self._cardWall:getSeat() == 1 and #list == 3 then
		print(">>>>>>>>>>>>>>>>>来年了")
		for _,card in pairs(list) do
			cardsr = cardsr .. string.format("等%d张", card) .. ","
		end
	end
	print(cardsr)
end

function PlayCardManager:baseAIPlayCard()
	--克隆一副手牌操作
	--这时候的手牌是需要出牌时候的手牌，也就是上牌之后
	local card_list = clone(self._cardWall:getDrakCards()) 
	self:_splitDarkCards(card_list) 
	self._lockedList = {{}, {}, {}}  --锁定列表
	
	--锁定顺子
	self:_lockedShun()
	self:_locakedKezi()
	self:_setLevelDoule()
	self:_setLevelClose()

	for _,list in pairs(self._cardAll) do
		if self._cardWall:getSeat() == 1 then
			dumps(list)
		end
	end

	local pcard = nil
	local min_level = 100
	for index,cards in pairs(self._cardAll) do
		for id,card in pairs(cards) do
			if self:_checkNotAtLockedList(index, id) and card._level < min_level then
				min_level = card._level
				pcard = card
			end
		end
	end
	if not pcard then return 0 end
	return pcard:getId()
end

function PlayCardManager:_checkNotAtLockedList(index, id)
	for _,val in pairs(self._lockedList[index]) do
		if val == id then
			return false
		end
	end
	return true
end

function PlayCardManager:_splitDarkCards(dark_list)
	self._cardAll = {}
	local que_type = self._cardWall:getQueType()
	for _,card in pairs(dark_list) do
		local card_type = card:getType()
		if card_type ~= que_type then
			if not self._cardAll[card_type] then
				self._cardAll[card_type] = {}
			end
			table.insert(self._cardAll[card_type], #self._cardAll[card_type]+1, card)
		end
	end
end

--顺子
function PlayCardManager:_lockedShun()
	local function checkThree(index, cards)
		for idex, card in pairs(cards) do
			local threeCards = {idex}
			local curId = card:getId()
			for _idex = idex+1, #cards do
				if cards[_idex]:getId() == curId+1 and self:_checkNotAtLockedList(index, _idex) then
					--table.insert(threeCards, #threeCards+1, cards[_idex])
					threeCards[2] = _idex
				end
			end

			for _idex = idex+1, #cards do
				if cards[_idex]:getId() == curId+2 and self:_checkNotAtLockedList(index, _idex) then
					--table.insert(threeCards, #threeCards+1, cards[_idex])
					threeCards[3] = _idex
				end
			end
			self:dumpThree(threeCards)
			if #threeCards == 3 then 
				for _,id in pairs(threeCards) do
					self._lockedList[index][id] = id
					--card._isLocked = true
				end
			end
		end
	end

	for index, cards in pairs(self._cardAll) do
		--条、筒、万
		checkThree(index, cards)
	end
end
--刻子
function PlayCardManager:_locakedKezi()
	for index,cards in pairs(self._cardAll) do
		for idex,card in pairs(cards) do
			if self:_checkNotAtLockedList(index, idex) then
				local curId = card:getId()
				threeCards = {idex}
				for _idex = idex+1, #cards do
					if cards[_idex]:getId() == curId and self:_checkNotAtLockedList(index, _idex) then
						table.insert(threeCards,#threeCards+1, _idex)
					end
				end

				if #threeCards >= 3 then
					for id,val in pairs(threeCards) do
						if id <= 3 then
							--card._isLocked = true
							self._lockedList[index][val] = val
						end
					end
				end
			end
		end
	end
end

--对子等级
function PlayCardManager:_setLevelDoule()
	for index,cards in pairs(self._cardAll) do
		for idex,card in pairs(cards) do
			if self:_checkNotAtLockedList(index, idex) then
				local twoCards = {card}
				local curId = card:getId()
				for _idex = idex+1, #cards do
					if cards[_idex]:getId() == card:getId() and self:_checkNotAtLockedList(index, _idex) then
						table.insert(twoCards, #twoCards+1, cards[_idex])
					end
				end
				if #twoCards == 2 then
					card._level = card._level + 1
				end
			end
		end
	end
end
--相近牌等级(相邻+2， 相近+1)
function PlayCardManager:_setLevelClose()
	for index,cards in pairs(self._cardAll) do
		for idex,card in pairs(cards) do
			if self:_checkNotAtLockedList(index, idex) then
				local curId = card:getId()
				for _idex = idex+1, #cards do
					if self:_checkNotAtLockedList(index, _idex) then
						--检查到一个相邻 +2
						local nexId = cards[_idex]:getId()
						if math.abs(nexId-curId) == 1 then
							card._level = card._level + 2
							cards[_idex]._level = cards[_idex]._level + 2
						end
						--检测到一个相近 +1
						if math.abs(nexId-curId) == 2 then
							card._level = card._level + 1
							cards[_idex]._level = cards[_idex]._level + 1
						end
					end
				end
			end
		end
	end
end
-- --散牌
-- function PlayCardManager:_setLevelBulk()

-- end

return PlayCardManager