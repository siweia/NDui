local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.themes["AuroraClassic"], function()
	B.ReskinPortraitFrame(ChannelFrame)
	B.Reskin(ChannelFrame.NewButton)
	B.Reskin(ChannelFrame.SettingsButton)
	B.ReskinScroll(ChannelFrame.ChannelList.ScrollBar)
	B.ReskinScroll(ChannelFrame.ChannelRoster.ScrollFrame.scrollBar)

	hooksecurefunc(ChannelFrame.ChannelList, "Update", function(self)
		for i = 1, self.Child:GetNumChildren() do
			local tab = select(i, self.Child:GetChildren())
			if not tab.styled and tab:IsHeader() then
				tab:SetNormalTexture("")
				tab.bg = B.CreateBDFrame(tab, .25)
				tab.bg:SetAllPoints()

				tab.styled = true
			end
		end
	end)

	B.StripTextures(CreateChannelPopup)
	B.SetBD(CreateChannelPopup)
	B.Reskin(CreateChannelPopup.OKButton)
	B.Reskin(CreateChannelPopup.CancelButton)
	B.ReskinClose(CreateChannelPopup.CloseButton)
	B.ReskinInput(CreateChannelPopup.Name)
	B.ReskinInput(CreateChannelPopup.Password)

	B.CreateBD(VoiceChatPromptActivateChannel)
	B.CreateSD(VoiceChatPromptActivateChannel)
	B.Reskin(VoiceChatPromptActivateChannel.AcceptButton)
	B.CreateBD(VoiceChatChannelActivatedNotification)
	B.CreateSD(VoiceChatChannelActivatedNotification)

	B.ReskinSlider(UnitPopupVoiceMicrophoneVolume.Slider)
	B.ReskinSlider(UnitPopupVoiceSpeakerVolume.Slider)

	-- VoiceActivityManager
	hooksecurefunc(VoiceActivityManager, "LinkFrameNotificationAndGuid", function(_, _, notification, guid)
		local class = select(2, GetPlayerInfoByGUID(guid))
		if class then
			local color = C.ClassColors[class]
			if notification.Name then
				notification.Name:SetTextColor(color.r, color.g, color.b)
			end
		end
	end)
end)