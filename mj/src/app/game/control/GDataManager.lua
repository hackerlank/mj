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
	self._figingInfo = {}   --胡牌优先级信息
	--都是暂时存放可相应的序列
	self._isHuSeat = {}   --可能多个 1炮多响
	self._isGangSeat = {}
	self._isPengSeat = {}
	--能够生效的操作序列
	self._actionSeats = nil

	self._needWaitList = {}  --需要等待的座位列表[只有这些玩家都操作了，才可做最后的判定]
	--[[
		--每次出牌清空
		{seat = 1, value = mjFighintInfoType.hu}
	]]
end

function GDataManager:setLayer(layer)
	this = layer
end

function GDataManager:reset()
	self._currentPos = 0 --当前活动玩家
	self._seats = {1, 2, 3, 4}

end

--检测所有的有效操作
function GDataManager:setFighingInfo(seat, value)
	self._figingInfo[seat] = value
	if value == mjFighintInfoType.hu then
		table.insert(self._isHuSeat, #self._isHuSeat+1, seat)
	elseif value == mjFighintInfoType.gang then
		table.insert(self._isGangSeat, #self._isGangSeat+1, seat)
	elseif value == mjFighintInfoType.peng then
		table.insert(self._isPengSeat, #self._isPengSeat+1, seat)
	end
end

--按 胡>杠>碰 优先级找出有效序列
function GDataManager:checkSortFightInfo() --out seat
	if #self._isHuSeat > 0 then
		for seat, value in pairs(self._figingInfo) do
			if value ~= mjFighintInfoType.hu then
				this:getHandCardsBySeat(seat):resetGang()
				this:getHandCardsBySeat(seat):retsetPeng()
			end
		end
		self._actionSeats = self._isHuSeat
	end
	if #self._isGangSeat > 0 then
		for seat, value in pairs(self._figingInfo) do
			if value ~= mjFighintInfoType.gang then
				this:getHandCardsBySeat(seat):retsetPeng()
			end
		end
		self._actionSeats = self._isGangSeat
	end
	self._actionSeats = self._isPengSeat
end

function GDataManager:removeActionSeat(seat)
	for _,_seat in pairs(self._actionSeats) do
		if _seat == seat then
			table.remove(self._actionSeats, _)
		end
	end
	if #self._actionSeats == 0 then
		--继续
		UIChangeObserver:getInstance():dispatcherUIChangeObserver(ListenerIds.kNextSeat)
	end
end

--过牌响应机制 
--[[
	1. 如果多家胡牌， 则都需要等待， 操作列表
	2. 有胡牌， 胡牌之外的都属于， 失效操作
]]

function GDataManager:resetSortFightInfo(ret)
	--ret : 成功操作 还是 未操作进入下一轮
	self._figingInfo = {}
	self._isHuSeat = {}
	self._isGangSeat = {}
	self._isPengSeat = {}
	self._actionSeats = nil
	if ret then
		this:getHandCardsBySeat(self._currentPos):getHandCardPos():subPlayCardNum()
	end
end

--============================================
function GDataManager:getCurrentSeat()
	return self._currentPos
end

function GDataManager:setCurrentSeat(seat)
	self._currentPos = seat
end

function GDataManager:getSeats()
	return self._seats
end

function GDataManager:getActionSeats()
	return self._actionSeats
end

return GDataManager