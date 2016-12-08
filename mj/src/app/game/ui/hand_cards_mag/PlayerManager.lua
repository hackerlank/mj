local PlayerManager = class("PlayerManager")

function PlayerManager:ctor()

end

function PlayerManager:waitPlayCard(card)
	--card 刚抓的牌
end

--检测到暗杠
function PlayerManager:checkDarkGang(ret)
	print(ret and "玩家检测到杠" or "")
	if ret then
		UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kMineGang, mjDarkGang)
	end
end

function PlayerManager:checkGang(ret)
	if ret then
		UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kMineGang, mjGang)
	end
end

function PlayerManager:checkPeng()

end

function PlayerManager:checkHu()

end

return PlayerManager