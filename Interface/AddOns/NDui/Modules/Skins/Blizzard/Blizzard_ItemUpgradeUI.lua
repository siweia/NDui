local _, ns = ...
local B, C, L, DB = unpack(ns)

local function reskinCurrencyIcon(self)
	for frame in self.iconPool:EnumerateActive() do
		if not frame.bg then
			frame.bg = B.ReskinIcon(frame.Icon)
			frame.bg:SetFrameLevel(2)
		end
	end
end

C.themes["Blizzard_ItemUpgradeUI"] = function()
	local ItemUpgradeFrame = ItemUpgradeFrame
	B.ReskinPortraitFrame(ItemUpgradeFrame)

	if DB.isNewPatch then
		hooksecurefunc(ItemUpgradeFrame, "Update", function(self)
			if self.upgradeInfo then
				self.UpgradeItemButton:SetPushedTexture(nil)
			end
		end)
		local bg = B.CreateBDFrame(ItemUpgradeFrame, .25)
		bg:SetPoint("TOPLEFT", 20, -25)
		bg:SetPoint("BOTTOMRIGHT", -20, 375)

		local itemButton = ItemUpgradeFrame.UpgradeItemButton
		itemButton.ButtonFrame:Hide()
		itemButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		itemButton.bg = B.ReskinIcon(itemButton.icon)
		B.ReskinIconBorder(itemButton.IconBorder)

		B.ReskinDropDown(ItemUpgradeFrame.ItemInfo.Dropdown)
		B.Reskin(ItemUpgradeFrame.UpgradeButton)
		ItemUpgradeFramePlayerCurrenciesBorder:Hide()

		B.CreateBDFrame(ItemUpgradeFrameLeftItemPreviewFrame, .25)
		ItemUpgradeFrameLeftItemPreviewFrame.NineSlice:SetAlpha(0)
		B.CreateBDFrame(ItemUpgradeFrameRightItemPreviewFrame, .25)
		ItemUpgradeFrameRightItemPreviewFrame.NineSlice:SetAlpha(0)

		hooksecurefunc(ItemUpgradeFrame.UpgradeCostFrame, "GetIconFrame", reskinCurrencyIcon)
		hooksecurefunc(ItemUpgradeFrame.PlayerCurrencies, "GetIconFrame", reskinCurrencyIcon)
	else
		local itemButton = ItemUpgradeFrame.ItemButton
		itemButton.bg = B.CreateBDFrame(itemButton, .25)
		itemButton.Frame:SetTexture("")
		itemButton:SetPushedTexture("")
		local hl = itemButton:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)

		hooksecurefunc("ItemUpgradeFrame_Update", function()
			local icon, _, quality = GetItemUpgradeItemInfo()
			if icon then
				itemButton.IconTexture:SetTexCoord(unpack(DB.TexCoord))
				local color = DB.QualityColors[quality or 1]
				itemButton.bg:SetBackdropBorderColor(color.r, color.g, color.b)
			else
				itemButton.IconTexture:SetTexture("")
				itemButton.bg:SetBackdropBorderColor(0, 0, 0)
			end
		end)

		local textFrame = ItemUpgradeFrame.TextFrame
		B.StripTextures(textFrame)
		local bg = B.CreateBDFrame(textFrame, .25)
		bg:SetPoint("TOPLEFT", itemButton.IconTexture, "TOPRIGHT", 3, C.mult)
		bg:SetPoint("BOTTOMRIGHT", -6, 2)

		B.StripTextures(ItemUpgradeFrame.ButtonFrame)
		B.StripTextures(ItemUpgradeFrameMoneyFrame)
		B.ReskinIcon(ItemUpgradeFrameMoneyFrame.Currency.icon)
		B.Reskin(ItemUpgradeFrameUpgradeButton)
		B.ReskinDropDown(ItemUpgradeFrame.UpgradeLevelDropDown.DropDownMenu)
		ItemUpgradeFrame.StatsScrollBar:SetAlpha(0)
	end
end