local DealingStage = class("DealingStage")

local this = nil  --之后的this都表示父节点
function DealingStage:ctor(layer)
	this = layer

	
end

function DealingStage:began()
	--計算 出莊家位置 1
	MjDataControl:getInstance():setBeganSzNumber(1)
	--發牌
	--根据庄家位置定制一次发牌顺序
	local seats = {}
	for _,seat in pairs(this:getSeats()) do
		if seat >= 1 then
			table.insert(seats, #seats + 1, seat)
		end
	end
	for _,seat in pairs(this:getSeats()) do
		if seat < 1 then
			table.insert(seats, #seats + 1, seat)
		end
	end
	for _,seat in pairs(seats) do
		local array = MjDataControl:getInstance():getCardMjArray(13)
		this:getHandCardsBySeat(seat):addHandCards(seat, array)
	end
end

return DealingStage