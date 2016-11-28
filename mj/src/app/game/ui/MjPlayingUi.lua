import("..common_define.init")
UIChangeObserver = require("app.game.UIObservers.UIChangeObserver")
MjDataControl = require("app.game.control.MjDataControl")
--ui
local HandCardsUi = import(".hand_cards_mag.HandCardsUi")
local DealCardsUi = import(".DealCardsUi")
local FightingStage = import("..control.FightingStage")
local MjPlayingUi = class("MjPlayingUi", function() return display.newLayer() end)

local game_params = {
	seats = {1,2,3,4},  --參與的人數個數
}

local SpriteRes = {
	background = "background/bg.jpg"
}

function MjPlayingUi:ctor()
	--data
	self._gData = game_params
	self._seats = self._gData.seats
	--ui
	self._allHandCards = {}
	self._allSurplusCards = {{},{},{},{}}  --所有余牌{1,2,3,4}每个位置17叠
	--object
	self._dealCardsUi = nil
	self._fightingState = nil

	self:_setupUi()
	self:_connectObserver()
	self:_ready()
end

function MjPlayingUi:_setupUi()
	local background = cc.ui.UIImage.new(SpriteRes.background)
	background:addTo(self)
	background:setLayoutSize(display.width, display.height)
	math.randomseed(os.time())
	local back_txt_sp = string.format("mj/back_text/bg_gk_name_%d.png", math.random(1, 13))
	display.newSprite(back_txt_sp)
	:addTo(self)
	:pos(display.cx, display.cy - 55)

end

function MjPlayingUi:_connectObserver()

end

function MjPlayingUi:_unConnectObserver()

end

function MjPlayingUi:_ready()
	MjDataControl:getInstance():dataStart()
	self:_initAllSurplusCards()

	for _,seat in pairs(self._seats) do
		self._allHandCards[seat] = HandCardsUi.new(self)
	end

	--self._dealCardsUi = DealCardsUi.new(self)
	--self._fightingState = FightingStage.new(self)
end

--初始化所有的余牌
function MjPlayingUi:_initAllSurplusCards()
	local cardArray = MjDataControl:getInstance():getMjArray()
	dump(cardArray)
	local pos1 = cc.p(200, 100)
	local pos2 = cc.p(display.width - 200, display.height-100)
	local pos3 = cc.p(200, display.height - 100)
	local pos4 = cc.p(200, display.height - 100)
	for id,card in pairs(cardArray) do
		if id <= 26 or (id > 54 and id <= 80) then
			local md = math.ceil(id / 34)
			local pos = md == 1 and pos1 or pos3
			local ar = md == 1 and 1 or 3
			table.insert(self._allSurplusCards[ar], #self._allSurplusCards[ar]+1, card)
			card:setSpriteFrame(mjCardBsx)
			local y = pos.y
			if id % 2 == 0 then
				y = y+15
			else
				pos.x = pos.x + mjCardBsxW
			end
			card:pos(pos.x, y)
		elseif id <= 54 or (id > 80 and id <= 108) then
			local md = math.ceil(id / 68)
			local ar = md == 1 and 2 or 4
			local pos = md == 1 and pos2 or pos4
			table.insert(self._allSurplusCards[ar], #self._allSurplusCards[ar]+1, card)
			card:setSpriteFrame(mjCardBh)
			local x = pos.x
			if id % 2 == 0 then
				pos.y = pos.y + 8
			else
				pos.y = pos.y - mjCardBhH
			end
			card:pos(x, pos.y)
		end
		card:addTo(self)
	end
end

--获得一个活动玩家（摸牌、出牌）
function MjPlayingUi:_getActivitySeat()
	local seat = self._fightingState:getActivitySeat()
	self._allHandCards[seat]:upCard(card, 1)
end

function MjPlayingUi:_fighting()

end

--get
function MjPlayingUi:getHandCardsBySeat(seat)
	return self._allHandCards[seat]
end

function MjPlayingUi:getGData()
	return self._gData
end

return MjPlayingUi