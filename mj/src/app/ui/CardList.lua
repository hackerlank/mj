local Card = import("..modules.Card")
local CardList = class("CardList", function() return display.newNode() end)

local kUpCardEnum = {
	unknow = 0,
	other = 1,
	mine = 2
}

function CardList:ctor(params)
	self._params = params
	self.m_need_sort = true  --需不需要做排序等操作(AI)
	self.m_open_list = {}  --明牌
	self.m_dark_list = {}  --暗牌 .

	--手外
	self.m_pengP = {}
	self.m_gangP = {}
	--手中
	self._jiang = {}
	self._kezi = {}
	self._gangzi = {}
end

function CardList:addCardIds(card_ids)
	for i,id in pairs(card_ids) do
		local card = Card.new()
		card:setId(id)
		card:setSortId(i)
		card:getSprite():addTo(self)
		table.insert(self.m_dark_list, #self.m_dark_list+1, card)
	end

	self:_sortMyCard()
	self:_setPramsByKey()
end

--上牌(他人出牌时，上牌检测; 自己摸牌时上牌检测)
function CardList:upCard(card, type)
	if type == kUpCardEnum.other then
		--检测 碰、杠、胡
		local ret1 = self:_checkPeng(card)
		local ret2 = self:_checkGang(card)
		return (ret1 or ret2)
	elseif type == kUpCardEnum.mine then
		card:setSortId(#self.m_dark_list + 1)
		table.insert(self.m_dark_list, #self.m_dark_list + 1, card)
		self:_setPramsByKey()
		--检测是否有暗杠、检测是否能胡牌
		self:_checkDarkGang()
	end
end

--排序 位置变化
function CardList:_sortMyCard()
	if self.m_need_sort then
		local sortFunc = function(a,b) return a:getId() < b:getId() end
		table.sort(self.m_dark_list, sortFunc)
		for i,card in pairs(self.m_dark_list) do
			card:setSortId(i)
			if self._params.id == 1 or self._params.id == 3 then
				card:setPos(self._params.pos.x + GCardWidth * card:getSortId(), self._params.pos.y)
			elseif self._params.id == 2 or self._params.id == 4 then
				-- card:getSprite():setContentSize(GCardWidth, GCardHeight)
				-- card:getSprite():setScale(GCardScale-0.2, GCardScale-0.2)
				card:getSprite():setRotation(-90)
				card:setPos(self._params.pos.x, self._params.pos.y + GCardWidth * card:getSortId())
			end
		end
	end
end

--出牌成功
function CardList:playSuccess(play_card)
	for _,card in pairs(self.m_dark_list) do
		if play_card:getId() == card:getId() then
			table.remove(self.m_dark_list, card:getSortId())
			break
		end
	end
	self:_sortMyCard()
	self:_setPramsByKey()
end
--======================================================
--逻辑检测部分
--======================================================
--need_sort = true
function CardList:_setPramsByKey()
	--分组存放（把刻字、杠子、将牌）罗列出来
	if not self.m_need_sort then
		return 
	end
	local tmp = {}
	for _,card in pairs(self.m_dark_list) do
		local id = card:getId()
		if not tmp[id] then
			tmp[id] = {}
		end
		table.insert(tmp[id], #tmp[id] + 1, card)
	end
	for _,val in pairs(tmp) do
		if #val == 2 then
			table.insert(self._jiang, #self._jiang+1, val)
		elseif #val == 3 then
			table.insert(self._kezi, #self._kezi+1, val)
		elseif #val == 4 then
			table.insert(self._gangzi, #self._gangzi+1, val)
		end
	end
end

function CardList:_checkPeng(card)
	for _,cards in pairs(self._jiang) do
		if cards[1]:getId() == card:getId() then
			print("----------检测到碰--------------")
			return true
		end
	end
end

function CardList:_doPeng()
	--执行
end

--每次上牌时检测 暗杠
function CardList:_checkDarkGang()
	for _,cards in pairs(self._gangzi) do
		print("有暗杠")
	end
end

function CardList:_checkGang(card)
	for _,cards in pairs(self._kezi) do
		if cards[1]:getId() == card:getId() then
			print("----------检测到杠--------------")
			return true
		end
	end
end

function CardList:_doGang()

end

function CardList:_checkHu()

end

function CardList:_doHu()

end

--====================================================
	-- self._jiang = {}
	-- self._kezi = {}
	-- self._gangzi = {}
function CardList:getDarkList()
	return self.m_dark_list
end

function CardList:getJiang()
	return self._jiang
end

function CardList:getKezi()
	return self._kezi
end

function CardList:gtGangzi()
	return self._gangzi
end

return CardList