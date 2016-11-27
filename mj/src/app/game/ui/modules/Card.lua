--所有牌的基類
local Card = class("Card", function() return display.newSprite() end)

function Card:ctor()
	self._id = nil
	self._name = nil
	self._type = nil
end		

function Card:changeId(id)
	self._id = id
	--計算
	self._name = mjCardTxt[self._id]
	self._type = mjCardType[math.ceil(self._id/9)]
end

function Card:getId()
	return self._id
end

function Card:getType()
	return self._type
end

function Card:getName()
	return self._name
end

return Card