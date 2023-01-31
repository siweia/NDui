local _, ns = ...
local B, C, L, DB = unpack(ns)

local function ReskinCustomizeButton(button)
	B.Reskin(button)
	button.__bg:SetInside(nil, 5, 5)
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
		ReskinCustomizeButton(productsFrame.PerksProgramFilter.FilterDropDownButton)
		B.ReskinIcon(productsFrame.PerksProgramCurrencyFrame.Icon)
		B.ReskinTrimScroll(productsFrame.ProductsScrollBoxContainer.ScrollBar, true)

		hooksecurefunc(productsFrame.ProductsScrollBoxContainer.ScrollBox, "Update", function(self)
			self:ForEachFrame(function(button)
				if button.styled then return end

				local container = button.ContentsContainer
				if container then
					B.ReskinIcon(container.Icon)
					B.ReplaceIconString(container.Price)
					hooksecurefunc(container.Price, "SetText", B.ReplaceIconString)
				end
				button.styled = true
			end)
		end)
	end
end