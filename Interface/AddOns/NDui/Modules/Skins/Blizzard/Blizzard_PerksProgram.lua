local _, ns = ...
local B, C, L, DB = unpack(ns)

local function ReskinCustomizeButton(button)
	B.Reskin(button)
	button.__bg:SetInside(nil, 5, 5)
end

local function ReskinRewardButton(button)
	if button.styled then return end

	local container = button.ContentsContainer
	if container then
		B.ReskinIcon(container.Icon)
		B.ReplaceIconString(container.Price)
		hooksecurefunc(container.Price, "SetText", B.ReplaceIconString)
	end
	button.styled = true
end

C.themes["Blizzard_PerksProgram"] = function()
	local frame = PerksProgramFrame
	if not frame then return end

	local footerFrame = frame.FooterFrame
	if footerFrame then
		ReskinCustomizeButton(footerFrame.LeaveButton)
		ReskinCustomizeButton(footerFrame.PurchaseButton)
		ReskinCustomizeButton(footerFrame.RefundButton) -- not seen yet, needs review
		B.ReskinCheck(footerFrame.TogglePlayerPreview)
		B.ReskinCheck(footerFrame.ToggleHideArmor)
		ReskinCustomizeButton(footerFrame.RotateButtonContainer.RotateLeftButton)
		ReskinCustomizeButton(footerFrame.RotateButtonContainer.RotateRightButton)
	end

	local productsFrame = frame.ProductsFrame
	if productsFrame then
		if DB.isWW then
			B.Reskin(productsFrame.PerksProgramFilter)
		else
			ReskinCustomizeButton(productsFrame.PerksProgramFilter.FilterDropDownButton)
		end
		B.ReskinIcon(productsFrame.PerksProgramCurrencyFrame.Icon)
		B.StripTextures(productsFrame.PerksProgramProductDetailsContainerFrame)
		B.SetBD(productsFrame.PerksProgramProductDetailsContainerFrame)
		B.ReskinTrimScroll(productsFrame.PerksProgramProductDetailsContainerFrame.SetDetailsScrollBoxContainer.ScrollBar)

		local productsContainer = productsFrame.ProductsScrollBoxContainer
		B.StripTextures(productsContainer)
		B.SetBD(productsContainer)
		B.ReskinTrimScroll(productsContainer.ScrollBar)
		B.StripTextures(productsContainer.PerksProgramHoldFrame)
		B.CreateBDFrame(productsContainer.PerksProgramHoldFrame, .25):SetInside(nil, 3, 3)

		hooksecurefunc(productsContainer.ScrollBox, "Update", function(self)
			self:ForEachFrame(ReskinRewardButton)
		end)
	end
end