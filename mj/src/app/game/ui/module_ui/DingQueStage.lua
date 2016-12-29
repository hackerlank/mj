--阶段：定缺
local DingQueStage = class("DingQueStage", function() return display.newLayer() end)

local SpriteRes = {
	bg = "#" .. mjActionBJ,
	title_text = "#dingque_word.png",
	btn_tiao = {
		normal = "#action_tiao1.png",
		pressed = "#action_tiao2.png",
		disabled = "#action_tiao3.png",
	},
	btn_wan = {
		normal = "#action_wan1.png",
		pressed = "#action_wan2.png",
		disabled = "#action_wan3.png",
	},
	btn_tong = {
		normal = "#action_tong1.png",
		pressed = "#action_tong2.png",
		disabled = "#action_tong3.png",
	}
}

local this = nil
function DingQueStage:ctor(layer)
	this = layer
	--所有玩家都定完缺，游戏开始
	self.m_aleadly_num = 0

	self:_setupUi()
end

function DingQueStage:_setupUi()
	self:addTo(this, mjLocalZorders.common_tip)
	ww.createShieldTouchLayer(self)

	self._bg = display.newSprite(SpriteRes.bg)
	self._bg:addTo(self)
	self._bg:pos(display.cx, 300)

	local w, h = W(self._bg), H(self._bg)

	display.newSprite(SpriteRes.title_text)
	:addTo(self._bg)
	:pos(w/2, h + 20)

	cc.ui.UIPushButton.new(SpriteRes.btn_wan)
	:addTo(self._bg)
	:pos(w / 2 - 120, h / 2)
	:onButtonClicked(handler(self, self._queWanClickListener))
	
	cc.ui.UIPushButton.new(SpriteRes.btn_tiao)
	:addTo(self._bg)
	:pos(w / 2, h / 2)
	:onButtonClicked(handler(self, self._queTiaoClickListener))

	cc.ui.UIPushButton.new(SpriteRes.btn_tong)
	:addTo(self._bg)
	:pos(w / 2+120, h / 2)
	:onButtonClicked(handler(self, self._queTongClickListener))

	--self:robotDingQue()
end

function DingQueStage:robotDingQue()
	for _,seat in pairs(GDataManager:getInstance():getSeats()) do
		if seat ~= 1 then
			this:getHandCardsBySeat(seat):updateCardWallQueInfo()
		end
	end
end

function DingQueStage:_buttonCommonClick(que_type)
	self:hide()
	GDataManager:getInstance():setQueType(que_type)
	this:getHandCardsBySeat(1):updateCardWallQueInfo(que_type)
	self:robotDingQue()
	--定缺完成 进入开始阶段
	UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kEnterFighting)
end

function DingQueStage:_queWanClickListener(event)
	self:_buttonCommonClick(mjCardType.mj_wan)
end

function DingQueStage:_queTiaoClickListener(event)
	self:_buttonCommonClick(mjCardType.mj_tiao)
end

function DingQueStage:_queTongClickListener(event)
	self:_buttonCommonClick(mjCardType.mj_bing)
end

return DingQueStage