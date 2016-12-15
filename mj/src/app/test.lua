--function Win(allPai)
--function Analyze(array, bool)

local allPai = {}  --二维数据{条、筒、万}

local allPai = {
	{1, 4, 1},  --对应每一个牌的张数
	{1, 1, 1},
	{0}
}

function Win(allPai)
	local jiangPos = nil
	local yuShu = nil
	local jiangExisited = false
    --是否满足3，3，3，3，2模型
	for i = 1, 3 do
		yuShu = #allPai[i] % 3
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
	for i = 1, 3 do
		if i ~= jiangPos then
			if not AnalyZe(allPai, i == 3)
				return false
			end
		end
	end
	local success = false

	for j = 1, 9 do
		if allPai[jiangPos][j] >= 2 then
			allPai[jiangPos][j] = allPai[jiangPos][j] - 2
			if AnalyZe(allPai[jiangPos], jiangPos == 3) then
				success = true
			end
			--还原
			allPai[jiangPos][j] = allPai[jiangPos][j] + 2
			if success then
				break
			end
		end
	end

	return success
end

function AnalyZe(aKindPai, ziPai)
	if aKindPai[1] == 0 then
		return true
	end
	--寻找第一牌
	for j = 1, 9 do
		if aKindPai[j] ~= 0 then
			break
		end

		local result
		local aKindJ = aKindPai[j]
		local aKind0 = aKindPai[0]
		if aKindJ >= 3 then
			--除去三张刻牌
			aKindJ = aKindJ - 3
			aKind0 = aKind0 - 3
			result = AnalyZe(aKindPai, ziPai)
			--还原三张牌
			aKindJ = aKindJ + 3
			aKind0 = aKind0 + 3
			return result
		end

		--座位顺牌
		local pai1 = aKindPai[j]
		local next1 = aKindPai[j+1]
		local next2 = aKindPai[j+2]
		if not ziPai  and j < 8 and (next1 > 0) and next2 > 0 then
			--除去三张牌
			pai1 = pai1 - 1
			next1 = next1 - 1
			next2 = next2 - 1
			aKindPai[0] = aKindPai[0] - 3
			result = AnalyZe(aKindPai, ziPai)
			pai1 = pai1 + 1
			next1 = next1 + 1
			next2 = next2 + 1
			aKindPai[0] = aKindPai[0] + 3
			return result
		end
	end
	return false
end