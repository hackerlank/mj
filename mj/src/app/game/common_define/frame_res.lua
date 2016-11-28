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

mjCardBsx = "bsx.png"  --桌面上的余牌暗牌 V 33*47
mjCardBsxW = 33

mjCardBh = "bh.png"  --桌面上的余牌暗牌 H 40*37
mjCardBhH = 37
-- mjAction_G = "action_a_g.png"  --杠
-- mjAction_H = "action_a_h.png"  --胡
-- mjAction_P = "action_a_p.png"  --碰
mjActionBJ = "action_bj.png"  --背景
mjActionG = {
	normal = "action_g1.png",
	pressed = "action_g2.png",
	disabled = "action_g3.png",
}

mjActionH = {
	normal = "action_h1.png",
	pressed = "action_h2.png",
	disabled = "action_h3.png",
}

mjActionP = {
	normal = "action_p1.png",
	pressed = "action_p2.png",
	disabled = "action_p3.png",
}

--過
mjActionX = {
	normal = "action_x1.png",
	pressed = "action_x2.png",
	disabled = "action_x3.png",
}

mjActionWan = {
	normal = "action_wan1.png",
	pressed = "action_wan2.png",
	disabled = "action_wan3.png",
}

mjActionTong = {
	normal = "action_tong1.png",
	pressed = "action_tong2.png",
	disabled = "action_tong3.png",
}

mjActionTiao = {
	normal = "action_tiao1.png",
	pressed = "action_tiao2.png",
	disabled = "action_tiao3.png",
}
