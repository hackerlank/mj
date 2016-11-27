import("..common_define.init")
UIChangeObserver = require("app.game.UIObservers.UIChangeObserver")
MjDataControl = require("app.game.control.MjDataControl")
--ui
local DealCardsUi = import(".DealCardsUi")
local HandCardByPos = import(".HandCardByPos")
local MjPlayingUi = class("MjPlayingUi", function() return display.newLayer() end)

local game_params = {
	seats = {1,2,3,4},  --參與的人數個數
}

local SpriteRes = {
	background = "background/bg.jpg"
}

function MjPlayingUi:ctor()
	--data
	self._seats = game_params.seats
	--ui
	--object
	self._dealCardsUi = nil
	self._handCardByPos = nil

	self:_setupUi()
	self:_connectObserver()
	self:_ready()
end

function MjPlayingUi:_setupUi()
	local background = cc.ui.UIImage.new(SpriteRes.background)
	background:addTo(self)
	background:setLayoutSize(display.width, display.height)
	math.randomseed(os.time())
	local back_txt_sp = string.format("mj/back_text/bg_gk_name_%d.png", math.random(1, 13))
	display.newSprite(back_txt_sp)
	:addTo(self)
	:pos(display.cx, display.cy - 55)

end

function MjPlayingUi:_connectObserver()

end

function MjPlayingUi:_unConnectObserver()

end

function MjPlayingUi:_ready()
	MjDataControl:getInstance():dataStart()

	self._handCardByPos = HandCardByPos.new(self)
	self._dealCardsUi = DealCardsUi.new(self)
end

--get
function MjPlayingUi:getHandCardByPos()
	return self._handCardByPos
end

return MjPlayingUi