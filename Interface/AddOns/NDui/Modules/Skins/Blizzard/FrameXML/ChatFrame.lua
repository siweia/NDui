local _, ns = ...
local B, C, L, DB = unpack(ns)
local r, g, b = DB.r, DB.g, DB.b

local function scrollOnEnter(self)
	self.thumbBG:SetBackdropColor(r, g, b, .25)
	self.thumbBG:SetBackdropBorderColor(r, g, b)
end

local function scrollOnLeave(self)
	self.thumbBG:SetBackdropColor(0, 0, 0, 0)
	self.thumbBG:SetBackdropBorderColor(0, 0, 0)
end

local function ReskinChatScroll(self)
	local bu = _G[self:GetName().."ThumbTexture"]
	bu:SetAlpha(0)
	bu:SetWidth(16)
	local bg = B.CreateBDFrame(bu, 0, true)
	local down = self.ScrollToBottomButton
	B.ReskinArrow(down, "down")
	down:SetPoint("BOTTOMRIGHT", _G[self:GetName().."ResizeButton"], "TOPRIGHT", -4, -2)

	self.ScrollBar.thumbBG = bg
	self.ScrollBar:HookScript("OnEnter", scrollOnEnter)
	self.ScrollBar:HookScript("OnLeave", scrollOnLeave)
end

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	-- Battlenet toast frame
	BNToastFrame:SetBackdrop(nil)
	B.SetBD(BNToastFrame)
	BNToastFrame.TooltipFrame:HideBackdrop()
	B.SetBD(BNToastFrame.TooltipFrame)

	TimeAlertFrame:SetBackdrop(nil)
	B.SetBD(TimeAlertFrame)

	-- Battletag invite frame
	local border, send, cancel = BattleTagInviteFrame:GetChildren()
	border:Hide()
	B.Reskin(send)
	B.Reskin(cancel)
	B.SetBD(BattleTagInviteFrame)

	local friendTex = "Interface\\HELPFRAME\\ReportLagIcon-Chat"
	local queueTex = "Interface\\HELPFRAME\\HelpIcon-ItemRestoration"
	local homeTex = "Interface\\Buttons\\UI-HomeButton"

	QuickJoinToastButton.FriendsButton:SetTexture(friendTex)
	QuickJoinToastButton.QueueButton:SetTexture(queueTex)
	QuickJoinToastButton:SetHighlightTexture("")
	hooksecurefunc(QuickJoinToastButton, "ToastToFriendFinished", function(self)
		self.FriendsButton:SetShown(not self.displayedToast)
	end)
	hooksecurefunc(QuickJoinToastButton, "UpdateQueueIcon", function(self)
		if not self.displayedToast then return end
		self.QueueButton:SetTexture(queueTex)
		self.FlashingLayer:SetTexture(queueTex)
		self.FriendsButton:SetShown(false)
	end)
	QuickJoinToastButton:HookScript("OnMouseDown", function(self)
		self.FriendsButton:SetTexture(friendTex)
	end)
	QuickJoinToastButton:HookScript("OnMouseUp", function(self)
		self.FriendsButton:SetTexture(friendTex)
	end)
	QuickJoinToastButton.Toast.Background:SetTexture("")
	local bg = B.SetBD(QuickJoinToastButton.Toast)
	bg:SetPoint("TOPLEFT", 10, -1)
	bg:SetPoint("BOTTOMRIGHT", 0, 3)
	bg:Hide()
	hooksecurefunc(QuickJoinToastButton, "ShowToast", function() bg:Show() end)
	hooksecurefunc(QuickJoinToastButton, "HideToast", function() bg:Hide() end)

	-- ChatFrame
	B.Reskin(ChatFrameChannelButton)
	ChatFrameChannelButton:SetSize(20, 20)
	B.Reskin(ChatFrameToggleVoiceDeafenButton)
	ChatFrameToggleVoiceDeafenButton:SetSize(20, 20)
	B.Reskin(ChatFrameToggleVoiceMuteButton)
	ChatFrameToggleVoiceMuteButton:SetSize(20, 20)
	B.Reskin(ChatFrameMenuButton)
	ChatFrameMenuButton:SetSize(20, 20)
	ChatFrameMenuButton:SetNormalTexture(homeTex)
	ChatFrameMenuButton:SetPushedTexture(homeTex)

	for i = 1, NUM_CHAT_WINDOWS do
		ReskinChatScroll(_G["ChatFrame"..i])
	end

	-- ChannelFrame
	B.ReskinPortraitFrame(ChannelFrame)
	B.Reskin(ChannelFrame.NewButton)
	B.Reskin(ChannelFrame.SettingsButton)
	B.ReskinScroll(ChannelFrame.ChannelList.ScrollBar)
	if DB.isNewPatch then
		B.ReskinTrimScroll(ChannelFrame.ChannelRoster.ScrollBar)
	else
		B.ReskinScroll(ChannelFrame.ChannelRoster.ScrollFrame.scrollBar)
	end

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