--todo：出牌阶段轮询
local FightingStage = class("FightingStage")
local this = nil
function FightingStage:ctor(layer)
	this = layer
	-- self._gData = self._parent:getGData()
	-- --self
	self._seatIndex = 0
	self._seats = GDataManager:getInstance():getSeats()
	self._playerNum = #self._seats

	UIChangeObserver:getInstance():addUIChangeObserver(ListenerIds.kPlayCard, self, handler(self, self._playCardSuccess))
	UIChangeObserver:getInstance():addUIChangeObserver(ListenerIds.kNextSeat, self, handler(self, self._getNextSeatActive))
end

function FightingStage:getActiveSeatUp()
	this:hideOperatorUi()
	this:timerBegan()
	for _,_seat in pairs(self._seats) do
		this:getHandCardsBySeat(_seat):getHuCheck():resetHu()
	end
	local seat = self:_getActivitySeat()
	GDataManager:getInstance():setCurrentSeat(seat)
	ww.print("----------------------当前活动玩家", seat)
	this:getHandCardsBySeat(seat):mineFeelCard(1)
end

function FightingStage:began()
	self:getActiveSeatUp()
end

function FightingStage:_getActivitySeat()
	self._seatIndex = self._seatIndex + 1
	if self._seatIndex > self._playerNum then
		self._seatIndex = 1
	end
	return self._seats[self._seatIndex]
end

--碰、杠、胡将跳过自己一个阶段
--碰、杠都会影响顺序
function FightingStage:updateSeatIndex(seat_pos)
	for id,pos in pairs(self._seats) do
		if pos == seat_pos then
			self._seatIndex = id
			break
		end
	end
end

function FightingStage:_playCardSuccess(card)
	ww.print("打出成功;座位号--", card:getSeat())
	--1. 该座位玩家成功打出
	--2. 其他三位玩家根据优先级检测 胡(并列)>杠>碰 (所有响应)
	--3. 检测到则等待 。。。
	--4. 未检测到 过
	for _,seat in pairs(GDataManager:getInstance():getSeats()) do
		if seat == card:getSeat() then
			card:setCardType(mjDCardType.mj_play)
			this:getHandCardsBySeat(card:getSeat()):playCardSuccess(card)
		else
			this:getHandCardsBySeat(seat):otherPlayCard(card)
		end
	end
	
	local actionSeats = GDataManager:getInstance():checkSortFightInfo()  --找出有效的序列
	if actionSeats and #actionSeats > 0 then
		--AI会有自己的响应机制 如果超时，则肯定是玩家未操作，按过处理
		dump(actionSeats)
		for _,_seat in pairs(actionSeats) do
			if _seat ~= 1 then
				this:getHandCardsBySeat(_seat):getManager():doAction()  --AI直接尝试直接操作
			end
		end
	end

	GDataManager:getInstance():resetSortFightInfo(false)

	local minePlayNotComon = GDataManager:getInstance():minePlayStateNotCommon()  --本家是否在其他状态
	if not minePlayNotComon then
		GDataManager:getInstance():removeActionSeat(1)
		GDataManager:getInstance():resetMinePlayState()
	end
end

function FightingStage:_getNextSeatActive()
	self:getActiveSeatUp()
end

return FightingStage