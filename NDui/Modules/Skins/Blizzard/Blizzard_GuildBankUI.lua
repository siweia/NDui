local _, ns = ...
local B, C, L, DB = unpack(ns)

-- /run LoadAddOn'Blizzard_GuildBankUI' GuildBankFrame:Show()

C.themes["Blizzard_GuildBankUI"] = function()
	B.StripTextures(GuildBankFrame)
	B.SetBD(GuildBankFrame, nil, 10, 0, 0, 6)
	local closeButton = select(11, GuildBankFrame:GetChildren())
	if closeButton then B.ReskinClose(closeButton) end

	GuildBankFrame.Emblem:SetAlpha(0)
	B.Reskin(GuildBankFrame.WithdrawButton)
	B.Reskin(GuildBankFrame.DepositButton)
	B.ReskinScroll(GuildBankTransactionsScrollFrameScrollBar)
	B.ReskinScroll(GuildBankInfoScrollFrameScrollBar)
	B.Reskin(GuildBankFrame.BuyInfo.PurchaseButton)
	B.Reskin(GuildBankFrame.Info.SaveButton)

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
			button:SetNormalTexture(0)
			button:SetPushedTexture(0)
			button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			button.icon:SetTexCoord(unpack(DB.TexCoord))
			button.bg = B.CreateBDFrame(button, .3)
			button.bg:SetBackdropColor(.3, .3, .3, .3)
			button.searchOverlay:SetOutside()
			B.ReskinIconBorder(button.IconBorder)
		end
	end

	for i = 1, 6 do
		local tab = _G["GuildBankTab"..i]
		local button = tab.Button
		local icon = button.IconTexture

		B.StripTextures(tab)
		button:SetNormalTexture(0)
		button:SetPushedTexture(0)
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		button:SetCheckedTexture(DB.pushedTex)
		B.CreateBDFrame(button)
		icon:SetTexCoord(unpack(DB.TexCoord))

		local a1, p, a2, x, y = button:GetPoint()
		button:SetPoint(a1, p, a2, x + C.mult, y)
	end

	local NUM_GUILDBANK_ICONS_PER_ROW = 10
	local NUM_GUILDBANK_ICON_ROWS = 9

	GuildBankPopupFrame:GetChildren():Hide()
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
			local icon = _G["GuildBankPopupButton"..i.."Icon"]
			if not button.styled then
				button:SetCheckedTexture(DB.pushedTex)
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