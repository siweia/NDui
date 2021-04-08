local _, ns = ...
local B, C, L, DB = unpack(ns)

local function Highlight_OnEnter(self)
	self.hl:Show()
end

local function Highlight_OnLeave(self)
	self.hl:Hide()
end

local function HandleRoleAnchor(self, role)
	self[role.."Count"]:SetWidth(24)
	self[role.."Count"]:SetFontObject(Game13Font)
	self[role.."Count"]:SetPoint("RIGHT", self[role.."Icon"], "LEFT", 1, 0)
end

local roleCache = {}
local roleOrder = {
	["TANK"] = 1,
	["HEALER"] = 2,
	["DAMAGER"] = 3,
}
local roleAtlas = {
	[1] = "groupfinder-icon-role-large-tank",
	[2] = "groupfinder-icon-role-large-heal",
	[3] = "groupfinder-icon-role-large-dps",
}

local function sortRoleOrder(a, b)
	if a and b then
		return a[1] < b[1]
	end
end

local function UpdateGroupRoles(self)
	wipe(roleCache)

	local count = 0
	for i = 1, 5 do
		local role, class = C_LFGList.GetSearchResultMemberInfo(self.resultID, i)
		local roleIndex = role and roleOrder[role]
		if roleIndex then
			count = count + 1
			if not roleCache[count] then roleCache[count] = {} end
			roleCache[count][1] = roleIndex
			roleCache[count][2] = class
		end
	end

	sort(roleCache, sortRoleOrder)
