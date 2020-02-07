local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_Communities"] = function()
	local r, g, b = DB.r, DB.g, DB.b
	local CommunitiesFrame = CommunitiesFrame

	B.ReskinPortraitFrame(CommunitiesFrame)
	CommunitiesFrame.NineSlice:Hide()
	CommunitiesFrame.PortraitOverlay:SetAlpha(0)
	B.ReskinDropDown(CommunitiesFrame.StreamDropDownMenu)
	B.ReskinMinMax(CommunitiesFrame.MaximizeMinimizeFrame)
	B.ReskinArrow(CommunitiesFrame.AddToChatButton, "down")
	B.ReskinDropDown(CommunitiesFrame.CommunitiesListDropDownMenu)

	local function reskinCommunityTab(tab)
		tab:GetRegions():Hide()
		B.ReskinIcon(tab.Icon)
		tab:SetCheckedTexture(DB.textures.pushed)
		local hl = tab:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetAllPoints(tab.Icon)
	end

	local function reskinGuildCards(cards)
		for _, name in pairs({"First", "Second", "Third"}) do
			local guildCard = cards[name.."Card"]
			B.StripTextures(guildCard)
			B.CreateBDFrame(guildCard, .25)
			B.Reskin(guildCard.RequestJoin)
		end
		B.ReskinArrow(cards.PreviousPage, "left")
		B.ReskinArrow(cards.NextPage, "right")
	end

	local function reskinCommunityCards(frame)
		for _, button in next, frame.ListScrollFrame.buttons do
			button.CircleMask:Hide()
			button.LogoBorder:Hide()
			button.Background:Hide()
			B.ReskinIcon(button.CommunityLogo)
			B.Reskin(button)
		end
		B.ReskinScroll(frame.ListScrollFrame.scrollBar)
	end

	local function reskinRequestCheckbox(self)
		for button in self.SpecsPool:EnumerateActive() do
			if button.CheckBox then
				B.ReskinCheck(button.CheckBox)
				button.CheckBox:SetSize(26, 26)
			end
		end
	end

	for _, name in next, {"GuildFinderFrame", "InvitationFrame", "TicketFrame", "CommunityFinderFrame", "ClubFinderInvitationFrame"} do
		local frame = CommunitiesFrame[name]
		if frame then
			B.StripTextures(frame)
			frame.InsetFrame:Hide()
			if frame.CircleMask then
				frame.CircleMask:Hide()
				frame.IconRing:Hide()
				B.ReskinIcon(frame.Icon)
			end
			if frame.FindAGuildButton then B.Reskin(frame.FindAGuildButton) end
			if frame.AcceptButton then B.Reskin(frame.AcceptButton) end
			if frame.DeclineButton then B.Reskin(frame.DeclineButton) end

			local optionsList = frame.OptionsList
			if optionsList then
				B.ReskinDropDown(optionsList.ClubFocusDropdown)
				B.ReskinDropDown(optionsList.ClubSizeDropdown)
				B.ReskinDropDown(optionsList.SortByDropdown)
				B.ReskinRole(optionsList.TankRoleFrame, "TANK")
				B.ReskinRole(optionsList.HealerRoleFrame, "HEALER")
				B.ReskinRole(optionsList.DpsRoleFrame, "DPS")
				B.ReskinInput(optionsList.SearchBox)
				optionsList.SearchBox:SetSize(118, 22)
				B.Reskin(optionsList.Search)
				optionsList.Search:ClearAllPoints()
				optionsList.Search:SetPoint("TOPRIGHT", optionsList.SearchBox, "BOTTOMRIGHT", 0, -2)
			end

			local requestFrame = frame.RequestToJoinFrame
			if requestFrame then
				B.StripTextures(requestFrame)
				B.SetBD(requestFrame)
				B.StripTextures(requestFrame.MessageFrame)
				B.StripTextures(requestFrame.MessageFrame.MessageScroll)
				B.CreateBDFrame(requestFrame.MessageFrame.MessageScroll, .25)
				B.Reskin(requestFrame.Apply)
				B.Reskin(requestFrame.Cancel)
				hooksecurefunc(requestFrame, "Initialize", reskinRequestCheckbox)
			end

			if frame.ClubFinderSearchTab then reskinCommunityTab(frame.ClubFinderSearchTab) end
			if frame.ClubFinderPendingTab then reskinCommunityTab(frame.ClubFinderPendingTab) end
			if frame.GuildCards then reskinGuildCards(frame.GuildCards) end
			if frame.PendingGuildCards then reskinGuildCards(frame.PendingGuildCards) end
			if frame.CommunityCards then reskinCommunityCards(frame.CommunityCards) end
			if frame.PendingCommunityCards then reskinCommunityCards(frame.PendingCommunityCards) end
		end
	end

	B.StripTextures(CommunitiesFrameCommunitiesList)
	CommunitiesFrameCommunitiesList.InsetFrame:Hide()
	CommunitiesFrameCommunitiesList.FilligreeOverlay:Hide()
	B.ReskinScroll(CommunitiesFrameCommunitiesListListScrollFrame.ScrollBar)
	CommunitiesFrameCommunitiesListListScrollFrame.ScrollBar.Background:Hide()

	hooksecurefunc(CommunitiesFrameCommunitiesList, "Update", function(self)
		local buttons = self.ListScrollFrame.buttons
		for i = 1, #buttons do
			local button = buttons[i]
			if not button.bg then
				button:GetRegions():Hide()
				button.Selection:SetAlpha(0)
				button:SetHighlightTexture("")
				button.bg = B.CreateBDFrame(button, 0)
				button.bg:SetPoint("TOPLEFT", 5, -5)
				button.bg:SetPoint("BOTTOMRIGHT", -10, 5)
				B.CreateGradient(button.bg)
			end

			if button.Selection:IsShown() then
				button.bg:SetBackdropColor(r, g, b, .25)
			else
				button.bg:SetBackdropColor(0, 0, 0, 0)
			end
		end
	end)

	for _, name in next, {"ChatTab", "RosterTab", "GuildBenefitsTab", "GuildInfoTab"} do
		local tab = CommunitiesFrame[name]
		reskinCommunityTab(tab)
	end

	-- ChatTab
	B.Reskin(CommunitiesFrame.InviteButton)
	B.StripTextures(CommunitiesFrame.Chat)
	B.ReskinScroll(CommunitiesFrame.Chat.MessageFrame.ScrollBar)
	CommunitiesFrame.ChatEditBox:DisableDrawLayer("BACKGROUND")
	local bg1 = B.CreateBDFrame(CommunitiesFrame.Chat.InsetFrame, .25)
	bg1:SetPoint("TOPLEFT", 1, -3)
	bg1:SetPoint("BOTTOMRIGHT", -3, 22)
	local bg2 = B.CreateBDFrame(CommunitiesFrame.ChatEditBox, 0)
	B.CreateGradient(bg2)
	bg2:SetPoint("TOPLEFT", -5, -5)
	bg2:SetPoint("BOTTOMRIGHT", 4, 5)

	do
		local dialog = CommunitiesFrame.NotificationSettingsDialog
		B.StripTextures(dialog)
		B.SetBD(dialog)
		B.ReskinDropDown(dialog.CommunitiesListDropDownMenu)
		B.Reskin(dialog.OkayButton)
		B.Reskin(dialog.CancelButton)
		B.ReskinCheck(dialog.ScrollFrame.Child.QuickJoinButton)
		dialog.ScrollFrame.Child.QuickJoinButton:SetSize(25, 25)
		B.Reskin(dialog.ScrollFrame.Child.AllButton)
		B.Reskin(dialog.ScrollFrame.Child.NoneButton)
		B.ReskinScroll(dialog.ScrollFrame.ScrollBar)

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
		B.ReskinCheck(dialog.TypeCheckBox)
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
		B.ReskinDropDown(dialog.ExpiresDropDownMenu)
		B.ReskinDropDown(dialog.UsesDropDownMenu)
		B.Reskin(dialog.GenerateLinkButton)

		dialog.InviteManager.ArtOverlay:Hide()
		B.StripTextures(dialog.InviteManager.ColumnDisplay)
		dialog.InviteManager.ListScrollFrame.Background:Hide()
		B.ReskinScroll(dialog.InviteManager.ListScrollFrame.scrollBar)
		dialog.InviteManager.ListScrollFrame.scrollBar.Background:Hide()

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
	B.CreateBDFrame(CommunitiesFrame.MemberList.ListScrollFrame, .25)
	B.StripTextures(CommunitiesFrame.MemberList.ColumnDisplay)
	B.ReskinDropDown(CommunitiesFrame.GuildMemberListDropDownMenu)
	B.ReskinScroll(CommunitiesFrame.MemberList.ListScrollFrame.scrollBar)
	CommunitiesFrame.MemberList.ListScrollFrame.scrollBar.Background:Hide()
	B.ReskinCheck(CommunitiesFrame.MemberList.ShowOfflineButton)
	CommunitiesFrame.MemberList.ShowOfflineButton:SetSize(25, 25)
	B.Reskin(CommunitiesFrame.CommunitiesControlFrame.GuildControlButton)
	B.Reskin(CommunitiesFrame.CommunitiesControlFrame.GuildRecruitmentButton)
	B.Reskin(CommunitiesFrame.CommunitiesControlFrame.CommunitiesSettingsButton)
	B.ReskinDropDown(CommunitiesFrame.CommunityMemberListDropDownMenu)

	local detailFrame = CommunitiesFrame.GuildMemberDetailFrame
	B.StripTextures(detailFrame)
	B.SetBD(detailFrame)
	B.ReskinClose(detailFrame.CloseButton)
	B.Reskin(detailFrame.RemoveButton)
	B.Reskin(detailFrame.GroupInviteButton)
	B.ReskinDropDown(detailFrame.RankDropdown)
	B.StripTextures(detailFrame.NoteBackground)
	B.CreateBDFrame(detailFrame.NoteBackground, .25)
	B.StripTextures(detailFrame.OfficerNoteBackground)
	B.CreateBDFrame(detailFrame.OfficerNoteBackground, .25)
	detailFrame:ClearAllPoints()
	detailFrame:SetPoint("TOPLEFT", CommunitiesFrame, "TOPRIGHT", 34, 0)

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
		B.ReskinCheck(dialog.ShouldListClub.Button)
		B.ReskinCheck(dialog.AutoAcceptApplications.Button)
		B.ReskinCheck(dialog.MaxLevelOnly.Button)
		B.ReskinCheck(dialog.MinIlvlOnly.Button)
		B.ReskinInput(dialog.MinIlvlOnly.EditBox)
		B.ReskinDropDown(ClubFinderFocusDropdown)
		B.ReskinDropDown(ClubFinderLookingForDropdown)
	end

	do
		local dialog = CommunitiesAvatarPickerDialog
		B.StripTextures(dialog)
		B.SetBD(dialog)
		select(9, dialog:GetRegions()):Hide()
		CommunitiesAvatarPickerDialogTop:Hide()
		CommunitiesAvatarPickerDialogMiddle:Hide()
		CommunitiesAvatarPickerDialogBottom:Hide()
		B.ReskinScroll(CommunitiesAvatarPickerDialogScrollBar)
		B.Reskin(dialog.OkayButton)
		B.Reskin(dialog.CancelButton)

		hooksecurefunc(CommunitiesAvatarPickerDialog.ScrollFrame, "Refresh", function(self)
			for i = 1, 5 do
				for j = 1, 6 do
					local avatarButton = self.avatarButtons[i][j]
					if avatarButton:IsShown() and not avatarButton.bg then
						avatarButton.bg = B.ReskinIcon(avatarButton.Icon)
						avatarButton.Selected:SetTexture("")
						avatarButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
					end

					if avatarButton.Selected:IsShown() then
						avatarButton.bg:SetBackdropBorderColor(r, g, b)
					else
						avatarButton.bg:SetBackdropBorderColor(0, 0, 0)
					end
				end
			end
		end)
	end

	local function updateNameFrame(self)
		if not self.expanded then return end
		if not self.bg then
			self.bg = B.CreateBDFrame(self.Class)
		end
		local memberInfo = self:GetMemberInfo()
		if memberInfo and memberInfo.classID then
			local classInfo = C_CreatureInfo.GetClassInfo(memberInfo.classID)
			if classInfo then
				local tcoords = CLASS_ICON_TCOORDS[classInfo.classFile]
				self.Class:SetTexCoord(tcoords[1] + .022, tcoords[2] - .025, tcoords[3] + .022, tcoords[4] - .025)
			end
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

		for _, button in ipairs(self.ListScrollFrame.buttons or {}) do
			if button and not button.hooked then
				hooksecurefunc(button, "RefreshExpandedColumns", updateNameFrame)
				if button.ProfessionHeader then
					local header = button.ProfessionHeader
					for i = 1, 3 do
						select(i, header:GetRegions()):Hide()
					end
					B.CreateBDFrame(header, .45)
					header:SetHighlightTexture(DB.bdTex)
					header:GetHighlightTexture():SetVertexColor(r, g, b, .25)
					B.CreateBDFrame(header.Icon)
				end

				button.hooked = true
			end
			if button and button.bg then
				button.bg:SetShown(button.Class:IsShown())
			end
		end
	end)

	-- Benefits
	CommunitiesFrame.GuildBenefitsFrame.Perks:GetRegions():SetAlpha(0)
	CommunitiesFrame.GuildBenefitsFrame.Rewards.Bg:SetAlpha(0)
	B.StripTextures(CommunitiesFrame.GuildBenefitsFrame)
	B.ReskinScroll(CommunitiesFrameRewards.scrollBar)

	local factionFrameBar = CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar
	B.StripTextures(factionFrameBar)
	B.CreateBDFrame(factionFrameBar, .25)
	factionFrameBar.Progress:SetTexture(DB.bdTex)
	factionFrameBar.Progress:SetAllPoints()

	hooksecurefunc("CommunitiesGuildPerks_Update", function(self)
		local buttons = self.Container.buttons
		for i = 1, #buttons do
			local button = buttons[i]
			if button and button:IsShown() and not button.bg then
				B.ReskinIcon(button.Icon)
				for i = 1, 4 do
					select(i, button:GetRegions()):SetAlpha(0)
				end
				button.bg = B.CreateBDFrame(button, .25)
				button.bg:SetPoint("TOPLEFT", button.Icon)
				button.bg:SetPoint("BOTTOMRIGHT", button.Right)
			end
		end
	end)

	hooksecurefunc("CommunitiesGuildRewards_Update", function(self)
		local buttons = self.RewardsContainer.buttons
		for i = 1, #buttons do
			local button = buttons[i]
			if button then
				if not button.bg then
					B.ReskinIcon(button.Icon)
					select(6, button:GetRegions()):SetAlpha(0)
					select(7, button:GetRegions()):SetAlpha(0)

					button.bg = B.CreateBDFrame(button, .25)
					button.bg:SetPoint("TOPLEFT", button.Icon, -5, 5)
					button.bg:SetPoint("BOTTOMRIGHT", 0, 10)
				end
				button.DisabledBG:Hide()
			end
		end
	end)

	-- Guild Info
	B.Reskin(CommunitiesFrame.GuildLogButton)
	B.StripTextures(CommunitiesFrameGuildDetailsFrameInfo)
	B.StripTextures(CommunitiesFrameGuildDetailsFrameNews)
	B.ReskinScroll(CommunitiesFrameGuildDetailsFrameInfoMOTDScrollFrameScrollBar)
	local bg3 = B.CreateBDFrame(CommunitiesFrameGuildDetailsFrameInfoMOTDScrollFrame, .25)
	bg3:SetPoint("TOPLEFT", 0, 3)
	bg3:SetPoint("BOTTOMRIGHT", -5, -4)

	B.StripTextures(CommunitiesGuildTextEditFrame)
	B.SetBD(CommunitiesGuildTextEditFrame)
	CommunitiesGuildTextEditFrameBg:Hide()
	B.StripTextures(CommunitiesGuildTextEditFrame.Container)
	B.CreateBDFrame(CommunitiesGuildTextEditFrame.Container, .25)
	B.ReskinScroll(CommunitiesGuildTextEditFrameScrollBar)
	B.ReskinClose(CommunitiesGuildTextEditFrameCloseButton)
	B.Reskin(CommunitiesGuildTextEditFrameAcceptButton)
	local closeButton = select(4, CommunitiesGuildTextEditFrame:GetChildren())
	B.Reskin(closeButton)

	B.ReskinScroll(CommunitiesFrameGuildDetailsFrameInfoScrollBar)
	B.CreateBDFrame(CommunitiesFrameGuildDetailsFrameInfo.DetailsFrame, .25)
	B.ReskinScroll(CommunitiesFrameGuildDetailsFrameNewsContainer.ScrollBar)
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
	B.ReskinScroll(CommunitiesGuildLogFrameScrollBar)
	B.StripTextures(CommunitiesGuildLogFrame.Container)
	B.CreateBDFrame(CommunitiesGuildLogFrame.Container, .25)
	local closeButton = select(3, CommunitiesGuildLogFrame:GetChildren())
	B.Reskin(closeButton)

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
		B.StripTextures(dialog.RecruitmentMessageFrame)
		B.StripTextures(dialog.RecruitmentMessageFrame.RecruitmentMessageInput)
		B.ReskinScroll(dialog.RecruitmentMessageFrame.RecruitmentMessageInput.ScrollBar)
		B.ReskinInput(dialog.RecruitmentMessageFrame)
		B.ReskinInput(dialog.MinIlvlOnly.EditBox)
		B.Reskin(dialog.Accept)
		B.Reskin(dialog.Cancel)
	end
end