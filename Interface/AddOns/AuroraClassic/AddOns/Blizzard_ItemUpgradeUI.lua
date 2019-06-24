local F, C = unpack(select(2, ...))

C.themes["Blizzard_ItemUpgradeUI"] = function()
	local ItemUpgradeFrame = ItemUpgradeFrame
	F.ReskinPortraitFrame(ItemUpgradeFrame)

	local itemButton = ItemUpgradeFrame.ItemButton
	itemButton.bg = F.CreateBDFrame(itemButton, .25)
	itemButton.Frame:SetTexture("")
	itemButton:SetPushedTexture("")
	local hl = itemButton:GetHighlightTexture()
	hl:SetColorTexture(1, 1, 1, .25)

	hooksecurefunc("ItemUpgradeFrame_Update", function()
		local icon, _, quality = GetItemUpgradeItemInfo()
		if icon then
			itemButton.IconTexture:SetTexCoord(.08, .92, .08, .92)
			local color = BAG_ITEM_QUALITY_COLORS[quality or 1]
			itemButton.bg:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			itemButton.IconTexture:SetTexture("")
			itemButton.bg:SetBackdropBorderColor(0, 0, 0)
		end
	end)

	local textFrame = ItemUpgradeFrame.TextFrame
	F.StripTextures(textFrame)
	local bg = F.CreateBDFrame(textFrame, .25)
	bg:SetPoint("TOPLEFT", itemButton.IconTexture, "TOPRIGHT", 3, C.mult)
	bg:SetPoint("BOTTOMRIGHT", -6, 2)

	F.StripTextures(ItemUpgradeFrame.ButtonFrame)
	F.StripTextures(ItemUpgradeFrameMoneyFrame)
	F.ReskinIcon(ItemUpgradeFrameMoneyFrame.Currency.icon)
	F.Reskin(ItemUpgradeFrameUpgradeButton)
end