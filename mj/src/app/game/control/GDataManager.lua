local GDataManager = class("GDataManager")
GDataManager.instance = nil

--游戏过程数据管理

function GDataManager.getInstance()
	if not GDataManager.instance then	
		GDataManager.instance = GDataManager.new()
	end
	return GDataManager.instance
end

-- mjFighintInfoType = {
-- 	hu = 3,
-- 	gang = 2,
-- 	peng = 1
-- }

local this = nil

function GDataManager:ctor()	
	self._seats = {1, 2, 3, 4}  --初始化好 继续游戏不会变动
	self._playSeconds = 12
	self._actionSeconds = 12
end

function GDataManager:reset()
	self._currentPos = 0 --当前活动玩家
	self._queType = 0

	self._actions = {}  --操作序列(有人出牌，其他三家做检测)
	self._actionNum = 0
	self._mineHasAction = false  --他人出牌时，自己是否有相应操作（碰，杠, 胡）

	--记牌器
	self._cardCount = {}  --存储42个 1-9:万 10-18:筒 19-27:条 28-31:(东南西北) 32-34:(中发白)
	for i=1, 27 do
		self._cardCount[i] = 0
	end
end

function GDataManager:setLayer(layer)
	this = layer
end

--每家只能有一个操作
function GDataManager:addAction(seat, value)
	self._actions[seat] = value
end

--优先级：胡>杠>碰  “胡”会有多项
function GDataManager:checkEffectiveAction()
	local isHu = false
	local isGang = false
	local isPeng = false
	for seat,val in pairs(self._actions) do
		if val == mjFighintInfoType.hu then
			isHu = true
		elseif val == mjFighintInfoType.gang then
			isGang = true
		elseif val == mjFighintInfoType.peng then
			isPeng = true
		end
	end
	if isHu then
		--有胡  其他的全部失效
		for seat,val in pairs(self._actions) do
			if val ~= mjFighintInfoType.hu then
				val = nil
			end
		end
		self._actionNum = #self._actions
		return self._actions
	end
	if isGang then
		--没有胡 有杠 碰失效
		for seat,val in pairs(self._actions) do
			if val ~= mjFighintInfoType.gang then
				val = nil
			end
		end
		self._actionNum = #self._actions
		return self._actions
	end

	if isPeng then
		self._actionNum = #self._actions
		return self._actions
	end

	return false
end

--重置掉（这个时候动作已经产生）
--如果都未响应的话（就视为过）
function GDataManager:resetActions()
	self._actions = {}
end

function GDataManager:responseAction()
	self._actionNum = self._actionNum - 1
	if self._actionNum == 0 then
		--下一个
		UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kNextSeat)
	end
end

--记牌器
function GDataManager:addCardCount(card_id)
	self._cardCount[card_id] = self._cardCount[card_id] + 1
end

--本家响应 action 结束
--注意：无效操作目前，界面上是不展示的，所以只有自己选“过”的时候才调用这个执行下一步
--若是选择了其他有效操作，则回走主循环
function GDataManager:mineHasActionReponse()
	if self._mineHasAction then
		self:responseAction()
		self._mineHasAction = false
	end
end

--============================================
function GDataManager:getCurrentSeat()
	return self._currentPos
end

function GDataManager:setCurrentSeat(seat)
	self._currentPos = seat
end

function GDataManager:getQueType()
	return self._queType
end

function GDataManager:setQueType(type)
	self._queType = type
end

function GDataManager:getMineHasAction()
	return self._mineHasAction
end

function GDataManager:setMineHasAction(ret)
	self._mineHasAction = ret
end

function GDataManager:getCardCount()
	return self._cardCount
end

--游戏默认参数
function GDataManager:getSeats()
	return self._seats
end

function GDataManager:getPlaySeconds()
	return self._playSeconds
end

function GDataManager:getActionSeconds()
	return self._actionSeconds
end

return GDataManager