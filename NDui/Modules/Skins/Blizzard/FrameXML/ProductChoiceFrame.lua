local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	local ProductChoiceFrame = ProductChoiceFrame

	B.ReskinPortraitFrame(ProductChoiceFrame)
	B.Reskin(ProductChoiceFrame.Inset.ClaimButton)
	B.ReskinArrow(ProductChoiceFrame.Inset.PrevPageButton, "left")
	B.ReskinArrow(ProductChoiceFrame.Inset.NextPageButton, "right")
end)