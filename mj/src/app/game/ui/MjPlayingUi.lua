import("..common_define.init")
UIChangeObserver = require("app.game.UIObservers.UIChangeObserver")
MjDataControl = require("app.game.control.MjDataControl")
--ui
local HandCardsUi = import(".hand_cards_mag.HandCardsUi")
local ReadyStage = import("..control.ReadyStage")
local DealingStage = import("..control.DealingStage")
local FightingStage = import("..control.FightingStage")
local MjPlayingUi = class("MjPlayingUi", function() return display.newLayer() end)

local game_params = {
	seats = {1,2,3,4},  --參與的人數個數
}

local SpriteRes = {
	background = "background/bg.jpg"
}

function MjPlayingUi:ctor()
	--data
	self._gData = game_params
	self._seats = self._gData.seats
	--ui
	self._HandCards = {}
	--object
	self._readyStage = nil
	self._dealingStage = nil
	self._fightingState = nil

	self:_setupUi()
	self:_connectObserver()
	self:start()
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

	--todo：初始化手牌（还未有手牌数据）
	for _,seat in pairs(self._seats) do
		self._HandCards[seat] = HandCardsUi.new(self)
	end

	self._readyStage = ReadyStage.new(self)
	self._dealingStage = DealingStage.new(self)
end

function MjPlayingUi:_connectObserver()

end

function MjPlayingUi:_unConnectObserver()

end

function MjPlayingUi:start()
	self._readyStage:began()
	self._dealingStage:began()
end	

--get
function MjPlayingUi:getHandCardsBySeat(seat)
	return self._HandCards[seat]
end

function MjPlayingUi:getGData()
	return self._gData
end

function MjPlayingUi:getSeats()
	return self._seats
end

return MjPlayingUi