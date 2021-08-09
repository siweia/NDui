local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_ItemUpgradeUI"] = function()
	local ItemUpgradeFrame = ItemUpgradeFrame
	B.ReskinPortraitFrame(ItemUpgradeFrame)

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