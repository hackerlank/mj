local SecondTimer = require("app.game.ui.modules.SecondTimer")
local PlayCardManager = class("PlayCardManager")

--共同点
--[[
	1. 自动出牌（1.缺牌直接出， 检测手中缺牌打出）
	2. 自己 杠， 自己胡
]]
local this = nil

function PlayCardManager:ctor(layer, cardWall)
	this = layer
	self._cardWall = cardWall
	self._seat = self._cardWall:getSeat()

	self._thinkTime = SecondTimer.new()
	self._recordAction = 0
	self._huIndex = 0  --胡牌还是自摸

	self._actionEnum = {
		hu = 1,
		dgang = 2,
		mgang = 3,
		gang = 4,
		peng = 5
	}
end

function PlayCardManager:_start(listener)
	local params = {
		time = 1,
		total_seconds = 1,
		end_listener = listener
	}
	self._thinkTime:start(params)
end

function PlayCardManager:playCard(card)
	self:autoPlayCard(card)
end

--auto play card
function PlayCardManager:autoPlayCard(card)
	--card: 抓上来的手牌
	if self._recordAction > 0 then
		--有操作执行 跳过执行
		return
	end
	--(碰牌的时候没有抓牌)
	--1.检测杠抓上来的牌是不是缺牌, 是缺牌直接打出 
	if card and card:getIsQue() then
		--直接打出
		self:_playCurrentCard(card)
		return
	end
	--2.检测手牌由没有缺牌， 找到缺牌打出
	local que_card = self._cardWall:findDarkCardsByQue()
	if que_card then
		self:_playCurrentCard(que_card)
		return
	end
	--3. 没有缺牌,抓什么打社
	--local play_id = self:baseAIPlayCard()
	--新的计算

	local play_id = self:_aiPlayCard()
	if play_id == 0 then
		--没有计算好，填补bug
		if card then
			self:_playCurrentCard(card)
		else
			local card_list = self._cardWall:getDrakCards()
			self:_playCurrentCard(card_list[1])
		end
	else
		self:_playCurrentCard(self:_checkPlayCardById(play_id))
	end

end

function PlayCardManager:_checkPlayCardById(id)
	for _,card in pairs(self._cardWall:getDrakCards()) do
		if card:getId() == id then
			return card
		end
	end
end

function PlayCardManager:_playCurrentCard(card)
	self:_start(function() 
		UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kPlayCard, card)
	end)
end

--todo:  在做检测的时候就自动出牌了
--检测到暗杠
function PlayCardManager:checkDarkGang(ret)
	if ret then
		self._recordAction = self._actionEnum.dgang
	end
end

function PlayCardManager:checkMGang(ret)
	if ret then
		self._recordAction = self._actionEnum.mgang
	end
end

function PlayCardManager:checkGang(ret)
	if ret then
		self._recordAction = self._actionEnum.gang
	end
end

function PlayCardManager:checkPeng(ret)
	if ret then
		self._recordAction = self._actionEnum.peng
	end
end

function PlayCardManager:checkHu(ret, index, card)
	--index 1: 自摸 2:胡
	if ret then
		self._recordAction = self._actionEnum.hu
		self._huIndex = index
		self._huCard = card
	end
end

--=====================================
------智能出牌---------
--[[
	a、检查听牌

　　　　b、去除间隔2个空位的不连续单牌，从两头向中间排查
　　　　c、去除间隔1个空位的不连续单牌，从两头向中间排查
　　　　d、去除连续牌数为4、7、10、13中的一张牌，让牌型成为无将胡牌型。如2344条，去除4条。
　　　　e、去除连续牌数为3、6、9、12中的一张牌，有将则打一吃二成为无将听牌型（如233条，去除3条）；
		   无将则打一成将成为有将胡牌型(如233条，去除2条)。
　　　　f、去除连续牌数位2、5、8、11中的一张牌，让牌型成为有将听牌型。如23445条，去除5条。
　　　　g、从将牌中打出一张牌。
]]

function PlayCardManager:_aiPlayCard()
	--如果胡牌了 就不到这里了
	--去掉连续牌
	local dark_list = clone(self._cardWall:getDrakCards()) --克隆手牌
	self:_splitCardsByType(dark_list)
	self:_cardsClassifyContinue()
	--先出掉散牌
	if #self._sanpai[3] > 0 then
		return self._sanpai[3][1]:getId()
	elseif #self._sanpai[2] > 0 then
		return self._sanpai[2][1]:getId()
	end
	--去除连续牌
	local card = self:_removeContinueCard()
	if card then
		return card:getId()
	end

	return 0
end

