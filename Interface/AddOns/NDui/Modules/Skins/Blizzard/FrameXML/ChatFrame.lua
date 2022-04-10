local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	-- Battlenet toast frame
	BNToastFrame:SetBackdrop(nil)
	B.SetBD(BNToastFrame)
	BNToastFrame.TooltipFrame:HideBackdrop()
	B.SetBD(BNToastFrame.TooltipFrame)

	TimeAlertFrame:SetBackdrop(nil)
	B.SetBD(TimeAlertFrame)

	-- Battletag invite frame
	BattleTagInviteFrame:SetBackdrop(nil)
	B.SetBD(BattleTagInviteFrame)
	local send, cancel = BattleTagInviteFrame:GetChildren()
	B.Reskin(send)
	B.Reskin(cancel)

	local homeTex = "Interface\\Buttons\\UI-HomeButton"
	B.Reskin(ChatFrameChannelButton)
	ChatFrameChannelButton:SetSize(20, 20)
	B.Reskin(ChatFrameMenuButton)
	ChatFrameMenuButton:SetSize(20, 20)
	ChatFrameMenuButton:SetNormalTexture(homeTex)
	ChatFrameMenuButton:SetPushedTexture(homeTex)

	-- ChannelFrame
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

	B.SetBD(VoiceChatPromptActivateChannel)
	B.Reskin(VoiceChatPromptActivateChannel.AcceptButton)
	VoiceChatChannelActivatedNotification:SetBackdrop(nil)
	B.SetBD(VoiceChatChannelActivatedNotification)

	B.ReskinSlider(UnitPopupVoiceMicrophoneVolume.Slider)
	B.ReskinSlider(UnitPopupVoiceSpeakerVolume.Slider)

	-- VoiceActivityManager
	hooksecurefunc(VoiceActivityManager, "LinkFrameNotificationAndGuid", function(_, _, notification, guid)
		local class = select(2, GetPlayerInfoByGUID(guid))
		if class then
			local color = DB.ClassColors[class]
			if notification.Name then
				notification.Name:SetTextColor(color.r, color.g, color.b)
			end
		end
	end)
end)