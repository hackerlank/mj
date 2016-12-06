local GDataManager = class("GDataManager")
GDataManager.instance = nil

function GDataManager.getInstance()
	if not GDataManager.instance then	
		GDataManager.instance = GDataManager.new()
	end
	return GDataManager.instance
end

function GDataManager:ctor()

end

function GDataManager:reset()
	self._seats = {1,2,3,4}

end

function GDataManager:getSeats()
	return self._seats
end

return GDataManager