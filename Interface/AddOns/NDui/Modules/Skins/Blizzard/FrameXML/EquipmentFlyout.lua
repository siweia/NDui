local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	EquipmentFlyoutFrameHighlight:Hide()

	local border = B.CreateBDFrame(EquipmentFlyoutFrame, 0)
	border:SetBackdropBorderColor(1, 1, 1)
	border:SetPoint("TOPLEFT", 2, -2)
	border:SetPoint("BOTTOMRIGHT", -2, 2)

	local navFrame = EquipmentFlyoutFrame.NavigationFrame

	EquipmentFlyoutFrameButtons.bg1:SetAlpha(0)
	EquipmentFlyoutFrameButtons:DisableDrawLayer("ARTWORK")
	Test2:Hide() -- wat

	navFrame:SetWidth(204)
	navFrame:SetPoint("TOPLEFT", EquipmentFlyoutFrameButtons, "BOTTOMLEFT", 1, 0)

	local function hook_SetVertexColor(self, r, g, b)
		self:GetParent().bg:SetBackdropBorderColor(r, g, b)
	end
	local function hook_Hide(self)
		self:GetParent().bg:SetBackdropBorderColor(0, 0, 0)
	end

	hooksecurefunc("EquipmentFlyout_CreateButton", function()
		local button = EquipmentFlyoutFrame.buttons[#EquipmentFlyoutFrame.buttons]

		button.IconBorder:SetAlpha(0)
		button.icon:SetTexCoord(unpack(DB.TexCoord))
		button:SetNormalTexture("")
		button:SetPushedTexture("")
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		button.bg = B.CreateBDFrame(button)

		if not button.Eye then
			button.Eye = button:CreateTexture()
			button.Eye:SetAtlas("Nzoth-inventory-icon")
			button.Eye:SetInside()
		end

		hooksecurefunc(button.IconBorder, "SetVertexColor", hook_SetVertexColor)
		hooksecurefunc(button.IconBorder, "Hide", hook_Hide)
	end)

	local function UpdateCorruption(button, location)
		local _, _, bags, voidStorage, slot, bag = EquipmentManager_UnpackLocation(location)
		if voidStorage then
			button.Eye:Hide()
			return
		end

		local itemLink
		if bags then
			itemLink = GetContainerItemLink(bag, slot)
		else
			itemLink = GetInventoryItemLink("player", slot)
		end
		button.Eye:SetShown(itemLink and IsCorruptedItem(itemLink))
	end

	hooksecurefunc("EquipmentFlyout_DisplayButton", function(button)
		local location = button.location
		local border = button.IconBorder
		if not location or not border then return end

		if location >= EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION then
			border:Hide()
		else
			border:Show()
		end

		UpdateCorruption(button, location)
	end)

	B.SetBD(EquipmentFlyoutFrame.NavigationFrame)
	B.ReskinArrow(EquipmentFlyoutFrame.NavigationFrame.PrevButton, "left")
	B.ReskinArrow(EquipmentFlyoutFrame.NavigationFrame.NextButton, "right")
end)