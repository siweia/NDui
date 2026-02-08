local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	TaxiFramePortrait = TaxiPortrait
	TaxiFrameCloseButton = TaxiCloseButton
	B.ReskinPortraitFrame(TaxiFrame, 17, -8, -45, 82)
end)