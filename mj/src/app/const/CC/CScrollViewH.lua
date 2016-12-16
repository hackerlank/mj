local CScrollViewH = class("CScrollViewH", function() 
	return display.newNode()
end)


function CScrollViewH:ctor(rect, direction)
	self.m_rect = rect
	self.m_items = {}
	self.m_layout_y = 0
	self.m_layout_x = 0
	self.m_direction = direction or 1
	self.m_scroll_view = cc.ui.UIScrollView.new({
		viewRect = rect, 
		--bgColor = cc.c4b(255, 0, 0, 100)
	})
	self.m_scroll_view:addTo(self)
	self.m_scroll_node = cc.Node:create()
	self.m_scroll_node:pos(rect.x, rect.y)
	self.m_scroll_node:setContentSize(rect.width, rect.height)
	self.m_scroll_view:setDirection(self.m_direction) --cc.ui.UIScrollView.DIRECTION_VERTICAL)
	self.m_scroll_view:addScrollNode(self.m_scroll_node)
end

function CScrollViewH:setBounceable(ret)
	self.m_scroll_view:setBounceable(ret)
end

function CScrollViewH:setLayoutY(y)
	self.m_layout_y = y or 0
end

function CScrollViewH:setLayoutX(x)
	self.m_layout_x = x or 0
end

function CScrollViewH:addScrollItem(data, i)
	assert("只给子类复写使用")
	--return display.newSprite("ui/ss.png")
end

function CScrollViewH:setup(tdata)
	for i,data in pairs(tdata) do
		--todo: item的锚点为中心点
		local item = self:addScrollItem(data, i)
		item:addTo(self.m_scroll_node)
		table.insert(self.m_items, #self.m_items+1, item)
	end
end

function CScrollViewH:addScallItem(data)
	local item = self:addScrollItem(data, #self.m_items+1)
	item:addTo(self.m_scroll_node)
	table.insert(self.m_items, #self.m_items+1, item)
end

--每次可能都需要动画
function CScrollViewH:showAction(delay, mtime, ftime)
	if self.m_direction == 1 then
		self.m_scroll_view:scrollTo(cc.p(-self.m_rect.width/2, -self.m_rect.height))
	elseif self.m_direction == 2 then
	end
	for id,item in pairs(self.m_items) do
		local count_id = item.index  or id
		item:stopAllActions()
		local time = (id > 5 and 5 or id) * (delay or 0.03)
		if self.m_direction == 1 then
			item:pos(self.m_layout_x+self.m_rect.width/2, -200)
			local iHeight = self.m_layout_y + H(item)
			item:runAction(cc.Sequence:create(
				cc.DelayTime:create(time),
				cca.moveTo((mtime or 0.5), self.m_layout_x+self.m_rect.width/2, self.m_rect.height + 10 - iHeight * (count_id-0.5)),
				cca.moveTo((ftime or 0.1), self.m_layout_x+self.m_rect.width/2, self.m_rect.height - iHeight * (count_id-0.5))
				))
		elseif self.m_direction == 2 then
			item:pos(self.m_rect.width + 500, self.m_rect.height/2)
			local iWidth = self.m_layout_x + W(item)
			item:runAction(cc.Sequence:create(
				cc.DelayTime:create(time),
				cca.moveTo((mtime or 0.5), iWidth * (count_id - 0.5) - 10, self.m_rect.height/2),
				cca.moveTo((ftime or 0.1), iWidth * (count_id - 0.5), self.m_rect.height/2)
				))
		end
		
	end
end


return CScrollViewH
