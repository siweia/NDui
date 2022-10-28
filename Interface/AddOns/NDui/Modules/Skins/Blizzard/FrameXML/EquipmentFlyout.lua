local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	hooksecurefunc("EquipmentFlyout_CreateButton", function()
		local button = EquipmentFlyoutFrame.buttons[#EquipmentFlyoutFrame.buttons]

		button:SetNormalTexture(0)
		button:SetPushedTexture(0)
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		button.bg = B.ReskinIcon(button.icon)
		B.ReskinIconBorder(button.IconBorder)
	end)

	hooksecurefunc("EquipmentFlyout_DisplayButton", function(button)
		local location = button.location
		local border = button.IconBorder
		if not location or not border then return end

		border:SetShown(location < EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION)
	end)

	hooksecurefunc("EquipmentFlyout_UpdateItems", function()
		local frame = EquipmentFlyoutFrame.buttonFrame
		if not frame.bg then
			frame.bg = B.SetBD(EquipmentFlyoutFrame.buttonFrame)
		end
		frame:SetWidth(frame:GetWidth()+3)
	end)

	EquipmentFlyoutFrameButtons.bg1:SetAlpha(0)
	EquipmentFlyoutFrameButtons:DisableDrawLayer("ARTWORK")

	local navigationFrame = EquipmentFlyoutFrame.NavigationFrame
	B.SetBD(navigationFrame)
	navigationFrame:SetPoint("TOPLEFT", EquipmentFlyoutFrameButtons, "BOTTOMLEFT", 0, -3)
	navigationFrame:SetPoint("TOPRIGHT", EquipmentFlyoutFrameButtons, "BOTTOMRIGHT", 0, -3)
	B.ReskinArrow(navigationFrame.PrevButton, "left")
	B.ReskinArrow(navigationFrame.NextButton, "right")
	navigationFrame.BottomBackground:Hide()
end)