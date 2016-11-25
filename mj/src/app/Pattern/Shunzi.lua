local Shunzi = class("Shunzi", import(".MjTitlePattern"))

function Shunzi:ctor(min, mid, max)
	Shunzi.super.ctor(self, mjPatternType.shunzi, {min, mid, max})

	if (not min) or (not mid) or (not max) then
		print("error：Shunzi.lua line:7 result:null")
	end
	if (min:getId()+1 ~= mid:getId()) or (mid:getId()+1 ~= max:getId()) then
		print("error：Shunzi.lua line:10 result:判断有误")
	end
end

return Shunzi