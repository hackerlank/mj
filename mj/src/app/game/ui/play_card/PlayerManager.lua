local PlayerManager = class("PlayerManager", import(".PlayCardManager"))

-- self._actionEnum = {
-- 		hu = 1,
-- 		dgang = 2,
-- 		mgang = 3,
-- 		gang = 4,
-- 		peng = 5
-- 	}
function PlayerManager:ctor(layer, cardWall)
	PlayerManager.super.ctor(self, layer, cardWall)
end

function PlayerManager:playCard(card)

end


--检测到暗杠
function PlayerManager:checkDarkGang(ret)
	if ret then
		UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kMineGang, mjDarkGang)
	end
end
--碰杠
function PlayerManager:checkMGang(ret)
	if ret then
		UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kMineGang, mjMGang)
	end
end
--直杠（杠他人的）
function PlayerManager:checkGang(ret)
	if ret then
		UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kMineGang, mjGang)
	end
end

function PlayerManager:checkPeng(ret)
	if ret then
		UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kPeng, ret)
	end
end

function PlayerManager:checkHu(ret, index, card)
	--index 1: 自摸 2:胡
	if ret then
		UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kHu, {id = index, card = card})
	end
end

function PlayerManager:doAction()
	print("对于玩家这个函数并没有什么卵用")
end

return PlayerManager