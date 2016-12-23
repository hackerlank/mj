local SurplusPosition = import(".SurplusPosition")
local DealingStage = class("DealingStage")

local this = nil  --之后的this都表示父节点
local kZSNumbers = {
	[1] = 1,
	[2] = 2,
	[3] = 3,
	[4] = 4,
	[5] = 1,
	[6] = 2	
}

function DealingStage:ctor(layer)
	this = layer

	self._IsEnterDingque = false
	self._BankerVec = 5
	self._bankerSeat = kZSNumbers[self._BankerVec]

	self._seats = GDataManager:getInstance():getSeats()
end

function DealingStage:began()
	self._IsEnterDingque = false
	--計算 出莊家位置 1
	local surplus_pos = SurplusPosition.new(this)
	surplus_pos:setSurplusCardsPosition(self._BankerVec)
	MjDataControl:getInstance():setBeganSzNumber(self._BankerVec)
	--發牌
	--根据庄家位置定制一次发牌顺序
	local seats = {}
	for _,seat in pairs(self._seats) do
		if seat >= 1 then
			table.insert(seats, #seats + 1, seat)
		end
	end
	for _,seat in pairs(self._seats) do
		if seat < 1 then
			table.insert(seats, #seats + 1, seat)
		end
	end
	for _,seat in pairs(seats) do
		--local array = MjDataControl:getInstance():getCardMjArray(13)
		--this:getHandCardsBySeat(seat):addHandCards(seat, array)
		self:_fourDealing(seat)
	end
end

function DealingStage:_fourDealing(seat)
	local actionSeq = {}
	for i = 1, 3 do
		local default = 4
		if i == 3 then
			default = 5
			if seat == self._bankerSeat then
				default = 5
			end
		end
		local function listener()
			local array = MjDataControl:getInstance():getCardMjArray(default)
			this:getHandCardsBySeat(seat):addHandCards(seat, array)
		end
		table.insert(actionSeq, #actionSeq + 1, cc.Sequence:create(
			cc.CallFunc:create(listener),
			cc.DelayTime:create(0.5)
			))
	end
	table.insert(actionSeq, #actionSeq + 1,
		cc.CallFunc:create(function() 
			local ret = seat == self._bankerSeat
			this:getHandCardsBySeat(seat):_darkCardChange(true, ret)
			self:_enterDingque()
		end))
	this:runAction(cc.Sequence:create(actionSeq))
end

function DealingStage:_enterDingque()
	if self._IsEnterDingque then
		return 
	end
	--当做发牌结束(进入定缺阶段)
	UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kEnterDingque)
	self._IsEnterDingque = true
	this:getHandCardsBySeat(self._bankerSeat):mineFeelCard(1)
end

return DealingStage