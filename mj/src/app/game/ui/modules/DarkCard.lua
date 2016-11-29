local DarkCard = class("DarkCard", import(".Card"))

function DarkCard:ctor(seat)
	DarkCard.super.ctor(self)

	self:setTouchEnabled(true)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self._darkCardTouchListener))
end

function DarkCard:changeId(id)
	DarkCard.super.changeId(self, id)
	self:setSpriteFrame(string.format("x_%d.png", id))
end

--
function DarkCard:recoverCard()
	self:setSpriteFrame(string.format("x_%d.png", self._id))
end

function DarkCard:_darkCardTouchListener(event)
	if event.name == "began" then
		UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kPlayCard, self)
		return false
	end
end

return DarkCard