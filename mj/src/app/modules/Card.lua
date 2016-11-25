local MakingTile = import(".MakingTile")
local Card = class("Card")

function Card:ctor()
	self._id = 0
	self._type = 0
	self._arrayType = 0
	self._name = 0
	self._sortId = 0  --这个目前用于手牌中排序位置依据
	self._selected = false
	self._state = 1  --{1.手牌、2打出}
	--ui
	self._touchTime = 0
	self._selectedIndex = 0
	self.m_scheduler_handler = nil
	self._sprite = MakingTile.new()
	self._sprite:setTouchEnabled(true)
	self._sprite:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self._spriteTouchEventListener))
end

function Card:_spriteTouchEventListener(event)
	local zorder = self._sprite:getLocalZOrder()
	if event.name == "began" then
		if not self.m_scheduler_handler then
        	self.m_scheduler_handler = scheduler.scheduleGlobal(handler(self, self._countTouchtime), 0.05)
    	end
    	self._selectedIndex = self._selectedIndex + 1
    	print("---------index------", self._selectedIndex)
    	if self._selectedIndex == 1 then
    		self:_setSelected(not self._selected)
    	elseif self._selectedIndex == 2 then
    		if self._selected then
    			self:_endSchduler()
    			self._state = 2
    			UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kPlayerCard, self)
    		else
    			self._selectedIndex = 1
    			self:_setSelected(not self._selected)
    		end
    	end

    	touchX, touchY = event.x, event.y
    	return true
	elseif event.name == "moved" then
		if touchMoveDistance(touchX, touchY, event.x, event.y) then
			self._sprite:pos(event.x, event.y)
			self._sprite:setOpacity(200)
			self._sprite:setScale(GCardScale+0.1)
			self._sprite:setLocalZOrder(1000)
		end
	else
		if self._state == 1 then
			self._sprite:pos(self._x, self._currentY)
			self._sprite:setOpacity(255)
			self._sprite:setScale(GCardScale)
			self._sprite:setLocalZOrder(zorder)
		end
	end
end

function Card:_endSchduler()
	if self.m_scheduler_handler then
		self._selectedIndex = 0
		self._touchTime = 0
	    scheduler.unscheduleGlobal(self.m_scheduler_handler)
	    self.m_scheduler_handler = nil
	end
end

function Card:_countTouchtime(dt)
	self._touchTime = self._touchTime + 1
	if self._touchTime >= 10 then
		self:_endSchduler()
	end
end

function Card:_setSelected(ret)
	self._selected = ret
	if ret then
		self._currentY = self._y + 20
		self._sprite:pos(self._x, self._y + 20)
	else
		self._currentY = self._y
		self._sprite:pos(self._x, self._y)
	end
end

function Card:setId(id)
	self._id = id
	self._type = math.floor(id / 10)
	self:_setArrayType()

	self._sprite:changeId(id)
end

function Card:setPos(x, y)
	self._x = x
	self._y = y
	self._sprite:pos(x, y)
end

function Card:_setArrayType()
	if self._type == mjCardType.mj_wan then
		self._arrayType = self._id
	elseif self._type == mjCardType.mj_bing then
		self._arrayType = self._id-1
	elseif self._type == mjCardType.mj_tiao then
		self._arrayType = self._id-2
	elseif self._type == mjCardType.mj_feng then
		self._arrayType = self._id-3
	elseif self._type == mjCardType.mj_zfb then
		self._arrayType = self._id-9
	end
	self._name = mjCardTxt[self._arrayType]
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

function Card:getArrayType()
	return self._arrayType
end

function Card:getSprite()
	return self._sprite
end

function Card:getSortId()
	return self._sortId
end

function Card:setSortId(id)
	self._sortId = id
end

return Card