local HuCheck = class("HuCheck")

function HuCheck:ctor(hand_cards)
	self._handCards = hand_cards

	self._jiang = {}
	self._kezi  ={}
	self._pai = {}
end

function HuCheck:_setPramsByKey(card_list)
	--分组存放（把刻字、杠子、将牌）罗列出来
	--暗牌每次有发生变化都要重新排列
	self._jiang = {}
	local tmp = {}
	for _,card in pairs(card_list) do
		local id = card:getId()
		if not tmp[id] then
			tmp[id] = {}
		end
		table.insert(tmp[id], #tmp[id] + 1, card)
	end

	self._pai = {}
	for _,val in pairs(tmp) do
		table.insert(self._pai, #self._pai + 1, val)
		if #val == 2 then
			table.insert(self._jiang, #self._jiang+1, val)
		elseif #val == 3 then
			--要把刻子放入将牌（能杠则能碰）
			table.insert(self._jiang, #self._jiang+1, {val[1], val[2]})
		elseif #val == 4 then
			table.insert(self._jiang, #self._jiang+1, {val[1], val[2]})
			table.insert(self._jiang, #self._jiang+1, {val[3], val[4]})
		end
	end

end

--如果是自己上牌（直接检测是否自摸）

--如果是他人出牌，克隆一份做为检测

function HuCheck:checkHu(card)
	self._jiang = {}
	local dark_list = clone(self._handCards:getDarkList())  --全都由克隆的作为检测
	if card then
		--他人上牌
		table.insert(dark_list, #dark_list+1, card)
	end
	self:_setPramsByKey(dark_list)

	--local tt = {1,1,1,2,3,4,5,6,7,6,7,8,9,9}
	-- local tt = {1,1,3,4,4,5,5,5,6,6,7,7,8,9}
	-- for _,val in pairs(dark_list) do
	-- 	val:changeId(tt[_])
	-- end
	--self:_setPramsByKey(dark_list)
	self:_checkCustom(dark_list)
	return self._isHu
end

local function removetb(gtb, tb)
	for _,card in pairs(tb) do
		for i,_card in pairs(gtb) do
			if card:getId() == _card:getId() then
				table.remove(gtb, i)
				break
			end
		end
	end
	return gtb
end

function HuCheck:_checkCustom(dark_list)
	if (#dark_list-2)%3 ~= 0 then
		--不符合3 3 3 3 2牌数规则 不和(小相公)
		print("error: file(HuCheck) 小相公")
		self._isHu = false
	end
	--必须有一对将牌 否则不和
	if #self._handCards:getJiang() == 0 then
		self._isHu = false
	end
	--去掉一对将牌
	for index,jiang in pairs(self._jiang) do
		if not self._isHu then
			local dark_list_clone = clone(dark_list)
			dark_list_clone = removetb(dark_list_clone, jiang)

			self:_setPramsByKey(dark_list_clone)
			--剩余的牌能组成顺子或刻子则可和牌
			local sortFunc = function(a,b) return a[1]:getId() < b[1]:getId() end
			table.sort(self._pai, sortFunc)
			self:AnalyZe(dark_list_clone, index)
		end
	end
end

local function dumpCardList(list)
	local str = ""
	for _,val in pairs(list) do
		str = str .. val:getName() .. ","
	end
	print(str)
end

function HuCheck:AnalyZe(dark_list_clone)
	local dark_list = clone(dark_list_clone)
	local tmp_value = nil
	dumpCardList(dark_list)

	for id,val in pairs(self._pai) do
		if id <= #self._pai - 2 then
			-- if #val == 4 then
			-- 	removetb(dark_list, val)
			-- 	if self:AnalyZe(dark_list) then
			-- 		return true
			-- 	end
			-- end

			if #val == 3 then
				removetb(dark_list, val)
				self._pai[id] = {}
				self:AnalyZe(dark_list)	
			end

			--匹配顺子 
			if #val > 0 then
				local id1 = val[1]:getId()
				local id2 = self._pai[id+1][1] and self._pai[id+1][1]:getId() or -1
				local id3 = self._pai[id+2][1] and self._pai[id+2][1]:getId() or -1
				if 	id1%9 ~= 8 and id1%9 ~= 0 and 
					(id2 == id1 + 1) and (id3 == id2 + 1) then
					removetb(dark_list, {val[1], self._pai[id+1][1], self._pai[id+2][1]})
					table.remove(self._pai[id], 1)
					table.remove(self._pai[id+1], 1)
					table.remove(self._pai[id+2], 1)
					dumpCardList(dark_list)
					self:AnalyZe(dark_list)
					return 
				end 
			end
		end
	end
	if #dark_list == 0 then
		print("#成啦#")
		self._isHu = true
	end
end

function HuCheck:getIsHu()
	return self._isHu
end

function HuCheck:resetHu()
	self._isHu = false
end

return HuCheck