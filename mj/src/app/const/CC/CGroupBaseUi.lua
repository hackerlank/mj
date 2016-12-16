local group_base = class("group_base")  --节点控制结构
function group_base:ctor()
	self.m_node = nil
	self.m_id = nil
end

function group_base:setData(data)
	self._node = data.node
	self._id = data.id
	self._active = true  --该节点不启动
end

function group_base:getNode()
	return self._node
end

function group_base:getId()
	return self._id
end

function group_base:setActive_(ret)
	self._active = ret
end

function group_base:getActive_()
	return self._active
end

--todo:需要排列展示的时候使用
--todo: 不论如何 插入顺序都是从底下到最上层 2.从左边到最右边
local CGroupBaseUi = class("CGroupBaseUi", function() return display.newNode() end)

function CGroupBaseUi:ctor()
	self.m_group_base = {}  --存放所有的node
	self.m_group_active_num = 0
	self.m_disX = 0
	self.m_twidth = 0
	self.m_my_anchorp = display.LEFT_CENTER
	
	self.m_disY = 0
	self.m_theight = 0
	self.m_direction = display.LEFT_TO_RIGHT
	

	self.m_group_node = cc.Node:create()
	self.m_group_node:addTo(self)
end

--todo:这里的node要设置contentsize大小 方便设置位置
function CGroupBaseUi:addChildNode(node, id)
	self.m_group_active_num = self.m_group_active_num + 1
	local base = group_base.new()
	base:setData({node = node, id = id})
	table.insert(self.m_group_base, #self.m_group_base+1, base)
	node:setTag(id)
	node:addTo(self.m_group_node)
	self:_resetAllCheckBoxPosition()
end

--设置横向间距
function CGroupBaseUi:setGroupLayoutX(disX)
	self.m_disX = disX
end

function CGroupBaseUi:setGroupLayoutY(disY)
	self.m_disY = disY
end

function CGroupBaseUi:setDirection(direction)
	--方向  两种：从左到右display.LEFT_TO_RIGHT  从下到上display.BOTTOM_TO_TOP
	self.m_direction = direction or display.LEFT_TO_RIGHT
	self:_resetAllCheckBoxPosition()
end

--设置节点锚点 setAnchorPoint
function CGroupBaseUi:setMyAnchorPoint(point)
	-- 1.中心点排列 display.CENTER 2.最左边排列 display.left_center(默认) display.CENTER_TOP
	self.m_my_anchorp = point or display.LEFT_CENTER
	self:_resetAllCheckBoxPosition()
end

--设置某个节点不启动
function CGroupBaseUi:setNotActiveById(id)
	for _,val in pairs(self.m_group_base) do
		if val._id == id then
			val._node:hide()
			val._active = false
			self.m_group_active_num = self.m_group_active_num - 1
			self:_resetAllCheckBoxPosition()
		end
	end
end

function CGroupBaseUi:setActiveById(id)
	for _,val in pairs(self.m_group_base) do
		if val._id == id then
			val._node:show()
			val._active = true
			self.m_group_active_num = self.m_group_active_num + 1
			self:_resetAllCheckBoxPosition()
		end
	end
end

function CGroupBaseUi:getGrouBase()
	return self.m_group_base
end

function CGroupBaseUi:getGroupActiveNum()
	return self.m_group_active_num
end

function CGroupBaseUi:_resetAllCheckBoxPosition()
	self.m_twidth = 0
	self.m_theight = 0
	for _,val in pairs(self.m_group_base) do
		if val._active then
			if self.m_direction == display.LEFT_TO_RIGHT then
				self.m_twidth = self.m_twidth + W(val._node) / 2
				val._node:pos(self.m_twidth, H(val._node)/2)
				
				if #self.m_group_base ~= _ then
					self.m_twidth = self.m_twidth + self.m_disX
					self.m_twidth = self.m_twidth + W(val._node) / 2
				else
					--self.m_twidth = self.m_twidth + self.m_disX/2
					self.m_twidth = self.m_twidth + W(val._node)/2
				end

			elseif self.m_direction == display.BOTTOM_TO_TOP then
				self.m_theight = self.m_theight + H(val._node) / 2
				val._node:pos(0, self.m_theight)
				self.m_theight = self.m_theight + H(val._node) / 2 + self.m_disY
			elseif self.m_direction == display.TOP_TO_BOTTOM then
				self.m_theight = self.m_theight - H(val._node) / 2
				val._node:pos(0, self.m_theight)
				self.m_theight = self.m_theight - H(val._node) / 2 - self.m_disY
			end
		end
	end

	if self.m_direction == display.LEFT_TO_RIGHT then
		if self.m_my_anchorp == display.CENTER then
			self.m_group_node:pos(-self.m_twidth / 2, 0)
		end
	elseif self.m_direction == display.BOTTOM_TO_TOP then
		if self.m_my_anchorp == display.CENTER then
			self.m_group_node:pos(0, -self.m_theight / 2)
		end
	end
end

function CGroupBaseUi:removeAllBaseNode()
	self.m_group_node:removeAllChildren()
	self.m_group_base = {}
end

return CGroupBaseUi