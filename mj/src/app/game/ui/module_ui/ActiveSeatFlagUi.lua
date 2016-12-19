--todo:  标记出牌时间和轮到谁出牌
local SecondTimer = require("app.game.ui.modules.SecondTimer")
local ActiveSeatFlagUi = class("ActiveSeatFlagUi", function() return display.newNode() end)

local SpriteRes = {
	timer_bg = "#timer_bj.png",
	timer_dir = "#timer_x.png"
}

local this = nil
function ActiveSeatFlagUi:ctor(layer)
	this = layer
	self._secondTimer = SecondTimer.new()

	self:_setupUi()
end

function ActiveSeatFlagUi:_setupUi()
	self._timerBg = display.newSprite(SpriteRes.timer_bg)
	self._timerBg:addTo(self)
	self._timerBg:pos(0, 50)

	self._timerLabel = ww.createLabel("0")
	self._timerLabel:addTo(self._timerBg)
	self._timerLabel:align(display.CENTER, W(self._timerBg)/2, H(self._timerBg)/2)

	self._flagSprite = display.newSprite(SpriteRes.timer_dir)
	self._flagSprite:addTo(self)
end

--正常出牌流程时间 15 有座位号
--检测有操作 等待时间 10s 没有座位号

function ActiveSeatFlagUi:start(seat, time)
	self:cstop()
	local params = {
		time = 1,
		total_seconds = time or 15,
		direction = 2,
		times_listener = handler(self, self._updateTimerLabel),
		end_listener = function() end
	}
	self._timerLabel:setString(time)
	self._secondTimer:start(params)
	self._flagSprite:setVisible(seat > 0)
	self:_updateFlagSpriteVec(seat)
end

function ActiveSeatFlagUi:_updateFlagSpriteVec(seat)
	if not seat or seat == 0 then return end
	local w, h = W(self._timerBg), H(self._timerBg)
	local vecs = {
		[1] = cc.p(0, 0),
		[2] = cc.p(w / 2 + 20, h / 2 + 20),
		[3] = cc.p(0, h + 40),
		[4] = cc.p(-w/2-20, h / 2 + 20)
	}
	self._flagSprite:setPosition(vecs[seat])
	self._flagSprite:setRotation(-90 * (seat - 1))
end

function ActiveSeatFlagUi:stop()
	self._secondTimer:stop()
end

function ActiveSeatFlagUi:cstop()
	self._secondTimer:cstop()
end

function ActiveSeatFlagUi:_updateTimerLabel(dt)
	self._timerLabel:setString(dt)
end

return ActiveSeatFlagUi