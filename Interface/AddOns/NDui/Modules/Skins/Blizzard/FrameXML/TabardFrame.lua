local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	B.ReskinPortraitFrame(TabardFrame)
	B.StripTextures(TabardFrameCostFrame)
	B.CreateBDFrame(TabardFrameCostFrame, .25)
	B.Reskin(TabardFrameAcceptButton)
	B.Reskin(TabardFrameCancelButton)
	B.ReskinRotationButtons("TabardCharacterModel")

	TabardFrameCustomizationBorder:Hide()
	for i = 1, 5 do
		B.StripTextures(_G["TabardFrameCustomization"..i])
		B.ReskinArrow(_G["TabardFrameCustomization"..i.."LeftButton"], "left")
		B.ReskinArrow(_G["TabardFrameCustomization"..i.."RightButton"], "right")
	end
end)