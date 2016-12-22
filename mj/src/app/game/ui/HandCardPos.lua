--[[
	這個類型只用来设置手牌位置
	包括【暗、碰、杠（明、暗）、胡、打出、上牌】
]]
local HandCardPos = class("HandCardPos")

local this = nil
function HandCardPos:ctor(layer, hand_card)
	this = layer
	self._handCard = hand_card  --手牌类

	--=============未手持， 碰、杠、暗杠的牌位置展示
	self._showBeganPos = nil
	self._upCardDistance = 0  --上牌离手牌距离
	--=============
	self._playCardNum = 0  --已打出多少张牌
	self._numIndex = 0     --这两条都用于计算打出牌的位置
end

function HandCardPos:reset()
	--=============未手持， 碰、杠、暗杠的牌位置展示
	self._showBeganPos = nil
	self._upCardDistance = 0  --上牌离手牌距离
	--=============
	self._playCardNum = 0  --已打出多少张牌
	self._numIndex = 0     --这两条都用于计算打出牌的位置
end

function HandCardPos:subPlayCardNum()
	--todo: 打出的手牌 被碰、杠、胡了
	self._playCardNum = self._playCardNum - 1
	self._numIndex = self._numIndex - 1
	if self._numIndex < 0 then
		self._numIndex = 0
	end
end

--[[
	首先对暗牌进行排序和位置设定
]]
--仅仅只是偏移量
local kDarkUpCardP = {
	[1] = 20,
	[2] = 10,
	[3] = 20,
	[4] = 10
}
--ret : 控制是否最后一张 隔开（上牌、碰）的时候可使用
function HandCardPos:sortDarkCards(is_sort, is_last)
	local seat = self._handCard:getSeat()
	local cards = self._handCard:getDrakCards()
	
	if is_sort then
		--摸到牌的时候不能排序(只是刚上牌的时候)
		local sortFunc = function(a,b) return a:getSortValue() < b:getSortValue() end
		table.sort(cards, sortFunc)
	end

	for id,card in pairs(cards) do
		local beganPos = mjDarkPositions[seat]
		card:setSeat(seat)
		if seat ~= 1 then
			card:setCardType(mjDCardType.mj_dark)
		end
		-- if seat ~= 1 then
		-- 	card:setCardType(mjDCardType.mj_play)
		-- end
		card:setSortId(id)
		local function getDis(seat)
			if id == #cards and is_last then 
			--最后一张是上的牌
				return kDarkUpCardP[seat]
			end
			return 0
		end
		if seat == 1 then  --66*94
			card:pos(beganPos.x + 66* id + getDis(1), beganPos.y)
		elseif seat == 2 then  --16*40
			card:pos(beganPos.x, beganPos.y + 32* id + getDis(2))
		elseif seat == 3 then  --66* 94
			card:pos(beganPos.x - 33* id - getDis(3), beganPos.y)
		else
			card:pos(beganPos.x, beganPos.y - 32* id - getDis(4))
		end
	end
end

--[[
	上牌位置
]]

function HandCardPos:setUpCardParams(card)
	local seat = self._handCard:getSeat()
	local cards = self._handCard:getDrakCards()

	local num = #cards + 1
	local beganPos = mjDarkPositions[seat]
	if seat == 1 then  --66*94
		card:pos(66 * num + 20, beganPos.y)
		self._upCardDistance = 20
	elseif seat == 2 then  --16*40
		card:pos(beganPos.x, beganPos.y + 40 * num + 10)
		self._upCardDistance = 40
	elseif seat == 3 then  --66* 94
		card:pos(beganPos.x - 66* num - 90, beganPos.y)
		self._upCardDistance = -20
	else
		card:pos(beganPos.x, beganPos.y - 40* num - 10)
		self._upCardDistance = -40
	end
end

--[[
	打出手牌位置
]]
local kPlayerCardNum = 7
function HandCardPos:setPlayCardPos(card)
	local seat = self._handCard:getSeat()
	if seat == 1 then
		self:_seat1PlayPos(card)
	elseif seat == 2 then
		self:_seat2PlayPos(card)
	elseif seat == 3 then
		self:_seat3PlayPos(card)
	elseif seat == 4 then
		self:_seat4PlayPos(card)
	end
	self._playCardNum = self._playCardNum + 1
	self._numIndex = self._numIndex + 1
	if self._numIndex % kPlayerCardNum == 0 then
		self._numIndex = 0
	end
end

function HandCardPos:_seat1PlayPos(card)
	local beganP = mjPlayPositions[1]
	local disX = math.floor(self._playCardNum/kPlayerCardNum) * 47
	card:pos(beganP.x + self._numIndex * 33, beganP.y-disX)
end

