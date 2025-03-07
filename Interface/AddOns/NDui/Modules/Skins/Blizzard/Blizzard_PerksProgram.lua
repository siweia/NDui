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
		B.ReskinIcon(container.PriceIcon)
	end
	button.styled = true
end

local function SetupSetButton(button)
	if button.bg then return end
	button.bg = B.ReskinIcon(button.Icon)
	B.ReskinIconBorder(button.IconBorder, true, true)
	button.BackgroundTexture:SetAlpha(0)
	button.SelectedTexture:SetColorTexture(1, .8, 0, .25)
	button.SelectedTexture:SetInside()
	button.HighlightTexture:SetColorTexture(1, 1, 1, .25)
	button.HighlightTexture:SetInside()
end

local function SetupFramBG(frame)
	local bg = B.SetBD(frame)
	bg:SetFrameLevel(0)
	if bg.__shadow then
		bg.__shadow:SetFrameLevel(0)
	end
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
		B.ReskinCheck(footerFrame.ToggleAttackAnimation)
		B.ReskinCheck(footerFrame.ToggleMountSpecial)
		ReskinCustomizeButton(footerFrame.RotateButtonContainer.RotateLeftButton)
		ReskinCustomizeButton(footerFrame.RotateButtonContainer.RotateRightButton)

		hooksecurefunc(GlowEmitterFactory, "Show", function(frame, target, show)
			local button = footerFrame.PurchaseButton
			if button and target == button and show then
				frame:Hide(target)
			end
		end)
	end

	local productsFrame = frame.ProductsFrame
	if productsFrame then
		B.ReskinFilterButton(productsFrame.PerksProgramFilter)
		B.ReskinIcon(productsFrame.PerksProgramCurrencyFrame.Icon)
		B.StripTextures(productsFrame.PerksProgramProductDetailsContainerFrame)
		SetupFramBG(productsFrame.PerksProgramProductDetailsContainerFrame)
		B.ReskinTrimScroll(productsFrame.PerksProgramProductDetailsContainerFrame.SetDetailsScrollBoxContainer.ScrollBar)

		hooksecurefunc(productsFrame.PerksProgramProductDetailsContainerFrame.SetDetailsScrollBoxContainer.ScrollBox, "Update", function(self)
			self:ForEachFrame(SetupSetButton)
		end)

		local productsContainer = productsFrame.ProductsScrollBoxContainer
		B.StripTextures(productsContainer)
		SetupFramBG(productsContainer)
		B.ReskinTrimScroll(productsContainer.ScrollBar)
		B.StripTextures(productsContainer.PerksProgramHoldFrame)
		B.CreateBDFrame(productsContainer.PerksProgramHoldFrame, .25):SetInside(nil, 3, 3)

		hooksecurefunc(productsContainer.ScrollBox, "Update", function(self)
			self:ForEachFrame(ReskinRewardButton)
		end)
	end
end