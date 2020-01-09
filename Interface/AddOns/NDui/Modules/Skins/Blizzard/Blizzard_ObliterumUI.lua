local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_ObliterumUI"] = function()
	local obliterum = ObliterumForgeFrame

	B.ReskinPortraitFrame(obliterum)
	B.Reskin(obliterum.ObliterateButton)
	obliterum.ItemSlot.Icon:SetTexCoord(.08, .92, .08, .92)
	B.CreateBDFrame(obliterum.ItemSlot.Icon)
end