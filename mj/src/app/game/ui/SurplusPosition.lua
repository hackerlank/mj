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
	local disW = 300
	local disH = 250
	local cardArray = MjDataControl:getInstance():getMjArray()
	if #cardArray == 108 then
		vecs = {26,28,26,28}
	elseif #cardArray == 136 then
		vecs = {34,34,34,34}
	end
	local pos1 = cc.p(display.cx-(vecs[1]+2)*mjCardBsxW/4, display.cy-disH)
	local pos2 = cc.p(display.cx+disW, display.cy+vecs[2]*mjCardBhH/4)
	local pos3 = cc.p(display.cx-(vecs[3]+2)*mjCardBsxW/4, display.cy+disH)
	local pos4 = cc.p(display.cx-disW, display.cy+vecs[4]*mjCardBhH/4)
	local posAr = {pos1, pos2, pos3, pos4}
	local function getPos(id, type)
		local x, y = posAr[type].x, posAr[type].y
		if id % 2 == 0 then
			if type == 1 or type == 3 then
				y = y + Wdis
			else
				posAr[type].y = posAr[type].y + Hdis
			end
		else
			if type == 1 or type == 3 then
				posAr[type].x = posAr[type].x + mjCardBsxW
			else
				posAr[type].y = posAr[type].y - mjCardBhH
			end
		end
		return cc.p(posAr[type].x, type % 2 ~= 0 and y or posAr[type].y)
	end
	for id,card in pairs(cardArray) do
		if id <= vecs[1] then
			table.insert(self._parent._allSurplusCards[1], #self._parent._allSurplusCards[2]+1, card)
			card:setSpriteFrame(mjCardBsx)
			card:setPosition(getPos(id, 1))
		elseif id <= (vecs[1]+vecs[2]) then
			table.insert(self._parent._allSurplusCards[2], #self._parent._allSurplusCards[2]+1, card)
			card:setSpriteFrame(mjCardBh)
			card:setPosition(getPos(id, 2))
		elseif id <= (vecs[1]+vecs[2]+vecs[3]) then
			table.insert(self._parent._allSurplusCards[3], #self._parent._allSurplusCards[3]+1, card)
			card:setSpriteFrame(mjCardBsx)	
			card:setPosition(getPos(id, 3))
		elseif id <= (vecs[1]+vecs[2]+vecs[3]+vecs[4]) then
			table.insert(self._parent._allSurplusCards[4], #self._parent._allSurplusCards[4]+1, card)
			card:setSpriteFrame(mjCardBh)
			card:setPosition(getPos(id, 4))
		end
		card:addTo(self._parent)
	end		
end

return SurplusPosition