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
	CommunitiesFrame.GuildFinderFrame:GetRegions():Hide()
	CommunitiesFrame.GuildFinderFrame.InsetFrame:Hide()
	F.Reskin(CommunitiesFrame.GuildFinderFrame.FindAGuildButton)

	CommunitiesFrameCommunitiesList.InsetFrame:Hide()
	CommunitiesFrameCommunitiesList.FilligreeOverlay:Hide()
	CommunitiesFrameCommunitiesList.Bg:Hide()
	F.ReskinScroll(CommunitiesFrameCommunitiesListListScrollFrame.ScrollBar)
	CommunitiesFrameCommunitiesListListScrollFrame.ScrollBar.Background:Hide()

	hooksecurefunc(CommunitiesFrameCommunitiesList, "Update", function(self)
		local buttons = self.ListScrollFrame.buttons
		for i = 1, #buttons do
			local button = buttons[i]
			if not button.bg then
				button:GetRegions():Hide()
				button.Selection:SetTexture("")
				button:SetHighlightTexture("")
				button.bg = F.CreateBDFrame(button, 0)
				button.bg:SetPoint("TOPLEFT", 5, -5)
				button.bg:SetPoint("BOTTOMRIGHT", -10, 5)
				F.CreateGradient(button.bg)
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
		tab:GetRegions():Hide()
		tab.Icon:SetTexCoord(.08, .92, .08, .92)
		F.CreateBDFrame(tab.Icon)
		tab:SetCheckedTexture(C.media.checked)
		tab:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	end

	-- ChatTab
	F.Reskin(CommunitiesFrame.InviteButton)
	F.StripTextures(CommunitiesFrame.Chat.InsetFrame)
	do
		local bg = F.CreateBDFrame(CommunitiesFrame.Chat.InsetFrame, .25)
		bg:SetPoint("BOTTOMRIGHT", -1, -3)
	end
	F.ReskinScroll(CommunitiesFrame.Chat.MessageFrame.ScrollBar)
	F.StripTextures(CommunitiesFrame.ChatEditBox)
	do
		local bg = F.CreateBDFrame(CommunitiesFrame.ChatEditBox, 0)
		F.CreateGradient(bg)
		bg:SetPoint("TOPLEFT", -2, -5)
		bg:SetPoint("BOTTOMRIGHT", 2, 5)
	end

	local dialog = CommunitiesFrame.NotificationSettingsDialog
	F.StripTextures(dialog)
	dialog.BG:Hide()
	F.SetBD(dialog)
	F.ReskinDropDown(dialog.CommunitiesListDropDownMenu)
	F.Reskin(dialog.OkayButton)
	F.Reskin(dialog.CancelButton)
	F.ReskinCheck(dialog.ScrollFrame.Child.QuickJoinButton)
	F.Reskin(dialog.ScrollFrame.Child.AllButton)
	F.Reskin(dialog.ScrollFrame.Child.NoneButton)
	F.ReskinScroll(dialog.ScrollFrame.ScrollBar)

	-- Roster
	CommunitiesFrame.MemberList.InsetFrame:Hide()
	F.CreateBDFrame(CommunitiesFrame.MemberList.ListScrollFrame, .25)
	F.StripTextures(CommunitiesFrame.MemberList.ColumnDisplay)
	F.ReskinDropDown(CommunitiesFrame.GuildMemberListDropDownMenu)
	F.ReskinScroll(CommunitiesFrame.MemberList.ListScrollFrame.scrollBar)
	CommunitiesFrame.MemberList.ListScrollFrame.scrollBar.Background:Hide()
	F.Reskin(CommunitiesFrame.CommunitiesControlFrame.GuildControlButton)
	F.Reskin(CommunitiesFrame.CommunitiesControlFrame.GuildRecruitmentButton)

	F.Reskin(CommunitiesFrame.CommunitiesControlFrame.CommunitiesSettingsButton)
	F.StripTextures(CommunitiesSettingsDialog)
	F.SetBD(CommunitiesSettingsDialog)
	F.Reskin(CommunitiesSettingsDialog.ChangeAvatarButton)
	F.Reskin(CommunitiesSettingsDialog.Accept)
	F.Reskin(CommunitiesSettingsDialog.Delete)
	F.Reskin(CommunitiesSettingsDialog.Cancel)
	F.ReskinInput(CommunitiesSettingsDialog.NameEdit)
	F.ReskinInput(CommunitiesSettingsDialog.ShortNameEdit)
	F.StripTextures(CommunitiesSettingsDialog.Description)
	F.CreateBDFrame(CommunitiesSettingsDialog.Description, .25)
	F.StripTextures(CommunitiesSettingsDialog.MessageOfTheDay)
	F.CreateBDFrame(CommunitiesSettingsDialog.MessageOfTheDay, .25)

	local function updateNameFrame(self)
		if not self.expanded then return end
		if not self.bg then
			self.bg = F.CreateBG(self.Class)
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

	hooksecurefunc(CommunitiesFrame.MemberList, "RefreshLayout", function(self)
		for i = 1, self.ColumnDisplay:GetNumChildren() do
			local child = select(i, self.ColumnDisplay:GetChildren())
			if not child.styled then
				F.StripTextures(child)
				F.CreateBDFrame(child, .25)
				child.styled = true
			end
		end

		for _, button in ipairs(self.ListScrollFrame.buttons or {}) do
			if button and not button.hooked then
				hooksecurefunc(button, "RefreshExpandedColumns", updateNameFrame)
				button.hooked = true
			end
			if button and button.bg then
				button.bg:SetShown(button.Class:IsShown())
			end
		end
	end)

	-- Benefits
	CommunitiesFrame.GuildBenefitsFrame.Perks:GetRegions():SetAlpha(0)
	CommunitiesFrame.GuildBenefitsFrame.InsetBorderLeft:SetAlpha(0)
	CommunitiesFrame.GuildBenefitsFrame.InsetBorderRight:SetAlpha(0)
	CommunitiesFrame.GuildBenefitsFrame.Rewards.Bg:SetAlpha(0)
	F.ReskinScroll(CommunitiesFrameRewards.scrollBar)

	hooksecurefunc("CommunitiesGuildPerks_Update", function(self)
		local buttons = self.Container.buttons
		for i = 1, #buttons do
			local button = buttons[i]
			if button and button:IsShown() and not button.bg then
				button.Icon:SetTexCoord(.08, .92, .08, .92)
				F.CreateBG(button.Icon)
				for i = 1, 4 do
					select(i, button:GetRegions()):SetAlpha(0)
				end
				button.bg = F.CreateBDFrame(button, .25)
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
					button.Icon:SetTexCoord(.08, .92, .08, .92)
					F.CreateBG(button.Icon)
					select(6, button:GetRegions()):SetAlpha(0)
					select(7, button:GetRegions()):SetAlpha(0)
					button.bg = F.CreateBDFrame(button, .25)
					button.bg:SetPoint("TOPLEFT", button.Icon, 0, 1)
					button.bg:SetPoint("BOTTOMRIGHT", 0, 3)
				end
				button.DisabledBG:Hide()
			end
		end
	end)

	-- Guild Info
	F.Reskin(CommunitiesFrame.GuildLogButton)
	F.StripTextures(CommunitiesFrameGuildDetailsFrameInfo)
	F.StripTextures(CommunitiesFrameGuildDetailsFrameNews)
	F.ReskinScroll(CommunitiesFrameGuildDetailsFrameInfoMOTDScrollFrameScrollBar)
	do
		local bg = F.CreateBDFrame(CommunitiesFrameGuildDetailsFrameInfoMOTDScrollFrame, .25)
		bg:SetPoint("TOPLEFT", 0, 3)
		bg:SetPoint("BOTTOMRIGHT", 0, -4)
	end
	F.ReskinScroll(CommunitiesFrameGuildDetailsFrameInfoScrollBar)
	F.CreateBDFrame(CommunitiesFrameGuildDetailsFrameInfo.DetailsFrame, .25)
	F.ReskinScroll(CommunitiesFrameGuildDetailsFrameNewsContainer.ScrollBar)
	CommunitiesFrameGuildDetailsFrame.InsetBorderLeft:SetAlpha(0)
	CommunitiesFrameGuildDetailsFrame.InsetBorderRight:SetAlpha(0)
	CommunitiesFrameGuildDetailsFrame.InsetBorderTopLeft:SetAlpha(0)
	CommunitiesFrameGuildDetailsFrame.InsetBorderTopRight:SetAlpha(0)
	CommunitiesFrameGuildDetailsFrame.InsetBorderBottomLeft:SetAlpha(0)
	CommunitiesFrameGuildDetailsFrame.InsetBorderBottomRight:SetAlpha(0)

	hooksecurefunc("CommunitiesGuildNewsButton_SetNews", function(button)
		if button.header:IsShown() then
			button.header:SetAlpha(0)
		end
	end)

	F.StripTextures(CommunitiesGuildNewsFiltersFrame)
	CommunitiesGuildNewsFiltersFrameBg:Hide()
	F.SetBD(CommunitiesGuildNewsFiltersFrame)
	F.ReskinClose(CommunitiesGuildNewsFiltersFrame.CloseButton)
	for _, name in next, {"GuildAchievement", "Achievement", "DungeonEncounter", "EpicItemLooted", "EpicItemPurchased", "EpicItemCrafted", "LegendaryItemLooted"} do
		local filter = CommunitiesGuildNewsFiltersFrame[name]
		F.ReskinCheck(filter)
	end

	F.StripTextures(CommunitiesGuildLogFrame)
	CommunitiesGuildLogFrameBg:Hide()
	F.SetBD(CommunitiesGuildLogFrame)
	F.ReskinClose(CommunitiesGuildLogFrameCloseButton)
	F.ReskinScroll(CommunitiesGuildLogFrameScrollBar)
	F.StripTextures(CommunitiesGuildLogFrame.Container)
	F.CreateBDFrame(CommunitiesGuildLogFrame.Container, .25)
	local closeButton = select(3, CommunitiesGuildLogFrame:GetChildren())
	F.Reskin(closeButton)
end