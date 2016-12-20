local SeatUi = class("SeatUi", function() return display.newNode() end)

local SpriteRes = {
	
}

function SeatUi:ctor(seat)
	self._seat = seat
	self._seatParams = mjPlayerInfoPos[seat]

	self._headUrl = nil
	self._nickName = nil

	--
	self._player = nil

	self:_setupUi()

	self:setPosition(self._seatParams.pos)
	self:_checkSeatMine()
end

function SeatUi:_setupUi()
	self._headUrl = display.newSprite("#ico_1.png")
	self._headUrl:addTo(self)
	self._headUrl:setScale(70 /W(self._headUrl))

	self._scoreLabel = ww.createLabel("10000", 16)
	self._scoreLabel:addTo(self)
	self._scoreLabel:align(display.CENTER, 0, -45)

	-- self._nickName = ww.createLabel("test", 20)
	-- self._nickName:addTo(self)
	-- self._nickName:align(display.CENTER , W(self._InfoBg) / 2, H(self._InfoBg) / 2 + 10)
end

function SeatUi:changePlayer(player)
	self._player = player
	self._headUrl:setSpriteFrame(self._player.url)
	--self._nickName:setString(self._player.nick_name)
end

--mine
function SeatUi:_checkSeatMine()
	if self._seat == 1 then
		self:pos(260, 155)
	end
end

--action
function SeatUi:actionPeng()

end

function SeatUi:actionGang()

end

function SeatUi:actionHu()

end

function SeatUi:subScore()

end

return SeatUi