end

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local r, g, b = DB.r, DB.g, DB.b

	local LFGListFrame = LFGListFrame
	LFGListFrame.NothingAvailable.Inset:Hide()

	-- [[ Category selection ]]

	local CategorySelection = LFGListFrame.CategorySelection

	B.Reskin(CategorySelection.FindGroupButton)
	B.Reskin(CategorySelection.StartGroupButton)
	CategorySelection.Inset:Hide()
	CategorySelection.CategoryButtons[1]:SetNormalFontObject(GameFontNormal)

	hooksecurefunc("LFGListCategorySelection_AddButton", function(self, btnIndex)
		local bu = self.CategoryButtons[btnIndex]
		if bu and not bu.styled then
			bu.Cover:Hide()
			bu.Icon:SetTexCoord(.01, .99, .01, .99)
			B.CreateBDFrame(bu.Icon)

			bu.styled = true
		end
	end)

	hooksecurefunc("LFGListSearchEntry_Update", function(self)
		local cancelButton = self.CancelButton
		if not cancelButton.styled then
			B.Reskin(cancelButton)
			cancelButton.styled = true
		end
	end)

	hooksecurefunc("LFGListSearchEntry_UpdateExpiration", function(self)
		local expirationTime = self.ExpirationTime
		if not expirationTime.fontStyled then
			expirationTime:SetWidth(42)
			expirationTime.fontStyled = true
		end
	end)

	-- [[ Search panel ]]

	local SearchPanel = LFGListFrame.SearchPanel

	B.Reskin(SearchPanel.RefreshButton)
	B.Reskin(SearchPanel.BackButton)
	B.Reskin(SearchPanel.SignUpButton)
	B.Reskin(SearchPanel.ScrollFrame.ScrollChild.StartGroupButton)
	B.ReskinInput(SearchPanel.SearchBox)
	B.ReskinScroll(SearchPanel.ScrollFrame.scrollBar)

	SearchPanel.RefreshButton:SetSize(24, 24)
	SearchPanel.RefreshButton.Icon:SetPoint("CENTER")
	SearchPanel.ResultsInset:Hide()
	B.StripTextures(SearchPanel.AutoCompleteFrame)

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

			local bg = B.CreateBDFrame(result, .5)
			local hl = result:CreateTexture(nil, "BACKGROUND")
			hl:SetInside(bg)
			hl:SetTexture(DB.bdTex)
			hl:SetVertexColor(r, g, b, .25)
			hl:Hide()
			result.hl = hl

			result:HookScript("OnEnter", Highlight_OnEnter)
			result:HookScript("OnLeave", Highlight_OnLeave)

			numResults = numResults + 1
		end
	end)

	-- [[ Application viewer ]]

	local ApplicationViewer = LFGListFrame.ApplicationViewer
	ApplicationViewer.InfoBackground:Hide()
	ApplicationViewer.Inset:Hide()

	for _, headerName in pairs({"NameColumnHeader", "RoleColumnHeader", "ItemLevelColumnHeader"}) do
		local header = ApplicationViewer[headerName]
		B.StripTextures(header)
		header.Label:SetFont(DB.Font[1], 14, DB.Font[3])
		header.Label:SetShadowColor(0, 0, 0, 0)
		header:SetHighlightTexture("")

		local bg = B.CreateBDFrame(header, .25)
		local hl = header:CreateTexture(nil, "BACKGROUND")
		hl:SetInside(bg)
		hl:SetTexture(DB.bdTex)
		hl:SetVertexColor(r, g, b, .25)
		hl:Hide()
		header.hl = hl

		header:HookScript("OnEnter", Highlight_OnEnter)
		header:HookScript("OnLeave", Highlight_OnLeave)
	end

	ApplicationViewer.RoleColumnHeader:SetPoint("LEFT", ApplicationViewer.NameColumnHeader, "RIGHT", 1, 0)
	ApplicationViewer.ItemLevelColumnHeader:SetPoint("LEFT", ApplicationViewer.RoleColumnHeader, "RIGHT", 1, 0)

	B.Reskin(ApplicationViewer.RefreshButton)
	B.Reskin(ApplicationViewer.RemoveEntryButton)
	B.Reskin(ApplicationViewer.EditButton)
	B.ReskinScroll(LFGListApplicationViewerScrollFrameScrollBar)

	ApplicationViewer.RefreshButton:SetSize(24, 24)
	ApplicationViewer.RefreshButton.Icon:SetPoint("CENTER")

	hooksecurefunc("LFGListApplicationViewer_UpdateApplicant", function(button)
		if not button.styled then
			B.Reskin(button.DeclineButton)
			B.Reskin(button.InviteButton)

			button.styled = true
		end
	end)

	-- [[ Entry creation ]]

	local EntryCreation = LFGListFrame.EntryCreation
	EntryCreation.Inset:Hide()
	B.StripTextures(EntryCreation.Description)
	B.Reskin(EntryCreation.ListGroupButton)
	B.Reskin(EntryCreation.CancelButton)
	B.ReskinInput(EntryCreation.Description)
	B.ReskinInput(EntryCreation.Name)
	B.ReskinInput(EntryCreation.ItemLevel.EditBox)
	B.ReskinInput(EntryCreation.VoiceChat.EditBox)
	B.ReskinDropDown(EntryCreation.CategoryDropDown)
	B.ReskinDropDown(EntryCreation.GroupDropDown)
	B.ReskinDropDown(EntryCreation.ActivityDropDown)
	B.ReskinCheck(EntryCreation.ItemLevel.CheckButton)
	B.ReskinCheck(EntryCreation.VoiceChat.CheckButton)
	B.ReskinCheck(EntryCreation.PrivateGroup.CheckButton)
	B.ReskinCheck(LFGListFrame.ApplicationViewer.AutoAcceptButton)

	-- [[ Role count ]]

	hooksecurefunc("LFGListGroupDataDisplayRoleCount_Update", function(self)
		if not self.styled then
			B.ReskinRole(self.TankIcon, "TANK")
			B.ReskinRole(self.HealerIcon, "HEALER")
			B.ReskinRole(self.DamagerIcon, "DPS")

			self.HealerIcon:SetPoint("RIGHT", self.DamagerIcon, "LEFT", -22, 0)
			self.TankIcon:SetPoint("RIGHT", self.HealerIcon, "LEFT", -22, 0)

			HandleRoleAnchor(self, "Tank")
			HandleRoleAnchor(self, "Healer")
			HandleRoleAnchor(self, "Damager")

			self.styled = true
		end
	end)

	hooksecurefunc("LFGListGroupDataDisplayEnumerate_Update", function(self, numPlayers)
		UpdateGroupRoles(self:GetParent():GetParent())

		for i = 1, 5 do
			local icon = self.Icons[i]
			if not icon.bg then
				if i > 1 then
					icon:ClearAllPoints()
					icon:SetPoint("RIGHT", self.Icons[i-1], "LEFT", -4, 0)
				end
				icon:SetSize(22, 22)
				icon.bg = B.CreateBDFrame(icon, .25)

				icon.role = self:CreateTexture(nil, "OVERLAY")
				icon.role:SetSize(18, 18)
				icon.role:SetPoint("CENTER", icon, "BOTTOM")
			end

			if i > numPlayers then
				icon.bg:Hide()
				icon.role:Hide()
			else
				icon.bg:Show()
				icon.role:Show()
			end
		end

		local iconIndex = numPlayers
		for i = 1, #roleCache do
			local roleInfo = roleCache[i]
			local icon = self.Icons[iconIndex]
			if roleInfo then
				icon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
				local tcoords = CLASS_ICON_TCOORDS[roleInfo[2]]
				icon:SetTexCoord(tcoords[1] + .022, tcoords[2] - .025, tcoords[3] + .022, tcoords[4] - .025)
				icon.role:SetAtlas(roleAtlas[roleInfo[1]])
				icon.bg:Show()
				iconIndex = iconIndex - 1
			end
		end

		for i = 1, iconIndex do
			local icon = self.Icons[i]
			icon:SetTexCoord(0, 1, 0, 1)
			icon.role:SetAtlas(nil)
			icon.bg:Hide()
		end
	end)

	-- Activity finder

	local ActivityFinder = EntryCreation.ActivityFinder

	ActivityFinder.Background:SetTexture("")
	B.StripTextures(ActivityFinder.Dialog)
	B.ReskinInput(ActivityFinder.Dialog)
	B.Reskin(ActivityFinder.Dialog.SelectButton)
	B.Reskin(ActivityFinder.Dialog.CancelButton)
	B.ReskinInput(ActivityFinder.Dialog.EntryBox)
	B.ReskinScroll(LFGListEntryCreationSearchScrollFrameScrollBar)

	-- [[ Application dialog ]]

	local LFGListApplicationDialog = LFGListApplicationDialog

	B.StripTextures(LFGListApplicationDialog)
	B.SetBD(LFGListApplicationDialog)
	B.StripTextures(LFGListApplicationDialog.Description)
	B.CreateBDFrame(LFGListApplicationDialog.Description, .25)
	B.Reskin(LFGListApplicationDialog.SignUpButton)
	B.Reskin(LFGListApplicationDialog.CancelButton)

	-- [[ Invite dialog ]]

	local LFGListInviteDialog = LFGListInviteDialog

	B.StripTextures(LFGListInviteDialog)
	B.SetBD(LFGListInviteDialog)
	B.Reskin(LFGListInviteDialog.AcceptButton)
	B.Reskin(LFGListInviteDialog.DeclineButton)
	B.Reskin(LFGListInviteDialog.AcknowledgeButton)

	local roleIcon = LFGListInviteDialog.RoleIcon
	roleIcon:SetTexture(DB.rolesTex)
	B.CreateBDFrame(roleIcon)

	hooksecurefunc("LFGListInviteDialog_Show", function(self, resultID)
		local role = select(5, C_LFGList.GetApplicationInfo(resultID))
		self.RoleIcon:SetTexCoord(B.GetRoleTexCoord(role))
	end)
end)