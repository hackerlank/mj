import("..common_define.init")
UIChangeObserver = require("app.game.UIObservers.UIChangeObserver")
MjDataControl = require("app.game.control.MjDataControl")
GDataManager = require("app.game.control.GDataManager")
--ui
local CardWallUi = import(".modules.CardWallUi")
local AoperatorUi = import(".AoperatorUi")
local SecondTimerUi = import(".SecondTimerUi")
local ReadyStage = import("..control.ReadyStage")
local DealingStage = import("..control.DealingStage")
local DingQueStage = import(".module_ui.DingQueStage")
local FightingStage = import("..control.FightingStage")
local MjPlayingUi = class("MjPlayingUi", function() return display.newLayer() end)

local SpriteRes = {
	background = "background/bg.jpg"
}

function MjPlayingUi:ctor()
	self:setNodeEventEnabled(true)
	--data
	GDataManager:getInstance():setLayer(self)
	GDataManager:getInstance():reset()
	self._seats = GDataManager:getInstance():getSeats()
	--ui
	self._HandCards = {}
	self._operatorUi = nil
	--object
	self._readyStage = nil
	self._dealingStage = nil
	self._fightingState = nil

	self:_setupUi()
	self:_connectObserver()
	self:start()
end

function MjPlayingUi:_setupUi()
	GSound:getInstance():playMusic(MJBACKGOURNDMUSIC)

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
		self._HandCards[seat] = CardWallUi.new(self)
	end

	self._readyStage = ReadyStage.new(self)
	self._dealingStage = DealingStage.new(self)
	self._fightingState = FightingStage.new(self)
	self._operatorUi = AoperatorUi.new(self)
	self._secondTimerUi = SecondTimerUi.new(self)
	DingQueStage.new(self)
end

function MjPlayingUi:_connectObserver()
	UIChangeObserver:getInstance():addUIChangeObserver(ListenerIds.kEnterFighting, self, handler(self, self._enterFighting))
end

function MjPlayingUi:_unConnectObserver()
	UIChangeObserver:getInstance():removeOneUIChangeObserver(ListenerIds.kEnterFighting, self)
end

function MjPlayingUi:onExit()
	self:_unConnectObserver()
	self:timerEnd()
	GSound:getInstance():stopMusics()
end

function MjPlayingUi:start()
	self._readyStage:began()
	self._dealingStage:began()
end	

function MjPlayingUi:_enterFighting()
	self._fightingState:began()
end

--非本类调用、中转过程
function MjPlayingUi:updateSeatIndex(seat)
	self._fightingState:updateSeatIndex(seat)
end

function MjPlayingUi:hideOperatorUi()
	self._operatorUi:hide()
end

function MjPlayingUi:timerBegan()
	self._secondTimerUi:start()
end

function MjPlayingUi:timerEnd()
	self._secondTimerUi:stop()
end

--==========================================================
--get
function MjPlayingUi:getHandCardsBySeat(seat)
	return self._HandCards[seat]
end

return MjPlayingUi