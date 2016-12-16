--todo:UICheckBoxButtonGroup 这真是个好东西，个数不同锚点位置都不一样 设你mb的动态位置
local CGroupBaseUi = import(".CGroupBaseUi")
local CGroupCheckBoxUi = class("CGroupCheckBoxUi", CGroupBaseUi)

function CGroupCheckBoxUi:ctor()
	CGroupCheckBoxUi.super.ctor(self)
	self.m_selected_tag = 0
	self.m_checkbox_changed_listener = nil
end

function CGroupCheckBoxUi:addCheckBox(checkBox, id)
	self:addChildNode(checkBox, id)
	checkBox:onButtonClicked(handler(self, self._checkBoxClickListener))
end

--设置选中状态
function CGroupCheckBoxUi:setSelectedByGroupIndex(index)
	self.m_group_base[index]:getNode():setButtonSelected(true)
end

function CGroupCheckBoxUi:onCheckBoxSelectChanged(listener)
	self.m_checkbox_changed_listener = listener
end

function CGroupCheckBoxUi:_checkBoxClickListener(event)
	local tag = event.target:getTag()
	if self.m_selected_tag ~= tag then
		self.m_selected_tag = tag
		for id,val in pairs(self.m_group_base) do
			self:_checkBoxSelectedState(val:getNode(), val:getNode():getTag() == tag)
		end
		if self.m_checkbox_changed_listener then
			self.m_checkbox_changed_listener(self.m_selected_tag)
		end
	else
		self:_checkBoxSelectedState(event.target, true)
	end
end

function CGroupCheckBoxUi:_checkBoxSelectedState(event, ret)
	event:setButtonSelected(ret)
	if self.m_click_listener then  --备用
		self.m_click_listener(ret)
	end
end

return CGroupCheckBoxUi