local Card = require("app.scenes.mj.modules.Card")
local CardList = import(".CardList")
local CardBackLayer = class("CardBackLayer", function() return display.newLayer() end)

function CardBackLayer:ctor(params)
	self._playerSeats = params.seats
	self._myPos = 1
	self._cardList = {}
	self:_initView()

	self:onConnectObservers()
end

function CardBackLayer:onConnectObservers()
	UIChangeObserver:getInstance():addUIChangeObserver(ListenerIds.kPlayerCard, self, handler(self, self._playCardListener))
end

function CardBackLayer:unConnectObservers()
	UIChangeObserver:getInstance():removeOneUIChangeObserver(ListenerIds.kPlayerCard, self)
end

function CardBackLayer:_initView()
	MjDataControl:getInstance():dataStart()
    
    for _,val in pairs(GPositions) do
    	local cards = MjDataControl:getInstance():getIdMjArray(13)
    	local cardlist = CardList.new(val)
    	cardlist:addTo(self)
    	cardlist:addCardIds(cards)
    	self._cardList[val.id] = cardlist
    end

    --self:_initStaticSurplusCards()
end

--分开来
function CardBackLayer:upOtherCard(seat_pos, up_card)
	local ret = false
	for _,pos in pairs(self._playerSeats) do
		if pos ~= seat_pos then
			if self._cardList[pos]:upCard(up_card, 1) then
				ret = true
			end
		end
	end
	if not ret then
		--都没有碰、杠、胡
		print("-----------没有可以碰或杠（下一个）----------")
		UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kNextSeat)
	end
end

--只用于自己上牌
function CardBackLayer:upMineCard(seat_pos, up_card)
	self._currentSeat = seat_pos
	if not up_card then
		--暂时先生成
		local cardid = MjDataControl:getInstance():getIdMjArray(1)
		up_card = Card.new()
	    up_card:setId(cardid[1])
	    up_card:getSprite():addTo(self._cardList[seat_pos])
	    local base_pos = GPositions[seat_pos].pos
	    local pos = base_pos
	    if seat_pos == 1 then
	    	pos = cc.p(base_pos.x + #self._cardList[seat_pos]:getDarkList() * GCardWidth + 99, base_pos.y)
	    elseif seat_pos == 2 then

	   	elseif seat_pos == 3 then
	   		pos = cc.p(base_pos.x - 99/2, base_pos.y)
	   	else
	   		pos = cc.p(base_pos.x, base_pos.y + #self._cardList[seat_pos]:getDarkList() * GCardWidth + 99)
	    end
	    up_card:setPos(pos.x, pos.y)
	end
	self._cardList[seat_pos]:upCard(up_card, 2)
end

function CardBackLayer:_playCardListener(play_card)
	print("-------出牌--------")
	self._cardList[self._currentSeat]:playSuccess(play_card)
	play_card:setPos(display.cx, 600)

	self:upOtherCard(self._currentSeat, play_card)
end

--余牌
function CardBackLayer:_initStaticSurplusCards()
	local mjArray = MjDataControl:getInstance():getMjArray()
	local params = {
		{id = 1, x = 140, y = 100, r = 0},
		{id = 2, x = display.width - 140, y = 100, r = -90}
	}
	local idn = 34
	local X = 0
	local Y = 0
	for i,id in pairs(mjArray) do
		local pam = nil
		if i <= 34 then
			pam = params[1]
		elseif i <= 68 then
			pam = params[2]
		else
			return
		end
		local card = Card.new()
    	card:setId(id)
    	card:getSprite():addTo(self)
    	card:getSprite():changeType(2)
    	card:getSprite():setRotation(pam.r)

    	card:getSprite():pos(pam.x, pam.y)
    	if pam.id == 1 then
    		pam.y = pam.y + 20
    	elseif pam.id == 2 then
    		pam.x = pam.x - 20
    	end
    	if i % 2 == 0 then
    		if pam.id == 1 then
	    		pam.x = pam.x + GCardWidth - 6
	    		pam.y = 100
	    	elseif pam.id == 2 then
	    		pam.y = pam.y + GCardWidth - 6
	    		pam.x = display.width - 140
	    	end
    	end
	end
end

return CardBackLayer