function HandCardPos:_seat2PlayPos(card)
	local beganP = mjPlayPositions[2]
	local disX = math.floor(self._playCardNum/kPlayerCardNum) * 40
	card:pos(beganP.x + disX, beganP.y + self._numIndex * 37)
end

function HandCardPos:_seat3PlayPos(card)
	local beganP = mjPlayPositions[3]
	local disX = math.floor(self._playCardNum/kPlayerCardNum) * 47
	card:pos(beganP.x - self._numIndex * 33, beganP.y+disX)
end

function HandCardPos:_seat4PlayPos(card)
	local beganP = mjPlayPositions[4]
	local disX = math.floor(self._playCardNum/kPlayerCardNum) * 40
	card:pos(beganP.x-disX, beganP.y-self._numIndex * 37)
end

--有杠牌 碰牌_showCards
function HandCardPos:setShowCardPos()
	--位置初始位置是手牌之后
	local num = #self._handCard:getDrakCards()
	if (num-2)%3 == 0 then
		num = num - 1
	end
	local card_lists = self._handCard:getShowCards()
	local seat = self._handCard:getSeat()

	if seat == 1 then
		self._showBeganPos = cc.p(mjDarkPositions[1].x + num*mjDarkCardSize[1].width + 190 + self._upCardDistance, mjDarkPositions[1].y)
	elseif seat == 2 then
		self._showBeganPos = cc.p(mjDarkPositions[2].x, mjDarkPositions[2].y+num*mjDarkCardSize[2].height+30+self._upCardDistance)
	elseif seat == 3 then
		self._showBeganPos = cc.p(mjDarkPositions[3].x - num*mjDarkCardSize[3].width - 80 - self._upCardDistance, mjDarkPositions[3].y)
	elseif seat == 4 then
		self._showBeganPos = cc.p(mjDarkPositions[4].x, mjDarkPositions[4].y - num * mjDarkCardSize[4].height - self._upCardDistance)
	end

	for _,card_list in pairs(card_lists) do
		self:_setShowCardsPosition(cards, card_list, seat)
	end
end

function HandCardPos:_setShowCardsPosition(cards, card_list, seat)
	local list = card_list.value
	local type_ = card_list.type
	local num = #list - 1
	for id,card in pairs(list) do
		if card:getSeat() ~= seat then
			this:getHandCardsBySeat(card:getSeat()):getHandCardPos():subPlayCardNum()  --这个调用很搞笑
		end
		card:setIsQue(false)
		card:setLocalZOrder(id)
		card:setSeat(seat)
		if type_ == mjNoDCardType.peng or type_ == mjNoDCardType.gang then
			card:setCardType(mjDCardType.mj_show)
		elseif type_ == mjNoDCardType.dgang then
			card:setCardType(mjDCardType.mj_tdark)
		end
		
		if id ~= 4 then
			card:pos(self._showBeganPos.x, self._showBeganPos.y)
			if seat == 1 then
				self._showBeganPos.x = self._showBeganPos.x + mjShowCardSize[seat].width
			elseif seat == 3 then
				self._showBeganPos.x = self._showBeganPos.x - mjShowCardSize[seat].width
			elseif seat == 2 then
				self._showBeganPos.y = self._showBeganPos.y + mjShowCardSize[seat].height
			elseif seat == 4 then
				self._showBeganPos.y = self._showBeganPos.y - mjShowCardSize[seat].height
			end
		else
			card:setCardType(mjDCardType.mj_show)
			if seat == 1 then
				card:pos(self._showBeganPos.x - mjShowCardSize[seat].width*2, self._showBeganPos.y+24)
			elseif seat == 3 then
				card:pos(self._showBeganPos.x + mjShowCardSize[seat].width*2, self._showBeganPos.y+24)
			elseif seat == 2 then
				card:pos(self._showBeganPos.y + mjShowCardSize[seat].height*2, self._showBeganPos.x+24)
			elseif seat == 4 then
				card:pos(self._showBeganPos.y - mjShowCardSize[seat].height*2, self._showBeganPos.x+24)
			end
		end
	end
	if seat == 1 or seat == 3 then
		self._showBeganPos.x = self._showBeganPos.x + (seat == 1 and 10 or -10)
	else
		self._showBeganPos.y = self._showBeganPos.y + (seat == 2 and 10 or -10)
	end
end

--胡牌位置
function HandCardPos:huCardsPositions(card)
	--mjHuCardPositions
	local num = #self._handCard:getHuCards()
	local seat = self._handCard:getSeat()
	local began_pos = mjHuCardPositions[seat]

	if card:getSeat() ~= seat then
		this:getHandCardsBySeat(card:getSeat()):getHandCardPos():subPlayCardNum()  --这个调用很搞笑
	end
	if seat == 1 then
		card:setSeat(1)
		card:setCardType(mjDCardType.mj_play)
		card:pos(began_pos.x + 33 * num, began_pos.y)
	end
end

return HandCardPos