
require("config")
require("cocos.init")
require("framework.init")
require("app.getVec")
require("app.CONST")
require("app.ConstFunc")
require("app.define.DefineConst")
scheduler = require(cc.PACKAGE_NAME .. ".scheduler")


local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    cc.FileUtils:getInstance():addSearchPath("res/")
    self:enterScene("MainScene")
end

return MyApp
