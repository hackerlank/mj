--直条的进度条 （血条）
local CProgressTimer = class("CProgressTimer", function() return display.newNode() end)

function CProgressTimer:ctor(bg_progress, sp_progress)
	self.m_bg_progress = bg_progress
	self.m_sp_progress = sp_progress

	--ui
	self.m_fill = nil
	self.m_fill_label = nil
	self.W = 0
	self.H = 0

	self:setupUi()
end

function CProgressTimer:setupUi()
	self.m_background = display.newSprite(self.m_bg_progress)
	self.m_background:addTo(self)
	self.W, self.H = W(self.m_background), H(self.m_background)

	self.m_fill = display.newProgressTimer(self.m_sp_progress, display.PROGRESS_TIMER_BAR)
    self.m_fill:setMidpoint(cc.p(0, 0.4))
    self.m_fill:setBarChangeRate(cc.p(1.0,0))
    self.m_fill:setPosition(self.W / 2, self.H / 2)
    self.m_fill:setPercentage(0)
    self.m_background:addChild(self.m_fill)

    --默认显示
    local params = {
    	text = "",
    	size = 20,
	}
    self.m_fill_label = cc.ui.UILabel.new(params)
    self.m_fill_label:addTo(self.m_background, 10)
    self.m_fill_label:align(display.CENTER, self.W / 2, self.H / 2)
end

function CProgressTimer:setPercentData(l_data, r_data)
	l_data = l_data or 0
	r_data = r_data or 1
	local str_fomat = string.format("%d/%d", l_data, r_data)
	self.m_fill_label:setString(str_fomat)
	local percent = l_data / (r_data / 100)
	self:setPercentage(percent)
end

function CProgressTimer:setPercentage(percent)
	self.m_fill:setPercentage(percent)
end

function CProgressTimer:hideFillLabel()
	self.m_fill_label:hide()
end

function CProgressTimer:getFillLabel()
	return self.m_fill_label
end

function CProgressTimer:setFillLabelColor(color)
	self.m_fill_label:setColor(color)
end

function CProgressTimer:setFillLabelSize(size)
	self.m_fill_label:setScale(size/24)
end

function CProgressTimer:getBackGround()
	return self.m_background
end

function CProgressTimer:getFill()
	return self.m_fill
end

function CProgressTimer:getW()
	return self.W
end

function CProgressTimer:getH()
	return self.H
end

return CProgressTimer