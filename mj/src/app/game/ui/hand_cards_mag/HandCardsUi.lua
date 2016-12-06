--===========================================
--[[
	1.手牌统一放游戏界面上管理
	2.暗牌、明牌两部分
]]
--===========================================
local HandCardPos = import(".HandCardPos")
local HuCheck = require("app.game.control.HuCheck")
local HandCardsUi = class("HandCardsUi")

local kUpCardEnum = {
	error = 0,
	mine = 1, 
	other = 2
}

function HandCardsUi:ctor(parent)
	self._parent = parent

	self._isRobot = false
	self._seat = 0  --初始化的玩家
	self._darkCards = {}  --暗牌
	self._pengCards = {}  --明牌|碰
	self._gangCards = {}  --明牌|杠

	--每次手牌变动都要更新
	self._jiang = {}
	self._kezi = {}
	self._gangzi = {}

	self._huCheck = HuCheck.new(self)
	self._handCardPos = HandCardPos.new(self)
end

--初始化：发牌阶段上牌多张；开始过程上牌是一张一张的上的；所以只用于初始化发牌
function HandCardsUi:addHandCards(seat, cards)
	self._seat = seat
	for _,card in pairs(cards) do
		table.insert(self._darkCards, #self._darkCards+1, card)
	end

	self:_darkCardChange()
end

--===================================================
--手上暗牌有变化
function HandCardsUi:_darkCardChange()
	self._handCardPos:sortDarkCards()
	self:_setPramsByKey()  --找出将、刻子、杠子
end


--[[
	主要分有两种情况：1. 自己上牌 2. 他人出牌
]]
--优先处理自己的过程（其他人只会抓牌 出牌）

function HandCardsUi:_otherPlayCard(card)
	--检测碰、杠、胡
	table.insert(self._darkCards, #self._darkCards+1, card)
	local isPeng = self:_checkPeng(card)
	local isGang = self:_checkGang(card)
	local isHu = self._huCheck:checkHu()
	if not isPeng and not isGang and not isHu then
		table.remove(self._darkCards, #self._darkCards)
		return true
	end
end

--上牌(他人出牌时，上牌检测; 自己摸牌时上牌检测)
function HandCardsUi:upCard(type, card)
	local other_ret = false
	if type == kUpCardEnum.other then  --2
		other_ret = self:_otherPlayCard(card)
		return other_ret
	elseif type == kUpCardEnum.mine then  --1
		local cards= MjDataControl:getInstance():getCardMjArray(1)
		self:_mineFeelCard(cards[1])
	end
end

function HandCardsUi:playSuccess(card)
	self._handCardPos:playingCardParams(self._seat, card)
	table.remove(self._darkCards, card:getSortId())
	self:_darkCardChange()
end

--自己上牌
function HandCardsUi:_mineFeelCard(card)
	--检测 暗杠、自摸
	card:setSeat(self._seat)
	self._handCardPos:setUpCardParams(self._seat, card)
	table.insert(self._darkCards, #self._darkCards+1, card)
	local isDarkG = self:_checkDarkGang()
	local isHu = self._huCheck:checkHu()
end

---&***************Check**********************&---
function HandCardsUi:_checkPeng(card)
	for _,cards in pairs(self._jiang) do
		if cards[1]:getId() == card:getId() then
			print("----------检测到碰--------------")
			return true
		end
	end
end

--每次上牌时检测 暗杠
function HandCardsUi:_checkDarkGang()
	for _,cards in pairs(self._gangzi) do
		print("----------检测有暗杠--------------")
	end
end

function HandCardsUi:_checkGang(card)
	for _,cards in pairs(self._kezi) do
		if cards[1]:getId() == card:getId() then
			print("----------检测到杠--------------")
			return true
		end
	end
end

--===========================================================================

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

function HandCardsUi:getSeat()
	return self._seat
end

return HandCardsUi