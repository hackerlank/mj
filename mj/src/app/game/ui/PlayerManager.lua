local PlayerManager = class("PlayerManager")

function PlayerManager:ctor()

end

function PlayerManager:waitPlayCard(card)
	--card 刚抓的牌
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