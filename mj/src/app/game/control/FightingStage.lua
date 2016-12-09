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
	local seat = self:_getActivitySeat()
	GDataManager:getInstance():setCurrentSeat(seat)
	print("----------------------当前活动玩家", seat)
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
	print("打出成功;座位号--", card:getSeat())
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
	
	local operate_seats = GDataManager:getInstance():checkSortFightInfo()
	if operate_seats and #operate_seats > 0 then
		--有 胡、杠或碰 需等待执行
		print("_____________进入操作等待___________________")
		this:getHandCardsBySeat(operate_seats[1]):getManager():doAction()  --ai直接执行了？
		--GDataManager:getInstance():resetSortFightInfo(true)  等待未执行 进入下一轮
		--AI会有自己的响应机制 如果超时，则肯定是玩家未操作，按过处理

	else
		--直接进入下一个
		UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kNextSeat)
	end

	
	-- self._parent:getHandCardsBySeat(data.seat):playSuccess(data.card)
	-- local ret = false
	-- for _,_seat in pairs(self._parent:getSeats()) do
	-- 	if _seat ~= data.seat then
	-- 		--其他人上牌 檢測
	-- 		if self._parent:getHandCardsBySeat(_seat):upCard(2, data.card) then
	-- 			ret = true
	-- 		end
	-- 	end
	-- end
	-- print("_-----------------ret------------", ret)
	-- if not ret then
	-- 	UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kNextSeat)
	-- end
end

function FightingStage:_getNextSeatActive()
	self:getActiveSeatUp()
end

return FightingStage