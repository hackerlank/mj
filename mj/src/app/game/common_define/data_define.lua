--一副整牌
mjArray= {
	1, 2, 3, 4, 5, 6, 7, 8, 9,  --万
	1, 2, 3, 4, 5, 6, 7, 8, 9,
	1, 2, 3, 4, 5, 6, 7, 8, 9,
	1, 2, 3, 4, 5, 6, 7, 8, 9,
	10, 11, 12, 13, 14, 15, 16, 17, 18,  --條
	10, 11, 12, 13, 14, 15, 16, 17, 18,  --條
	10, 11, 12, 13, 14, 15, 16, 17, 18,  --條
	10, 11, 12, 13, 14, 15, 16, 17, 18,  --條
	19, 20, 21, 22, 23, 24, 25, 26, 27,
	19, 20, 21, 22, 23, 24, 25, 26, 27,
	19, 20, 21, 22, 23, 24, 25, 26, 27,
	19, 20, 21, 22, 23, 24, 25, 26, 27,  --筒
	-- 31, 32, 33, 34,  --东南西北
	-- 31, 32, 33, 34,
	-- 31, 32, 33, 34,
	-- 31, 32, 33, 34,
	-- 41, 42, 43,  --中发白
	-- 41, 42, 43,
	-- 41, 42, 43,
	-- 41, 42, 43,
	--51, 52, 53, 54, 55, 56, 57, 58  --花
}

mjCardTxt = {
	"一万","二万","三万","四万","五万","六万","七万","八万","九万",  
    "一索","二索","三索","四索","五索","六索","七索","八索","九索",  
    "一筒","二筒","三筒","四筒","五筒","六筒","七筒","八筒","九筒",  
    "东", "南", "西", "北", "中", "发", "白",  
    "春", "夏", "秋", "冬", "梅", "兰", "竹", "菊"  
}
--手牌位置
mjDarkPositions = {
	[1] = cc.p(0, 50),  --本家手牌的位置
	[2] = cc.p(display.width - 120, 130),
	[3] = cc.p(display.cx + 37*6, display.height-35),
	[4] = cc.p(120, 130 + 37*13-20)
}

--用户信息位置
mjPlayerInfoPos = {
	[1] = {
		pos = cc.p(display.width - 60, 170),
		zPos = cc.p(display.cx, 150),
		banker_pos = cc.p(40, 15)
	},
	[2] = {
		pos = cc.p(display.width - 40, display.top - 250),
		zPos = cc.p(display.width - 70, display.cy),
		banker_pos = cc.p(-40, 15)
	},
	[3] = { 
		pos = cc.p(mjDarkPositions[3].x + 70, mjDarkPositions[3].y-15),--cc.p(display.width - 270, display.top - 50),
		zPos = cc.p(display.cx, display.top - 80),
		banker_pos = cc.p(40, 15)
	},
	[4] = {
		pos = cc.p(40, display.top - 250),
		zPos = cc.p(70, display.cy),
		banker_pos = cc.p(40, 15)
	}
}

--出牌起始位置
mjPlayPositions = {
	[1] = cc.p(display.cx - 100, display.cy - 100),
	[2] = cc.p(display.cx + 180, display.cy - 100+10),
	[3] = cc.p(display.cx + 100, display.cy + 140),
	[4] = cc.p(display.cx - 180, display.cy + 100+35),
}

--胡牌起始未知
mjHuCardPositions = {
	[1] = cc.p(display.cx + 100, 150),
	[2] = cc.p(display.width - 50, 100),
	[3] = cc.p(display.width - 50, display.height-50),
	[4] = cc.p(50, display.height - 50)
}

--头像（时钟位置）
-- mjPlayerPositions = {
-- 	[1] = cc.p(0, 50),  --本家手牌的位置
-- 	[2] = cc.p(display.width - 50, 100),
-- 	[3] = cc.p(display.width - 50, display.height-50),
-- 	[4] = cc.p(40, display.height - 50)
-- }