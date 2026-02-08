local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_FlightMap"] = function()
	B.ReskinPortraitFrame(FlightMapFrame)
	FlightMapFrameBg:Hide()
	FlightMapFrame.ScrollContainer.Child.TiledBackground:Hide()
end