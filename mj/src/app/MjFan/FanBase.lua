local FanBase = class("FanBase")

FanBase.MjFanType = {
	unknow = 0,
	standed = 1,	--标准类型
	seven = 2,		--七对类型
	thirteen = 3  --十三不靠类型
}

function FanBase:ctor()
	self._fan = 0
	self._title = ""
end

function FanBase:tryMatch(handTiles, darkTiles)

end

function FanBase:init(fan, title)
	if fan < 1 then
		assert("异常，番数不可能为0")
	end
	if not title then
		assert("异常， title空盒子")
	end
	self._fan = fan
	self._title = title
end

----------------------------

function FanBase:tostring()
	return self._title
end

function FanBase:setFan(fan)
	self._fan = fan
end

function FanBase:getFan()
	return self._fan
end

function FanBase:getTitle()
	return self._title
end

function FanBase:setTitle(title)
	self._title = title
end

return FanBase