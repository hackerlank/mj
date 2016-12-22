local SeatUi = class("SeatUi", function() return display.newNode() end)

local SpriteRes = {
	action_a_p = "#action_a_p.png",
	action_a_g = "#action_a_g.png",
	action_a_h = "#action_a_h.png",

	mark_banker = "#mark_zhuang.png",
	mark_tiao = "mark_tiao.png",
	mark_tong = "mark_tong.png",
	mark_wan = "mark_wan.png",
}

local this = nil
function SeatUi:ctor(layer, seat)
	this = layer
	self._seat = seat
	self._seatParams = mjPlayerInfoPos[seat]
	self._zPos = self._seatParams.zPos   --播放字动画位置（碰、杠、胡）

	self._headUrl = nil     --头像
	self._nickName = nil    --呢称
	self._scoreLabel = nil  --积分
	self._queMark = nil     --定缺
	--
	self._player = nil

	self:_setupUi()

	self:setPosition(self._seatParams.pos)
	self:addTo(this)

	self:_checkSeatMine()
end

function SeatUi:_setupUi()
	self._headUrl = display.newSprite("#ico_1.png")
	self._headUrl:addTo(self)
	self._headUrl:setScale(70 /W(self._headUrl))

	-- self._markBanker = display.newSprite(SpriteRes.mark_banker)
	-- self._markBanker:addTo(self)
	-- self._markBanker:setPosition(self._seatParams.banker_pos)

	self._queMark = display.newSprite()
	self._queMark:addTo(self)
	self._queMark:pos(30, 30)

	self._scoreLabel = ww.createLabel("10000", 16)
	self._scoreLabel:addTo(self)
	self._scoreLabel:align(display.CENTER, 0, -45)

	-- self._nickName = ww.createLabel("test", 20)
	-- self._nickName:addTo(self)
	-- self._nickName:align(display.CENTER , W(self._InfoBg) / 2, H(self._InfoBg) / 2 + 10)
end

function SeatUi:changePlayer(player)
	self._player = player
	self._headUrl:setSpriteFrame(self._player.url)
	--self._nickName:setString(self._player.nick_name)
end

--mine
function SeatUi:_checkSeatMine()
	if self._seat == 1 then
		self:pos(40, 155)
	end
end

--set mark que
function SeatUi:setMarkQue(dex)
	if dex == mjCardType.mj_wan then
		self._queMark:setSpriteFrame(SpriteRes.mark_wan)
	elseif dex == mjCardType.mj_tiao then
		self._queMark:setSpriteFrame(SpriteRes.mark_tiao)
	elseif dex == mjCardType.mj_bing then
		self._queMark:setSpriteFrame(SpriteRes.mark_tong)
	else
		self._queMark:setTexture("")
	end
	local params = {
		init_scale = 0,
		max_scale = 1.3,
		time = 0.2,
		rtime = 0.2,
	}
	common_action_fadeIn(self._queMark, params)
end

--action
function SeatUi:_createZiAction(texture, listener)
	local sp = display.newSprite(texture)
	sp:setPosition(self._zPos)
	sp:addTo(this, mjLocalZorders.common_tip)
	local function listener_()
		if listener then listener() end
		sp:removeFromParent()
	end
	local params = {
		init_scale = 4,
		max_scale = 1.2,
		time = 0.1,
		rtime = 0.2,
		end_listener = listener_,
		listener_delay = 0.3
	}
	common_action_fadeIn(sp, params)

	self:_actionSubScore(1000)
end

function SeatUi:actionPeng(listener)
	self:_createZiAction(SpriteRes.action_a_p, listener)
end

function SeatUi:actionGang(listener)
	self:_createZiAction(SpriteRes.action_a_g, listener)
end

function SeatUi:actionHu(listener)
	self:_createZiAction(SpriteRes.action_a_h, listener)
end

function SeatUi:_actionSubScore(score)
	local label = ww.createBMFontLabel("-" .. score, FNT_NUMBER_BLUE_2)
	label:align(display.CENTER)
	--label:setPosition(self._zPos)
	label:pos(self._zPos.x - 200, self._zPos.y)
	label:addTo(this, mjLocalZorders.common_tip)
	label:setOpacity(0)
	label:runAction(cc.Sequence:create(
		cc.Spawn:create(cca.fadeIn(0.3), cca.moveTo(0.3, self._zPos.x, self._zPos.y)),
		cca.fadeOut(0.4),
		cc.CallFunc:create(function() label:removeFromParent() end)
		))
end

return SeatUi