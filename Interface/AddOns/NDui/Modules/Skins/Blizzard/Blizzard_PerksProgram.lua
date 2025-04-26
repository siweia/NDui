local _, ns = ...
local B, C, L, DB = unpack(ns)

local function ReskinCustomizeButton(button)
	B.Reskin(button)
	button.__bg:SetInside(nil, 5, 5)
end

local function ReskinCartToggle(button)
	if not button.styled then
		button:GetNormalTexture():SetAlpha(0)
		button:GetPushedTexture():SetAlpha(0)
		button:GetDisabledTexture():SetAlpha(0)
		button:GetHighlightTexture():SetAlpha(0)
		button.styled = true
	end
	if not button.tex then
		button.tex = button:CreateTexture()
		button.tex:SetPoint("BOTTOMLEFT", 5, 5)
		button.tex:SetSize(22, 22)
		button.tex:SetAtlas("Perks-shoppingcart")
		button.tex.isIgnored = true
	end
	if not button.state then
		button.state = button:CreateFontString()
		button.state:SetPoint("TOPRIGHT", -3, 0)
		button.state:SetFontObject(Game20Font)
	end
	button.state:SetText(button.itemInCart and "|cffff0000-|r" or "|cff00ff00+|r")
end

local function ReskinRewardButton(button)
	if button.styled then return end

	local container = button.ContentsContainer
	if container then
		B.ReskinIcon(container.Icon)
		B.ReskinIcon(container.PriceIcon)
		ReskinCartToggle(container.CartToggleButton)
		hooksecurefunc(container.CartToggleButton, "UpdateCartState", ReskinCartToggle)
	end
	button.styled = true
end

local function SetupSetButton(button)
	if button.bg then return end
	button.IconMask:Hide()
	button.bg = B.ReskinIcon(button.Icon)
	button.IconBorder:SetAlpha(0)
	button.BackgroundTexture:SetAlpha(0)
	local bg = B.CreateBDFrame(button.BackgroundTexture, .25)
	bg:SetInside(button.BackgroundTexture, 3, 3)
	button.HighlightTexture:SetColorTexture(1, 1, 1, .25)
	button.HighlightTexture:SetInside(bg)
end

local function SetupCartItem(button)
	if button.styled then return end
	if button.Icon then
		SetupSetButton(button)
	end
	if button.PriceIcon then
		B.ReskinIcon(button.PriceIcon)
	end
	if button.RemoveFromCartItemButton then
		B.ReskinFilterReset(button.RemoveFromCartItemButton.RemoveFromListButton)
	end
	button.styled = true
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
		ReskinCustomizeButton(footerFrame.RefundButton)
		ReskinCustomizeButton(footerFrame.AddToCartButton)
		ReskinCustomizeButton(footerFrame.RemoveFromCartButton)
		B.ReskinCheck(footerFrame.TogglePlayerPreview)
		B.ReskinCheck(footerFrame.ToggleHideArmor)
		B.ReskinCheck(footerFrame.ToggleAttackAnimation)
		B.ReskinCheck(footerFrame.ToggleMountSpecial)
		ReskinCustomizeButton(footerFrame.RotateButtonContainer.RotateLeftButton)
		ReskinCustomizeButton(footerFrame.RotateButtonContainer.RotateRightButton)

		ReskinCustomizeButton(footerFrame.ViewCartButton)
		local tex = footerFrame.ViewCartButton:CreateTexture()
		tex:SetInside(nil, 10, 10)
		tex:SetAtlas("Perks-shoppingcart")

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

		local cartFrame = productsFrame.PerksProgramShoppingCartFrame
		if cartFrame then
			B.StripTextures(cartFrame)
			SetupFramBG(cartFrame)
			B.ReskinTrimScroll(cartFrame.ItemList.ScrollBar)
			B.ReskinClose(cartFrame.CloseButton)
			ReskinCustomizeButton(cartFrame.PurchaseCartButton)

			ReskinCustomizeButton(cartFrame.ClearCartButton)
			local tex = cartFrame.ClearCartButton:CreateTexture()
			tex:SetInside(nil, 10, 10)
			tex:SetAtlas("common-icon-undo")
			tex:SetVertexColor(1, 0, 0)

			hooksecurefunc(cartFrame.ItemList.ScrollBox, "Update", function(self)
				self:ForEachFrame(SetupCartItem)
			end)
		end
	end
end