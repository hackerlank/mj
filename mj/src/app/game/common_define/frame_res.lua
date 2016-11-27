--todo:所有緩存資源
local FrameRes = {
	frame_mjtt = {
		plist = "mj/tiles/mjtt.plist",
		image = "mj/tiles/mjtt.png"
	}
}

function AddGameFrameRes()
	for _,file in pairs(FrameRes) do
		display.addSpriteFrames(file.plist, file.image)
	end
end

--todo:用的別人的資源 資源名定義一下 
--1 x_1 ~ x_27  [萬、條、筒]  暗牌
--2 yx_1 ~ yx_27  明牌左方向
--3 zx_1 ~ zx_27  明牌右方向

--暗牌每傢展示不一樣（本家不需處理)
mjDarkBack = {
	[2] = "by.png", --下傢
	[3] = "bx.png",
	[4] = "bz.png"
}

mjCardBs = "bs.png"  --桌面上的余牌暗牌 V
mjCardBh = "bh.png"  --桌面上的余牌暗牌 H
