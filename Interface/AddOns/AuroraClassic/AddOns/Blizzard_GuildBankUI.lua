local F, C = unpack(select(2, ...))

C.themes["Blizzard_GuildBankUI"] = function()
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
	for i = 1, 3 do
		select(i, GuildBankPopupScrollFrame:GetRegions()):Hide()
	end
	for i = 1, 2 do
		select(i, GuildBankTransactionsScrollFrame:GetRegions()):Hide()
		select(i, GuildBankInfoScrollFrame:GetRegions()):Hide()
	end

	F.SetBD(GuildBankFrame)
	F.Reskin(GuildBankFrameWithdrawButton)
	F.Reskin(GuildBankFrameDepositButton)
	F.Reskin(GuildBankFramePurchaseButton)
	F.Reskin(GuildBankPopupOkayButton)
	F.Reskin(GuildBankPopupCancelButton)
	F.Reskin(GuildBankInfoSaveButton)
	F.ReskinClose(GuildBankFrame.CloseButton)
	F.ReskinScroll(GuildBankTransactionsScrollFrameScrollBar)
	F.ReskinScroll(GuildBankInfoScrollFrameScrollBar)
	F.ReskinScroll(GuildBankPopupScrollFrameScrollBar)
	F.ReskinInput(GuildItemSearchBox)

	for i = 1, 4 do
		local tab = _G["GuildBankFrameTab"..i]
		F.ReskinTab(tab)

		if i ~= 1 then
			tab:SetPoint("LEFT", _G["GuildBankFrameTab"..i-1], "RIGHT", -15, 0)
		end
	end

	for i = 1, 8 do
		select(i, GuildBankPopupFrame.BorderBox:GetRegions()):Hide()
	end
	GuildBankPopupFrame.BG:Hide()
	F.CreateBD(GuildBankPopupFrame)
	F.CreateSD(GuildBankPopupFrame)
	F.CreateBD(GuildBankPopupEditBox, .25)
	GuildBankPopupFrame:SetPoint("TOPLEFT", GuildBankFrame, "TOPRIGHT", 2, -30)
	GuildBankPopupFrame:SetHeight(525)

	GuildBankFrameWithdrawButton:SetPoint("RIGHT", GuildBankFrameDepositButton, "LEFT", -1, 0)

	for i = 1, NUM_GUILDBANK_COLUMNS do
		_G["GuildBankColumn"..i]:GetRegions():Hide()
		for j = 1, NUM_SLOTS_PER_GUILDBANK_GROUP do
			local bu = _G["GuildBankColumn"..i.."Button"..j]
			local border = bu.IconBorder
			local searchOverlay = bu.searchOverlay

			bu:SetNormalTexture("")
			bu:SetPushedTexture("")
			bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

			bu.icon:SetTexCoord(.08, .92, .08, .92)

			border:SetPoint("TOPLEFT", -1.2, 1.2)
			border:SetPoint("BOTTOMRIGHT", 1.2, -1.2)
			border:SetDrawLayer("BACKGROUND")

			searchOverlay:SetPoint("TOPLEFT", -1.2, 1.2)
			searchOverlay:SetPoint("BOTTOMRIGHT", 1.2, -1.2)
			F.CreateBDFrame(bu, .25)
		end
	end

	hooksecurefunc("GuildBankFrame_Update", function()
		for i = 1, NUM_GUILDBANK_COLUMNS do
			for j = 1, NUM_SLOTS_PER_GUILDBANK_GROUP do
				local bu = _G["GuildBankColumn"..i.."Button"..j]
				bu.IconBorder:SetTexture(C.media.backdrop)
			end
		end
	end)

	for i = 1, 8 do
		local tb = _G["GuildBankTab"..i]
		local bu = _G["GuildBankTab"..i.."Button"]
		local ic = _G["GuildBankTab"..i.."ButtonIconTexture"]
		local nt = _G["GuildBankTab"..i.."ButtonNormalTexture"]

		bu:SetPushedTexture("")
		bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		tb:GetRegions():Hide()
		nt:SetAlpha(0)

		bu:SetCheckedTexture(C.media.checked)
		F.CreateBG(bu)

		local a1, p, a2, x, y = bu:GetPoint()
		bu:SetPoint(a1, p, a2, x + 1, y)

		ic:SetTexCoord(.08, .92, .08, .92)
	end

	GuildBankPopupFrame:HookScript("OnShow", function()
		for i = 1, NUM_GUILDBANK_ICONS_PER_ROW * NUM_GUILDBANK_ICON_ROWS do
			local bu = _G["GuildBankPopupButton"..i]

			if not bu.styled then
				bu:SetCheckedTexture(C.media.checked)
				select(2, bu:GetRegions()):Hide()

				_G["GuildBankPopupButton"..i.."Icon"]:SetTexCoord(.08, .92, .08, .92)

				F.CreateBG(_G["GuildBankPopupButton"..i.."Icon"])
				bu.styled = true
			end
		end
	end)
end