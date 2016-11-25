local Jiang = class("Jiang", import(".MjTitlePattern"))

function Jiang:ctor(tile)
	Jiang.super.ctor(self, mjPatternType.jiang, {tile, tile})

end