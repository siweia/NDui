local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	local r, g, b = C.r, C.g, C.b

	F.StripTextures(ChannelFrame)
	F.SetBD(ChannelFrame)
	F.ReskinClose(ChannelFrameCloseButton)
	F.Reskin(ChannelFrame.NewButton)
	F.Reskin(ChannelFrame.SettingsButton)
	F.ReskinScroll(ChannelFrame.ChannelRoster.ScrollFrame.scrollBar)

	ChannelFrameInset:Hide()
	ChannelFrame.LeftInset:Hide()
	ChannelFrame.RightInset:Hide()

	hooksecurefunc(ChannelFrame.ChannelList, "Update", function(self)
		for i = 1, self.Child:GetNumChildren() do
			local tab = select(i, self.Child:GetChildren())
			if not tab.styled and tab:IsHeader() then
				tab:SetNormalTexture("")
				tab.bg = F.CreateBDFrame(tab, .25)
				tab.bg:SetAllPoints()

				tab.styled = true
			end
		end
	end)

	F.StripTextures(CreateChannelPopup)
	F.SetBD(CreateChannelPopup)
	F.Reskin(CreateChannelPopup.OKButton)
	F.Reskin(CreateChannelPopup.CancelButton)
	F.ReskinClose(CreateChannelPopup.CloseButton)
	F.ReskinInput(CreateChannelPopup.Name)
	F.ReskinInput(CreateChannelPopup.Password)

	F.Reskin(ChatFrameChannelButton)
	ChatFrameChannelButton:SetSize(20, 20)
	F.Reskin(ChatFrameToggleVoiceDeafenButton)
	ChatFrameToggleVoiceDeafenButton:SetSize(20, 20)
	F.Reskin(ChatFrameToggleVoiceMuteButton)
	ChatFrameToggleVoiceMuteButton:SetSize(20, 20)
	F.Reskin(ChatFrameMenuButton)
	ChatFrameMenuButton:SetSize(20, 20)
	ChatFrameMenuButton:SetNormalTexture("Interface\\Buttons\\UI-HomeButton")
	ChatFrameMenuButton:SetPushedTexture("Interface\\Buttons\\UI-HomeButton")

	F.CreateBD(VoiceChatPromptActivateChannel)
	F.CreateSD(VoiceChatPromptActivateChannel)
	F.Reskin(VoiceChatPromptActivateChannel.AcceptButton)
	F.CreateBD(VoiceChatChannelActivatedNotification)
	F.CreateSD(VoiceChatChannelActivatedNotification)
end)