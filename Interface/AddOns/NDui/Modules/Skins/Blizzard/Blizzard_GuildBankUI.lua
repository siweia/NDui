local _, ns = ...
local B, C, L, DB = unpack(ns)

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
	B.CreateBD(GuildBankPopupEditBox, .25)
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
			bu.icon:SetTexCoord(unpack(DB.TexCoord))
			local bg = B.CreateBDFrame(bu, .3)
			bg:SetBackdropColor(.3, .3, .3, .3)

			border:SetOutside()
			border:SetDrawLayer("BACKGROUND")
			searchOverlay:SetOutside()
		end
	end

	hooksecurefunc("GuildBankFrame_Update", function()
		for i = 1, NUM_GUILDBANK_COLUMNS do
			for j = 1, NUM_SLOTS_PER_GUILDBANK_GROUP do
				local bu = _G["GuildBankColumn"..i.."Button"..j]
				bu.IconBorder:SetTexture(DB.bdTex)
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

		bu:SetCheckedTexture(DB.textures.pushed)
		B.CreateBDFrame(bu)

		local a1, p, a2, x, y = bu:GetPoint()
		bu:SetPoint(a1, p, a2, x + 1, y)

		ic:SetTexCoord(unpack(DB.TexCoord))
	end

	GuildBankPopupFrame:HookScript("OnShow", function()
		for i = 1, NUM_GUILDBANK_ICONS_PER_ROW * NUM_GUILDBANK_ICON_ROWS do
			local bu = _G["GuildBankPopupButton"..i]
			local icon = _G["GuildBankPopupButton"..i.."Icon"]
			if not bu.styled then
				bu:SetCheckedTexture(DB.textures.pushed)
				select(2, bu:GetRegions()):Hide()
				B.ReskinIcon(icon)
				local hl = bu:GetHighlightTexture()
				hl:SetColorTexture(1, 1, 1, .25)
				hl:SetAllPoints(icon)

				bu.styled = true
			end
		end
	end)
end