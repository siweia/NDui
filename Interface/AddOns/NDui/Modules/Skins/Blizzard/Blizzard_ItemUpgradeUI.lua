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

	hooksecurefunc(ItemUpgradeFrame, "Update", function(self)
		if self.upgradeInfo then
			self.UpgradeItemButton:SetPushedTexture(DB.blankTex)
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

	local TT = B:GetModule("Tooltip")
	TT.ReskinTooltip(ItemUpgradeFrame.ItemHoverPreviewFrame)
end