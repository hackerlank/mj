local SecondTimer = class("SecondTimer")

function SecondTimer:ctor()

	self.m_scheduler_handler = nil
	self.m_is_loop = false  --循环
end

--[[
	#param: time  default 1s :必须存在
	#total_seconds 总时间(停止条件)；可能没有，只需要计算总时间的话，必要的时候停止
	#end_listener 停止时响应
	#times_listener 每次调度时响应
]]
function SecondTimer:start(params)
	if not self.m_scheduler_handler then
		self.m_scheduler_handler = scheduler.scheduleGlobal(handler(self, self._systemTimeStep), time or 1)
	end

	self.m_current_time = 0
	self.m_total_seconds = params.total_seconds
	self.m_end_listener = params.end_listener
	self.m_times_listener = params.times_listener
	self.m_time = params.time or 1.0 
end

function SecondTimer:_systemTimeStep(dt)
	self.m_current_time = self.m_current_time + self.m_time
	if self.m_current_time >= self.m_total_seconds then
		self:stop()
	end
	if self.m_times_listener then
		self.m_times_listener(self.m_current_time)
	end
end

function SecondTimer:stop()
	self.m_current_time = 0
	if self.m_scheduler_handler then
		scheduler.unscheduleGlobal(self.m_scheduler_handler)
		self.m_scheduler_handler = nil
		if self.m_end_listener then
			self.m_end_listener()
		end
	end
end

return SecondTimer