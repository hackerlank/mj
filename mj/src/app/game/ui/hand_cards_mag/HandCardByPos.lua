--===========================================
--[[
	只做位置上的变动，动画
]]
--===========================================
local HandCardByPos = class("HandCardByPos")

local kDis = {
	[1] = 66,
	[2] = 40,
	[3] = 66,
	[4] = 40
}

function HandCardByPos:ctor(parent)
	self._parent = parent

	self._cardsPos = {}
end

function HandCardByPos:sortDarkList(seat, cards)
	local sortFunc = function(a,b) return a:getId() < b:getId() end
	table.sort(cards, sortFunc)

	self:update(seat, cards)
end

function HandCardByPos:update(seat, cards)
	self._cardsPos[seat] = cards
	for _,card in pairs(cards) do
		local beganPos = mjDarkPositions[seat]
		if seat ~= 1 then
			card:setSpriteFrame(mjDarkBack[seat])
		else
			card:recoverCard()
		end
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

function HandCardByPos:setUpCardParams(seat, card)
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
		card:pos(beganPos.x, beganPos.y + 40* _)
	elseif seat == 3 then  --66* 94
			card:pos(beganPos.x - 66* _, beganPos.y)
	else
			card:pos(beganPos.x, beganPos.y - 40* _)
	end
	
end

return HandCardByPos