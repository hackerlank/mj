--todo:手牌數據控制
local Card = import("..ui.modules.Card")
local MjDataControl = class("MjDataControl")
MjDataControl.instance = nil

MDEBUG = false

--血流成河 108 牌
local sz_gets = {
		[1] = {
			began = 3, 
			isShun = false
		},
		[2] = {
			began = 50,
			isShun = true
		},
		[3] = {
			began = 74, 
			isShun = false
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
	self.m_current_id = 0
	self.m_total_ids = 108
	self.m_isShun = true
end

function MjDataControl:dataStart()
	self.m_mj_array = nil  --当局游戏的牌组(id)
	self.m_sz_number = 0  --一開莊丟到的數字
	self.m_current_id = 0
	self.m_total_ids = 108
	self.m_isShun = true
	self:_randMjArray()
end

function MjDataControl:_randMjArray()
	local array = clone(mjArray)
	local cards = {}
	if MDEBUG then
		for _,val in pairs(array) do
			local dark_card = Card.new()
			dark_card:changeId(val)
			table.insert(cards,#cards+1, dark_card)
		end
	else
		local num = #mjArray
		while num >= 1 do
			local index = math.random(1, num)
			--移除随机出来的这个
			local dark_card = Card.new()
			dark_card:changeId(array[index])
			table.insert(cards,#cards+1, dark_card)
			table.remove(array, index)
			num = num - 1
		end
	end
	
	--打乱结束则不会再改变牌顺序
	self.m_mj_array = cards
end

--确定庄家位置
function MjDataControl:setBeganSzNumber(number)
	self.m_sz_number = number  --(1 - 6)
	local gets = sz_gets[self.m_sz_number]
	self.m_current_id = gets.began
	self.m_isShun = gets.isShun
end

--摸牌、取牌（這裏衹有暗牌）
function MjDataControl:getCardMjArray(num)
	--从头开始取
	local currentArr = {}
	--衹是重新排一下獲取序號

	local cardsArr = {}
	if not self.m_isShun then
		while num > 0 do
			num = num - 1
			table.insert(cardsArr,#cardsArr+1, self.m_mj_array[self.m_current_id])
			self.m_current_id = self.m_current_id + 1
			if self.m_current_id > self.m_total_ids then
				self.m_current_id = 1
			end
		end
	else
		for i = self.m_current_id, self.m_current_id - num + 1 do
			table.insert(cardsArr,#cardsArr+1, self.m_mj_array[i])
		end
		self.m_current_id = self.m_current_id - num
	end
	return cardsArr
end

--每当牌数发生变化时
function MjDataControl:dispatcherCardNumChange()
	
end

function MjDataControl:getMjArray()
	return self.m_mj_array
end

return MjDataControl