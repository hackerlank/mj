local CGroupButtonUi = class("CGroupButtonUi", import(".CGroupBaseUi"))

function CGroupButtonUi:ctor()
	self.m_selected_tag = 0
end

function CGroupButtonUi:addButton(button, id)
	self:addChildNode(button, id)
	button:onButtonClicked(handler(self, self._buttonClickListener))
end

function CGroupButtonUi:onButtonSelectChanged(listener)
	self.m_button_change_listener = listener
end

function CGroupButtonUi:_buttonClickListener(event)
	local tag = event.target:getTag()
	if self.m_selected_tag ~= tag then
		self.m_selected_tag = tag
		if self.m_button_change_listener then
			self.m_button_change_listener(tag)
		end
	end
end

return CGroupButtonUi