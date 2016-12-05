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

	self.m_max_playing_nums = {
		{num = 0,y = 0},
		{num = 0,y = 0},
		{num = 0,y = 0},
		{num = 0,y = 0},
	}

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
		card:pos(beganPos.x, beganPos.y + kDis[2] * num + 30)
	elseif seat == 3 then  --66* 94
		card:pos(beganPos.x - kDis[3]* num - 90, beganPos.y)
	else
		card:pos(beganPos.x, beganPos.y - kDis[4]* num - 30)
	end
end

--打出的牌的位置及變化
local kMax = 10
function HandCardByPos:playingCardParams(seat, card)
	local kPlayingCardBeganPos = {
		[1] = cc.p(display.cx - kMax/2 * 33, display.cy - 150),
		[2] = cc.p(display.cx - kMax/2 * 37, display.cx + 150),
	}
	local began_pos = kPlayingCardBeganPos[seat]
	self.m_max_playing_nums[seat].num = self.m_max_playing_nums[seat].num + 1
	if seat == 1 then
		card:setSpriteFrame(string.format("szx_%d.png", card:getId()))
		card:pos(began_pos.x + self.m_max_playing_nums[seat].num * 33, began_pos.y + self.m_max_playing_nums[seat].y)
	elseif seat == 2 then
		print("__________________seat_________________", 2)
		card:setSpriteFrame(string.format("zx_%d.png", card:getId()))
		card:pos(began_pos.x, began_pos.y + self.m_max_playing_nums[seat].num * 37)
	elseif seat == 3 then

	else

	end
end

return HandCardByPos