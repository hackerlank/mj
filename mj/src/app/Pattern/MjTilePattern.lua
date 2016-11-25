local MjTitlePattern = class("MjTitlePattern")

function MjTitlePattern:ctor(patternType, mjTitles)
	self._patternType = patternType
	self._mjTitles = mjTitles
end

function MjTitlePattern:toString()
	local str = ""
	for _,val in pairs(titles) do
		str = str .. title:getName()
	end
	return str
end

return MjTitlePattern