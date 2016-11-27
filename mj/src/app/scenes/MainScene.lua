local MjPlayingUi = require("app.game.ui.MjPlayingUi")
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    cc.ui.UILabel.new({
            UILabelType = 2, text = "Hello, World", size = 64})
        :align(display.CENTER, display.cx, display.cy)
        :addTo(self)
    AddGameFrameRes()

    -- local CardBackLayer = require("app.GameControl")
    -- local card_layer = CardBackLayer.new():addTo(self)
    -- local allPai = {}
    -- local CardList = require("app.ui.CardList")
    -- local card_list = CardList.new({id = 1, pos = cc.p(50, 100)})
    -- card_list:addCardIds({1,2,3,2,3,4,4,5,6,7,7,7,9,8})
    
    -- require("app.modules.HuCheck").new(card_list)
    MjPlayingUi.new()
    :addTo(self)
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
