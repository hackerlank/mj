local RobotManager = class("RobotManager")

function RobotManager:ctor()

end

function RobotManager:waitPlayCard(card)
	assert("直接出牌")
	UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kPlayCard, card)
end

--检测到暗杠
function RobotManager:checkDarkGang(ret)
	assert("ai检测到杠")
end

function RobotManager:checkGang()

end

function RobotManager:checkPeng()

end

function RobotManager:checkHu()

end

return RobotManager