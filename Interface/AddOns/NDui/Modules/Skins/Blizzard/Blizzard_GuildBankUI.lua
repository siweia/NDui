local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_GuildBankUI"] = function()
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
end