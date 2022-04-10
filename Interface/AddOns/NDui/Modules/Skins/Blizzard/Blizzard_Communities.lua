local _, ns = ...
local B, C, L, DB = unpack(ns)

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
	B.ReskinDropDown(CommunitiesFrame.StreamDropDownMenu)
	B.StripTextures(CommunitiesFrame.MaximizeMinimizeFrame)
	B.ReskinMinMax(CommunitiesFrame.MaximizeMinimizeFrame)
	B.ReskinArrow(CommunitiesFrame.AddToChatButton, "down")
	B.ReskinDropDown(CommunitiesFrame.CommunitiesListDropDownMenu)

	for i = 1, 5 do
		B.ReskinTab(_G["CommunitiesFrameTab"..i])
	end

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
	B.ReskinScroll(CommunitiesFrameCommunitiesListListScrollFrame.ScrollBar)
	CommunitiesFrameCommunitiesListListScrollFrame.ScrollBar.Background:Hide()

	hooksecurefunc(CommunitiesFrameCommunitiesList, "Update", function(self)
		local buttons = self.ListScrollFrame.buttons
		for i = 1, #buttons do
			local button = buttons[i]
			if not button.bg then
				button.bg = B.CreateBDFrame(button, 0, true)
				button.bg:SetPoint("TOPLEFT", 5, -5)
				button.bg:SetPoint("BOTTOMRIGHT", -10, 5)

				button:SetHighlightTexture("")
				button.IconRing:SetAlpha(0)
				button.__iconBorder = B.ReskinIcon(button.Icon)
				button.Background:Hide()
				button.Selection:SetAlpha(0)
				hooksecurefunc(button.Selection, "SetShown", updateCommunitiesSelection)
			end

			button.CircleMask:Hide()
			button.__iconBorder:SetShown(button.IconRing:IsShown())
		end
	end)

	for _, name in next, {"ChatTab", "RosterTab"} do
		local tab = CommunitiesFrame[name]
		tab:GetRegions():Hide()
		B.ReskinIcon(tab.Icon)
		tab:SetCheckedTexture(DB.textures.pushed)
		local hl = tab:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetAllPoints(tab.Icon)
	end

	-- ChatTab
	B.Reskin(CommunitiesFrame.InviteButton)
	B.StripTextures(CommunitiesFrame.Chat)
	B.ReskinScroll(CommunitiesFrame.Chat.MessageFrame.ScrollBar)
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
		B.ReskinDropDown(dialog.CommunitiesListDropDownMenu)
		B.Reskin(dialog.OkayButton)
		B.Reskin(dialog.CancelButton)
		B.ReskinCheck(dialog.ScrollFrame.Child.QuickJoinButton)
		dialog.ScrollFrame.Child.QuickJoinButton:SetSize(25, 25)
		B.Reskin(dialog.ScrollFrame.Child.AllButton)
		B.Reskin(dialog.ScrollFrame.Child.NoneButton)
		B.ReskinScroll(dialog.ScrollFrame.ScrollBar)
		dialog.ScrollFrame.ScrollBar.Background:Hide()

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
	--B.ReskinDropDown(CommunitiesFrame.GuildMemberListDropDownMenu)
	B.ReskinScroll(CommunitiesFrame.MemberList.ListScrollFrame.scrollBar)
	CommunitiesFrame.MemberList.ListScrollFrame.scrollBar.Background:Hide()
	B.ReskinCheck(CommunitiesFrame.MemberList.ShowOfflineButton)
	CommunitiesFrame.MemberList.ShowOfflineButton:SetSize(25, 25)
	--B.Reskin(CommunitiesFrame.CommunitiesControlFrame.GuildControlButton)
	--B.Reskin(CommunitiesFrame.CommunitiesControlFrame.GuildRecruitmentButton)
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
						avatarButton.bg:SetVertexColor(r, g, b)
					else
						avatarButton.bg:SetVertexColor(0, 0, 0)
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
				B.ClassIconTexCoord(self.Class, classInfo.classFile)
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
end