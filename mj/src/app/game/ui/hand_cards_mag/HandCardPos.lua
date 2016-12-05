--[[
	這個類型只用来设置手牌位置
	包括【暗、碰、杠（明、暗）、胡、打出、上牌】
]]
local HandCardPos = class("HandCardPos")

function HandCardPos:cotr(hand_card)
	self._handCard = hand_card  --手牌类
end

--[[
	首先对暗牌进行排序和位置设定
]]

function HandCardPos:sortDarkCards()
	local seat = self._handCard:getSeat()
	local cards = self._handCard:getDarkList()
	
	local sortFunc = function(a,b) return a:getId() < b:getId() end
	table.sort(cards, sortFunc)

	for _,card in pairs(cards) do
		local beganPos = mjDarkPositions[seat]
		card:setSeat(seat)
		card:setCardType(mjDCardType.mj_dark)
		card:setSortId(_)
		if seat == 1 then  --66*94
			card:pos(beganPos.x + 66* _, beganPos.y)
		elseif seat == 2 then  --16*40
			card:pos(beganPos.x, beganPos.y + 40* _)
		elseif seat == 3 then  --66* 94
			card:pos(beganPos.x - 66* _, beganPos.y)
		else
			card:pos(beganPos.x, beganPos.y - 40* _)
		end
	end
end

--[[
	上牌位置
]]

function HandCardPos:setUpCardParams(seat, card)
	local num = #self._cardsPos[seat] + 1
	local beganPos = mjDarkPositions[seat]
	if seat ~= 1 then
		card:setSpriteFrame(mjDarkBack[seat])
	else
		card:recoverCard()
	end
	if seat == 1 then  --66*94
		card:pos(kDis[1] * num + 90, beganPos.y)
	elseif seat == 2 then  --16*40
		card:pos(beganPos.x, beganPos.y + kDis[2] * num + 30)
	elseif seat == 3 then  --66* 94
		card:pos(beganPos.x - kDis[3]* num - 90, beganPos.y)
	else
		card:pos(beganPos.x, beganPos.y - kDis[4]* num - 30)
	end
end

return HandCardPos