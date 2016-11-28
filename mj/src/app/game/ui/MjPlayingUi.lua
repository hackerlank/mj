import("..common_define.init")
UIChangeObserver = require("app.game.UIObservers.UIChangeObserver")
MjDataControl = require("app.game.control.MjDataControl")
--ui
local HandCardsUi = import(".hand_cards_mag.HandCardsUi")
local DealCardsUi = import(".DealCardsUi")
local FightingStage = import("..control.FightingStage")
local SurplusPosition = import(".SurplusPosition")
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
	self._allHandCards = {}
	self._allSurplusCards = {{},{},{},{}}  --所有余牌{1,2,3,4}每个位置17叠
	self._beganSurplusPam = {}
	--object
	self._dealCardsUi = nil
	self._fightingState = nil

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
	local surplus_obj = SurplusPosition.new(self)

	for _,seat in pairs(self._seats) do
		self._allHandCards[seat] = HandCardsUi.new(self)
	end

	self._dealCardsUi = DealCardsUi.new(self)
	--self._fightingState = FightingStage.new(self)
end

--获得一个活动玩家（摸牌、出牌）
function MjPlayingUi:_getActivitySeat()
	local seat = self._fightingState:getActivitySeat()
	self._allHandCards[seat]:upCard(card, 1)
end

function MjPlayingUi:_fighting()

end

--get
function MjPlayingUi:getHandCardsBySeat(seat)
	return self._allHandCards[seat]
end

function MjPlayingUi:getGData()
	return self._gData
end

function MjPlayingUi:setBeganSurplusPam(seat, x, dir)
	self._beganSurplusPam = {seat = seat, x = x, dir = dir}
end

function MjPlayingUi:getBeganSurplusPam()
	return self._beganSurplusPam
end

return MjPlayingUi