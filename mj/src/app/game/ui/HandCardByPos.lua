local HandCardByPos = class("HandCardByPos")

function HandCardByPos:ctor(parent)
	self._parent = parent

	self._cardsPos = {}
end

function HandCardByPos:_sortDarkList(cards)
	local sortFunc = function(a,b) return a:getId() < b:getId() end
	table.sort(cards, sortFunc)
end

function HandCardByPos:init(seat, cards)
	self:_sortDarkList(cards)
	self._cardsPos[seat] = cards
	for _,card in pairs(cards) do
		local beganPos = mjDarkPositions[seat]
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

return HandCardByPos