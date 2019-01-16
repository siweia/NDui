local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	local ProductChoiceFrame = ProductChoiceFrame

	F.ReskinPortraitFrame(ProductChoiceFrame)
	F.Reskin(ProductChoiceFrame.Inset.ClaimButton)
	F.ReskinArrow(ProductChoiceFrame.Inset.PrevPageButton, "left")
	F.ReskinArrow(ProductChoiceFrame.Inset.NextPageButton, "right")
end)