local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_ObliterumUI"] = function()
	local obliterum = ObliterumForgeFrame

	B.ReskinPortraitFrame(obliterum)
	B.Reskin(obliterum.ObliterateButton)
	B.ReskinIcon(obliterum.ItemSlot.Icon)
end