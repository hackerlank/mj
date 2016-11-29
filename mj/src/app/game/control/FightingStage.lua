--todo：出牌阶段轮询
local FightingStage = class("FightingStage")

function FightingStage:ctor(parent)
	self._parent = parent
	self._gData = self._parent:getGData()
	--self
	self._seatIndex = 0
	self._palyerSeats = self._gData.seats
	self._playerNum = #self._gData.seats

	UIChangeObserver:getInstance():addUIChangeObserver(ListenerIds.kPlayCard, self, handler(self, self._playCardSuccess))
	UIChangeObserver:getInstance():addUIChangeObserver(ListenerIds.kNextSeat, self, handler(self, self._getNextSeatActive))
end

function FightingStage:getActiveSeatUp()
	local seat = self:_getActivitySeat()
	print("----------------------当前活动玩家", seat)
	self._parent:getHandCardsBySeat(seat):upCard(1)
end

function FightingStage:began()
	self:getActiveSeatUp()
end

function FightingStage:_getActivitySeat()
	self._seatIndex = self._seatIndex + 1
	if self._seatIndex > self._playerNum then
		self._seatIndex = 1
	end
	return self._palyerSeats[self._seatIndex]
end

--碰、杠都会影响顺序
function FightingStage:updateSeatIndex(seat_pos)
	for id,pos in pairs(self._palyerSeats) do
		if pos == seat_pos then
			self._seatIndex = id
			break
		end
	end
end

function FightingStage:_playCardSuccess(data)
	self._parent:getHandCardsBySeat(data.seat):playSuccess(data.card)
	local ret = false
	for _,_seat in pairs(self._parent:getSeats()) do
		if _seat ~= data.seat then
			--其他人上牌 檢測
			if self._parent:getHandCardsBySeat(_seat):upCard(2, data.card) then
				ret = true
			end
		end
	end
	print("_-----------------ret------------", ret)
	if not ret then
		UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kNextSeat)
	end
end

function FightingStage:_getNextSeatActive()
	self:getActiveSeatUp()
end

return FightingStage