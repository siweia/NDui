local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	local ProductChoiceFrame = ProductChoiceFrame

	ProductChoiceFrame.Inset.Bg:Hide()
	ProductChoiceFrame.Inset:DisableDrawLayer("BORDER")

	F.ReskinPortraitFrame(ProductChoiceFrame)
	F.Reskin(ProductChoiceFrame.Inset.ClaimButton)
end)