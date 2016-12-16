--列表和
local function countTableAddValues(tb)
	local num = 0
	for _,v in pairs(tb) do
		num = num + v
	end
	return num
end

local Robot = class("Robot")

function Robot:ctor(card_wall)
	self._cardWall = card_wall  --牌墙对象

	self._cardWall = {}
end

--对手做的统一处理
function Robot:_setDarkList()

end

--条1、筒2、万3 存放(有多少牌)
function Robot:_splitDarkList()
	local dark_list = self._cardWall:getDarkList()
	self._cardAll = {}
	for _,card in pairs(dark_list) do
		local card_type = card:getType()
		if not self._cardAll[card_type] then
			self._cardAll[card_type] = {0, 0, 0, 0, 0, 0, 0, 0, 0}
		end
		local value = card:getId() % 9
		value = value == 0 and 9 or value
		self._cardAll[card_type][value] = self._cardAll[card_type][value] + 1
	end
end

--定缺(找出最少的一门)
function Robot:DingQue()
	local max = 0
	local cardType = 0
	for id,val in pairs(self._cardAll) do
		if countTableAddValues(val) > max then
			max = countTableAddValues(val)
			cardType = i
		end
	end
	return cardType  --(缺门类型）
end



return Robot