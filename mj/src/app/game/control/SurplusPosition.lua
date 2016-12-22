--[[
	初始化所有的麻將放置在桌面上，所有麻将个数应该是固定的
]]
local SurplusPosition = class("SurplusPosition")

--要求 居中展示
--四川麻将 108张牌 
--国际麻将 136 张
local this = nil
local vecs = {}
function SurplusPosition:ctor(layer)
	this = layer

	self:setupUi()
end

function SurplusPosition:setupUi()
	--mjCardBhH
	--mjCardBsxW
	local Hdis = 10
	local Wdis = 15
	local disW = 370
	local disH = 240
	local cardArray = MjDataControl:getInstance():getMjArray()
	local sz_number = MjDataControl:getInstance():getSZNumber()
	if #cardArray == 108 then
		vecs = {28,26,28,26}
	elseif #cardArray == 136 then
		vecs = {34,34,34,34}
	end
	local pos1 = cc.p(display.cx-(vecs[1]+2)*mjCardBsxW/4, display.cy-disH + mjCardBhH*0.6)
	local pos2 = cc.p(display.cx+disW, display.cy-(vecs[2]-5)*mjCardBhH/4)             
	local pos3 = cc.p(display.cx+(vecs[3]+2)*mjCardBsxW/4, display.cy+disH+45)
	local pos4 = cc.p(display.cx-disW, display.cy+(vecs[4]-5)*mjCardBhH/4)
	local posAr = {pos1, pos2, pos3, pos4}

	local function getPos(id, type)
		local x, y = posAr[type].x, posAr[type].y
		if id % 2 == 0 then
			if type == 1 or type == 3 then
				y = y - Wdis
			else
				posAr[type].y = posAr[type].y + Hdis
			end
		else
			if type == 1 then
				posAr[type].x = posAr[type].x + mjCardBsxW
			elseif type == 3 then
				posAr[type].x = posAr[type].x - mjCardBsxW
			elseif type == 2 then
				posAr[type].y = posAr[type].y + mjCardBhH/2
			else
				posAr[type].y = posAr[type].y - mjCardBhH
			end
		end
		return cc.p(posAr[type].x, type % 2 ~= 0 and y or posAr[type].y)
	end
	for id,card in pairs(cardArray) do
		--標志位： card_bpos:哪一家上 card_bid: 序號
		if id <= vecs[1] then
			card:setSeat(1)
			card:setPosition(getPos(id, 1))
			card:addTo(this)
		elseif id <= (vecs[1]+vecs[2]) then
			card:setSeat(2)
			card:setPosition(getPos(id, 2))
			card:addTo(this)
		elseif id <= (vecs[1]+vecs[2]+vecs[3]) then
			card:setSeat(3)	
			card:setPosition(getPos(id, 3))
			card:addTo(this)
		elseif id <= (vecs[1]+vecs[2]+vecs[3]+vecs[4]) then
			card:setSeat(4)
			card:setPosition(getPos(id, 4))
			card:addTo(this)
		end
		card:setCardType(mjDCardType.mj_init)
	end		
end

local function checkIdVec(card, id, x, y)
	if id % 2 == 0 then
		card:pos(X(card)+x, Y(card)+y)
	end
end

local function NcheckIdVec(card, id, x, y)
	if id % 2 ~= 0 then
		card:pos(X(card)+x, Y(card)+y)
	end
end

function SurplusPosition:setSurplusCardsPosition(sz_number)
	if sz_number == 1 or sz_number == 4 or sz_number == 5 then
		self:_updateCardsLocalZorder1()
	else
		self:_updateCardsLocalZorder()
	end
end

function SurplusPosition:_updateCardsLocalZorder()
	local cardArray = MjDataControl:getInstance():getMjArray()
	local Type2Index = 60
	local Type1Index = 1
	local Type3Index = 1
	local Type4Index = 10

	local zoerder2 = 0
	for id,card in pairs(cardArray) do
		if id <= vecs[1] then
			card:setLocalZOrder(Type1Index)
			Type1Index = Type1Index + 1
			checkIdVec(card, id, 0, 25)
		elseif id <= (vecs[1]+vecs[2])then
			if id%2 ~= 0 then
				card:setLocalZOrder(Type2Index-1)
			else
				card:setLocalZOrder(Type2Index)
				Type2Index = Type2Index - 2
			end
		elseif id <= (vecs[1]+vecs[2]+vecs[3]) then
			card:setLocalZOrder(Type3Index)
			Type3Index = Type3Index + 1
			checkIdVec(card, id, 0, 25)
		elseif id <= (vecs[1]+vecs[2]+vecs[3]+vecs[4]) then
			card:setLocalZOrder(Type4Index)
			Type4Index = Type4Index + 1
		end
	end
end

function SurplusPosition:_updateCardsLocalZorder1()
	local cardArray = MjDataControl:getInstance():getMjArray()
	local Type2Index = 60
	local Type1Index = 60
	local Type3Index = 60
	local Type4Index = 10

	local zoerder2 = 0
	for id,card in pairs(cardArray) do
		if id <= vecs[1] then
			card:setLocalZOrder(Type1Index)
			Type1Index = Type1Index - 1
		elseif id <= (vecs[1]+vecs[2])then
			card:setLocalZOrder(Type2Index)
			Type2Index = Type2Index - 1
			checkIdVec(card, id, 0, 27)
		elseif id <= (vecs[1]+vecs[2]+vecs[3]) then
			card:setLocalZOrder(Type3Index)
			Type3Index = Type3Index - 1
			checkIdVec(card, id, 0, -0)
		elseif id <= (vecs[1]+vecs[2]+vecs[3]+vecs[4]) then
			if id%2 == 0 then
				card:setLocalZOrder(Type4Index-1)
				Type4Index = Type4Index + 2
			else
				card:setLocalZOrder(Type4Index)
			end
			NcheckIdVec(card, id, 0, 20)
		end
	end
end

return SurplusPosition