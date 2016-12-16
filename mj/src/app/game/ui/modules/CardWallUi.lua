--[[
	1. 只有一副牌<明牌、暗牌>
	2. 将、刻子、杠子(碰牌属于明刻、杠牌属于明杠)
	3. 检测 杠、碰、暗杠、碰杠
]]
local HandCardPos = import("..HandCardPos")
local RobotManager = import("..RobotManager")
local PlayerManager = import("..PlayerManager")
--local HuCheck = import(".HuCheck")
local CardCheckHu = import(".CardCheckHu")
local CardWallUi = class("CardWallUi")

local this = nil
function CardWallUi:ctor(layer)
	this = layer

	self._seat = 0
	self._queType = nil  --定缺类型

	self._darkCards = {}  --牌墙【暗牌】
	self._showCards = {}  --明牌【碰、杠】
	self._huCards = {}    --明牌【胡的牌】

	self._jiang = {}
	self._kezi = {}  --明刻(碰的牌)
	self._dkezi = {} --暗刻
	self._gangzi = {}  --暗杠（手中未杠出去的牌）

	self._peng = nil  --可碰列表
	self._gang = nil  --可杠列表

	self._handCardPos = HandCardPos.new(this, self)
	self._huCheck = CardCheckHu.new(self)
end

--初始化：发牌阶段上牌多张；开始过程上牌是一张一张的上的；所以只用于初始化发牌
function CardWallUi:addHandCards(seat, cards)
	self._seat = seat
	if seat == 1 then
		self._manager = PlayerManager.new()
	else
		self._manager = RobotManager.new(this, self)
	end
	for id,card in pairs(cards) do
		card:setIsMine(seat == 1)
		table.insert(self._darkCards, #self._darkCards+1, card)
	end

	self:_darkCardChange(true)
end

--手牌有变化
function CardWallUi:_darkCardChange(is_sort, is_last)
	--分割暗牌(找出 将、暗刻、暗杠)
	self:_setPramsByKey() 
	--对手牌进行排序
	self._handCardPos:sortDarkCards(is_sort, is_last)
	self._handCardPos:setShowCardPos()
end

function CardWallUi:_setPramsByKey()
	--在暗牌中找
	self._jiang = {}
	self._dkezi = {}
	self._gangzi = {}
	local tmp = {}
	for _,card in pairs(self._darkCards) do
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
			--要把刻子放入将牌（能杠则能碰）
			table.insert(self._jiang, #self._jiang+1, {val[1], val[2]})
			table.insert(self._dkezi, #self._dkezi+1, val)
		elseif #val == 4 then
			table.insert(self._gangzi, #self._gangzi+1, val)
		end
	end
end

--从暗牌列表中移除一些牌
function CardWallUi:_removeCards(cards)
	local index = 0
	for _,_card in pairs(cards) do
		for id,__card in pairs(self._darkCards) do
			if _card:getId() == __card:getId() then
				table.remove(self._darkCards, __card:getSortId() - index)
				index = index + 1
				break
			end
		end
	end
end

function CardWallUi:removeLastDrakCard()
	table.remove(self._darkCards, #self._darkCards)
end

--定完缺 设置一遍
function CardWallUi:updateCardWallQueInfo(que_type)
	self._queType = que_type
	for _,card in pairs(self._darkCards) do
		if card:getType() == self._queType then
			card:setIsQue(true)
		end
	end
	self:_darkCardChange(true, true)
end

--[[
	分有两种情况：1. 自己上牌 2. 他人出牌
]]
--自己上牌
function CardWallUi:mineFeelCard()
	--按顺序获取一张牌
	local card= MjDataControl:getInstance():getCardMjArray(1)[1]  
	--设置成改位置玩家手牌
	card:setSeat(self._seat)
	card:setIsMine(self._seat == 1)
	--类型设置成暗牌（frame）
	card:setCardType(mjDCardType.mj_dark)

	if self:_checkQue({card}) then
		card:setIsQue(true)
	end
	--放在暗牌列表最后
	card:setSortId(#self._darkCards+1)  
	table.insert(self._darkCards, #self._darkCards+1, card)

	self:_darkCardChange(false, true)

	--暗杠
	self._manager:checkDarkGang(self:_checkDarkGang())
	self._manager:checkMGang(self:_checkMGang(card))
	self._manager:checkHu(self:_checkHu(), 1, card) --检测暗杠

	self._manager:playCard(card)
end

function CardWallUi:otherPlayCard(card)
	--检测碰、杠、胡
	--self:_setPramsByKey()  --找出杠子等牌,检测杠
	local isGang = self:_checkGang(card)
	self._manager:checkGang(isGang)
	local isPeng = self:_checkPeng(card)
	self._manager:checkPeng(isPeng)
	local isHu = self:_checkHu(card)
	self._manager:checkHu(isHu, 2, card)
	local fighting_type = nil
	
	if isPeng then
		fighting_type = mjFighintInfoType.peng
	end
	if isGang then
		fighting_type = mjFighintInfoType.gang
	end
	if isHu then
		fighting_type = mjFighintInfoType.hu
	end
	GDataManager:getInstance():addAction(self._seat, fighting_type)
end

--出牌成功
function CardWallUi:playCardSuccess(card)
	GSound:getInstance():playEffect(card:getSound())
	self._handCardPos:setPlayCardPos(card)
	table.remove(self._darkCards, card:getSortId())
	self:_darkCardChange(true) --未加入插入动画
end

function CardWallUi:insertHuCard(card)
	table.insert(self._huCards, #self._huCards+1, card)
	self._handCardPos:huCardsPositions(card)
end

--================================================
--检测--
function CardWallUi:_checkQue(list)
	--检测通过的牌组中有没有缺牌
	for _,card in pairs(list) do
		if card:getType() == self._queType then
			return card
		end
	end
end

--检测并找出手牌中的一张缺牌
function CardWallUi:findDarkCardsByQue()
	return self:_checkQue(self._darkCards)
end

function CardWallUi:_checkHu(card)
	local ret = self._huCheck:checkHu(card)
	if ret then
		if self:_checkQue(self._darkCards) then
			return false
		end
		return ret
	end
end

function CardWallUi:_checkDarkGang()
	--只检测手中的暗杠
	local num = #self._gangzi
	if num > 0 then
		if self:_checkQue(self._gangzi) then
			return false
		end
		return true
	end
end

function CardWallUi:_checkMGang(card)
	--检测明刻中是否能杠
	self._gang = nil
	local gang = nil
	dump(self._kezi)
	for _,cards in pairs(self._kezi) do
		if cards[1]:getId() == card:getId() then
			--检测通过
			if self:_checkQue(cards) then
				return false
			end
			gang = clone(cards)
			table.insert(gang, #gang+1, card)
			self._gang = gang
			return true
		end
	end
end

function CardWallUi:_checkGang(card)
	local gang = nil
	for _,cards in pairs(self._dkezi) do
		if cards[1]:getId() == card:getId() then
			if self:_checkQue(cards) then
				return false
			end
			gang = clone(cards)
			table.insert(gang, #gang+1, card)
			self._gang = gang
			return true
		end
	end
end

function CardWallUi:_checkPeng(card)
	--遍历手中将牌
	local peng = {}
	for _,cards in pairs(self._jiang) do
		if cards[1]:getId() == card:getId() then
			if self:_checkQue(cards) then
				return false
			end
			--检测到可碰的牌， 放入可碰列表(只会有一个碰)
			peng = clone(cards)
			table.insert(peng, #peng+1, card)
			self._peng = peng
			return true
		end
	end
end

--执行--
function CardWallUi:doPeng()
	if self._peng then
		table.insert(self._showCards, {
			type = mjNoDCardType.peng,
			value = clone(self._peng)
		})
		--碰的这三张牌变为持有的铭刻
		table.insert(self._kezi, #self._kezi+1, clone(self._peng))
		self:_removeCards(self._peng)
		self:_darkCardChange(true, true)
		self._peng = nil

		this:updateSeatIndex(self._seat)
		GSound:getInstance():playEffect(mjSpecialEffect.woman.peng)
	end
end

function CardWallUi:doDarkGang()
	if #self._gangzi > 0 then
		table.insert(self._showCards, {
			type = mjNoDCardType.dgang,
			value = clone(self._gangzi[1])
		})
		self:_removeCards(self._gangzi[1])
		self:_darkCardChange(true)

		GSound:getInstance():playEffect(mjSpecialEffect.woman.gang)
	end
end

function CardWallUi:doMGang()
	print(#self._gang)
	if self._gang and #self._gang == 4 then
		for id,cards in pairs(self._showCards) do
			if cards[1]:getId() == self._gang[1]:getId() then
				self._showCards[id].type = mjNoDCardType.gang
				table.insert(self._showCards[id].value, #self._showCards[id].value+1, self._gang[4])
				self:_darkCardChange(true)
				self._gang = nil

				GSound:getInstance():playEffect(mjSpecialEffect.woman.gang)
			end
		end
	end
end

function CardWallUi:doGang()
	if self._gang then
		table.insert(self._showCards, {
			type = mjNoDCardType.gang,
			value = clone(self._gang)
			})
		self:_removeCards(self._gang)
		self._gang = nil
		self:_darkCardChange()

		this:updateSeatIndex(self._seat)

		GSound:getInstance():playEffect(mjSpecialEffect.woman.gang)
	end
end

--================================================
--*set & get*
function CardWallUi:getDrakCards()
	return self._darkCards
end

function CardWallUi:getJiang()
	return self._jiang
end

function CardWallUi:getKezi()
	return self._kezi
end

function CardWallUi:getGangzi()
	return self._gangzi
end

function CardWallUi:getShowCards()
	return self._showCards
end

function CardWallUi:getSeat()
	return self._seat
end

function CardWallUi:getHuCards()
	return self._huCards
end 

function CardWallUi:getHandCardPos()
	return self._handCardPos
end

function CardWallUi:getManager()
	return self._manager
end

function CardWallUi:getHuCheck()
	return self._huCheck
end

return CardWallUi