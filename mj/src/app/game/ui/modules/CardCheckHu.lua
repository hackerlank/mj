local CardCheckHu = class("CardCheckHu")

--self._cardAll = {}  --二维表 3、9  
-- mjCardType = {
-- 	mj_wan = 1,
-- 	mj_tiao = 2,
-- 	mj_bing = 3,
-- 	mj_feng = 4,
-- 	mj_zfb = 5,
-- 	mj_hua = 6
-- }

function CardCheckHu:ctor(hand_cards)
	self._handCards = hand_cards
	self._cardAll = {}
end

local function dumpCardList(list)
	local str = ""
	for _,val in pairs(list) do
		str = str .. val:getName() .. ","
	end
	self:print(str)
end

function CardCheckHu:print(fmt, ...)
    if self._handCards:getSeat() == 1 then
        print(fmt, ...)
    end
end


function CardCheckHu:checkHu(card)
	self:print("<<<<<<<<<<<<<<<<<<<<<<<<<本次检测>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
	local dark_list = clone(self._handCards:getDrakCards())
	if card then
		--他人上牌
		table.insert(dark_list, #dark_list+1, card)
	end
	if self._handCards:_checkQue(dark_list) then
		return false
	end
	-- local tt = {4,5,6,9,9,16,16,16}
	-- local tmp = {}
	-- for _,val in pairs(tt) do
	-- 	dark_list[_]:changeId(val)
	-- 	table.insert(tmp, #tmp+1, dark_list[_])
	-- end
	self:_splitDarkCards(dark_list)
	return self:_Win()
end

function CardCheckHu:_splitDarkCards(dark_list)
	self._cardAll = {}
	for _,card in pairs(dark_list) do
		local card_type = card:getType()
		if not self._cardAll[card_type] then
			self._cardAll[card_type] = {0, 0, 0, 0, 0, 0, 0, 0, 0}
		end
		local value = card:getId() % 9
		value = value == 0 and 9 or value
		self._cardAll[card_type][value] = self._cardAll[card_type][value] + 1
	end
end

local function countTableAddValues(tb)
	local num = 0
	for _,v in pairs(tb) do
		num = num + v
	end
	return num
end

function CardCheckHu:_Win()
	local jiangPos = nil
	local yuShu = nil
	local jiangExisited = false
    --是否满足3，3，3，3，2模型
	for i,val in pairs(self._cardAll) do
		yuShu = countTableAddValues(val) % 3
		if yuShu == 1 then
			return false
		elseif yuShu == 2 then
			if jiangExisited then
				return false
			end
			jiangPos = i
			jiangExisited = true
		end
	end

	self:print("-----------jiangPos-----", jiangPos)
	if not jiangPos then
		return 
	end

	for i,val in pairs(self._cardAll) do
		if i ~= jiangPos then
			self:print(self:_AnalyZe(val, false))
			if not self:_AnalyZe(val, false) then
				return false
			end
		end
	end
	
	local success = false
	for j = 1, 9 do
		if self._cardAll[jiangPos][j] >= 2 then
			self._cardAll[jiangPos][j] = self._cardAll[jiangPos][j] - 2
			if self:_AnalyZe(self._cardAll[jiangPos], jiangPos == 3) then
				success = true
			end
			self:print("______________________第几次遍历__________________", j, success)
			--还原
			self._cardAll[jiangPos][j] = self._cardAll[jiangPos][j] + 2
			if success then
				break
			end
		end
	end
	if success then
		self:print("%赫拉%")
	end

	return success
end

function CardCheckHu:_AnalyZe(aKindPai, ziPai)
	if countTableAddValues(aKindPai) == 0 then
		self:print("应该是走这里啊")
		return true
	end
	--寻找第一牌
	for j = 1, 9 do
		ww.print("------------------------------------", ziPai, j)
		if aKindPai[j] ~= 0 then
		
		local result = false
		if aKindPai[j] >= 3 then
			--self:print("---------------------------刻子---------")
			--除去三张刻牌
			aKindPai[j] = aKindPai[j] - 3
			result = self:_AnalyZe(aKindPai, ziPai)
			--还原三张牌
			aKindPai[j] = aKindPai[j] + 3
			return result
		end
		--座位顺牌
		if not ziPai  and j < 8 and (aKindPai[j+1] > 0) and aKindPai[j+2] > 0 then
			--self:print("------------------顺子------------------")
			--除去三张牌
			aKindPai[j] = aKindPai[j] - 1
			aKindPai[j+1] = aKindPai[j+1] - 1
			aKindPai[j+2] = aKindPai[j+2] - 1
			result = self:_AnalyZe(aKindPai, ziPai)
			self:print(result)
			aKindPai[j] = aKindPai[j] + 1
			aKindPai[j+1] = aKindPai[j+1] + 1
			aKindPai[j+2] = aKindPai[j+2] + 1
			return result
		end
		end
	end
	return false
end

return CardCheckHu