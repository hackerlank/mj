--===========================================
--[[
	1.手牌统一放游戏界面上管理
	2.暗牌、明牌两部分
	
	1.手牌、暗牌、杠牌、胡牌、碰牌
	AI:
		
	玩家:
		1.操作界面 （检测到 杠、碰、胡、过）
]]
--===========================================
local HandCardPos = import(".HandCardPos")
local HuCheck = require("app.game.control.HuCheck")
local RobotManager = import(".RobotManager")
local PlayerManager = import(".PlayerManager")
local HandCardsUi = class("HandCardsUi")

local kUpCardEnum = {
	error = 0,
	mine = 1, 
	other = 2
}

local this = nil

function HandCardsUi:ctor(layer)
	this = layer
	self._manager = nil   --反应管理（AI和玩家区别）

	self._seat = 0  --初始化的玩家
	self._darkCards = {}  --暗牌
	self._showCards = {}  --明牌|碰
	self._huCards = {}  --胡牌里列表

	--每次手牌变动都要更新
	self._jiang = {}
	self._kezi = {}
	self._gangzi = {}

	--存入碰牌
	self._peng = nil  --碰只能有一对
	self._gang = nil

	self._huCheck = HuCheck.new(self)
	self._handCardPos = HandCardPos.new(self)
end

