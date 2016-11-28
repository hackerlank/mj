local SurplusPosition = class("SurplusPosition")

--要求 居中展示
--四川麻将 108张牌 
--国际麻将 136 张
function SurplusPosition:ctor(parent)
	self._parent = parent

	self:setupUi()
end

function SurplusPosition:setupUi()
	--mjCardBhH
	--mjCardBsxW
	local Hdis = 10
	local Wdis = 15
	local disW = 250
	local disH = 200
	local cardArray = MjDataControl:getInstance():getMjArray()
	if #cardArray == 108 then
		vecs = {26,28,26,28}
	elseif #cardArray == 136 then
		vecs = {34,34,34,34}
	end
	local pos1 = cc.p(display.cx-(vecs[1]+2)*mjCardBsxW/4, display.cy-disH)
	local pos2 = cc.p(display.cx+disW, display.cy-(vecs[2]-5)*mjCardBhH/4)
	local pos3 = cc.p(display.cx+(vecs[3]+2)*mjCardBsxW/4, display.cy+disH)
	local pos4 = cc.p(display.cx-disW, display.cy+(vecs[4]-5)*mjCardBhH/4)
	local posAr = {pos1, pos2, pos3, pos4}

	local Type2Index = 28
	local Type1Index = 26
	local Type3Index = 26
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
				Type2Index = Type2Index - 1
			else
				posAr[type].y = posAr[type].y - mjCardBhH
			end
		end
		return cc.p(posAr[type].x, type % 2 ~= 0 and y or posAr[type].y)
	end
	
	for id,card in pairs(cardArray) do

		--標志位： card_bpos:哪一家上 card_bid: 序號
		if id <= vecs[1] then
			card:setSpriteFrame(mjCardBsx)
			card:setPosition(getPos(id, 1))
			card:addTo(self._parent, Type1Index)
			Type1Index = Type1Index - 1
		elseif id <= (vecs[1]+vecs[2]) then
			card:setSpriteFrame(mjCardBh)
			card:setPosition(getPos(id, 2))
			card:addTo(self._parent, Type2Index)
		elseif id <= (vecs[1]+vecs[2]+vecs[3]) then
			card:setSpriteFrame(mjCardBsx)	
			card:setPosition(getPos(id, 3))
			card:addTo(self._parent, Type3Index)
			Type3Index = Type3Index - 1
		elseif id <= (vecs[1]+vecs[2]+vecs[3]+vecs[4]) then
			card:setSpriteFrame(mjCardBh)
			card:setPosition(getPos(id, 4))
			card:addTo(self._parent)
		end
	end		
end

return SurplusPosition