local SeatActions = class("SeatActions")

local this = nil
function SeatActions:ctor(layer)
	this = layer
end

function SeatActions:doActionDingque()
	print("缺")
end

function SeatActions:doActionPeng()
	print("碰")
end

function SeatActions:doActionGuafeng()
	print("杠、刮风")
end

function SeatActions:doActionHu()
	print("胡")
end

return SeatActions