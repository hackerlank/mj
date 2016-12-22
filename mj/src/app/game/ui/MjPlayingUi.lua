import("..common_define.init")
UIChangeObserver = require("app.game.UIObservers.UIChangeObserver")
MjDataControl = require("app.game.control.MjDataControl")
GDataManager = require("app.game.control.GDataManager")
--ui
local CardWallUi = import(".modules.CardWallUi")
local AoperatorUi = import(".AoperatorUi")
local SeatUi = import(".modules.SeatUi")
--local SecondTimerUi = import(".SecondTimerUi")
local ActiveSeatFlagUi = import(".module_ui.ActiveSeatFlagUi")  --只是标记出牌时间的一个节点
local ReadyStage = import("..control.ReadyStage")
local DealingStage = import("..control.DealingStage")
local DingQueStage = import(".module_ui.DingQueStage")
local FightingStage = import("..control.FightingStage")
local MjPlayingUi = class("MjPlayingUi", function() return display.newLayer() end)

local SpriteRes = {
	background = "background/bg.jpg",
	btn_start = {normal = "#start.png", pressed = "#start2.png"}
}

function MjPlayingUi:ctor()
	self:setNodeEventEnabled(true)
	--data
	GDataManager:getInstance():setLayer(self)
	self._seats = GDataManager:getInstance():getSeats()
	--ui
	self._HandCards = {}
	self._PlayerSeatUis = {}
	self._operatorUi = nil
	self._cardsNumLabel = nil  --牌张剩余数 监听
	self._globalTimerUi = nil
	--object
	self._readyStage = nil
	self._dealingStage = nil
	self._fightingState = nil
	self._dignque = nil

	self:_setupUi()
	self:_connectObserver()
end

function MjPlayingUi:_setupUi()
	--GSound:getInstance():playMusic(MJBACKGOURNDMUSIC)

	local background = cc.ui.UIImage.new(SpriteRes.background)
	background:addTo(self)
	background:setLayoutSize(display.width, display.height)
	math.randomseed(os.time())
	local back_txt_sp = string.format("mj/back_text/bg_gk_name_%d.png", math.random(1, 13))
	display.newSprite(back_txt_sp)
	:addTo(self)
	:pos(display.cx, display.cy - 55)

	--余牌统计
	self._cardsNumLabel = ww.createLabel("")
	self._cardsNumLabel:addTo(self)
	self._cardsNumLabel:align(display.LEFT_CENTER, 40, display.top - 50)
	--开始按钮
	self._beganButton = ww.createButton(SpriteRes.btn_start)
	self._beganButton:addTo(self)
	self._beganButton:pos(display.cx, display.cy - 120)
	self._beganButton:onButtonClicked(handler(self, self._beganButtonClickListener))

	-- local xx = ww.createButton(SpriteRes.btn_start)
	-- xx:addTo(self, 100000)
	-- xx:pos(display.cx, display.cy + 120)
	-- xx:onButtonClicked(function()  
	-- 	UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kGameOver)
	-- 	end)

	-- self._playCardFlag = display.newSprite("mj/sp_play_flag.png")
	-- self._playCardFlag:addTo(self)
	-- self._playCardFlag:pos(display.cx, display.cy)
	-- self._playCardFlag:runAction(cc.RepeatForever:create(cc.Sequence:create(
	-- 	cca.moveBy(0.3, 0, -10),
	-- 	cca.moveBy(0.3, 0, 10)
	-- 	)))
	-- self._playCardFlag:hide()

	--todo：初始化手牌（还未有手牌数据）
	for _,seat in pairs(self._seats) do
		self._HandCards[seat] = CardWallUi.new(self)
		--todo:初始化玩家头像等信息
		self._PlayerSeatUis[seat] = SeatUi.new(self, seat)
	end
	

	self._readyStage = ReadyStage.new(self)
	self._dealingStage = DealingStage.new(self)
	self._fightingState = FightingStage.new(self)
	self._operatorUi = AoperatorUi.new(self)
end

function MjPlayingUi:_connectObserver()
	UIChangeObserver:getInstance():addUIChangeObserver(ListenerIds.kEnterDingque, self, handler(self, self._enterDingque))
	UIChangeObserver:getInstance():addUIChangeObserver(ListenerIds.kEnterFighting, self, handler(self, self._enterFighting))
	UIChangeObserver:getInstance():addUIChangeObserver(ListenerIds.kGameOver, self, handler(self, self._enterGameOver))
	UIChangeObserver:getInstance():addUIChangeObserver(ListenerIds.kCardsNum, self, handler(self, self._updateCardsNumResult))
end

function MjPlayingUi:_unConnectObserver()
	UIChangeObserver:getInstance():removeOneUIChangeObserver(ListenerIds.kEnterDingque, self)
	UIChangeObserver:getInstance():removeOneUIChangeObserver(ListenerIds.kEnterFighting, self)
	UIChangeObserver:getInstance():removeOneUIChangeObserver(ListenerIds.kCardsNum, self)
	UIChangeObserver:getInstance():removeOneUIChangeObserver(ListenerIds.kGameOver, self)
end

function MjPlayingUi:onExit()
	self:_unConnectObserver()
	self._globalTimerUi:stop()  --总时间
	GSound:getInstance():stopMusics()
end

--result
function MjPlayingUi:_updateCardsNumResult(data)
	self._cardsNumLabel:setString("剩余：" .. data .. "张")
end

----button listener
function MjPlayingUi:_beganButtonClickListener(event)
	self:start()
	event.target:hide()
end
--1.准备 初始化数据
--2.发牌
--3.定缺
--4.开始
--5.结算

function MjPlayingUi:restar()

end

function MjPlayingUi:start()
	GDataManager:getInstance():reset()

	-- for _,seat in pairs(self._seats) do
	-- 	self._HandCards[seat] = CardWallUi.new(self)
	-- 	--todo:初始化玩家头像等信息
	-- 	self._PlayerSeatUis[seat] = SeatUi.new(self, seat)
	-- end
	
	self._readyStage:began()
	self._dealingStage:began()
end	

function MjPlayingUi:_enterDingque()
	if not self._dignque then
		self._dignque = DingQueStage.new(self)
	else
		self._dignque:show()
	end
end

function MjPlayingUi:_enterFighting()
	if not self._globalTimerUi then
		self._globalTimerUi = ActiveSeatFlagUi.new()
		self._globalTimerUi:addTo(self)
		self._globalTimerUi:pos(display.cx, display.cy)
	else
		self._globalTimerUi:show()
	end

	self._fightingState:began()
end

--游戏结算
function MjPlayingUi:_enterGameOver()
	MjDataControl:getInstance():removeAllCards()
	self._beganButton:show()
	for _,seat in pairs(self._seats) do
		self._HandCards[seat]:reset()
		self._PlayerSeatUis[seat]:setMarkQue()
	end
	
	--hide
	self._operatorUi:hide()
	self._globalTimerUi:hide()
	self._cardsNumLabel:setString("")
end

--非本类调用、中转过程
function MjPlayingUi:updateSeatIndex(seat)
	self._fightingState:updateSeatIndex(seat)
end

function MjPlayingUi:hideOperatorUi()
	self._operatorUi:hide()
end

function MjPlayingUi:startGlobalTimer(seat, time)
	self._globalTimerUi:start(seat, time)
end

--==========================================================
--get
function MjPlayingUi:getHandCardsBySeat(seat)
	return self._HandCards[seat]
end

function MjPlayingUi:getPlayerSeatUi(seat)
	return self._PlayerSeatUis[seat]
end

return MjPlayingUi