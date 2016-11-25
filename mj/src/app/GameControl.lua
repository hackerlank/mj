local FightingStage = import(".FightingStage")
local CardBackLayer = require("app.scenes.mj.ui.CardBackLayer")
local GameControl = class("GameControl", function() return display.newLayer() end)

function GameControl:ctor()
	self._beganPos = 1 --庄家位置
	self._seatPos = {1, 2, 3, 4}
	self._currentPlayers = #self._seatPos


	self._fightingStage = FightingStage.new({seats = self._seatPos})

	self:onConnectObservers()

	self:_setupUi()
end

function GameControl:onConnectObservers()
	UIChangeObserver:getInstance():addUIChangeObserver(ListenerIds.kNextSeat, self, handler(self, self._nextFightingListenr))
end

function GameControl:unConnectObservers()
	UIChangeObserver:getInstance():removeOneUIChangeObserver(ListenerIds.kNextSeat, self)
end

--==================================================
--listeners
function GameControl:_nextFightingListenr()
	self:_getActivitySeat()
end
--==================================================

function GameControl:_setupUi()
	local base_pos = cc.p(50, 200)
    cc.ui.UIPushButton.new({normal = "2.png"})
    :addTo(self, 1000)
    :pos(50, 50)
    :onButtonClicked(function(event) 
        self._cardBackLayer:upMineCard(1)
        end)

	self:gameStar()
end

function GameControl:gameStar()
	self:_dealing()
	self:_fighting()
end

--1.随出庄家
--2.发牌
--暂时舍去
function GameControl:_dealing()
	self._cardBackLayer = CardBackLayer.new({seats = self._seatPos})
    :addTo(self)
end

--从1开始(递归进行)
--游戏结束{1.有人胡牌 2.最后一张牌 流局}
--一人出牌结束（先检测其他人是否有 碰、杠、胡 才可以进行下一个出牌，否等待10s）
--获取当然活动的玩家座位
function GameControl:_getActivitySeat()
	local current_seat = self._fightingStage:getActivitySeat()
	--上牌
	print("_________当前活动玩家__________", current_seat)
	self._cardBackLayer:upMineCard(current_seat)
end

function GameControl:_fighting()
	self:_getActivitySeat()
end

function GameControl:_counting()

end

--===============================================\
function GameControl:_showSeatTimer()

end

return GameControl