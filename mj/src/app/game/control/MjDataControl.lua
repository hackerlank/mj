--todo:手牌數據控制
local DarkCard = import("..ui.modules.DarkCard")
local MjDataControl = class("MjDataControl")
MjDataControl.instance = nil

--血流成河 108 牌
local sz_gets = {
		[1] = {
			{began = 3, ends = 108},
			{began = 1, ends = 2}
		},
		[2] = {
			{began = 50, ends = 1},
			{began = 108, ends = 51}
		},
		[3] = {
			{began = 74, ends = 1},
			{began = 108, ends = 73}
		},
		[4] = {
			{began = 89, ends = 108},
			{began = 1, ends = 88}
		},
		[5] = {
			{began = 11, ends = 108},
			{began = 1, ends = 10}
		},
		[6] = {
			{began = 42, ends = 1},
			{began = 108, ends = 43}
		},
	}

function MjDataControl.getInstance()
	if not MjDataControl.instance then
		MjDataControl.instance = MjDataControl.new()
	end
	return MjDataControl.instance
end

function MjDataControl:ctor()
	math.randomseed(os.time())

	self.m_mj_array = nil  --当局游戏的牌组(id)
	self.m_sz_number = 0  --一開莊丟到的數字
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
		table.remove(array, index)
		num = num - 1
	end
	--打乱结束则不会再改变牌顺序
	self.m_mj_array = cards
end


function MjDataControl:setBeganSzNumber(number)
	self.m_sz_number = number  --(1 - 6)
end

local iii = 3

--摸牌、取牌（這裏衹有暗牌）
function MjDataControl:getCardMjArray(num)
	--从头开始取
	local sz_gets_arr = sz_gets[self.m_sz_number]
	local currentArr = {}
	--衹是重新排一下獲取序號
	-- for _,val in pairs(sz_gets_arr) do
	-- 	for i = val.began, val.ends do
	-- 		table.insert(currentArr, #currentArr+1, self.m_mj_array[i])
	-- 	end
	-- end
	--dump(currentArr)
	--self.m_mj_array = currentArr
	--dump(self.m_mj_array)

	local cardsArr = {}
	-- local tmpB = {}
	-- for id,card in pairs(self.m_mj_array) do
	-- 	if id <= num then
	-- 		print("--------------id---------", id)
	-- 		table.insert(cardsArr,#cardsArr+1, card)
	-- 	else
	-- 		table.insert(tmpB,#tmpB+1, card)
	-- 	end
	-- end
	-- self.m_mj_array = tmpB  --（ids）
	for i = iii, iii + num-1 do
		table.insert(cardsArr,#cardsArr+1, self.m_mj_array[i])
	end
	iii = iii + num
	return cardsArr
end

--每当牌数发生变化时
function MjDataControl:dispatcherCardNumChange()
	
end

function MjDataControl:getMjArray()
	return self.m_mj_array
end

return MjDataControl