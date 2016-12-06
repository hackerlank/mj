--[[
stage = > {
	1.初始化所有手牌数据和界面（准备阶段， 游戏重新开始时需重新执行）
	2.进入发牌阶段（1. 计算出庄家位置 2.按顺序发牌）
	
}

HandCardUi = {
	1. 位置类 = {
		1.根据座位计算每家手牌的位置=> 【碰牌、杠牌都属于手牌位置】
		2.根据座位计算每家出牌的位置
		3.
	}
	2. 胡牌检测 => 【1.自己上牌的时候 检测；2. 他人出牌时候 检测】
	3. 碰牌检测 【他人出牌的时候】
	4. 杠牌检测 【他人出牌的时候； 自己上牌的时候（暗杠）】
}

所以，上牌流程 =>{
	1. 上牌：将值插入到手牌 
	2. 检测：检测时候有杠， 检测是否有胡
	3. 有杠或胡 则显示对应操作； 超过默认时间则自动胡牌，自动杠
	4. 没有杠或胡，则正常出牌； 超出默认时间自动出牌（默认优先打缺）
}

--对应出牌之外的三家
出牌流程 => {
	1. 上牌：检测否有碰、杠、胡【插入值到最后】；
	2. 有则游戏进度暂停；默认操作时间，超出时间跳过；优先级{胡>杠>碰}； 这里要将所有人的都要遍历出来
	3. 没有则移除上牌值，过（三家都检测通过）
}

]]