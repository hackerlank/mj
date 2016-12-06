--[[
	這個類型只用来设置手牌位置
	包括【暗、碰、杠（明、暗）、胡、打出、上牌】
]]
local HandCardPos = class("HandCardPos")

function HandCardPos:ctor(hand_card)
	self._handCard = hand_card  --手牌类

	self._playCardNum = 0  --已打出多少张牌
	self._numIndex = 0
end

--[[
	首先对暗牌进行排序和位置设定
]]

function HandCardPos:sortDarkCards()
	local seat = self._handCard:getSeat()
	local cards = self._handCard:getDarkList()
	
	local sortFunc = function(a,b) return a:getId() < b:getId() end
	table.sort(cards, sortFunc)

	for _,card in pairs(cards) do
		local beganPos = mjDarkPositions[seat]
		card:setSeat(seat)
		card:setCardType(mjDCardType.mj_dark)
		card:setSortId(_)
		if seat == 1 then  --66*94
			card:pos(beganPos.x + 66* _, beganPos.y)
		elseif seat == 2 then  --16*40
			card:pos(beganPos.x, beganPos.y + 40* _)
		elseif seat == 3 then  --66* 94
			card:pos(beganPos.x - 66* _, beganPos.y)
		else
			card:pos(beganPos.x, beganPos.y - 40* _)
		end
	end
end

--[[
	上牌位置
]]

function HandCardPos:setUpCardParams(card)
	local seat = self._handCard:getSeat()
	local cards = self._handCard:getDarkList()

	local num = #cards + 1
	local beganPos = mjDarkPositions[seat]
	if seat == 1 then  --66*94
		card:pos(66 * num + 90, beganPos.y)
	elseif seat == 2 then  --16*40
		card:pos(beganPos.x, beganPos.y + 40 * num + 30)
	elseif seat == 3 then  --66* 94
		card:pos(beganPos.x - 66* num - 90, beganPos.y)
	else
		card:pos(beganPos.x, beganPos.y - 40* num - 30)
	end
end

--[[
	打出手牌位置
]]
function HandCardPos:setPlayCardPos(card)
	local seat = self._handCard:getSeat()
	if seat == 1 then
		self:_seat1PlayPos(card)
	elseif seat == 2 then
		self:_seat2PlayPos(card)
	elseif seat == 3 then
		self:_seat3PlayPos(card)
	elseif seat == 4 then
		self:_seat4PlayPos(card)
	end
	self._playCardNum = self._playCardNum + 1
	self._numIndex = self._numIndex + 1
	if self._numIndex%8 == 0 then
		self._numIndex = 0
	end
end

function HandCardPos:_seat1PlayPos(card)
	local beganP = mjPlayPositions[1]
	local disX = math.floor(self._playCardNum/8) * 47
	card:pos(beganP.x + self._numIndex * 33, beganP.y-disX)
end

function HandCardPos:_seat2PlayPos(card)
	local beganP = mjPlayPositions[2]
	local disX = math.floor(self._playCardNum/8) * 40
	card:pos(beganP.x + disX, beganP.y + self._numIndex * 37)
end

function HandCardPos:_seat3PlayPos(card)
	local beganP = mjPlayPositions[3]
	local disX = math.floor(self._playCardNum/8) * 47
	card:pos(beganP.x - self._numIndex * 33, beganP.y+disX)
end

function HandCardPos:_seat4PlayPos(card)
	local beganP = mjPlayPositions[4]
	local disX = math.floor(self._playCardNum/8) * 40
	card:pos(beganP.x-disX, beganP.y-self._numIndex * 37)
end

return HandCardPos