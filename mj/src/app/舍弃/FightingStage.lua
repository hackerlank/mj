local FightingStage = class("FightingStage")

function FightingStage:ctor(params)
	self._baseTime = params.base_time

	--self
	self._seatIndex = 0
	self._palyerSeats = params.seats
	self._playerNum = #params.seats
end

function FightingStage:getActivitySeat()
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