local SecondTimer = require("app.game.ui.modules.SecondTimer")
local SecondTimerUi = class("SecondTimerUi", function() return display.newNode() end)

local this = nil

function SecondTimerUi:ctor(layer)
	this = layer
	self:addTo(this)
	
	self.m_second_timer = SecondTimer.new()
end

function SecondTimerUi:start()
	local params = {
		time = 1,
		total_seconds = 30,
		times_listener = function(dt) ww.print("时间..", dt) end
	}
	self.m_second_timer:start(params)
end

return SecondTimerUi