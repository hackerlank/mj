local AoperatorUi = class("AoperatorUi", function() return display.newSprite("#" .. mjActionBJ) end)

local this = nil

function AoperatorUi:ctor(layer)
	this = layer

	self:addTo(this, mjLocalZorders.operate_ui)
	self:pos(display.cx/3, 250)

	self._buttons = {}
	self._open = false
	self._isDarkGang = false  --是否暗杠
	self._huInfo = nil  --胡牌信息

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
	UIChangeObserver:getInstance():addUIChangeObserver(ListenerIds.kHu, self, handler(self, self._checkHuResult))
end

function AoperatorUi:destroy()

end

function AoperatorUi:_showOperatorUi()
	self:show()
	if not self._open then
		self._open = true
		self:_resetButtonsEnable()
	end
	--轮到本家出牌，没有“过”选项
	local current_seat = GDataManager:getInstance():getCurrentSeat()
	if current_seat == 1 then
		self:setButtonEnableFalse(4)
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

function AoperatorUi:_checkHuResult(data)
	--id card
	self:_showOperatorUi()
	self:setButtonEnable(3)
	self._huInfo = data
end

--===================================

function AoperatorUi:_resetButtonsEnable()
	for _id,button in pairs(self._buttons) do
		button:setButtonEnabled(false)
		if _id == #self._buttons then
			button:setButtonEnabled(true)
		end
	end
end

function AoperatorUi:setButtonEnable(index)
	self._buttons[index]:setButtonEnabled(true)
end

function AoperatorUi:setButtonEnableFalse(index)
	self._buttons[index]:setButtonEnabled(false)
end

--click listener
function AoperatorUi:_commonClickListener()
	self:hide()
	self._open = false
end

function AoperatorUi:_actionPClickListener()
	GDataManager:getInstance():setCurrentSeat(1)
	self:_commonClickListener()
	this:getHandCardsBySeat(1):doPeng()
end

function AoperatorUi:_actionGClickListener()
	GDataManager:getInstance():setCurrentSeat(1)
	self:_commonClickListener()
	if self._isDarkGang then
		local gangzi = this:getHandCardsBySeat(1):getGangzi()  --所有杠子
		this:getHandCardsBySeat(1):doDarkGang(gangzi[1])
	else
		this:getHandCardsBySeat(1):doGang()
	end
	this:getHandCardsBySeat(1):mineFeelCard()  --再次上牌
end

function AoperatorUi:_actionHClickListener()
	self:_commonClickListener()
	if self._huInfo then
		this:updateSeatIndex(1)
		this:getHandCardsBySeat(1):insertHuCard(self._huInfo.card)
		if self._huInfo.id == 2 then
			GDataManager:getInstance():mineHasActionReponse()  --不需要出牌，所以减1
		else
			--自摸
			this:getHandCardsBySeat(1):removeLastDrakCard()
			UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kNextSeat)
		end
		self._huInfo = nil
	end
end

function AoperatorUi:_actionXClickListener()
	self:_commonClickListener()
	GDataManager:getInstance():mineHasActionReponse()
	--放弃操作,超时视为放弃操作
	--轮到本家出牌，且有对应杠、碰操作时， 没有过选项
end

return AoperatorUi