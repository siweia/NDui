local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	for i = 1, 5 do
		local tab = _G["FriendsFrameTab"..i]
		tab.bg = B.ReskinTab(tab)
		local hl = _G["FriendsFrameTab"..i.."HighlightTexture"]
		hl:SetPoint("TOPLEFT", tab.bg, C.mult, -C.mult)
		hl:SetPoint("BOTTOMRIGHT", tab.bg, -C.mult, C.mult)
		if i == 1 then
			tab:SetPoint("BOTTOMLEFT", -2, -31)
		end
	end
	FriendsFrameIcon:Hide()
	B.StripTextures(FriendsFrameFriendsScrollFrame)
	B.StripTextures(IgnoreListFrame)

	for i = 1, FRIENDS_TO_DISPLAY do
		local bu = _G["FriendsFrameFriendsScrollFrameButton"..i]
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
		nt:SetTexture("Interface\\FriendsFrame\\PlusManz-PlusManz")
		nt:SetTexCoord(.1, .9, .1, .9)
		local hl = travelPass:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetAllPoints()
	end

	local function UpdateScroll()
		for i = 1, FRIENDS_TO_DISPLAY do
			local bu = _G["FriendsFrameFriendsScrollFrameButton"..i]

			if bu.gameIcon:IsShown() then
				bu.bg:Show()
				bu.gameIcon:SetPoint("TOPRIGHT", bu.travelPassButton, "TOPLEFT", -4, 0)
			else
				bu.bg:Hide()
			end
		end
	end
	hooksecurefunc("FriendsFrame_UpdateFriends", UpdateScroll)
	hooksecurefunc(FriendsFrameFriendsScrollFrame, "update", UpdateScroll)

	local header = FriendsFrameFriendsScrollFrame.PendingInvitesHeaderButton
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

	hooksecurefunc(FriendsFrameFriendsScrollFrame.invitePool, "Acquire", reskinInvites)
	hooksecurefunc("FriendsFrame_UpdateFriendButton", function(button)
		if button.buttonType == FRIENDS_BUTTON_TYPE_INVITE then
			reskinInvites(FriendsFrameFriendsScrollFrame.invitePool)
		elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
			local nt = button.travelPassButton:GetNormalTexture()
			if FriendsFrame_GetInviteRestriction(button.id) == 8 then
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
		button:GetRegions():SetTexCoord(.08, .92, .08, .92)
		B.CreateBDFrame(button)
	end

	B.CreateBD(FriendsFrameBattlenetFrame.UnavailableInfoFrame)
	FriendsFrameBattlenetFrame.UnavailableInfoFrame:SetPoint("TOPLEFT", FriendsFrame, "TOPRIGHT", 1, -18)

	FriendsFrameBattlenetFrame:GetRegions():Hide()
	B.CreateBDFrame(FriendsFrameBattlenetFrame, .25)

	FriendsFrameBattlenetFrame.Tag:SetParent(FriendsListFrame)
	FriendsFrameBattlenetFrame.Tag:SetPoint("TOP", FriendsFrame, "TOP", 0, -8)

	hooksecurefunc("FriendsFrame_CheckBattlenetStatus", function()
		if BNFeaturesEnabled() then
			local frame = FriendsFrameBattlenetFrame
			frame.BroadcastButton:Hide()

			if BNConnected() then
				frame:Hide()
				FriendsFrameBroadcastInput:Show()
				FriendsFrameBroadcastInput_UpdateDisplay()
			end
		end
	end)

	hooksecurefunc("FriendsFrame_Update", function()
		if FriendsFrame.selectedTab == 1 and FriendsTabHeader.selectedTab == 1 and FriendsFrameBattlenetFrame.Tag:IsShown() then
			FriendsFrameTitleText:Hide()
		else
			FriendsFrameTitleText:Show()
		end
	end)

	local whoBg = B.CreateBDFrame(WhoFrameEditBox, 0, true)
	whoBg:SetPoint("TOPLEFT", WhoFrameEditBoxInset)
	whoBg:SetPoint("BOTTOMRIGHT", WhoFrameEditBoxInset, -1, 1)

	B.ReskinPortraitFrame(FriendsFrame)
	B.Reskin(FriendsFrameAddFriendButton)
	B.Reskin(FriendsFrameSendMessageButton)
	B.Reskin(FriendsFrameIgnorePlayerButton)
	B.Reskin(FriendsFrameUnsquelchButton)
	B.ReskinScroll(FriendsFrameFriendsScrollFrameScrollBar)
	B.ReskinScroll(FriendsFrameIgnoreScrollFrameScrollBar)
	B.ReskinScroll(FriendsFriendsScrollFrameScrollBar)
	B.ReskinScroll(WhoListScrollFrameScrollBar)
	B.ReskinDropDown(FriendsFrameStatusDropDown)
	B.ReskinDropDown(WhoFrameDropDown)
	B.ReskinDropDown(FriendsFriendsFrameDropDown)
	B.Reskin(FriendsListFrameContinueButton)
	B.StripTextures(FriendsFriendsList)
	B.CreateBDFrame(FriendsFriendsList, .25)
	B.StripTextures(AddFriendNoteFrame)
	B.CreateBDFrame(AddFriendNoteFrame, .25)
	B.ReskinInput(AddFriendNameEditBox)
	B.ReskinInput(FriendsFrameBroadcastInput)
	B.StripTextures(AddFriendFrame)
	B.SetBD(AddFriendFrame)
	B.StripTextures(FriendsFriendsFrame)
	B.SetBD(FriendsFriendsFrame)
	B.Reskin(WhoFrameWhoButton)
	B.Reskin(WhoFrameAddFriendButton)
	B.Reskin(WhoFrameGroupInviteButton)
	B.Reskin(AddFriendEntryFrameAcceptButton)
	B.Reskin(AddFriendEntryFrameCancelButton)
	B.Reskin(FriendsFriendsSendRequestButton)
	B.Reskin(FriendsFriendsCloseButton)
	B.Reskin(AddFriendInfoFrameContinueButton)

	for i = 1, 4 do
		B.StripTextures(_G["WhoFrameColumnHeader"..i])
	end

	B.StripTextures(WhoFrameListInset)
	WhoFrameEditBoxInset:Hide()

	for i = 1, 2 do
		B.StripTextures(_G["FriendsTabHeaderTab"..i])
	end

	WhoFrameWhoButton:SetPoint("RIGHT", WhoFrameAddFriendButton, "LEFT", -1, 0)
	WhoFrameAddFriendButton:SetPoint("RIGHT", WhoFrameGroupInviteButton, "LEFT", -1, 0)
	FriendsFrameTitleText:SetPoint("TOP", FriendsFrame, "TOP", 0, -8)

	-- GuildFrame

	B.StripTextures(GuildFrame)
	B.ReskinArrow(GuildFrameGuildListToggleButton, "right")
	B.Reskin(GuildFrameGuildInformationButton)
	B.Reskin(GuildFrameAddMemberButton)
	B.Reskin(GuildFrameControlButton)
	B.StripTextures(GuildFrameLFGFrame)
	B.ReskinCheck(GuildFrameLFGButton)
	B.ReskinScroll(GuildListScrollFrameScrollBar)
	for i = 1, 4 do
		local bg = B.ReskinTab(_G["GuildFrameColumnHeader"..i])
		bg:SetPoint("TOPLEFT", 5, -2)
		bg:SetPoint("BOTTOMRIGHT", 0, 0)
		local bg = B.ReskinTab(_G["GuildFrameGuildStatusColumnHeader"..i])
		bg:SetPoint("TOPLEFT", 5, -2)
		bg:SetPoint("BOTTOMRIGHT", 0, 0)
	end

	B.StripTextures(GuildMemberDetailFrame)
	B.SetBD(GuildMemberDetailFrame)
	GuildMemberDetailFrame:SetPoint("TOPLEFT", GuildFrame, "TOPRIGHT", 4, -15)
	B.ReskinClose(GuildMemberDetailCloseButton)
	B.StripTextures(GuildMemberNoteBackground)
	B.CreateBDFrame(GuildMemberNoteBackground, .25)
	B.StripTextures(GuildMemberOfficerNoteBackground)
	B.CreateBDFrame(GuildMemberOfficerNoteBackground, .25)
	B.ReskinArrow(GuildFramePromoteButton, "up")
	B.ReskinArrow(GuildFrameDemoteButton, "down")
	GuildFramePromoteButton:SetHitRectInsets(0, 0, 0, 0)
	GuildFrameDemoteButton:SetHitRectInsets(0, 0, 0, 0)
	GuildFrameDemoteButton:SetPoint("LEFT", GuildFramePromoteButton, "RIGHT", 4, 0)
	B.Reskin(GuildMemberRemoveButton)
	B.Reskin(GuildMemberGroupInviteButton)

	B.StripTextures(GuildInfoFrame)
	B.SetBD(GuildInfoFrame)
	B.ReskinScroll(GuildInfoFrameScrollFrameScrollBar)
	B.ReskinClose(GuildInfoCloseButton)
	B.StripTextures(GuildInfoTextBackground)
	B.CreateBDFrame(GuildInfoTextBackground, .25)
	B.Reskin(GuildInfoSaveButton)
	B.Reskin(GuildInfoCancelButton)

	B.StripTextures(GuildControlPopupFrame)
	GuildControlPopupFrame:SetPoint("TOPLEFT", GuildFrame, "TOPRIGHT", 3, 0)
	B.SetBD(GuildControlPopupFrame)
	B.ReskinDropDown(GuildControlPopupFrameDropDown)
	B.ReskinArrow(GuildControlPopupFrameAddRankButton, "right")
	B.StripTextures(GuildControlPopupFrameEditBox)
	local bg = B.CreateBDFrame(GuildControlPopupFrameEditBox, 0, true)
	bg:SetPoint("TOPLEFT", -5, -5)
	bg:SetPoint("BOTTOMRIGHT", 5, 5)
	B.Reskin(GuildControlPopupAcceptButton)
	B.Reskin(GuildControlPopupFrameCancelButton)

	for i = 1, 16 do
		local checkbox = _G["GuildControlPopupFrameCheckbox"..i]
		if checkbox then
			B.ReskinCheck(checkbox)
		end
	end

	local function SetGuildInput(frame)
		B.ReskinInput(frame)
		frame.bg:SetPoint("TOPLEFT", -2, -7)
		frame.bg:SetPoint("BOTTOMRIGHT", 2, 7)
	end
	SetGuildInput(GuildControlWithdrawGoldEditBox)
	SetGuildInput(GuildControlWithdrawItemsEditBox)

	B.ReskinCheck(GuildControlTabPermissionsViewTab)
	B.ReskinCheck(GuildControlTabPermissionsDepositItems)
	B.ReskinCheck(GuildControlTabPermissionsUpdateText)
	GuildControlPopupFrameTabPermissions:HideBackdrop()

	-- Font width fix
	for i = 1, 13 do
		_G["GuildFrameButton"..i.."Level"]:SetWidth(30)
	end
end)