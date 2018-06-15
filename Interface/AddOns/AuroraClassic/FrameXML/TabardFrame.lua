local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	TabardFrameMoneyInset:DisableDrawLayer("BORDER")
	TabardFrameCustomizationBorder:Hide()
	TabardFrameMoneyBg:Hide()
	TabardFrameMoneyInsetBg:Hide()

	for i = 19, 28 do
		select(i, TabardFrame:GetRegions()):Hide()
	end

	for i = 1, 5 do
		_G["TabardFrameCustomization"..i.."Left"]:Hide()
		_G["TabardFrameCustomization"..i.."Middle"]:Hide()
		_G["TabardFrameCustomization"..i.."Right"]:Hide()
		F.ReskinArrow(_G["TabardFrameCustomization"..i.."LeftButton"], "left")
		F.ReskinArrow(_G["TabardFrameCustomization"..i.."RightButton"], "right")
	end

	F.ReskinPortraitFrame(TabardFrame, true)
	F.CreateBD(TabardFrameCostFrame, .25)
	F.Reskin(TabardFrameAcceptButton)
	F.Reskin(TabardFrameCancelButton)
	F.ReskinArrow(TabardCharacterModelRotateLeftButton, "left")
	F.ReskinArrow(TabardCharacterModelRotateRightButton, "right")
	TabardCharacterModelRotateRightButton:SetPoint("TOPLEFT", TabardCharacterModelRotateLeftButton, "TOPRIGHT", 1, 0)
end)