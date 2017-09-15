local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	local r, g, b = C.r, C.g, C.b

	local LFGListFrame = LFGListFrame

	-- [[ Category selection ]]

	local CategorySelection = LFGListFrame.CategorySelection

	CategorySelection.Inset.Bg:Hide()
	select(10, CategorySelection.Inset:GetRegions()):Hide()
	CategorySelection.Inset:DisableDrawLayer("BORDER")

	F.Reskin(CategorySelection.FindGroupButton)
	F.Reskin(CategorySelection.StartGroupButton)

	CategorySelection.CategoryButtons[1]:SetNormalFontObject(GameFontNormal)

	hooksecurefunc("LFGListCategorySelection_AddButton", function(self, btnIndex)
		local bu = self.CategoryButtons[btnIndex]

		if bu and not bu.styled then
			bu.Cover:Hide()

			bu.Icon:SetDrawLayer("BACKGROUND", 1)
			bu.Icon:SetTexCoord(.01, .99, .01, .99)

			local bg = F.CreateBG(bu)
			bg:SetPoint("TOPLEFT", bu.Icon, -1.2, 1.2)
			bg:SetPoint("BOTTOMRIGHT", bu.Icon, 1.2, -1.2)

			bu.styled = true
		end
	end)

	-- [[ Nothing available ]]

	local NothingAvailable = LFGListFrame.NothingAvailable

	NothingAvailable.Inset:DisableDrawLayer("BORDER")

	-- [[ Search panel ]]

	local SearchPanel = LFGListFrame.SearchPanel

	SearchPanel.ResultsInset.Bg:Hide()
	SearchPanel.ResultsInset:DisableDrawLayer("BORDER")

	F.Reskin(SearchPanel.RefreshButton)
	F.Reskin(SearchPanel.BackButton)
	F.Reskin(SearchPanel.SignUpButton)
	F.Reskin(SearchPanel.ScrollFrame.StartGroupButton)
	F.ReskinInput(SearchPanel.SearchBox)
	F.ReskinScroll(SearchPanel.ScrollFrame.scrollBar)

	SearchPanel.RefreshButton:SetSize(24, 24)
	SearchPanel.RefreshButton.Icon:SetPoint("CENTER")

	-- Auto complete frame

	SearchPanel.AutoCompleteFrame.BottomLeftBorder:Hide()
	SearchPanel.AutoCompleteFrame.BottomRightBorder:Hide()
	SearchPanel.AutoCompleteFrame.BottomBorder:Hide()
	SearchPanel.AutoCompleteFrame.LeftBorder:Hide()
	SearchPanel.AutoCompleteFrame.RightBorder:Hide()

	local function resultOnEnter(self)
		self.hl:Show()
	end

	local function resultOnLeave(self)
		self.hl:Hide()
	end

	local numResults = 1
	hooksecurefunc("LFGListSearchPanel_UpdateAutoComplete", function(self)
		local AutoCompleteFrame = self.AutoCompleteFrame

		for i = numResults, #AutoCompleteFrame.Results do
			local result = AutoCompleteFrame.Results[i]

			if numResults == 1 then
				result:SetPoint("TOPLEFT", AutoCompleteFrame.LeftBorder, "TOPRIGHT", -8, 1)
				result:SetPoint("TOPRIGHT", AutoCompleteFrame.RightBorder, "TOPLEFT", 5, 1)
			else
				result:SetPoint("TOPLEFT", AutoCompleteFrame.Results[i-1], "BOTTOMLEFT", 0, 1)
				result:SetPoint("TOPRIGHT", AutoCompleteFrame.Results[i-1], "BOTTOMRIGHT", 0, 1)
			end

			result:SetNormalTexture("")
			result:SetPushedTexture("")
			result:SetHighlightTexture("")

			local hl = result:CreateTexture(nil, "BACKGROUND")
			hl:SetAllPoints()
			hl:SetTexture(C.media.backdrop)
			hl:SetVertexColor(r, g, b, .2)
			hl:Hide()
			result.hl = hl

			F.CreateBD(result, .5)

			result:HookScript("OnEnter", resultOnEnter)
			result:HookScript("OnLeave", resultOnLeave)

			numResults = numResults + 1
		end
	end)

	-- [[ Application viewer ]]

	local ApplicationViewer = LFGListFrame.ApplicationViewer

	ApplicationViewer.InfoBackground:Hide()

	ApplicationViewer.Inset.Bg:Hide()
	ApplicationViewer.Inset:DisableDrawLayer("BORDER")

	local function headerOnEnter(self)
		self.hl:Show()
	end

	local function headerOnLeave(self)
		self.hl:Hide()
	end

	for _, headerName in pairs({"NameColumnHeader", "RoleColumnHeader", "ItemLevelColumnHeader"}) do
		local header = ApplicationViewer[headerName]
		header.Left:Hide()
		header.Middle:Hide()
		header.Right:Hide()
		header.Label:SetFont(C.media.font, 14, "OUTLINE")
		header.Label:SetShadowColor(0, 0, 0, 0)
		header:SetHighlightTexture("")

		local hl = header:CreateTexture(nil, "BACKGROUND")
		hl:SetAllPoints()
		hl:SetTexture(C.media.backdrop)
		hl:SetVertexColor(r, g, b, .2)
		hl:Hide()
		header.hl = hl

		F.CreateBD(header, .25)

		header:HookScript("OnEnter", headerOnEnter)
		header:HookScript("OnLeave", headerOnLeave)
	end

	ApplicationViewer.RoleColumnHeader:SetPoint("LEFT", ApplicationViewer.NameColumnHeader, "RIGHT", 1, 0)
	ApplicationViewer.ItemLevelColumnHeader:SetPoint("LEFT", ApplicationViewer.RoleColumnHeader, "RIGHT", 1, 0)

	F.Reskin(ApplicationViewer.RefreshButton)
	F.Reskin(ApplicationViewer.RemoveEntryButton)
	F.Reskin(ApplicationViewer.EditButton)
	F.ReskinScroll(LFGListApplicationViewerScrollFrameScrollBar)

	ApplicationViewer.RefreshButton:SetSize(24, 24)
	ApplicationViewer.RefreshButton.Icon:SetPoint("CENTER")

	-- [[ Entry creation ]]

	local EntryCreation = LFGListFrame.EntryCreation

	EntryCreation.Inset.Bg:Hide()
	select(10, EntryCreation.Inset:GetRegions()):Hide()
	EntryCreation.Inset:DisableDrawLayer("BORDER")

	for i = 1, 9 do
		select(i, EntryCreation.Description:GetRegions()):Hide()
	end

	F.Reskin(EntryCreation.ListGroupButton)
	F.Reskin(EntryCreation.CancelButton)
	F.CreateBD(EntryCreation.Description, 0)
	F.CreateGradient(EntryCreation.Description)
	F.ReskinInput(EntryCreation.Name)
	F.ReskinInput(EntryCreation.ItemLevel.EditBox)
	F.ReskinInput(EntryCreation.VoiceChat.EditBox)
	F.ReskinDropDown(EntryCreation.CategoryDropDown)
	F.ReskinDropDown(EntryCreation.GroupDropDown)
	F.ReskinDropDown(EntryCreation.ActivityDropDown)
	F.ReskinCheck(EntryCreation.ItemLevel.CheckButton)
	F.ReskinCheck(EntryCreation.VoiceChat.CheckButton)
	F.ReskinCheck(EntryCreation.PrivateGroup.CheckButton)
	F.ReskinCheck(LFGListFrame.ApplicationViewer.AutoAcceptButton)

	-- [[ Role count ]]

	hooksecurefunc("LFGListGroupDataDisplayRoleCount_Update", function(self)
		if not self.styled then
			for _, roleButton in pairs({self.TankIcon, self.HealerIcon, self.DamagerIcon}) do
				roleButton:SetTexture(C.media.roleIcons)

				local left = self:CreateTexture(nil, "OVERLAY")
				left:SetWidth(1.2)
				left:SetTexture(C.media.backdrop)
				left:SetVertexColor(0, 0, 0)

				local right = self:CreateTexture(nil, "OVERLAY")
				right:SetWidth(1.2)
				right:SetTexture(C.media.backdrop)
				right:SetVertexColor(0, 0, 0)

				local top = self:CreateTexture(nil, "OVERLAY")
				top:SetHeight(1.2)
				top:SetTexture(C.media.backdrop)
				top:SetVertexColor(0, 0, 0)

				local bottom = self:CreateTexture(nil, "OVERLAY")
				bottom:SetHeight(1.2)
				bottom:SetTexture(C.media.backdrop)
				bottom:SetVertexColor(0, 0, 0)

				if roleButton == self.TankIcon then
					roleButton:SetTexCoord(0, .24, .25, .5)

					left:SetPoint("TOPLEFT", roleButton, 2, -3)
					left:SetPoint("BOTTOMLEFT", roleButton, 2, 1)
					right:SetPoint("TOPRIGHT", roleButton, -1, -3)
					right:SetPoint("BOTTOMRIGHT", roleButton, -1, 1)
					top:SetPoint("TOPLEFT", roleButton, 2, -2)
					top:SetPoint("TOPRIGHT", roleButton, -1, -2)
					bottom:SetPoint("BOTTOMLEFT", roleButton, 2, 1)
					bottom:SetPoint("BOTTOMRIGHT", roleButton, -1, 1)
				elseif roleButton == self.HealerIcon then
					roleButton:SetTexCoord(.249, .5, 0.003, .243)

					left:SetPoint("TOPLEFT", roleButton, 2, -1)
					left:SetPoint("BOTTOMLEFT", roleButton, 2, 1)
					right:SetPoint("TOPRIGHT", roleButton, -1, -1)
					right:SetPoint("BOTTOMRIGHT", roleButton, -1, 1)
					top:SetPoint("TOPLEFT", roleButton, 2, -1)
					top:SetPoint("TOPRIGHT", roleButton, -1, -1)
					bottom:SetPoint("BOTTOMLEFT", roleButton, 2, 1)
					bottom:SetPoint("BOTTOMRIGHT", roleButton, -1, 1)
				else
					roleButton:SetTexCoord(.25, .5, .25, .5)

					left:SetPoint("TOPLEFT", roleButton, 2, -3)
					left:SetPoint("BOTTOMLEFT", roleButton, 2, 1)
					right:SetPoint("TOPRIGHT", roleButton, -1, -3)
					right:SetPoint("BOTTOMRIGHT", roleButton, -1, 1)
					top:SetPoint("TOPLEFT", roleButton, 2, -2)
					top:SetPoint("TOPRIGHT", roleButton, -1, -2)
					bottom:SetPoint("BOTTOMLEFT", roleButton, 2, 1)
					bottom:SetPoint("BOTTOMRIGHT", roleButton, -1, 1)
				end
			end

			self.styled = true
		end
	end)

	-- Activity finder

	local ActivityFinder = EntryCreation.ActivityFinder

	ActivityFinder.Background:SetTexture("")
	ActivityFinder.Dialog.Bg:Hide()
	for i = 1, 9 do
		select(i, ActivityFinder.Dialog.BorderFrame:GetRegions()):Hide()
	end

	F.CreateBD(ActivityFinder.Dialog)
	ActivityFinder.Dialog:SetBackdropColor(.2, .2, .2, .9)

	F.Reskin(ActivityFinder.Dialog.SelectButton)
	F.Reskin(ActivityFinder.Dialog.CancelButton)
	F.ReskinInput(ActivityFinder.Dialog.EntryBox)
	F.ReskinScroll(LFGListEntryCreationSearchScrollFrameScrollBar)

	-- [[ Application dialog ]]

	local LFGListApplicationDialog = LFGListApplicationDialog

	for i = 1, 9 do
		select(i, LFGListApplicationDialog.Description:GetRegions()):Hide()
	end

	F.CreateBD(LFGListApplicationDialog)
	F.CreateSD(LFGListApplicationDialog)
	F.CreateBD(LFGListApplicationDialog.Description, .25)
	F.Reskin(LFGListApplicationDialog.SignUpButton)
	F.Reskin(LFGListApplicationDialog.CancelButton)

	-- [[ Invite dialog ]]

	local LFGListInviteDialog = LFGListInviteDialog

	F.CreateBD(LFGListInviteDialog)
	F.CreateSD(LFGListInviteDialog)
	F.Reskin(LFGListInviteDialog.AcceptButton)
	F.Reskin(LFGListInviteDialog.DeclineButton)
	F.Reskin(LFGListInviteDialog.AcknowledgeButton)

	do
		local RoleIcon = LFGListInviteDialog.RoleIcon

		RoleIcon:SetTexture(C.media.roleIcons)

		local left = LFGListInviteDialog:CreateTexture(nil, "OVERLAY")
		left:SetWidth(1.2)
		left:SetTexture(C.media.backdrop)
		left:SetVertexColor(0, 0, 0)
		left:SetPoint("TOPLEFT", RoleIcon, 8, -6)
		left:SetPoint("BOTTOMLEFT", RoleIcon, 8, 10)

		local right = LFGListInviteDialog:CreateTexture(nil, "OVERLAY")
		right:SetWidth(1.2)
		right:SetTexture(C.media.backdrop)
		right:SetVertexColor(0, 0, 0)
		right:SetPoint("TOPRIGHT", RoleIcon, -8, -6)
		right:SetPoint("BOTTOMRIGHT", RoleIcon, -8, 10)

		local top = LFGListInviteDialog:CreateTexture(nil, "OVERLAY")
		top:SetHeight(1.2)
		top:SetTexture(C.media.backdrop)
		top:SetVertexColor(0, 0, 0)
		top:SetPoint("TOPLEFT", RoleIcon, 8, -6)
		top:SetPoint("TOPRIGHT", RoleIcon, -8, -6)

		local bottom = LFGListInviteDialog:CreateTexture(nil, "OVERLAY")
		bottom:SetHeight(1.2)
		bottom:SetTexture(C.media.backdrop)
		bottom:SetVertexColor(0, 0, 0)
		bottom:SetPoint("BOTTOMLEFT", RoleIcon, 8, 10)
		bottom:SetPoint("BOTTOMRIGHT", RoleIcon, -8, 10)
	end
end)