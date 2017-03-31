local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	SendMailMoneyInset:DisableDrawLayer("BORDER")
	InboxFrame:GetRegions():Hide()
	SendMailMoneyBg:Hide()
	SendMailMoneyInsetBg:Hide()
	OpenMailFrameIcon:Hide()
	OpenMailHorizontalBarLeft:Hide()
	select(18, MailFrame:GetRegions()):Hide()
	select(25, OpenMailFrame:GetRegions()):Hide()
	for i = 4, 7 do
		select(i, SendMailFrame:GetRegions()):Hide()
	end
	select(4, SendMailScrollFrame:GetRegions()):Hide()
	select(2, OpenMailScrollFrame:GetRegions()):Hide()

	F.ReskinPortraitFrame(MailFrame, true)
	F.ReskinPortraitFrame(OpenMailFrame, true)
	F.Reskin(SendMailMailButton)
	F.Reskin(SendMailCancelButton)
	F.Reskin(OpenMailReplyButton)
	F.Reskin(OpenMailDeleteButton)
	F.Reskin(OpenMailCancelButton)
	F.Reskin(OpenMailReportSpamButton)
	F.Reskin(OpenAllMail)
	F.ReskinInput(SendMailNameEditBox, 20)
	F.ReskinInput(SendMailSubjectEditBox)
	F.ReskinInput(SendMailMoneyGold)
	F.ReskinInput(SendMailMoneySilver)
	F.ReskinInput(SendMailMoneyCopper)
	F.ReskinScroll(SendMailScrollFrameScrollBar)
	F.ReskinScroll(OpenMailScrollFrameScrollBar)
	F.ReskinRadio(SendMailSendMoneyButton)
	F.ReskinRadio(SendMailCODButton)

	SendMailMailButton:SetPoint("RIGHT", SendMailCancelButton, "LEFT", -1, 0)
	OpenMailDeleteButton:SetPoint("RIGHT", OpenMailCancelButton, "LEFT", -1, 0)
	OpenMailReplyButton:SetPoint("RIGHT", OpenMailDeleteButton, "LEFT", -1, 0)

	SendMailMoneySilver:SetPoint("LEFT", SendMailMoneyGold, "RIGHT", 1, 0)
	SendMailMoneyCopper:SetPoint("LEFT", SendMailMoneySilver, "RIGHT", 1, 0)

	OpenMailLetterButton:SetNormalTexture("")
	OpenMailLetterButton:SetPushedTexture("")
	OpenMailLetterButtonIconTexture:SetTexCoord(.08, .92, .08, .92)

	for i = 1, 2 do
		F.ReskinTab(_G["MailFrameTab"..i])
	end

	local bgmail = CreateFrame("Frame", nil, OpenMailLetterButton)
	bgmail:SetPoint("TOPLEFT", -1, 1)
	bgmail:SetPoint("BOTTOMRIGHT", 1, -1)
	bgmail:SetFrameLevel(OpenMailLetterButton:GetFrameLevel()-1)
	F.CreateBD(bgmail)

	OpenMailMoneyButton:SetNormalTexture("")
	OpenMailMoneyButton:SetPushedTexture("")
	OpenMailMoneyButtonIconTexture:SetTexCoord(.08, .92, .08, .92)

	local bgmoney = CreateFrame("Frame", nil, OpenMailMoneyButton)
	bgmoney:SetPoint("TOPLEFT", -1, 1)
	bgmoney:SetPoint("BOTTOMRIGHT", 1, -1)
	bgmoney:SetFrameLevel(OpenMailMoneyButton:GetFrameLevel()-1)
	F.CreateBD(bgmoney)

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
		bu:SetCheckedTexture(C.media.checked)

		st:Hide()
		line:Hide()
		ic:SetTexCoord(.08, .92, .08, .92)
		bd:SetAlpha(0)
		F.CreateBDFrame(bu)
	end

	for i = 1, ATTACHMENTS_MAX_SEND do
		local bu = _G["SendMailAttachment"..i]
		local border = bu.IconBorder

		bu:GetRegions():Hide()

		border:SetPoint("TOPLEFT", -1.2, 1.2)
		border:SetPoint("BOTTOMRIGHT", 1.2, -1.2)
		border:SetDrawLayer("BACKGROUND")

		local bg = CreateFrame("Frame", nil, bu)
		bg:SetPoint("TOPLEFT", -1.2, 1.2)
		bg:SetPoint("BOTTOMRIGHT", 1.2, -1.2)
		bg:SetFrameLevel(0)
		F.CreateBD(bg, .25)
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
		ic:SetTexCoord(.08, .92, .08, .92)

		border:SetTexture(C.media.backdrop)
		border.SetTexture = F.dummy
		border:SetPoint("TOPLEFT", -1.2, 1.2)
		border:SetPoint("BOTTOMRIGHT", 1.2, -1.2)
		border:SetDrawLayer("BACKGROUND")

		local bg = CreateFrame("Frame", nil, bu)
		bg:SetPoint("TOPLEFT", -1.2, 1.2)
		bg:SetPoint("BOTTOMRIGHT", 1.2, -1.2)
		bg:SetFrameLevel(0)
		F.CreateBD(bg, .25)
	end

	hooksecurefunc("SendMailFrame_Update", function()
		for i = 1, ATTACHMENTS_MAX_SEND do
			local button = _G["SendMailAttachment"..i]
			button.IconBorder:SetTexture(C.media.backdrop)
			if button:GetNormalTexture() then
				button:GetNormalTexture():SetTexCoord(.08, .92, .08, .92)
			end
		end
	end)
end)