local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	F.StripTextures(ChannelFrame)
	F.SetBD(ChannelFrame)
	F.ReskinClose(ChannelFrameCloseButton)
	F.Reskin(ChannelFrame.NewButton)
	F.Reskin(ChannelFrame.SettingsButton)
	F.ReskinScroll(ChannelFrame.ChannelList.ScrollBar)
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

	F.CreateBD(VoiceChatPromptActivateChannel)
	F.CreateSD(VoiceChatPromptActivateChannel)
	F.Reskin(VoiceChatPromptActivateChannel.AcceptButton)
	F.CreateBD(VoiceChatChannelActivatedNotification)
	F.CreateSD(VoiceChatChannelActivatedNotification)

	F.ReskinSlider(UnitPopupVoiceMicrophoneVolume.Slider)
	F.ReskinSlider(UnitPopupVoiceSpeakerVolume.Slider)

	-- VoiceActivityManager
	hooksecurefunc(VoiceActivityManager, "LinkFrameNotificationAndGuid", function(_, _, notification, guid)
		local class = select(2, GetPlayerInfoByGUID(guid))
		if class then
			local color = C.classcolours[class]
			if notification.Name then
				notification.Name:SetTextColor(color.r, color.g, color.b)
			end
		end
	end)
end)