local AoperatorUi = class("AoperatorUi", function() return display.newSprite("#" .. mjActionBJ) end)

local this = nil

function AoperatorUi:ctor(layer)
	this = layer

	self:addTo(this, mjLocalZorders.operate_ui)
	self:pos(display.cx, 200)

	self._buttons = {}
	self._open = false
	self._isDarkGang = false  --是否暗杠

	local kButtons = {
		[1] = {images = mjActionP, listener = handler(self, self._actionPClickListener)},
		[2] = {images = mjActionG, listener = handler(self, self._actionGClickListener)},
		[3] = {images = mjActionH, listener = handler(self, self._actionHClickListener)},
		[4] = {images = mjActionX, listener = handler(self, self._actionXClickListener)},
	}

	--{1: 碰 2：杠 3：胡 4：过}
	for id,val in pairs(kButtons) do
		local button = cc.ui.UIPushButton.new(val.images)
		button:pos(100 * id, 80)
		button:addTo(self)
		button:onButtonClicked(val.listener)
		self._buttons[id] = button
	end

	self:hide()

	UIChangeObserver:getInstance():addUIChangeObserver(ListenerIds.kMineGang, self, handler(self, self._checkGangResult))
	UIChangeObserver:getInstance():addUIChangeObserver(ListenerIds.kPeng, self, handler(self, self._checkPengResult))
end

function AoperatorUi:destroy()

end

function AoperatorUi:_showOperatorUi()
	self:show()
	if not self._open then
		self._open = true
		self:_resetButtonsEnable()
	end
end

function AoperatorUi:_checkGangResult(gang_type)
	self._isDarkGang = (gang_type == mjDarkGang)
	self:_showOperatorUi()
	self:setButtonEnable(2)
end

function AoperatorUi:_checkPengResult(ret)
	if ret then
		self:_showOperatorUi()
		self:setButtonEnable(1)
	end
end

--===================================

function AoperatorUi:_resetButtonsEnable()
	for _id,button in pairs(self._buttons) do
		button:setButtonEnabled(false)
	end
end

function AoperatorUi:setButtonEnable(index)
	self._buttons[index]:setButtonEnabled(true)
end

function AoperatorUi:_actionPClickListener()
	self:hide()
	this:getHandCardsBySeat(1):doPeng()
end

function AoperatorUi:_actionGClickListener()
	self:hide()
	if self._isDarkGang then
		local gangzi = this:getHandCardsBySeat(1):getGangzi()  --所有杠子
		this:getHandCardsBySeat(1):doDarkGang(gangzi[1])
	else
		this:getHandCardsBySeat(1):doGang()
	end
	this:getHandCardsBySeat(1):mineFeelCard()  --再次上牌
end

function AoperatorUi:_actionHClickListener()
	self:hide()
end

function AoperatorUi:_actionXClickListener()
	self:hide()
	UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kXGuo)
end

return AoperatorUi