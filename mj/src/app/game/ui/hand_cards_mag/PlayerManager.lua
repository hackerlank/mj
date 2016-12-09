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

function PlayerManager:checkHu()

end

function PlayerManager:doAction()
	print("对于玩家这个函数并没有什么卵用")
end

return PlayerManager