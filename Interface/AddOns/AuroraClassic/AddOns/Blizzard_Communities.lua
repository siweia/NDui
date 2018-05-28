local F, C = unpack(select(2, ...))

C.themes["Blizzard_Communities"] = function()
	local r, g, b = C.r, C.g, C.b
	local frame = CommunitiesFrame

	F.StripTextures(CommunitiesFrame)
	F.SetBD(CommunitiesFrame)
	CommunitiesFrame.PortraitOverlay:SetAlpha(0)
	CommunitiesFrame.MaximizeMinimizeFrame:GetRegions():Hide()
	F.ReskinDropDown(CommunitiesFrame.StreamDropDownMenu)
	F.ReskinClose(CommunitiesFrameCloseButton)
	F.ReskinMinMax(CommunitiesFrame.MaximizeMinimizeFrame)
	CommunitiesFrameInset:Hide()
	F.ReskinArrow(CommunitiesFrame.AddToChatButton, "down")
	F.ReskinDropDown(CommunitiesFrame.CommunitiesListDropDownMenu)

	CommunitiesFrameCommunitiesList.InsetFrame:Hide()
	CommunitiesFrameCommunitiesList.FilligreeOverlay:Hide()
	CommunitiesFrameCommunitiesList.Bg:Hide()
	F.ReskinScroll(CommunitiesFrameCommunitiesListListScrollFrame.ScrollBar)
	CommunitiesFrameCommunitiesListListScrollFrame.ScrollBar.Background:Hide()

	hooksecurefunc(CommunitiesFrameCommunitiesList, "Update", function(self)
		local buttons = self.ListScrollFrame.buttons
		for i = 1, #buttons do
			local button = buttons[i]
			if not button.styled then
				button:GetRegions():Hide()
				local bg = F.CreateBDFrame(button, 0)
				bg:SetPoint("TOPLEFT", 5, -5)
				bg:SetPoint("BOTTOMRIGHT", -10, 5)
				F.CreateGradient(bg)

				local highlight = button:GetHighlightTexture()
				highlight:SetColorTexture(r, g, b, .25)
				highlight:SetAllPoints(bg)

				button.styled = true
			end
		end
	end)

	F.Reskin(CommunitiesFrame.InviteButton)
	F.StripTextures(CommunitiesFrame.Chat.InsetFrame)
	F.CreateBD(CommunitiesFrame.Chat.InsetFrame, .25)
	F.ReskinScroll(CommunitiesFrame.Chat.MessageFrame.ScrollBar)

	F.StripTextures(CommunitiesFrame.MemberList.InsetFrame)
	F.CreateBD(CommunitiesFrame.MemberList.InsetFrame, .25)
	F.ReskinScroll(CommunitiesFrame.MemberList.ListScrollFrame.scrollBar)
	CommunitiesFrame.MemberList.ListScrollFrame.scrollBar.Background:Hide()

	F.StripTextures(CommunitiesFrame.ChatEditBox)
	local bg = F.CreateBDFrame(CommunitiesFrame.ChatEditBox, 0)
	F.CreateGradient(bg)
	bg:SetPoint("TOPLEFT", -2, -5)
	bg:SetPoint("BOTTOMRIGHT", 2, 5)

	for _, name in next, {"ChatTab", "RosterTab"} do
		local tab = CommunitiesFrame[name]
		tab:GetRegions():Hide()
		tab.Icon:SetTexCoord(.08, .92, .08, .92)
		F.CreateBDFrame(tab.Icon)
		tab:SetCheckedTexture(C.media.checked)
		tab:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	end
end