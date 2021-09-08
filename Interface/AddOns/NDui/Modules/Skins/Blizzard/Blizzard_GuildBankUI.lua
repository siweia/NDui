local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_GuildBankUI"] = function()
	if DB.isNewPatch then
		B.StripTextures(GuildBankFrame)
		B.ReskinPortraitFrame(GuildBankFrame)

		GuildBankFrame.Emblem:Hide()
		GuildBankFrame.MoneyFrameBG:Hide()
		B.Reskin(GuildBankFrame.WithdrawButton)
		B.Reskin(GuildBankFrame.DepositButton)
		B.ReskinScroll(GuildBankTransactionsScrollFrameScrollBar)
		B.ReskinScroll(GuildBankInfoScrollFrameScrollBar)
		B.Reskin(GuildBankFrame.BuyInfo.PurchaseButton)
		B.Reskin(GuildBankFrame.Info.SaveButton)
		B.ReskinInput(GuildItemSearchBox)

		GuildBankFrame.WithdrawButton:SetPoint("RIGHT", GuildBankFrame.DepositButton, "LEFT", -2, 0)

		for i = 1, 4 do
			local tab = _G["GuildBankFrameTab"..i]
			B.ReskinTab(tab)
	
			if i ~= 1 then
				tab:SetPoint("LEFT", _G["GuildBankFrameTab"..i-1], "RIGHT", -15, 0)
			end
		end

		for i = 1, 7 do
			local column = GuildBankFrame.Columns[i]
			column:GetRegions():Hide()
	
			for j = 1, 14 do
				local button = column.Buttons[j]
				button:SetNormalTexture("")
				button:SetPushedTexture("")
				button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				button.icon:SetTexCoord(unpack(DB.TexCoord))
				button.bg = B.CreateBDFrame(button, .3)
				button.bg:SetBackdropColor(.3, .3, .3, .3)
				button.searchOverlay:SetOutside()
				B.ReskinIconBorder(button.IconBorder)
			end
		end

		for i = 1, 8 do
			local tab = _G["GuildBankTab"..i]
			local button = tab.Button
			local icon = button.IconTexture
	
			B.StripTextures(tab)
			button:SetNormalTexture("")
			button:SetPushedTexture("")
			button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			button:SetCheckedTexture(DB.textures.pushed)
			B.CreateBDFrame(button)
			icon:SetTexCoord(unpack(DB.TexCoord))
	
			local a1, p, a2, x, y = button:GetPoint()
			button:SetPoint(a1, p, a2, x + C.mult, y)
		end

		local NUM_GUILDBANK_ICONS_PER_ROW = 10
		local NUM_GUILDBANK_ICON_ROWS = 9

		GuildBankPopupFrame.BorderBox:Hide()
		GuildBankPopupFrame.BG:Hide()
		B.SetBD(GuildBankPopupFrame)
		GuildBankPopupEditBox:DisableDrawLayer("BACKGROUND")
		B.ReskinInput(GuildBankPopupEditBox)
		GuildBankPopupFrame:SetHeight(525)
		B.Reskin(GuildBankPopupFrame.OkayButton)
		B.Reskin(GuildBankPopupFrame.CancelButton)
		B.ReskinScroll(GuildBankPopupFrame.ScrollFrame.ScrollBar)
	
		GuildBankPopupFrame:HookScript("OnShow", function()
			for i = 1, NUM_GUILDBANK_ICONS_PER_ROW * NUM_GUILDBANK_ICON_ROWS do
				local button = _G["GuildBankPopupButton"..i]
				if not button.styled then
					button:SetCheckedTexture(DB.textures.pushed)
					select(2, button:GetRegions()):Hide()
					B.ReskinIcon(button.Icon)
					local hl = button:GetHighlightTexture()
					hl:SetColorTexture(1, 1, 1, .25)
					hl:SetAllPoints(button.Icon)
	
					button.styled = true
				end
			end
		end)

		return
	end

	GuildBankFrame:DisableDrawLayer("BACKGROUND")
	GuildBankFrame:DisableDrawLayer("BORDER")

	GuildBankFrame.TopLeftCorner:Hide()
	GuildBankFrame.TopRightCorner:Hide()
	GuildBankFrame.TopBorder:Hide()
	GuildBankTabTitleBackground:SetTexture("")
	GuildBankTabTitleBackgroundLeft:SetTexture("")
	GuildBankTabTitleBackgroundRight:SetTexture("")
	GuildBankTabLimitBackground:SetTexture("")
	GuildBankTabLimitBackgroundLeft:SetTexture("")
	GuildBankTabLimitBackgroundRight:SetTexture("")
	GuildBankEmblemFrame:Hide()
	GuildBankMoneyFrameBackgroundLeft:Hide()
	GuildBankMoneyFrameBackgroundMiddle:Hide()
	GuildBankMoneyFrameBackgroundRight:Hide()
	GuildBankPopupNameLeft:Hide()
	GuildBankPopupNameMiddle:Hide()
	GuildBankPopupNameRight:Hide()

	B.SetBD(GuildBankFrame)
	B.Reskin(GuildBankFrameWithdrawButton)
	B.Reskin(GuildBankFrameDepositButton)
	B.Reskin(GuildBankFramePurchaseButton)
	B.Reskin(GuildBankPopupOkayButton)
	B.Reskin(GuildBankPopupCancelButton)
	B.Reskin(GuildBankInfoSaveButton)
	B.ReskinClose(GuildBankFrame.CloseButton)
	B.ReskinScroll(GuildBankTransactionsScrollFrameScrollBar)
	B.ReskinScroll(GuildBankInfoScrollFrameScrollBar)
	B.ReskinScroll(GuildBankPopupScrollFrameScrollBar)
	B.ReskinInput(GuildItemSearchBox)

	for i = 1, 4 do
		local tab = _G["GuildBankFrameTab"..i]
		B.ReskinTab(tab)

		if i ~= 1 then
			tab:SetPoint("LEFT", _G["GuildBankFrameTab"..i-1], "RIGHT", -15, 0)
		end
	end

	B.StripTextures(GuildBankPopupFrame.BorderBox)
	GuildBankPopupFrame.BG:Hide()
	B.SetBD(GuildBankPopupFrame)
	B.CreateBDFrame(GuildBankPopupEditBox, .25)
	GuildBankPopupFrame:SetPoint("TOPLEFT", GuildBankFrame, "TOPRIGHT", 2, -30)
	GuildBankPopupFrame:SetHeight(525)

	GuildBankFrameWithdrawButton:SetPoint("RIGHT", GuildBankFrameDepositButton, "LEFT", -1, 0)

	for i = 1, NUM_GUILDBANK_COLUMNS do
		_G["GuildBankColumn"..i]:GetRegions():Hide()

		for j = 1, NUM_SLOTS_PER_GUILDBANK_GROUP do
			local button = _G["GuildBankColumn"..i.."Button"..j]
			button:SetNormalTexture("")
			button:SetPushedTexture("")
			button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			button.icon:SetTexCoord(unpack(DB.TexCoord))
			button.bg = B.CreateBDFrame(button, .3)
			button.bg:SetBackdropColor(.3, .3, .3, .3)
			button.searchOverlay:SetOutside()
			B.ReskinIconBorder(button.IconBorder)
		end
	end

	for i = 1, 8 do
		local tab = _G["GuildBankTab"..i]
		local button = _G["GuildBankTab"..i.."Button"]
		local icon = _G["GuildBankTab"..i.."ButtonIconTexture"]

		B.StripTextures(tab)
		button:SetNormalTexture("")
		button:SetPushedTexture("")
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		button:SetCheckedTexture(DB.textures.pushed)
		B.CreateBDFrame(button)
		icon:SetTexCoord(unpack(DB.TexCoord))

		local a1, p, a2, x, y = button:GetPoint()
		button:SetPoint(a1, p, a2, x + C.mult, y)
	end

	GuildBankPopupFrame:HookScript("OnShow", function()
		for i = 1, NUM_GUILDBANK_ICONS_PER_ROW * NUM_GUILDBANK_ICON_ROWS do
			local button = _G["GuildBankPopupButton"..i]
			local icon = _G["GuildBankPopupButton"..i.."Icon"]
			if not button.styled then
				button:SetCheckedTexture(DB.textures.pushed)
				select(2, button:GetRegions()):Hide()
				B.ReskinIcon(icon)
				local hl = button:GetHighlightTexture()
				hl:SetColorTexture(1, 1, 1, .25)
				hl:SetAllPoints(icon)

				button.styled = true
			end
		end
	end)
end