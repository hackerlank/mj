--[[
	準備阶段，这里是游戏刚开始的最初始阶段
]]
local ReadyStage = class("ReadyStage")

local this = nil
function ReadyStage:ctor(layer)
	this = layer
end

--初始化所有准备数据
function ReadyStage:began()
	MjDataControl:getInstance():dataStart()  --初始化麻將數據（創建了麻將Ui）
end

return ReadyStage