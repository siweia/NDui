local F, C = unpack(select(2, ...))

C.themes["Blizzard_ObliterumUI"] = function()
	F.ReskinPortraitFrame(ObliterumForgeFrame)
	ObliterumForgeFrameBtnCornerLeft:Hide()
	ObliterumForgeFrameBtnCornerRight:Hide()
	ObliterumForgeFrameButtonBottomBorder:Hide()
	ObliterumForgeFrameInset:Hide()
	F.Reskin(ObliterumForgeFrame.ObliterateButton)
	ObliterumForgeFrame.ItemSlot.Icon:SetTexCoord(.08, .92, .08, .92)
	F.CreateBDFrame(ObliterumForgeFrame.ItemSlot.Icon)
end