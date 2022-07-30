local _, ns = ...
local B, C, L, DB = unpack(ns)

local atlasToTex = {
	["friendslist-invitebutton-horde-normal"] = "Interface\\FriendsFrame\\PlusManz-Horde",
	["friendslist-invitebutton-alliance-normal"] = "Interface\\FriendsFrame\\PlusManz-Alliance",
	["friendslist-invitebutton-default-normal"] = "Interface\\FriendsFrame\\PlusManz-PlusManz",
}
local function replaceInviteTex(self, atlas)
	local tex = atlasToTex[atlas]
	if tex then
		self:SetTexture(tex)
	end
end

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	for i = 1, 4 do
		local tab = _G["FriendsFrameTab"..i]
		if tab then
			B.ReskinTab(tab)
			B.ResetTabAnchor(tab)
		end
	end
	FriendsFrameIcon:Hide()
	B.StripTextures(IgnoreListFrame)

	for i = 1, FRIENDS_TO_DISPLAY do
		local bu = _G["FriendsListFrameScrollFrameButton"..i]
		local ic = bu.gameIcon

		bu.background:Hide()
		bu:SetHighlightTexture(DB.bdTex)
		bu:GetHighlightTexture():SetVertexColor(.24, .56, 1, .2)
		ic:SetSize(22, 22)
		ic:SetTexCoord(.17, .83, .17, .83)

		bu.bg = CreateFrame("Frame", nil, bu)
		bu.bg:SetAllPoints(ic)
		B.CreateBDFrame(bu.bg, 0)

		local travelPass = bu.travelPassButton
		travelPass:SetSize(22, 22)
		travelPass:SetPushedTexture(nil)
		travelPass:SetDisabledTexture(nil)
		travelPass:SetPoint("TOPRIGHT", -3, -6)
		B.CreateBDFrame(travelPass, 1)
		local nt = travelPass:GetNormalTexture()
		nt:SetTexCoord(.1, .9, .1, .9)
		hooksecurefunc(nt, "SetAtlas", replaceInviteTex)
		local hl = travelPass:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetAllPoints()
	end

	local function UpdateScroll()
		for i = 1, FRIENDS_TO_DISPLAY do
			local bu = _G["FriendsListFrameScrollFrameButton"..i]
			if bu.gameIcon:IsShown() then
				bu.bg:Show()
				bu.gameIcon:SetPoint("TOPRIGHT", bu.travelPassButton, "TOPLEFT", -4, 0)
			else
				bu.bg:Hide()
			end
		end
	end
	hooksecurefunc("FriendsFrame_UpdateFriends", UpdateScroll)
	hooksecurefunc(FriendsListFrameScrollFrame, "update", UpdateScroll)

	local header = FriendsListFrameScrollFrame.PendingInvitesHeaderButton
	for i = 1, 11 do
		select(i, header:GetRegions()):Hide()
	end
	local headerBg = B.CreateBDFrame(header, .25)
	headerBg:SetPoint("TOPLEFT", 2, -2)
	headerBg:SetPoint("BOTTOMRIGHT", -2, 2)

	local function reskinInvites(self)
		for invite in self:EnumerateActive() do
			if not invite.styled then
				B.Reskin(invite.AcceptButton)
				B.Reskin(invite.DeclineButton)

				invite.styled = true
			end
		end
	end

	hooksecurefunc(FriendsListFrameScrollFrame.invitePool, "Acquire", reskinInvites)

	local INVITE_RESTRICTION_NONE = 9
	hooksecurefunc("FriendsFrame_UpdateFriendButton", function(button)
		if button.buttonType == FRIENDS_BUTTON_TYPE_INVITE then
			reskinInvites(FriendsListFrameScrollFrame.invitePool)
		elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
			local nt = button.travelPassButton:GetNormalTexture()
			if FriendsFrame_GetInviteRestriction(button.id) == INVITE_RESTRICTION_NONE then
				nt:SetVertexColor(1, 1, 1)
			else
				nt:SetVertexColor(.3, .3, .3)
			end
		end
	end)

	FriendsFrameStatusDropDown:ClearAllPoints()
	FriendsFrameStatusDropDown:SetPoint("TOPLEFT", FriendsFrame, "TOPLEFT", 10, -28)

	for _, button in pairs({FriendsTabHeaderSoRButton, FriendsTabHeaderRecruitAFriendButton}) do
		button:SetPushedTexture("")
		button:GetRegions():SetTexCoord(unpack(DB.TexCoord))
		B.CreateBDFrame(button)
	end

	-- FriendsFrameBattlenetFrame

	FriendsFrameBattlenetFrame:GetRegions():Hide()
	local bg = B.CreateBDFrame(FriendsFrameBattlenetFrame, .25)
	bg:SetPoint("TOPLEFT", 0, -2)
	bg:SetPoint("BOTTOMRIGHT", -2, 2)
	bg:SetBackdropColor(0, .6, 1, .25)

	local broadcastButton = FriendsFrameBattlenetFrame.BroadcastButton
	broadcastButton:SetSize(20, 20)
	B.Reskin(broadcastButton)
	local newIcon = broadcastButton:CreateTexture(nil, "ARTWORK")
	newIcon:SetAllPoints()
	newIcon:SetTexture("Interface\\FriendsFrame\\BroadcastIcon")

	local broadcastFrame = FriendsFrameBattlenetFrame.BroadcastFrame
	B.StripTextures(broadcastFrame)
	B.SetBD(broadcastFrame, nil, 10, -10, -10, 10)
	broadcastFrame.EditBox:DisableDrawLayer("BACKGROUND")
	local bg = B.CreateBDFrame(broadcastFrame.EditBox, 0, true)
	bg:SetPoint("TOPLEFT", -2, -2)
	bg:SetPoint("BOTTOMRIGHT", 2, 2)
	B.Reskin(broadcastFrame.UpdateButton)
	B.Reskin(broadcastFrame.CancelButton)
	broadcastFrame:ClearAllPoints()
	broadcastFrame:SetPoint("TOPLEFT", FriendsFrame, "TOPRIGHT", 3, 0)

	local function BroadcastButton_SetTexture(self)
		self.BroadcastButton:SetNormalTexture("")
		self.BroadcastButton:SetPushedTexture("")
	end
	hooksecurefunc(broadcastFrame, "ShowFrame", BroadcastButton_SetTexture)
	hooksecurefunc(broadcastFrame, "HideFrame", BroadcastButton_SetTexture)

	local unavailableFrame = FriendsFrameBattlenetFrame.UnavailableInfoFrame
	B.StripTextures(unavailableFrame)
	B.SetBD(unavailableFrame)
	unavailableFrame:SetPoint("TOPLEFT", FriendsFrame, "TOPRIGHT", 3, -18)

	B.ReskinPortraitFrame(FriendsFrame)
	B.Reskin(FriendsFrameAddFriendButton)
	B.Reskin(FriendsFrameSendMessageButton)
	B.Reskin(FriendsFrameIgnorePlayerButton)
	B.Reskin(FriendsFrameUnsquelchButton)
	B.ReskinScroll(FriendsListFrameScrollFrame.scrollBar)
	B.ReskinScroll(IgnoreListFrameScrollFrame.scrollBar)
	B.ReskinScroll(WhoListScrollFrame.scrollBar)
	B.ReskinDropDown(FriendsFrameStatusDropDown)
	B.ReskinDropDown(WhoFrameDropDown)
	B.ReskinDropDown(FriendsFriendsFrameDropDown)
	B.Reskin(FriendsListFrameContinueButton)
	B.ReskinInput(AddFriendNameEditBox)
	B.StripTextures(AddFriendFrame)
	B.SetBD(AddFriendFrame)
	B.StripTextures(FriendsFriendsFrame)
	B.SetBD(FriendsFriendsFrame)
	B.Reskin(FriendsFriendsFrame.SendRequestButton)
	B.Reskin(FriendsFriendsFrame.CloseButton)
	B.ReskinScroll(FriendsFriendsScrollFrame.scrollBar)
	B.Reskin(WhoFrameWhoButton)
	B.Reskin(WhoFrameAddFriendButton)
	B.Reskin(WhoFrameGroupInviteButton)
	B.Reskin(AddFriendEntryFrameAcceptButton)
	B.Reskin(AddFriendEntryFrameCancelButton)
	B.Reskin(AddFriendInfoFrameContinueButton)

	for i = 1, 4 do
		B.StripTextures(_G["WhoFrameColumnHeader"..i])
	end

	B.StripTextures(WhoFrameListInset)
	WhoFrameEditBoxInset:Hide()
	local whoBg = B.CreateBDFrame(WhoFrameEditBox, 0, true)
	whoBg:SetPoint("TOPLEFT", WhoFrameEditBoxInset)
	whoBg:SetPoint("BOTTOMRIGHT", WhoFrameEditBoxInset, -1, 1)

	for i = 1, 3 do
		B.StripTextures(_G["FriendsTabHeaderTab"..i])
	end

	WhoFrameWhoButton:SetPoint("RIGHT", WhoFrameAddFriendButton, "LEFT", -1, 0)
	WhoFrameAddFriendButton:SetPoint("RIGHT", WhoFrameGroupInviteButton, "LEFT", -1, 0)
	FriendsFrameTitleText:SetPoint("TOP", FriendsFrame, "TOP", 0, -8)
end)