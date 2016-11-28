local DarkCard = class("DarkCard", import(".Card"))

function DarkCard:ctor(seat)
	DarkCard.super.ctor(self)
end

function DarkCard:changeId(id)
	DarkCard.super.changeId(self, id)
	self:setSpriteFrame(string.format("x_%d.png", id))
end

--
function DarkCard:recoverCard()
	self:setSpriteFrame(string.format("x_%d.png", self._id))
end

return DarkCard