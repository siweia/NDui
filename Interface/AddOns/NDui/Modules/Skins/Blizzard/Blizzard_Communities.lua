local _, ns = ...
local B, C, L, DB = unpack(ns)

local function updateNameFrame(self)
	if not self.expanded then return end
	if not self.bg then
		self.bg = B.CreateBDFrame(self.Class)
	end
	local memberInfo = self:GetMemberInfo()
	if memberInfo and memberInfo.classID then
		local classInfo = C_CreatureInfo.GetClassInfo(memberInfo.classID)
		if classInfo then
			B.ClassIconTexCoord(self.Class, classInfo.classFile)
		end
	end
end

local function updateCommunitiesSelection(texture, show)
	local button = texture:GetParent()
	if show then
		if texture:GetTexCoord() == 0 then
			button.bg:SetBackdropColor(0, 1, 0, .25)
		else
			button.bg:SetBackdropColor(.51, .773, 1, .25)
		end
	else
		button.bg:SetBackdropColor(0, 0, 0, 0)
	end
end

C.themes["Blizzard_Communities"] = function()
	local r, g, b = DB.r, DB.g, DB.b
	local CommunitiesFrame = CommunitiesFrame

	B.ReskinPortraitFrame(CommunitiesFrame)
	CommunitiesFrame.PortraitOverlay:SetAlpha(0)
	if DB.isNewPatch then
		B.ReskinDropDown(CommunitiesFrame.StreamDropdown)
		B.ReskinDropDown(CommunitiesFrame.CommunitiesListDropdown)
	else
		B.ReskinDropDown(CommunitiesFrame.StreamDropDownMenu)
		B.ReskinDropDown(CommunitiesFrame.CommunitiesListDropDownMenu)
	end
	B.StripTextures(CommunitiesFrame.MaximizeMinimizeFrame)
	B.ReskinMinMax(CommunitiesFrame.MaximizeMinimizeFrame)
	CommunitiesFrame.MaximizeMinimizeFrame.MinimizeButton:SetDisabledTexture(0)
	B.ReskinArrow(CommunitiesFrame.AddToChatButton, "down")

	for _, name in next, {"InvitationFrame", "TicketFrame"} do
		local frame = CommunitiesFrame[name]
		B.StripTextures(frame)
		B.CreateBDFrame(frame, .25)
		frame.InsetFrame:Hide()
		if frame.CircleMask then
			frame.CircleMask:Hide()
			B.ReskinIcon(frame.Icon)
		end
		if frame.FindAGuildButton then B.Reskin(frame.FindAGuildButton) end
		if frame.AcceptButton then B.Reskin(frame.AcceptButton) end
		if frame.DeclineButton then B.Reskin(frame.DeclineButton) end

		local optionsList = frame.OptionsList
		if optionsList then
			B.ReskinDropDown(optionsList.ClubFocusDropdown)
			optionsList.ClubFocusDropdown.GuildFocusDropdownLabel:SetWidth(150)
			B.ReskinDropDown(optionsList.ClubSizeDropdown)
			B.ReskinRole(optionsList.TankRoleFrame, "TANK")
			B.ReskinRole(optionsList.HealerRoleFrame, "HEALER")
			B.ReskinRole(optionsList.DpsRoleFrame, "DPS")
			B.ReskinInput(optionsList.SearchBox)
			optionsList.SearchBox:SetSize(118, 22)
			B.Reskin(optionsList.Search)
			optionsList.Search:ClearAllPoints()
			optionsList.Search:SetPoint("TOPRIGHT", optionsList.SearchBox, "BOTTOMRIGHT", 0, -2)
			B.Reskin(frame.PendingClubs)
		end
	end

	B.StripTextures(CommunitiesFrameCommunitiesList)
	CommunitiesFrameCommunitiesList.InsetFrame:Hide()
	CommunitiesFrameCommunitiesList.FilligreeOverlay:Hide()

	B.StripTextures(ClubFinderGuildFinderFrame.DisabledFrame)
	B.ReskinTrimScroll(CommunitiesFrameCommunitiesList.ScrollBar)

	hooksecurefunc(CommunitiesFrameCommunitiesList.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if not child.bg then
				child.bg = B.CreateBDFrame(child, 0, true)
				child.bg:SetPoint("TOPLEFT", 5, -5)
				child.bg:SetPoint("BOTTOMRIGHT", -10, 5)

				child:SetHighlightTexture(0)
				child.IconRing:SetAlpha(0)
				child.__iconBorder = B.ReskinIcon(child.Icon)
				child.Background:Hide()
				child.Selection:SetAlpha(0)
				hooksecurefunc(child.Selection, "SetShown", updateCommunitiesSelection)
			end

			child.CircleMask:Hide()
			child.__iconBorder:SetShown(child.IconRing:IsShown())
		end
	end)

	for _, name in next, {"ChatTab", "RosterTab", "GuildBenefitsTab", "GuildInfoTab"} do
		local tab = CommunitiesFrame[name]
		if tab then
			tab:GetRegions():Hide()
			B.ReskinIcon(tab.Icon)
			tab:SetCheckedTexture(DB.pushedTex)
			local hl = tab:GetHighlightTexture()
			hl:SetColorTexture(1, 1, 1, .25)
			hl:SetAllPoints(tab.Icon)
		end
	end

	-- ChatTab
	B.Reskin(CommunitiesFrame.InviteButton)
	B.StripTextures(CommunitiesFrame.Chat)
	B.ReskinTrimScroll(CommunitiesFrame.Chat.ScrollBar)
	CommunitiesFrame.ChatEditBox:DisableDrawLayer("BACKGROUND")
	local bg1 = B.CreateBDFrame(CommunitiesFrame.Chat.InsetFrame, .25)
	bg1:SetPoint("TOPLEFT", 1, -3)
	bg1:SetPoint("BOTTOMRIGHT", -3, 22)
	local bg2 = B.CreateBDFrame(CommunitiesFrame.ChatEditBox, 0, true)
	bg2:SetPoint("TOPLEFT", -5, -5)
	bg2:SetPoint("BOTTOMRIGHT", 4, 5)

	do
		local dialog = CommunitiesFrame.NotificationSettingsDialog
		B.StripTextures(dialog)
		dialog.BG:Hide()
		B.SetBD(dialog)
		if DB.isNewPatch then
			B.ReskinDropDown(dialog.CommunitiesListDropdown)
		else
			B.ReskinDropDown(dialog.CommunitiesListDropDownMenu)
		end
		if dialog.Selector then
			B.StripTextures(dialog.Selector)
			B.Reskin(dialog.Selector.OkayButton)
			B.Reskin(dialog.Selector.CancelButton)
		end
		B.ReskinCheck(dialog.ScrollFrame.Child.QuickJoinButton)
		dialog.ScrollFrame.Child.QuickJoinButton:SetSize(25, 25)
		B.Reskin(dialog.ScrollFrame.Child.AllButton)
		B.Reskin(dialog.ScrollFrame.Child.NoneButton)
		B.ReskinTrimScroll(dialog.ScrollFrame.ScrollBar)

		hooksecurefunc(dialog, "Refresh", function(self)
			local frame = self.ScrollFrame.Child
			for i = 1, frame:GetNumChildren() do
				local child = select(i, frame:GetChildren())
				if child.StreamName and not child.styled then
					B.ReskinRadio(child.ShowNotificationsButton)
					B.ReskinRadio(child.HideNotificationsButton)

					child.styled = true
				end
			end
		end)
	end

	do
		local dialog = CommunitiesFrame.EditStreamDialog
		B.StripTextures(dialog)
		B.SetBD(dialog)
		dialog.NameEdit:DisableDrawLayer("BACKGROUND")
		local bg = B.CreateBDFrame(dialog.NameEdit, .25)
		bg:SetPoint("TOPLEFT", -3, -3)
		bg:SetPoint("BOTTOMRIGHT", -4, 3)
		B.StripTextures(dialog.Description)
		B.CreateBDFrame(dialog.Description, .25)
		if DB.isNewPatch then
			B.ReskinCheck(dialog.TypeCheckbox)
		else
			B.ReskinCheck(dialog.TypeCheckBox)
		end
		B.Reskin(dialog.Accept)
		B.Reskin(dialog.Delete)
		B.Reskin(dialog.Cancel)
	end

	do
		local dialog = CommunitiesTicketManagerDialog
		B.StripTextures(dialog)
		B.SetBD(dialog)
		dialog.Background:Hide()
		B.Reskin(dialog.LinkToChat)
		B.Reskin(dialog.Copy)
		B.Reskin(dialog.Close)
		B.ReskinArrow(dialog.MaximizeButton, "down")
		if DB.isNewPatch then
			B.ReskinDropDown(dialog.ExpiresDropdown)
			B.ReskinDropDown(dialog.UsesDropdown)
		else
			B.ReskinDropDown(dialog.ExpiresDropDownMenu)
			B.ReskinDropDown(dialog.UsesDropDownMenu)
		end
		B.Reskin(dialog.GenerateLinkButton)

		dialog.InviteManager.ArtOverlay:Hide()
		B.StripTextures(dialog.InviteManager.ColumnDisplay)
		dialog.InviteManager.ScrollBar:GetChildren():Hide()
		B.ReskinTrimScroll(dialog.InviteManager.ScrollBar)

		hooksecurefunc(dialog, "Update", function(self)
			local column = self.InviteManager.ColumnDisplay
			for i = 1, column:GetNumChildren() do
				local child = select(i, column:GetChildren())
				if not child.styled then
					B.StripTextures(child)
					B.CreateBDFrame(child, .25)

					child.styled = true
				end
			end

			local buttons = self.InviteManager.ListScrollFrame.buttons
			for i = 1, #buttons do
				local button = buttons[i]
				if not button.styled then
					B.Reskin(button.CopyLinkButton)
					button.CopyLinkButton.Background:Hide()
					B.Reskin(button.RevokeButton)
					button.RevokeButton:SetSize(18, 18)

					button.styled = true
				end
			end
		end)
	end

	-- Roster
	CommunitiesFrame.MemberList.InsetFrame:Hide()
	B.StripTextures(CommunitiesFrame.MemberList.ColumnDisplay)
	if DB.isNewPatch then
		B.ReskinDropDown(CommunitiesFrame.GuildMemberListDropdown)
	else
		B.ReskinDropDown(CommunitiesFrame.GuildMemberListDropDownMenu)
	end
	CommunitiesFrame.MemberList.ScrollBar:GetChildren():Hide()
	B.ReskinTrimScroll(CommunitiesFrame.MemberList.ScrollBar)
	B.Reskin(CommunitiesFrame.CommunitiesControlFrame.GuildControlButton)
	B.Reskin(CommunitiesFrame.CommunitiesControlFrame.GuildRecruitmentButton)

	hooksecurefunc(CommunitiesFrame.MemberList.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if not child.styled then
				hooksecurefunc(child, "RefreshExpandedColumns", updateNameFrame)
				child.styled = true
			end

			local header = child.ProfessionHeader
			if header and not header.styled then
				for i = 1, 3 do
					select(i, header:GetRegions()):Hide()
				end
				header.bg = B.CreateBDFrame(header, .25)
				header.bg:SetInside()
				header:SetHighlightTexture(DB.bdTex)
				header:GetHighlightTexture():SetVertexColor(r, g, b, .25)
				header:GetHighlightTexture():SetInside(header.bg)
				B.CreateBDFrame(header.Icon)
				header.styled = true
			end

			if child and child.bg then
				child.bg:SetShown(child.Class:IsShown())
			end
		end
	end)
	B.ReskinCheck(CommunitiesFrame.MemberList.ShowOfflineButton)
	CommunitiesFrame.MemberList.ShowOfflineButton:SetSize(25, 25)
	B.Reskin(CommunitiesFrame.CommunitiesControlFrame.CommunitiesSettingsButton)

	do
		local dialog = CommunitiesSettingsDialog
		B.StripTextures(dialog)
		B.SetBD(dialog)
		B.Reskin(dialog.ChangeAvatarButton)
		B.Reskin(dialog.Accept)
		B.Reskin(dialog.Delete)
		B.Reskin(dialog.Cancel)
		B.ReskinInput(dialog.NameEdit)
		B.ReskinInput(dialog.ShortNameEdit)
		B.StripTextures(dialog.Description)
		B.CreateBDFrame(dialog.Description, .25)
		B.StripTextures(dialog.MessageOfTheDay)
		B.CreateBDFrame(dialog.MessageOfTheDay, .25)
	end

	do
		local dialog = CommunitiesAvatarPickerDialog
		B.StripTextures(dialog)
		B.SetBD(dialog)
		B.ReskinTrimScroll(CommunitiesAvatarPickerDialog.ScrollBar)
		if dialog.Selector then
			B.StripTextures(dialog.Selector)
			B.Reskin(dialog.Selector.OkayButton)
			B.Reskin(dialog.Selector.CancelButton)
		end
	end

	hooksecurefunc(CommunitiesFrame.MemberList, "RefreshListDisplay", function(self)
		for i = 1, self.ColumnDisplay:GetNumChildren() do
			local child = select(i, self.ColumnDisplay:GetChildren())
			if not child.styled then
				B.StripTextures(child)
				B.CreateBDFrame(child, .25)

				child.styled = true
			end
		end
	end)

	-- Benefits
	CommunitiesFrame.GuildBenefitsFrame.Perks:GetRegions():SetAlpha(0)
	CommunitiesFrame.GuildBenefitsFrame.Rewards.Bg:SetAlpha(0)
	B.StripTextures(CommunitiesFrame.GuildBenefitsFrame)
	B.ReskinTrimScroll(CommunitiesFrame.GuildBenefitsFrame.Perks.ScrollBar)
	B.ReskinTrimScroll(CommunitiesFrame.GuildBenefitsFrame.Rewards.ScrollBar)

	local function handleRewardButton(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if not child.styled then
				local iconbg = B.ReskinIcon(child.Icon)
				B.StripTextures(child)
				child.bg = B.CreateBDFrame(child, .25)
				child.bg:ClearAllPoints()
				child.bg:SetPoint("TOPLEFT", iconbg)
				child.bg:SetPoint("BOTTOMLEFT", iconbg)
				child.bg:SetWidth(child:GetWidth()-5)

				child.styled = true
			end
		end
	end
	hooksecurefunc(CommunitiesFrame.GuildBenefitsFrame.Perks.ScrollBox, "Update", handleRewardButton)
	hooksecurefunc(CommunitiesFrame.GuildBenefitsFrame.Rewards.ScrollBox, "Update", handleRewardButton)

	local factionFrameBar = CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar
	B.StripTextures(factionFrameBar)
	local bg = B.CreateBDFrame(factionFrameBar, .25)
	factionFrameBar.Progress:SetTexture(DB.bdTex)
	bg:SetOutside(factionFrameBar.Progress)

	-- Guild Info
	B.Reskin(CommunitiesFrame.GuildLogButton)
	B.StripTextures(CommunitiesFrameGuildDetailsFrameInfo)
	B.StripTextures(CommunitiesFrameGuildDetailsFrameNews)
	B.ReskinTrimScroll(CommunitiesFrameGuildDetailsFrameInfoMOTDScrollFrame.ScrollBar)
	local bg3 = B.CreateBDFrame(CommunitiesFrameGuildDetailsFrameInfoMOTDScrollFrame, .25)
	bg3:SetPoint("TOPLEFT", 0, 3)
	bg3:SetPoint("BOTTOMRIGHT", -5, -4)

	B.StripTextures(CommunitiesGuildTextEditFrame)
	B.SetBD(CommunitiesGuildTextEditFrame)
	CommunitiesGuildTextEditFrameBg:Hide()
	B.StripTextures(CommunitiesGuildTextEditFrame.Container)
	B.CreateBDFrame(CommunitiesGuildTextEditFrame.Container, .25)
	B.ReskinTrimScroll(CommunitiesGuildTextEditFrame.Container.ScrollFrame.ScrollBar)
	B.ReskinClose(CommunitiesGuildTextEditFrameCloseButton)
	B.Reskin(CommunitiesGuildTextEditFrameAcceptButton)
	local closeButton = select(4, CommunitiesGuildTextEditFrame:GetChildren())
	B.Reskin(closeButton)

	B.ReskinTrimScroll(CommunitiesFrameGuildDetailsFrameInfo.DetailsFrame.ScrollBar)
	B.CreateBDFrame(CommunitiesFrameGuildDetailsFrameInfo.DetailsFrame, .25)
	CommunitiesFrameGuildDetailsFrameNews.ScrollBar:GetChildren():Hide()
	B.ReskinTrimScroll(CommunitiesFrameGuildDetailsFrameNews.ScrollBar)
	B.StripTextures(CommunitiesFrameGuildDetailsFrame)

	hooksecurefunc("GuildNewsButton_SetNews", function(button)
		if button.header:IsShown() then
			button.header:SetAlpha(0)
		end
	end)

	B.StripTextures(CommunitiesGuildNewsFiltersFrame)
	CommunitiesGuildNewsFiltersFrameBg:Hide()
	B.SetBD(CommunitiesGuildNewsFiltersFrame)
	B.ReskinClose(CommunitiesGuildNewsFiltersFrame.CloseButton)
	for _, name in next, {"GuildAchievement", "Achievement", "DungeonEncounter", "EpicItemLooted", "EpicItemPurchased", "EpicItemCrafted", "LegendaryItemLooted"} do
		local filter = CommunitiesGuildNewsFiltersFrame[name]
		B.ReskinCheck(filter)
	end

	B.StripTextures(CommunitiesGuildLogFrame)
	CommunitiesGuildLogFrameBg:Hide()
	B.SetBD(CommunitiesGuildLogFrame)
	B.ReskinClose(CommunitiesGuildLogFrameCloseButton)
	B.ReskinTrimScroll(CommunitiesGuildLogFrame.Container.ScrollFrame.ScrollBar)
	B.StripTextures(CommunitiesGuildLogFrame.Container)
	B.CreateBDFrame(CommunitiesGuildLogFrame.Container, .25)
	local closeButton = select(3, CommunitiesGuildLogFrame:GetChildren())
	B.Reskin(closeButton)

	local bossModel = CommunitiesFrameGuildDetailsFrameNews.BossModel
	B.StripTextures(bossModel)
	bossModel:ClearAllPoints()
	bossModel:SetPoint("LEFT", CommunitiesFrame, "RIGHT", 40, 0)
	local textFrame = bossModel.TextFrame
	B.StripTextures(textFrame)
	local bg = B.SetBD(bossModel)
	bg:SetOutside(bossModel, nil, nil, textFrame)

	-- Recruitment dialog
	do
		local dialog = CommunitiesFrame.RecruitmentDialog
		B.StripTextures(dialog)
		B.SetBD(dialog)
		B.ReskinCheck(dialog.ShouldListClub.Button)
		B.ReskinCheck(dialog.MaxLevelOnly.Button)
		B.ReskinCheck(dialog.MinIlvlOnly.Button)
		B.ReskinDropDown(dialog.ClubFocusDropdown)
		B.ReskinDropDown(dialog.LookingForDropdown)
		B.ReskinDropDown(dialog.LanguageDropdown)
		B.StripTextures(dialog.RecruitmentMessageFrame)
		B.StripTextures(dialog.RecruitmentMessageFrame.RecruitmentMessageInput)
		B.ReskinTrimScroll(dialog.RecruitmentMessageFrame.RecruitmentMessageInput.ScrollBar)
		B.ReskinInput(dialog.RecruitmentMessageFrame)
		B.ReskinInput(dialog.MinIlvlOnly.EditBox)
		B.Reskin(dialog.Accept)
		B.Reskin(dialog.Cancel)
	end

	-- ApplicantList
	local applicantList = CommunitiesFrame.ApplicantList
	B.StripTextures(applicantList)
	B.StripTextures(applicantList.ColumnDisplay)

	local listBG = B.CreateBDFrame(applicantList, .25)
	listBG:SetPoint("TOPLEFT", 0, 0)
	listBG:SetPoint("BOTTOMRIGHT", -15, 0)

	local function reskinApplicant(button)
		if button.styled then return end

		button:SetPoint("LEFT", listBG, C.mult, 0)
		button:SetPoint("RIGHT", listBG, -C.mult, 0)
		button:SetHighlightTexture(DB.bdTex)
		button:GetHighlightTexture():SetVertexColor(r, g, b, .25)
		button.InviteButton:SetSize(66, 18)
		button.CancelInvitationButton:SetSize(20, 18)

		B.Reskin(button.InviteButton)
		B.Reskin(button.CancelInvitationButton)
		hooksecurefunc(button, "UpdateMemberInfo", updateMemberName)

		UpdateRoleTexture(button.RoleIcon1)
		UpdateRoleTexture(button.RoleIcon2)
		UpdateRoleTexture(button.RoleIcon3)
		button.styled = true
	end

	hooksecurefunc(applicantList, "BuildList", function(self)
		local columnDisplay = self.ColumnDisplay
		for i = 1, columnDisplay:GetNumChildren() do
			local child = select(i, columnDisplay:GetChildren())
			if not child.styled then
				B.StripTextures(child)

				local bg = B.CreateBDFrame(child, .25)
				bg:SetPoint("TOPLEFT", 4, -2)
				bg:SetPoint("BOTTOMRIGHT", 0, 2)

				child:SetHighlightTexture(DB.bdTex)
				local hl = child:GetHighlightTexture()
				hl:SetVertexColor(r, g, b, .25)
				hl:SetInside(bg)

				child.styled = true
			end
		end
	end)

	applicantList.ScrollBar:GetChildren():Hide()
	B.ReskinTrimScroll(applicantList.ScrollBar)

	hooksecurefunc(applicantList.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local button = select(i, self.ScrollTarget:GetChildren())
			reskinApplicant(button)
		end
	end)
end