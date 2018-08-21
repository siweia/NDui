local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
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
	local bg = F.CreateBDFrame(QuickJoinToastButton.Toast)
	bg:SetPoint("TOPLEFT", 10, -1)
	bg:SetPoint("BOTTOMRIGHT", 0, 3)
	F.CreateSD(bg)
	bg:Hide()
	hooksecurefunc(QuickJoinToastButton, "ShowToast", function() bg:Show() end)
	hooksecurefunc(QuickJoinToastButton, "HideToast", function() bg:Hide() end)

	F.Reskin(ChatFrameChannelButton)
	ChatFrameChannelButton:SetSize(20, 20)
	F.Reskin(ChatFrameToggleVoiceDeafenButton)
	ChatFrameToggleVoiceDeafenButton:SetSize(20, 20)
	F.Reskin(ChatFrameToggleVoiceMuteButton)
	ChatFrameToggleVoiceMuteButton:SetSize(20, 20)
	F.Reskin(ChatFrameMenuButton)
	ChatFrameMenuButton:SetSize(20, 20)
	ChatFrameMenuButton:SetNormalTexture(homeTex)
	ChatFrameMenuButton:SetPushedTexture(homeTex)

	local function reskinScroll(self)
		local bu = _G[self:GetName().."ThumbTexture"]
		bu:SetAlpha(0)
		bu:SetWidth(16)
		local bg = F.CreateBDFrame(bu)
		F.CreateGradient(bg)
		local down = self.ScrollToBottomButton
		F.ReskinArrow(down, "down")
		down:SetPoint("BOTTOMRIGHT", _G[self:GetName().."ResizeButton"], "TOPRIGHT", -3, -2)
	end

	for i = 1, NUM_CHAT_WINDOWS do
		reskinScroll(_G["ChatFrame"..i])
	end
end)