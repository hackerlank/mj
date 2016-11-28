--===========================================
--[[
	1.手牌统一放游戏界面上管理
	2.暗牌、明牌两部分
]]
--===========================================
local HandCardByPos = import(".HandCardByPos")
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
	self._handCardByPos = HandCardByPos.new()
	self._seat = 0  --初始化的玩家
	self._darkCards = {}
	self._openCards = {}

	--
	self._jiang = {}
	self._kezi = {}
	self._gangzi = {}

	self._huCheck = HuCheck.new(self)
end

--初始化：开始阶段满手牌（暗牌）(4\4\5)
function HandCardsUi:addHandCards(seat, cards)
	self._seat = seat
	for _,card in pairs(cards) do
		if seat ~= 1 then
			card:setSpriteFrame(mjDarkBack[seat])
		else
			card:recoverCard()
		end
		table.insert(self._darkCards, #self._darkCards+1, card)
	end

	self:_darkCardChange()
end

--===================================================
function HandCardsUi:_darkCardChange()
	self._handCardByPos:update(self._seat, self._darkCards)
	self:_setPramsByKey()
end
-----------对暗牌的处理--------------
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

--上牌(他人出牌时，上牌检测; 自己摸牌时上牌检测)
function HandCardsUi:upCard(type, card)
	if type == kUpCardEnum.other then
		self:_otherPlayCard(card)
	elseif type == kUpCardEnum.mine then
		local cards= MjDataControl:getInstance():getCardMjArray(1)
		self:_mineFeelCard(cards[1])
	end
end

function HandCardsUi:_playSuccess(card)
	card:pos(display.cx, display.cy)
	--table.remove()
end

function HandCardsUi:_otherPlayCard(card)
	--检测碰、杠、胡
	local isPeng = self:_checkPeng(card)
	local isGang = self:_checkGang(card)
	local isHu = self._huCheck:checkHu(card)

end

function HandCardsUi:_mineFeelCard(card)
	--检测 暗杠、自摸
	table.insert(self._darkCards, #self._darkCards+1, card)
	local isDarkG = self:_checkDarkGang()
	local isHu = self._huCheck:checkHu(card)
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
--
function HandCardsUi:_upCardAction()
	--card:setRota
end

return HandCardsUi