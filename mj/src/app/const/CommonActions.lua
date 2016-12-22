--@param init_scale: 初始大小
--@param max_scale:  最大大小
--@param time:       运动时间1
--@param rtime:      还原时间
--@param end_listener:   动画结束时的回调
--@param listener_delay: 动画结束时回调的延迟时间

--动作过程：fadeIn & scale  listener:动画结束后的回调
function common_action_fadeIn(node, params)--, time, rtime, listener)
	node:setOpacity(0)
	node:setScale(params.init_scale)
	local fIn = cca.fadeIn(params.time)
	local scale = cca.scaleTo(params.time, params.max_scale)
	local spawn = cc.Spawn:create(fIn, scale)
	local seq = {spawn, cca.scaleTo(params.rtime, 1)}
	if params.end_listener then
		if params.listener_delay then
			table.insert(seq, #seq+1, cc.DelayTime:create(params.listener_delay))
		end
		table.insert(seq, #seq+1, cc.CallFunc:create(params.end_listener))
	end
	node:runAction(cc.Sequence:create(seq))
end