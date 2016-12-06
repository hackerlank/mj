local AoperatorUi = class("AoperatorUi", function() return display.newSprite("#" .. mjActionBJ) end)

local this = nil

function AoperatorUi:ctor(layer)
	this = layer

	self:addTo(this)
	self:pos(display.cx, 200)

	self._buttons = {}

	local kButtons = {
		[1] = {images = mjActionP, listener = handler(self, self._actionPClickListener)},
		[2] = {images = mjActionG, listener = handler(self, self._actionGClickListener)},
		[3] = {images = mjActionH, listener = handler(self, self._actionHClickListener)},
		[4] = {images = mjActionX, listener = handler(self, self._actionXClickListener)},
	}


	for id,val in pairs(kButtons) do
		local button = cc.ui.UIPushButton.new(val.images)
		button:pos(100 * id, 80)
		button:addTo(self)
		button:onButtonClicked(val.listener)
		self._buttons[id] = button
	end

	self:showOperatorUi({1,3})
end

function AoperatorUi:showOperatorUi(status)
	for _id,button in pairs(self._buttons) do
		local ret = false
		for _,__id in pairs(status) do
			if _id == __id then
				ret = true
				break
			end
		end
		button:setButtonEnabled(ret)
	end
end

function AoperatorUi:_actionPClickListener()

end

function AoperatorUi:_actionGClickListener()

end

function AoperatorUi:_actionHClickListener()

end

function AoperatorUi:_actionXClickListener()

end

return AoperatorUi