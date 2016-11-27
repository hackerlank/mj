--todo:還是在主界面上進行，只是獨立出來
local DealCardsUi = class("DealCardsUi")

function DealCardsUi:ctor(parent)
	self._parent = parent  --游戲界面(MjPlayingUi)
	self._seats = self._parent._seats

	self:_setupUi()
end

function DealCardsUi:_setupUi()
	for _,seat in pairs(self._seats) do
		local cards = MjDataControl:getInstance():getCardMjArray(13)
		for _,card in pairs(cards) do
			if seat ~= 1 then
				card:setSpriteFrame(mjDarkBack[seat])
			end
			card:addTo(self._parent)
		end
		self._parent:getHandCardByPos():init(seat, cards)
	end
end

--上翻動作
function DealCardsUi:_upFAction()
	sp:runAction(seq)
end

return DealCardsUi