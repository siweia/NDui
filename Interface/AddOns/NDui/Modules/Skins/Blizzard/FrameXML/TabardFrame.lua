local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	B.ReskinPortraitFrame(TabardFrame)
	TabardFrameMoneyInset:Hide()
	TabardFrameMoneyBg:Hide()
	B.CreateBDFrame(TabardFrameCostFrame, .25)
	B.Reskin(TabardFrameAcceptButton)
	B.Reskin(TabardFrameCancelButton)
	B.ReskinArrow(TabardCharacterModelRotateLeftButton, "left")
	B.ReskinArrow(TabardCharacterModelRotateRightButton, "right")
	TabardCharacterModelRotateRightButton:SetPoint("TOPLEFT", TabardCharacterModelRotateLeftButton, "TOPRIGHT", 1, 0)

	TabardFrameCustomizationBorder:Hide()
	for i = 1, 5 do
		B.StripTextures(_G["TabardFrameCustomization"..i])
		B.ReskinArrow(_G["TabardFrameCustomization"..i.."LeftButton"], "left")
		B.ReskinArrow(_G["TabardFrameCustomization"..i.."RightButton"], "right")
	end
end)