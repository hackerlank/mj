local FanPinghu = class("FanPinghu", import(".FanBase"))

function FanPinghu:ctor()
	FanPinghu.super.ctor(self)

	self:init(1, "平胡")
end

function FanPinghu:tryMatch(handTiles, darkTiles)

end

return FanPinghu