local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	SendMailMoneyInset:DisableDrawLayer("BORDER")
	InboxFrame:GetRegions():Hide()
	SendMailMoneyBg:Hide()
	SendMailMoneyInset:Hide()
	OpenMailFrameIcon:Hide()
	OpenMailHorizontalBarLeft:Hide()
	B.StripTextures(SendMailFrame)
	OpenStationeryBackgroundLeft:Hide()
	OpenStationeryBackgroundRight:Hide()
	SendStationeryBackgroundLeft:Hide()
	SendStationeryBackgroundRight:Hide()
	InboxPrevPageButton:GetRegions():Hide()
	InboxNextPageButton:GetRegions():Hide()
	InboxTitleText:SetPoint("CENTER", MailFrame, 0, 195)

	B.ReskinPortraitFrame(MailFrame)
	B.ReskinPortraitFrame(OpenMailFrame)
	B.Reskin(SendMailMailButton)
	B.Reskin(SendMailCancelButton)
	B.Reskin(OpenMailReplyButton)
	B.Reskin(OpenMailDeleteButton)
	B.Reskin(OpenMailCancelButton)
	B.Reskin(OpenMailReportSpamButton)
	B.Reskin(OpenAllMail)
	B.ReskinInput(SendMailNameEditBox, 20)
	B.ReskinInput(SendMailSubjectEditBox)
	B.ReskinInput(SendMailMoneyGold)
	B.ReskinInput(SendMailMoneySilver)
	B.ReskinInput(SendMailMoneyCopper)
	B.ReskinScroll(SendMailScrollFrameScrollBar)
	B.ReskinScroll(OpenMailScrollFrameScrollBar)
	B.ReskinRadio(SendMailSendMoneyButton)
	B.ReskinRadio(SendMailCODButton)
	B.ReskinArrow(InboxPrevPageButton, "left")
	B.ReskinArrow(InboxNextPageButton, "right")

	local bg = B.CreateBDFrame(SendMailScrollFrame, .25)
	bg:SetPoint("TOPLEFT", 6, 0)

	SendMailMailButton:SetPoint("RIGHT", SendMailCancelButton, "LEFT", -1, 0)
	OpenMailDeleteButton:SetPoint("RIGHT", OpenMailCancelButton, "LEFT", -1, 0)
	OpenMailReplyButton:SetPoint("RIGHT", OpenMailDeleteButton, "LEFT", -1, 0)

	SendMailMoneySilver:SetPoint("LEFT", SendMailMoneyGold, "RIGHT", 1, 0)
	SendMailMoneyCopper:SetPoint("LEFT", SendMailMoneySilver, "RIGHT", 1, 0)

	OpenMailLetterButton:SetNormalTexture("")
	OpenMailLetterButton:SetPushedTexture("")
	OpenMailLetterButtonIconTexture:SetTexCoord(unpack(DB.TexCoord))
	B.CreateBDFrame(OpenMailLetterButton)

	for i = 1, 2 do
		B.ReskinTab(_G["MailFrameTab"..i])
	end

	OpenMailMoneyButton:SetNormalTexture("")
	OpenMailMoneyButton:SetPushedTexture("")
	OpenMailMoneyButtonIconTexture:SetTexCoord(unpack(DB.TexCoord))
	B.CreateBDFrame(OpenMailMoneyButton)

	SendMailSubjectEditBox:SetPoint("TOPLEFT", SendMailNameEditBox, "BOTTOMLEFT", 0, -1)

	for i = 1, INBOXITEMS_TO_DISPLAY do
		local it = _G["MailItem"..i]
		local bu = _G["MailItem"..i.."Button"]
		local st = _G["MailItem"..i.."ButtonSlot"]
		local ic = _G["MailItem"..i.."Button".."Icon"]
		local bd = _G["MailItem"..i.."Button".."IconBorder"]
		local line = select(3, _G["MailItem"..i]:GetRegions())

		local a, b = it:GetRegions()
		a:Hide()
		b:Hide()
		bu:SetCheckedTexture(DB.textures.pushed)
		bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

		st:Hide()
		line:Hide()
		ic:SetTexCoord(unpack(DB.TexCoord))
		bd:SetAlpha(0)
		B.CreateBDFrame(bu)
	end

	for i = 1, ATTACHMENTS_MAX_SEND do
		local bu = _G["SendMailAttachment"..i]
		local border = bu.IconBorder

		bu:GetRegions():Hide()
		bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

		border:SetOutside()
		border:SetDrawLayer("BACKGROUND")
		B.CreateBDFrame(bu, .25)
	end

	-- sigh
	-- we mess with quality colour numbers, so we have to fix this
	hooksecurefunc("SendMailFrame_Update", function()
		for i = 1, ATTACHMENTS_MAX_SEND do
			local bu = _G["SendMailAttachment"..i]

			if bu:GetNormalTexture() == nil and bu.IconBorder:IsShown() then
				bu.IconBorder:Hide()
			end
		end
	end)

	for i = 1, ATTACHMENTS_MAX_RECEIVE do
		local bu = _G["OpenMailAttachmentButton"..i]
		local ic = _G["OpenMailAttachmentButton"..i.."IconTexture"]
		local border = bu.IconBorder

		bu:SetNormalTexture("")
		bu:SetPushedTexture("")
		bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		ic:SetTexCoord(unpack(DB.TexCoord))

		border:SetTexture(DB.bdTex)
		border.SetTexture = B.Dummy
		border:SetOutside()
		border:SetDrawLayer("BACKGROUND")
		B.CreateBDFrame(bu, .25)
	end

	hooksecurefunc("SendMailFrame_Update", function()
		for i = 1, ATTACHMENTS_MAX_SEND do
			local button = _G["SendMailAttachment"..i]
			button.IconBorder:SetTexture(DB.bdTex)
			if button:GetNormalTexture() then
				button:GetNormalTexture():SetTexCoord(unpack(DB.TexCoord))
			end
		end
	end)

	MailFont_Large:SetTextColor(1, 1, 1)
	MailFont_Large:SetShadowColor(0, 0, 0)
	MailFont_Large:SetShadowOffset(1, -1)
	MailTextFontNormal:SetTextColor(1, 1, 1)
	MailTextFontNormal:SetShadowOffset(1, -1)
	MailTextFontNormal:SetShadowColor(0, 0, 0)
	InvoiceTextFontNormal:SetTextColor(1, 1, 1)
	InvoiceTextFontSmall:SetTextColor(1, 1, 1)
end)