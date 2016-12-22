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
			began = 76, 
			isShun = true
		},
		[4] = {
			began = 91,
			isShun = false
		},
		[5] = {
			began = 11,
			isShun = false
		},
		[6] = {
			began = 42,
			isShun = true
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

end

function MjDataControl:dataStart()
	self.m_mj_array = nil  --当局游戏的牌组(id)
	self.m_sz_number = 0  --一開莊丟到的數字
	self.m_cards_num = 108  --牌张总数
	self.m_current_num = 0  --当前使用张数
	self.m_game_over = false

	self:_randMjArray()
end

--打乱 随机 
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
	self.m_mj_array = cards  --牌的总数不会少
end

--确定庄家位置
function MjDataControl:setBeganSzNumber(number)
	self.m_sz_number = number  --(1 - 6)
	local gets = sz_gets[self.m_sz_number]
	if gets.isShun then
		self:_sortCardsByBeganNumber_1(gets.began)
	else
		self:_sortCardsByBeganNumber(gets.began)
	end
end

function MjDataControl:_sortCardsByBeganNumber(began_num)
	local cardArray = {}
	for id,card in pairs(self.m_mj_array) do
		if id >= began_num then
			table.insert(cardArray, #cardArray+1, card)
		end
	end
	for id,card in pairs(self.m_mj_array) do
		if id < began_num then
			table.insert(cardArray, #cardArray+1, card)
		end
	end
	self.m_mj_array = cardArray
end

--顺时针
function MjDataControl:_sortCardsByBeganNumber_1(began_num)
	local cardArray = {}
	for i = 1, began_num do
		table.insert(cardArray, #cardArray+1, self.m_mj_array[began_num-i+1])
	end
	local num = 108
	for i = began_num + 1, 108 do
		table.insert(cardArray, #cardArray+1, self.m_mj_array[num])
		num = num - 1
	end

	self.m_mj_array = cardArray
end

--摸牌、取牌（這裏衹有暗牌）
function MjDataControl:getCardMjArray(num)
	--衹是重新排一下獲取序號
	local cardsArr = {}
	for i = 1, num do
		self:dispatcherCardNumChange()
		table.insert(cardsArr, #cardsArr+1, self.m_mj_array[self.m_current_num])
	end

	return cardsArr
end

--每当牌数发生变化时
function MjDataControl:dispatcherCardNumChange()
	self.m_current_num = self.m_current_num + 1
	UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kCardsNum, self.m_cards_num - self.m_current_num)
end

function MjDataControl:checkGameOver()
	if self.m_current_num == self.m_cards_num then
		self.m_game_over = true
		UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kGameOver)
	end
end

--删除掉所有的牌\等待重新生成
function MjDataControl:removeAllCards()
	for _,card in pairs(self.m_mj_array) do
		card:removeFromParent()
	end
	self.m_mj_array = {}
end

function MjDataControl:getMjArray()
	return self.m_mj_array
end

function MjDataControl:getSZNumber()
	return self.m_sz_number
end

function MjDataControl:getGameOver()
	return self.m_game_over
end

--当前拿到第几张牌
function MjDataControl:getCurrentNum()
	return self.m_current_num
end

return MjDataControl