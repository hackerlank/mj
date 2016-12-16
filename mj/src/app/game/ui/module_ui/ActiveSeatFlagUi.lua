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

end

function ActiveSeatFlagUi:start()
	local params = {
		time = 1,
		total_seconds = 30,
		times_listener = function(dt) ww.print("时间..", dt) end
	}
	self.m_second_timer:start(params)
end


return ActiveSeatFlagUi