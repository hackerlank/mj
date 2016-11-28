--todo:手牌數據控制
local DarkCard = import("..ui.modules.DarkCard")
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
	self.m_mj_array = nil  --当局游戏的牌组(id)
	self:randMjArray()
end

function MjDataControl:randMjArray()
	local array = clone(mjArray)
	local cards = {}
	local num = #mjArray
	while num >= 1 do
		local index = math.random(1, num)
		--移除随机出来的这个
		local dark_card = DarkCard.new()
		dark_card:changeId(array[index])
		table.insert(cards,#cards+1, dark_card)

		--table.insert(tmpArr, #tmpArr+1, array[index])
		table.remove(array, index)
		num = num - 1
	end
	--打乱结束则不会再改变牌顺序
	self.m_mj_array = cards
end

--摸牌、取牌（這裏衹有暗牌）
-- function MjDataControl:getCardMjArray(num)
-- 	--从头开始取
-- 	local cards = {}
-- 	local tmpB = {}
-- 	for id,val in pairs(self.m_mj_array) do
-- 		if id <= num then
-- 			--todo:從這裏直接生成牌
-- 			local dark_card = DarkCard.new()
-- 			dark_card:changeId(val)
-- 			table.insert(cards,#cards+1, dark_card)
-- 		else
-- 			table.insert(tmpB,#tmpB+1, val)
-- 		end
-- 	end
-- 	self.m_mj_array = tmpB  --（ids）
-- 	return cards
-- end

--每当牌数发生变化时
function MjDataControl:dispatcherCardNumChange()
	
end

function MjDataControl:getMjArray()
	return self.m_mj_array
end

return MjDataControl