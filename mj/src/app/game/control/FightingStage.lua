--todo：出牌阶段轮询
local FightingStage = class("FightingStage")

function FightingStage:ctor(parent)
	self._parent = parent
	self._gData = self._parent:getGData()
	--self
	self._seatIndex = 0
	self._palyerSeats = self._gData.seats
	self._playerNum = #self._gData.seats

	UIChangeObserver:getInstance():addObserver(ListenerIds.kPlayCard, handler(self, self._playCardSuccess))
end

function FightingStage:began()
	local seat = self:_getActivitySeat()
	print("----------------------当前活动玩家", seat)
	self._parent:getHandCardsBySeat(seat):upCard(1)
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

return FightingStage