local SeatUi = class("SeatUi", function() return display.newNode() end)

local SpriteRes = {
	infoframe = "#infoframe.png",
}

function SeatUi:ctor(seat_params)
	self._seatParams = seat_params

	self._headUrl = nil
	self._nickName = nil

	--
	self._player = nil

	self:_setupUi()
	self:setPosition(self._seatParams.pos)
end

function SeatUi:_setupUi()
	self._headUrl = display.newSprite("#ico_1.png")
	self._headUrl:addTo(self)

	self._InfoBg = display.newSprite(SpriteRes.infoframe)
	self._InfoBg:addTo(self)
	self._InfoBg:pos(0, -65)

	self._nickName = ww.createLabel("test", 20)
	self._nickName:addTo(self._InfoBg)
	self._nickName:align(display.CENTER , W(self._InfoBg) / 2, H(self._InfoBg) / 2 + 10)
end

function SeatUi:changePlayer(player)
	self._player = player
	self._headUrl:setSpriteFrame(self._player.url)
	self._nickName:setString(self._player.nick_name)
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