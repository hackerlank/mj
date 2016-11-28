--todo:還是在主界面上進行，只是獨立出來
--todo:发牌
local DealCardsUi = class("DealCardsUi")

function DealCardsUi:ctor(parent)
	self._parent = parent  --游戲界面(MjPlayingUi)
	self._seats = self._parent._seats

	self:_setupUi()
end

function DealCardsUi:_setupUi()
	--todo:这里要庄家选牌，从哪一方开始{seat, x}
	self._parent:setBeganSurplusPam(1, 4, true)
	for _,seat in pairs(self._seats) do
		local cards = self._parent:getMjArray(13)
		self._parent:getHandCardsBySeat(seat):addHandCards(seat, cards)
	end
end

--上翻動作
function DealCardsUi:_upFAction()
	sp:runAction(seq)
end

return DealCardsUi