--初始化：发牌阶段上牌多张；开始过程上牌是一张一张的上的；所以只用于初始化发牌
function HandCardsUi:addHandCards(seat, cards)
	self._seat = seat
	if seat == 1 then
		self._manager = PlayerManager.new()
	else
		self._manager = RobotManager.new(this, seat)
	end
	for id,card in pairs(cards) do
		card:setIsMine(seat == 1)
		table.insert(self._darkCards, #self._darkCards+1, card)
	end

	self:_darkCardChange()
end

--===================================================
--手上暗牌有变化
function HandCardsUi:_darkCardChange()
	self._handCardPos:sortDarkCards()
	self:_setPramsByKey()  --找出将、刻子、杠子
	self._handCardPos:setShowCardPos()
end


--[[
	主要分有两种情况：1. 自己上牌 2. 他人出牌
]]
--优先处理自己的过程（其他人只会抓牌 出牌）
--自己上牌
function HandCardsUi:mineFeelCard()
	local card= MjDataControl:getInstance():getCardMjArray(1)[1]
	card:setSeat(self._seat)
	card:setIsMine(self._seat == 1)
	card:setCardType(mjDCardType.mj_dark)
	self._handCardPos:setUpCardParams(card)
	card:setSortId(#self._darkCards+1)
	table.insert(self._darkCards, #self._darkCards+1, card)

	--检测 暗杠、自摸
	self:_setPramsByKey()  --找出杠子等牌,检测杠
	self._manager:checkDarkGang(self:_checkDarkGang()) --检测暗杠
	self._manager:checkHu(self._huCheck:checkHu(), 1, card) --检测暗杠
	self._manager:waitPlayCard(card)
end


function HandCardsUi:otherPlayCard(card)
	--检测碰、杠、胡
	--self:_setPramsByKey()  --找出杠子等牌,检测杠
	local isGang = self:_checkGang(card)
	self._manager:checkGang(isGang)
	local isPeng = self:_checkPeng(card)
	self._manager:checkPeng(isPeng)
	local isHu = self._huCheck:checkHu(card)
	self._manager:checkHu(isHu, 2, card)
	local fighting_type = nil
	if isHu then
		fighting_type = mjFighintInfoType.hu
	elseif isGang then
		fighting_type = mjFighintInfoType.gang
	elseif isPeng then
		fighting_type = mjFighintInfoType.peng
	end
	GDataManager:getInstance():setFighingInfo(self._seat, fighting_type)
end

--===============================================
--重置
function HandCardsUi:retsetPeng()
	self._peng = nil
end

function HandCardsUi:resetGang()
	self._gang = nil
end
--===============================================

function HandCardsUi:playCardSuccess(card)
	self._handCardPos:setPlayCardPos(card)
	table.remove(self._darkCards, card:getSortId())
	self:_darkCardChange() --未加入插入动画

	self:retsetPeng()
	self:resetGang()
end

---&***************Check**********************&---
function HandCardsUi:_checkPeng(card)
	for _,cards in pairs(self._jiang) do
		if cards[1]:getId() == card:getId() then
			table.insert(cards, #cards+1, card)
			self._peng = cards
			return true
		end
	end
end

--每次上牌时检测 暗杠
function HandCardsUi:_checkDarkGang()
	return (#self._gangzi > 0)
end

function HandCardsUi:_checkGang(card)
	for _,cards in pairs(self._kezi) do
		if cards[1]:getId() == card:getId() then
			table.insert(cards, #cards+1, card)
			self._gang = cards
			return true
		end
	end
end
---&***************do check**********************&---
function HandCardsUi:_removeCards(cards)
	local index = 0
	for _,_card in pairs(cards) do
		for id,__card in pairs(self._darkCards) do
			if _card:getId() == __card:getId() then
				table.remove(self._darkCards, __card:getSortId() - index)
				index = index + 1
				break
			end
		end
	end
end

function HandCardsUi:_doActionAfter()

end

--明杠只有一个 暗杠可能有多个
function HandCardsUi:doGang()
	if self._gang then
		table.insert(self._showCards, {
			type = mjNoDCardType.dgang,
			value = self._gang
			})
		self:_removeCards(self._gang)
		self:_darkCardChange()

		GDataManager:getInstance():resetSortFightInfo(true)
		this:updateSeatIndex(self._seat)
	end
end

--[[
	手上本来就有一副暗杠， 又检测到明杠
]]
function HandCardsUi:doDarkGang(cards)
	table.insert(self._showCards, {
		type = mjNoDCardType.dgang,
		value = cards
	})
	self:_removeCards(cards)
	self:_darkCardChange()
end

function HandCardsUi:doPeng()
	if self._peng then
		table.insert(self._showCards, {
			type = mjNoDCardType.peng,
			value = self._peng
			})
		self:_removeCards(self._peng)
		self:_darkCardChange()
		self._peng = nil

		GDataManager:getInstance():resetSortFightInfo(true)
		this:updateSeatIndex(self._seat)
	end
end
--===========================================================================
--胡牌列表
function HandCardsUi:insertHuCard(card)
	table.insert(self._huCards, #self._huCards+1, card)
	self._handCardPos:huCardsPositions(card)
end

--分割手牌
function HandCardsUi:_setPramsByKey()
	--分组存放（把刻字、杠子、将牌）罗列出来
	--暗牌每次有发生变化都要重新排列
	self._jiang = {}
	self._kezi = {}
	self._gangzi = {}
	local tmp = {}
	for _,card in pairs(self._darkCards) do
		local id = card:getId()
		if not tmp[id] then
			tmp[id] = {}
		end
		table.insert(tmp[id], #tmp[id] + 1, card)
	end
	for _,val in pairs(tmp) do
		if #val == 2 then
			table.insert(self._jiang, #self._jiang+1, val)
		elseif #val == 3 then
			--要把刻子放入将牌（能杠则能碰）
			table.insert(self._jiang, #self._jiang+1, {val[1], val[2]})
			table.insert(self._kezi, #self._kezi+1, val)
		elseif #val == 4 then
			table.insert(self._gangzi, #self._gangzi+1, val)
		end
	end
end
--get
function HandCardsUi:getDarkList()
	return self._darkCards
end

function HandCardsUi:getJiang()
	return self._jiang
end

function HandCardsUi:getKezi()
	return self._kezi
end

function HandCardsUi:getGangzi()
	return self._gangzi
end

function HandCardsUi:getShowCards()
	return self._showCards
end

function HandCardsUi:getSeat()
	return self._seat
end

function HandCardsUi:getHandCardPos()
	return self._handCardPos
end

function HandCardsUi:getManager()
	return self._manager
end

function HandCardsUi:getHuCheck()
	return self._huCheck
end

function HandCardsUi:getHuCards()
	return self._huCards
end

return HandCardsUi