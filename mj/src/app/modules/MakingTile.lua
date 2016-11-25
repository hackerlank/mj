local MakingTile = class("MakingTile", function() return display.newSprite() end)

local kType = {
	unknow = 0,
	dark2 = 1, --自己牌
	dark1 = 2, --他人牌
	out1 = 3   --打出牌
}

local kBackSprite = {
	[kType.dark2] = "titles/dark_2.png",
	[kType.dark1] = "titles/dark_1.png",
	[kType.out1] = "titles/out_1.png"
}

function MakingTile:ctor(type)
	self._type = type or 1

	self:setTexture(kBackSprite[1])
	self._tile = display.newSprite()
	self._tile:addTo(self)
	self._tile:pos(W(self)/2, H(self)/2-10)

	self:setContentSize(GCardWidth, GCardHeight)
	self:setScale(GCardScale, GCardScale)
end

function MakingTile:changeType(type)
	self._type = type or 1
	self:setTexture(kBackSprite[type])
	self._tile:setVisible(not type == kType.dark1)
end

function MakingTile:changeId(id)
	self._tile:setTexture(string.format("titles/%d.png", id))
end

return MakingTile