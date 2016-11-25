local MjDataControl = class("MjDataControl")
MjDataControl.instance = nil

function MjDataControl.getInstance()
	if not MjDataControl.instance then
		MjDataControl.instance = MjDataControl.new()
	end
	return MjDataControl.instance
end

function MjDataControl:ctor()
	math.randomseed(os.time())

	self.m_mj_array = nil  --当局游戏的牌组(id)
end

function MjDataControl:dataStart()
	self:randMjArray()
end

function MjDataControl:randMjArray()
	local array = clone(mjArray)
	local tmpArr = {}
	local num = #mjArray
	while num > 1 do
		local index = math.random(1, num)
		--移除随机出来的这个
		table.insert(tmpArr, #tmpArr+1, array[index])
		table.remove(array, index)
		num = num - 1
	end
	--打乱结束则不会再改变牌顺序
	self.m_mj_array = tmpArr
end

function MjDataControl:getIdMjArray(num)
	--从头开始取
	local tmpA = {}
	local tmpB = {}
	for id,val in pairs(self.m_mj_array) do
		if id <= num then
			table.insert(tmpA,#tmpA+1, val)
		else
			table.insert(tmpB,#tmpB+1, val)
		end
	end
	self.m_mj_array = tmpB
	return tmpA
end

--每当牌数发生变化时
function MjDataControl:dispatcherCardNumChange()
	
end

function MjDataControl:getMjArray()
	return self.m_mj_array
end

return MjDataControl