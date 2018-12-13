local F, C = unpack(select(2, ...))

C.themes["Blizzard_ObliterumUI"] = function()
	local obliterum = ObliterumForgeFrame

	F.ReskinPortraitFrame(obliterum, true)
	F.Reskin(obliterum.ObliterateButton)
	obliterum.ItemSlot.Icon:SetTexCoord(.08, .92, .08, .92)
	F.CreateBDFrame(obliterum.ItemSlot.Icon)
end