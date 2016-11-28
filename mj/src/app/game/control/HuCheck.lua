local HuCheck = class("HuCheck")

function HuCheck:ctor(hand_cards)
	self._handCards = hand_cards
end

function HuCheck:_checkCustom(cards)
	local dark_list = self.m_card_list:getDarkList()
	if (#dark_list-2)%3 ~= 0 then
		--不符合3 3 3 3 2牌数规则 不和(小相公)
		print("error: file(HuCheck) 小相公")
		self._isHu = false
	end
	--必须有一对将牌 否则不和
	if #self.m_card_list:getJiang() == 0 then
		self._isHu = false
	end

	local jiangs = self.m_card_list:getJiang()
	--刻子也放进来
	for _,val in pairs(self.m_card_list:getKezi()) do
		table.insert(jiangs, #jiangs + 1, {val[1], val[2]})
	end
	
	for index,jiang in pairs(jiangs) do
		local dark_list_clone = clone(dark_list)
		for _,card in pairs(jiang) do
			for i,_card in pairs(dark_list_clone) do
				if card:getId() == _card:getId() then
					table.remove(dark_list_clone, i)
					break
				end
			end
		end
		--dark_list_clone 除了这对将牌之外的牌
		--剩余的牌能组成顺子或刻子则可和牌
		self:AnalyZe(dark_list_clone, index)
	end
end

--分解成“刻”、“顺” 组合
function HuCheck:AnalyZe(dark_list_clone, jIndex)
	--dump(dark_list_clone)
	local dark_list_ = clone(dark_list_clone)
	for id,card in pairs(dark_list_) do
		if id > #dark_list_ - 2 then
			return 
		end
		--1.尽量组顺子
		if card:getId() == dark_list_[id+1]:getId() and 
			dark_list_[id+1]:getId() == dark_list_[id+2]:getId() then
			--刻子
			table.remove(dark_list_, id)
			table.remove(dark_list_, id)
			table.remove(dark_list_, id)
			if #dark_list_ == 0 then
				self._isHu = true
				return
			end
			self:AnalyZe(dark_list_, jIndex)
			return
		end
		--到这里说明组
		table.remove(dark_list_, id)
		local index = 1
		for i = 1, 2 do
			for _,_card in pairs(dark_list_) do
				if _card:getId() == card:getId() + i then
					index = index + 1
					table.remove(dark_list_, _)
					break
				end
			end
		end
		if index >= 2 then
			if #dark_list_ == 0 then
				self._isHu = true
				return
			end
			self:AnalyZe(dark_list_, jIndex)
			return
		else
			self._isHu = false
			return
		end
	end
end

return HuCheck