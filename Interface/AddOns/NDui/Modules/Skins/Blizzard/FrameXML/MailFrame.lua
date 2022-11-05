local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local texL, texR, texT, texB = unpack(DB.TexCoord)

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

	B.ReskinPortraitFrame(MailFrame)
	B.ReskinPortraitFrame(OpenMailFrame)
	B.Reskin(SendMailMailButton)
	B.Reskin(SendMailCancelButton)
	B.Reskin(OpenMailReplyButton)
	B.Reskin(OpenMailDeleteButton)
	B.Reskin(OpenMailCancelButton)
	B.Reskin(OpenMailReportSpamButton)
	B.Reskin(OpenAllMail)
	B.ReskinInput(SendMailNameEditBox, 20, 85)
	B.ReskinInput(SendMailSubjectEditBox, nil, 200)
	B.ReskinInput(SendMailMoneyGold)
	B.ReskinInput(SendMailMoneySilver)
	B.ReskinInput(SendMailMoneyCopper)
	B.ReskinScroll(SendMailScrollFrameScrollBar)
	B.ReskinScroll(OpenMailScrollFrameScrollBar)
	B.ReskinRadio(SendMailSendMoneyButton)
	B.ReskinRadio(SendMailCODButton)
	B.ReskinArrow(InboxPrevPageButton, "left")
	B.ReskinArrow(InboxNextPageButton, "right")

	B.CreateBDFrame(OpenMailScrollFrame, .25)
	local bg = B.CreateBDFrame(SendMailScrollFrame, .25)
	bg:SetPoint("TOPLEFT", 6, 0)

	SendMailMailButton:SetPoint("RIGHT", SendMailCancelButton, "LEFT", -1, 0)
	OpenMailDeleteButton:SetPoint("RIGHT", OpenMailCancelButton, "LEFT", -1, 0)
	OpenMailReplyButton:SetPoint("RIGHT", OpenMailDeleteButton, "LEFT", -1, 0)

	SendMailMoneySilver:SetPoint("LEFT", SendMailMoneyGold, "RIGHT", 1, 0)
	SendMailMoneyCopper:SetPoint("LEFT", SendMailMoneySilver, "RIGHT", 1, 0)

	SendMailSubjectEditBox:SetPoint("TOPLEFT", SendMailNameEditBox, "BOTTOMLEFT", 0, -1)

	for i = 1, 2 do
		B.ReskinTab(_G["MailFrameTab"..i])
	end
	MailFrameTab2:ClearAllPoints()
	MailFrameTab2:SetPoint("TOPLEFT", MailFrameTab1, "TOPRIGHT", -15, 0)

	for _, button in pairs({OpenMailLetterButton, OpenMailMoneyButton}) do
		B.StripTextures(button)
		button.icon:SetTexCoord(texL, texR, texT, texB)
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		B.CreateBDFrame(button)
	end

	for i = 1, INBOXITEMS_TO_DISPLAY do
		local item = _G["MailItem"..i]
		local button = _G["MailItem"..i.."Button"]
		B.StripTextures(item)
		B.StripTextures(button)
		button:SetCheckedTexture(DB.textures.pushed)
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		button.Icon:SetTexCoord(texL, texR, texT, texB)
		button.IconBorder:SetAlpha(0)
		B.CreateBDFrame(button)
	end

	for i = 1, ATTACHMENTS_MAX_SEND do
		local button = _G["SendMailAttachment"..i]
		B.StripTextures(button)
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		button.bg = B.CreateBDFrame(button, .25)
		B.ReskinIconBorder(button.IconBorder)
	end

	hooksecurefunc("SendMailFrame_Update", function()
		for i = 1, ATTACHMENTS_MAX_SEND do
			local button = SendMailFrame.SendMailAttachments[i]
			if HasSendMailItem(i) then
				button:GetNormalTexture():SetTexCoord(texL, texR, texT, texB)
			end
		end
	end)

	for i = 1, ATTACHMENTS_MAX_RECEIVE do
		local button = _G["OpenMailAttachmentButton"..i]
		B.StripTextures(button)
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		button.icon:SetTexCoord(texL, texR, texT, texB)
		button.bg = B.CreateBDFrame(button, .25)
		B.ReskinIconBorder(button.IconBorder)
	end

	MailFont_Large:SetTextColor(1, 1, 1)
	MailFont_Large:SetShadowColor(0, 0, 0, 0)
	MailTextFontNormal:SetTextColor(1, 1, 1)
	MailTextFontNormal:SetShadowColor(0, 0, 0, 0)
	InvoiceTextFontNormal:SetTextColor(1, 1, 1)
	InvoiceTextFontSmall:SetTextColor(1, 1, 1)
end)