--不同类型分开存,除缺之外的类
function PlayCardManager:_splitCardsByType(dark_list)
	self._cardAll = {}
	local que_type = self._cardWall:getQueType()
	for _,card in pairs(dark_list) do
		local card_type = card:getType()
		if card_type ~= que_type then
			if not self._cardAll[card_type] then
				self._cardAll[card_type] = {}
			end
			table.insert(self._cardAll[card_type], #self._cardAll[card_type]+1, card)
		end
	end
end

--分好阵营
function PlayCardManager:_cardsClassifyContinue()
	--[[
		拿出连续牌和非连续牌
	]]
	self._continue = {}
	self._sanpai = {
		[2] = {},  --间隔2
		[3] = {}   --间隔3 和 以上
	}
	local index = 1

	local function insertContinue(card)
		if not self._continue[index] then
			self._continue[index] = {}
		end
		table.insert(self._continue[index], #self._continue[index]+1, card)
	end

	local function insertSanpai(card, dis)
		if dis >= 2 then
			if dis > 3 then dis = 3 end
			table.insert(self._sanpai[dis], #self._sanpai[dis] + 1, card)
		end
	end

	local function insertDis(card, dis)
		if dis >= 2 then
			insertSanpai(card, dis)
		else
			insertContinue(card)
		end
	end


	local function checkContinue(cards)
		index = index + 1
		if #cards == 1 then
			table.insert(self._sanpai[3], #self._sanpai[3]+1, cards[1])
		else
			for id,card in pairs(cards) do
				--从第二张开始
				if id == 1 then
					local dis = math.abs(card:getId()-cards[id+1]:getId())
					insertDis(card, dis)
				elseif id == #cards then
					local dis = math.abs(card:getId()-cards[id-1]:getId())
					insertDis(card, dis)
				else
					--左隔2 又隔3
					local dis1 = math.abs(card:getId() - cards[id+1]:getId())  --右边
					local dis2 = math.abs(card:getId() - cards[id-1]:getId())  --左边
					local dis = dis1 > dis2 and dis2 or dis1  --选择关系度小的那个
					if dis2 >= 2 then
						--具有隔开了一次
						index = index + 1
					end
					insertDis(card, dis)
				end
			end
		end
	end

	local sortFunc = function(a, b) return a:getId() < b:getId() end
	for _,cards in pairs(self._cardAll) do
		table.sort(cards, sortFunc)
		checkContinue(cards)
	end
end

local function checkShunzi(cards)
	if #cards == 3 then
		if cards[1]:getId() == cards[2]:getId()-1 and 
			cards[2]:getId() == cards[3]:getId()-1 then
			return true
		end
		if cards[1]:getId() == cards[2]:getId() and
			cards[2]:getId() == cards[3]:getId() then
			return true
		end
	else
		return false
	end
	return true
end

function PlayCardManager:_removeContinueCard()
	for _,cards in pairs(self._continue) do
		--优先处理
		if #cards == 4 or #cards == 7 or #cards == 10 or #cards == 13 then
			--1> 4 7 10 13 : 锁定三张，多余牌出掉
			return self:_lockedShunzi(cards)
		end
	end
	for _,cards in pairs(self._continue) do
		if #cards == 3 or #cards == 6 or #cards == 9 or #cards == 12 then
			--2> 3 6 9 12 : 分两个情况 是否有将
			if not checkShunzi(cards) then
				return self:_locked36912(cards)
			end
		end
	end
	for _,cards in pairs(self._continue) do
		if #cards == 2 or #cards == 5 or #cards == 8 or #cards == 11 then
			--3> 2 5 8 11 : 保证有将牌
			return self:_locked25811(cards)
		end
	end
end

function PlayCardManager:_lockedShunzi(cards)
	local function removeShunzi()
		for id = 1, #cards - 2 do
		local curr = cards[id]
		local next1 = cards[id+1]
		local next2 = cards[id+2]
			if curr:getId()+1 == next1:getId() and next1:getId()+1 == next2:getId() then
				table.remove(cards, id)
				table.remove(cards, id)
				table.remove(cards, id)
				print(">>>>>>>>>#>>>", #cards)
				if #cards == 1 then
					return
				end
				removeShunzi()
				return
			end
		end
	end
	removeShunzi()
	return cards[1]
end

function PlayCardManager:_locked36912()
	print(">>>>>>>36912")
end

function PlayCardManager:_locked25811(cards)
	--锁定一对将牌， 打出这手牌中的散牌
	for id = 1, #cards -1 do
		local curr = cards[id]
		local next1 = cards[id+1]
		if curr:getId() == next1:getId() then
			table.remove(cards, id)
			table.remove(cards, id)
			break
		end
	end
	--找出散牌
	local function checkSanPai(card, dis)
		if dis >= 2 then
			return card
		end
	end
	if #cards == 1 then
		return cards[1]
	else
		for id = 1, #cards - 1 do
			--从第二张开始
			local card = cards[id]
			if id == 1 then
				local dis = math.abs(card:getId()-cards[id+1]:getId())
				return checkSanPai(card, dis)
			elseif id == #cards then
				local dis = math.abs(card:getId()-cards[id-1]:getId())
				return checkSanPai(card, dis)
			else
				--左隔2 又隔3
				local dis1 = math.abs(card:getId() - cards[id+1]:getId())  --右边
				local dis2 = math.abs(card:getId() - cards[id-1]:getId())  --左边
				local dis = dis1 > dis2 and dis2 or dis1
				return checkSanPai(card, dis)
			end
		end
	end
end

return PlayCardManager