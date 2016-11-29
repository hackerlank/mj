import(".ListenerId")
local UIChangeObserver = class("UIChangeObserver")
UIChangeObserver.instance = nil

function UIChangeObserver.getInstance()
	if not UIChangeObserver.instance then
		UIChangeObserver.instance = UIChangeObserver.new()
	end
	return UIChangeObserver.instance
end

function UIChangeObserver:ctor()
	self.m_change_observers = {}
end

function UIChangeObserver:addUIChangeObserver(name, id, observer)
	if not self.m_change_observers[name] then
		self.m_change_observers[name] = {}
	end
	self.m_change_observers[name][id] = observer
end

function UIChangeObserver:removeOneUIChangeObserver(name, id)
	self.m_change_observers[name][id] = nil
end

function UIChangeObserver:removeUIChangeObserver(name)
	self.m_change_observers[name] = nil
end

function UIChangeObserver:removeAllUIChangeObserver()
	self.m_change_observers = {}
end

function UIChangeObserver:dispatcherUIChangeObserver(name, data)
	if self.m_change_observers[name] then
	 	for _,observer in pairs(self.m_change_observers[name]) do
	 		observer(data)
	 	end
	end
end

return UIChangeObserver