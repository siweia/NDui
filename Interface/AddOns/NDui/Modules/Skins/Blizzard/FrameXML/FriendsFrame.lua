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
		self.ownerIcon:SetTexture(tex)
	end
end

local function reskinFriendButton(button)
	if not button.styled then
		local gameIcon = button.gameIcon
		gameIcon:SetSize(22, 22)
		gameIcon:SetTexCoord(.17, .83, .17, .83)
		button.background:Hide()
		button:SetHighlightTexture(DB.bdTex)
		button:GetHighlightTexture():SetVertexColor(.24, .56, 1, .2)
		button.bg = B.CreateBDFrame(gameIcon, 0)

		local travelPass = button.travelPassButton
		travelPass:SetSize(22, 22)
		travelPass:SetPoint("TOPRIGHT", -3, -6)
		B.CreateBDFrame(travelPass, 1)
		travelPass.NormalTexture:SetAlpha(0)
		travelPass.PushedTexture:SetAlpha(0)
		travelPass.DisabledTexture:SetAlpha(0)
		travelPass.HighlightTexture:SetColorTexture(1, 1, 1, .25)
		travelPass.HighlightTexture:SetAllPoints()
		gameIcon:SetPoint("TOPRIGHT", travelPass, "TOPLEFT", -4, 0)

		local icon = travelPass:CreateTexture(nil, "ARTWORK")
		icon:SetTexCoord(.1, .9, .1, .9)
		icon:SetAllPoints()
		button.newIcon = icon
		travelPass.NormalTexture.ownerIcon = icon
		hooksecurefunc(travelPass.NormalTexture, "SetAtlas", replaceInviteTex)

		button.styled = true
	end

	button.bg:SetShown(button.gameIcon:IsShown())
end

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	for i = 1, 4 do
		local tab = _G["FriendsFrameTab"..i]
		if tab then
			B.ReskinTab(tab)
			B.ResetTabAnchor(tab)
			if i ~= 1 then
				tab:ClearAllPoints()
				tab:SetPoint("TOPLEFT", _G["FriendsFrameTab"..(i-1)], "TOPRIGHT", -15, 0)
			end
		end
	end
	FriendsFrameIcon:Hide()
	B.StripTextures(IgnoreListFrame)

	local INVITE_RESTRICTION_NONE = 9
	hooksecurefunc("FriendsFrame_UpdateFriendButton", function(button)
		if button.gameIcon then
			reskinFriendButton(button)
		end

		if button.newIcon and button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
			if FriendsFrame_GetInviteRestriction(button.id) == INVITE_RESTRICTION_NONE then
				button.newIcon:SetVertexColor(1, 1, 1)
			else
				button.newIcon:SetVertexColor(.5, .5, .5)
			end
		end
	end)

	hooksecurefunc("FriendsFrame_UpdateFriendInviteButton", function(button)
		if not button.styled then
			B.Reskin(button.AcceptButton)
			B.Reskin(button.DeclineButton)

			button.styled = true
		end
	end)

	hooksecurefunc("FriendsFrame_UpdateFriendInviteHeaderButton", function(button)
		if not button.styled then
			button:DisableDrawLayer("BACKGROUND")
			local bg = B.CreateBDFrame(button, .25)
			bg:SetInside(button, 2, 2)
			local hl = button:GetHighlightTexture()
			hl:SetColorTexture(.24, .56, 1, .2)
			hl:SetInside(bg)

			button.styled = true
		end
	end)

	FriendsFrameStatusDropDown:ClearAllPoints()
	FriendsFrameStatusDropDown:SetPoint("TOPLEFT", FriendsFrame, "TOPLEFT", 10, -28)

	for _, button in pairs({FriendsTabHeaderSoRButton, FriendsTabHeaderRecruitAFriendButton}) do
		button:SetPushedTexture(0)
		button:GetRegions():SetTexCoord(unpack(DB.TexCoord))
		B.CreateBDFrame(button, .25)
	end

	-- FriendsFrameBattlenetFrame

	FriendsFrameBattlenetFrame:GetRegions():Hide()
	local bg = B.CreateBDFrame(FriendsFrameBattlenetFrame, .25)
	bg:SetPoint("TOPLEFT", 0, -2)
	bg:SetPoint("BOTTOMRIGHT", -2, 2)
	bg:SetBackdropColor(0, .6, 1, .25)

	local broadcastButton = FriendsFrameBattlenetFrame.BroadcastButton
	broadcastButton:SetSize(20, 20)
	broadcastButton:GetNormalTexture():SetAlpha(0)
	broadcastButton:GetPushedTexture():SetAlpha(0)
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

	local unavailableFrame = FriendsFrameBattlenetFrame.UnavailableInfoFrame
	B.StripTextures(unavailableFrame)
	B.SetBD(unavailableFrame)
	unavailableFrame:SetPoint("TOPLEFT", FriendsFrame, "TOPRIGHT", 3, -18)

	B.ReskinPortraitFrame(FriendsFrame)
	B.Reskin(FriendsFrameAddFriendButton)
	B.Reskin(FriendsFrameSendMessageButton)
	B.Reskin(FriendsFrameIgnorePlayerButton)
	B.Reskin(FriendsFrameUnsquelchButton)
	B.ReskinTrimScroll(FriendsListFrame.ScrollBar)
	B.ReskinTrimScroll(IgnoreListFrame.ScrollBar)
	B.ReskinTrimScroll(WhoFrame.ScrollBar)
	B.ReskinTrimScroll(FriendsFriendsFrame.ScrollBar)
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