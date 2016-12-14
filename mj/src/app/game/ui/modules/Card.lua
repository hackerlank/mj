--所有牌的基類
local Card = class("Card", function() return display.newSprite() end)

function Card:ctor()
	self._id = nil
	self._name = nil
	self._type = nil  --条、筒、万
	self._cardType = nil --牌形式
	--附加属性
	self._sortId = 0  --在手牌中的位置
	self._seat = 1    --属于哪个玩家
	self._isMine = false  --

	--self:setCardType(mjDCardType.mj_init)  --一开始所有的牌都是默认牌
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self._darkCardTouchListener))
end		

function Card:changeId(id)
	self._id = id
	--計算
	self._name = mjCardTxt[self._id]
	self._type = mjCardType[math.ceil(self._id/9)]
end

function Card:setCardType(card_type)
	if card_type < mjDCardType.mj_init or card_type > mjDCardType.mj_show then
		assert("牌型更改错误 error: Card line: 30")
	end
	self._cardType = card_type
	local card_type_listeners = {
		[mjDCardType.mj_init] = handler(self, self._changeToInit),
		[mjDCardType.mj_dark] = handler(self, self._changeToDark),
		[mjDCardType.mj_play] = handler(self, self._changeToPlay),
		[mjDCardType.mj_tdark] = handler(self, self._changeToTDark),
		[mjDCardType.mj_show] = handler(self, self._changeToShow),
	}
	card_type_listeners[card_type]()
end

--初始化牌形式
function Card:_changeToInit()
	self:setSpriteFrame(mjInitCardKey[self._seat])
end

--手牌形式
function Card:_changeToDark()
	local card = ""
	if self._seat == 1 then
		card = string.format(mjDarkCardKey[1] .. "%d.png", self._id)
	else
		card = mjDarkCardKey[self._seat]
	end
	self:setSpriteFrame(card)
end

--出牌形式
function Card:_changeToPlay()
	self:setTouchEnabled(false)
	local card = string.format(mjPlayCardKey[self._seat] .. "%d.png", self._id)
	self:setSpriteFrame(card)
end

--暗杠暗牌牌情况(手牌区域)
function Card:_changeToTDark()
	self:setSpriteFrame(mjTDarkCardKey[self._seat])
end

--碰、杠、胡明牌情况(手牌区域)
function Card:_changeToShow()
	local card = string.format(mjShowCardKey[self._seat] .. "%d.png", self._id)
	self:setSpriteFrame(card)
end

function Card:_darkCardTouchListener(event)
	if event.name == "began" then
		local current_seat = GDataManager:getInstance():getCurrentSeat()
		if current_seat == 1 then
			UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kPlayCard, self)
		end
		return false
	end
end

--======================================

function Card:setSeat(seat)
	self._seat = seat
end

function Card:getSeat()
	return self._seat
end

function Card:getSortId()
	return self._sortId
end

function Card:setSortId(id)
	self._sortId = id
end

function Card:setIsMine(ret)
	self._isMine = ret
	self:setTouchEnabled(ret)
end

--======================================

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