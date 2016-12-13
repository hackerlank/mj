--[[
	1. 只有一副牌<明牌、暗牌>
	2. 将、刻子、杠子(碰牌属于明刻、杠牌属于明杠)
	3. 检测 杠、碰、暗杠、碰杠
]]
local HandCardPos = import("..HandCardPos")
local RobotManager = import("..RobotManager")
local PlayerManager = import("..PlayerManager")

local CardWallUi = class("CardWallUi")

local this = nil
function CardWallUi:ctor(layer)
	this = layer

	self._seat = 0
	slef._cardWall = {}
	self._huCards = {}

	self._jiang = {}  --暗 
	self._kezi = {}   --明(碰牌属于明刻)、暗
	self._gangzi = {} --暗

	self._dgangzi = {}

	self._peng = {}  --可碰列表
	self._gang = {}  --可杠列表

	self._handCardPos = HandCardPos.new(self)
end

--初始化：发牌阶段上牌多张；开始过程上牌是一张一张的上的；所以只用于初始化发牌
function CardWallUi:addHandCards(seat, cards)
	self._seat = seat
	if seat == 1 then
		self._manager = PlayerManager.new()
	else
		self._manager = RobotManager.new(this, seat)
	end
	for id,card in pairs(cards) do
		card:setIsMine(seat == 1)
		table.insert(self._cardWall, #self._cardWall+1, card)
	end

	self:_darkCardChange()
end

--找出所有暗牌
function CardWallUi:findDarkCards()
	for _,card in pairs(self._cardWall) do
		if card:getIsDark() then
			
		end
	end
end

--分割手牌(找出 将、刻、杠)
function CardWallUi:_setPramsByKey()
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

--手牌有变化
function CardWallUi:_darkCardChange()
	self._handCardPos:sortDarkCards()
	self:_setPramsByKey()  --找出将、刻子、杠子
	self._handCardPos:setShowCardPos()
end

--================================================
--*set & get*
function CardWallUi:getCardWall()
	return self._cardWall
end

function CardWallUi:getJiang()
	return self._jiang
end

function CardWallUi:getKezi()
	return self._kezi
end

function CardWallUi:getGangzi()
	return self._gangzi
end

-- function CardWallUi:getShowCards()
-- 	return self._showCards
-- end

function CardWallUi:getSeat()
	return self._seat
end

function CardWallUi:getHuCards()
	return self._huCards
end 

function CardWallUi:getHandCardPos()
	return self._handCardPos
end

function CardWallUi:getManager()
	return self._manager
end

-- function CardWallUi:getHuCheck()
-- 	return self._huCheck
-- end

return CardWallUi