local LoadingScene = class("LoadingScene", function()
    return display.newScene("LoadingScene")
end)

 local SpriteRes = {
 	loading_bg = "background/loading.jpg"
}

function LoadingScene:ctor()

	self:setupUi()
end

function LoadingScene:setupUi()
	local background = cc.ui.UIImage.new(SpriteRes.loading_bg)
	background:addTo(self)
	background:setLayoutSize(display.width, display.height)

	--app:enterScene("MainScene", {true})
end

return LoadingScene