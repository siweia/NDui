local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_LookingForGroupUI"] = function()
	local closeButton = LFGParentFrame:GetChildren()
	if not LFGParentFrame.CloseButton then
		LFGParentFrame.CloseButton = closeButton
	end
	B.ReskinPortraitFrame(LFGParentFrame, 19, -10, -30, 75)

	B.ReskinTab(LFGParentFrameTab1)
	B.ReskinTab(LFGParentFrameTab2)

	-- LFGListingFrame
	B.StripTextures(LFGListingFrame)
	B.Reskin(LFGListingFrameBackButton)
	B.Reskin(LFGListingFramePostButton)
	B.ReskinEditBox(LFGListingComment)
	B.Reskin(LFGListingFrame.GroupRoleButtons.RolePollButton)
	B.ReskinDropDown(LFGListingFrame.GroupRoleButtons.RoleDropDown)

	hooksecurefunc("LFGListingRoleIcon_UpdateRoleTexture", function(self)
		if not self.roleID then return end

		if not self.bg then
			B.ReskinRole(self, self.roleID)
		end
		self:GetNormalTexture():SetTexCoord(B.GetRoleTexCoord(self.roleID))
	end)

	hooksecurefunc("LFGListingCategorySelection_AddButton", function(self, btnIndex)
		local bu = self.CategoryButtons[btnIndex]
		if bu and not bu.styled then
			bu.Cover:Hide()
			bu.Icon:SetTexCoord(.01, .99, .01, .99)
			B.CreateBDFrame(bu.Icon)

			bu.styled = true
		end
	end)

	B.StripTextures(LFGListingFrameActivityView)
	--B.ReskinTrimScroll(LFGListingFrameActivityViewScrollBar)
	LFGListingFrameActivityViewScrollBar:SetAlpha(0) -- taint if skinned, so hide it

	local function skinBigRole(roleButton, role)
		B.ReskinCheck(roleButton.CheckButton)
		roleButton.CheckButton:SetFrameLevel(6)
		B.ReskinRole(roleButton, role)
	end
	skinBigRole(LFGListingFrame.SoloRoleButtons.Tank, "TANK")
	skinBigRole(LFGListingFrame.SoloRoleButtons.Healer, "HEALER")
	skinBigRole(LFGListingFrame.SoloRoleButtons.DPS, "DPS")
	skinBigRole(LFGListingFrameNewPlayerFriendlyButton, "LEADER")

	local function skinOptions(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if child.CheckButton:IsObjectType("CheckButton") and not child.CheckButton.styled then
				B.ReskinCheck(child.CheckButton)
				child.CheckButton.styled = true
			elseif child.ExpandOrCollapseButton and not child.ExpandOrCollapseButton.styled then
				B.ReskinCollapse(child.ExpandOrCollapseButton)
				child.ExpandOrCollapseButton.__texture:DoCollapse(false)
				child.ExpandOrCollapseButton.styled = true
			end
		end
	end
	hooksecurefunc(LFGListingFrameActivityView.ScrollBox, "Update", skinOptions)
	hooksecurefunc(LFGListingFrameActivityView, "Show", function(self)
		skinOptions(self.ScrollBox)
	end)

	B.StripTextures(LFGBrowseFrame)
	B.ReskinTrimScroll(LFGBrowseFrameScrollBar)
	B.Reskin(LFGBrowseFrameSendMessageButton)
	B.Reskin(LFGBrowseFrameGroupInviteButton)
	B.ReskinDropDown(LFGBrowseFrameCategoryDropDown)
	B.ReskinDropDown(LFGBrowseFrameActivityDropDown)
	B.Reskin(LFGBrowseFrameRefreshButton)
	LFGBrowseFrameRefreshButton.__bg:SetInside(nil, 3, 3)

	-- Role icons in application
	local function replaceSmallRole(self, x1, x2)
		if x1 == .5 and x2 == .75 then
			B.ReskinSmallRole(self, "TANK")
		elseif x1 == .75 and x2 == 1 then
			B.ReskinSmallRole(self, "HEALER")
		elseif x1 == .25 and x2 == .5 then
			B.ReskinSmallRole(self, "DPS")
		end
	end
	hooksecurefunc("LFGBrowseUtil_MapRoleStatesToRoleIcons", function(iconArray)
		for i = 1, #iconArray do
			local icon = iconArray[i]
			if not icon.hooked then
				hooksecurefunc(icon, "SetTexCoord", replaceSmallRole)
				icon.hooked = true
			end
		end
	end)

	hooksecurefunc("LFGBrowseGroupDataDisplaySolo_Update", function(self)
		if not self.fontReplaced then
			self.RolesText:SetText(ROLE)
			self.RolesText:SetFontObject(Game12Font)
			self.fontReplaced = true
		end
	end)

	-- Role icons in existing groups
	local GroupAtlasList = {
		TANK = "groupfinder-icon-role-large-tank",
		HEALER = "groupfinder-icon-role-large-heal",
		DAMAGER = "groupfinder-icon-role-large-dps",
	}
	for i=1, #CLASS_SORT_ORDER do
		GroupAtlasList[CLASS_SORT_ORDER[i]] = "groupfinder-icon-class-"..strlower(CLASS_SORT_ORDER[i])
	end

	local roleCache = {}
	local roleOrder = {
		["TANK"] = 1,
		["HEALER"] = 2,
		["DAMAGER"] = 3,
	}
	local roleTexes = {DB.tankTex, DB.healTex, DB.dpsTex}

	local function sortRoleOrder(a, b)
		if a and b then
			return a[1] < b[1]
		end
	end

	local function GetCorrectRoleInfo(frame, i)
		if frame.resultID then
			local _, role, class = C_LFGList.GetSearchResultMemberInfo(frame.resultID, i)
			return role, class, i == 1
		end
	end

	local function UpdateGroupRoles(self)
		wipe(roleCache)

		if not self.__owner then
			self.__owner = self:GetParent():GetParent()
		end

		local count = 0
		for i = 1, 5 do
			local role, class, isLeader = GetCorrectRoleInfo(self.__owner, i)
			local roleIndex = role and roleOrder[role]
			if roleIndex then
				count = count + 1
				if not roleCache[count] then roleCache[count] = {} end
				roleCache[count][1] = roleIndex
				roleCache[count][2] = class
				roleCache[count][3] = isLeader
			end
		end

		sort(roleCache, sortRoleOrder)
	end

	hooksecurefunc("LFGBrowseGroupDataDisplayEnumerate_Update", function(self, numPlayers, _, disabled)
		UpdateGroupRoles(self)

		for i = 1, 5 do
			local icon = self.Icons[i]
			if not icon.role then
				if i == 1 then
					icon:SetPoint("RIGHT", -5, -2)
				else
					icon:ClearAllPoints()
					icon:SetPoint("RIGHT", self.Icons[i-1], "LEFT", 2, 0)
				end
				icon:SetSize(26, 26)

				icon.role = self:CreateTexture(nil, "OVERLAY", nil, 2)
				icon.role:SetSize(16, 16)
				icon.role:SetPoint("TOPLEFT", icon, -3, 3)

				icon.leader = self:CreateTexture(nil, "OVERLAY", nil, 1)
				icon.leader:SetSize(14, 14)
				icon.leader:SetPoint("TOP", icon, 4, 7)
				icon.leader:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
				icon.leader:SetRotation(rad(-15))
			end

			if i > numPlayers then
				icon.role:Hide()
			else
				icon.role:Show()
				icon.role:SetDesaturated(disabled)
				icon.role:SetAlpha(disabled and .5 or 1)
				icon.leader:SetDesaturated(disabled)
				icon.leader:SetAlpha(disabled and .5 or 1)
			end
			icon.leader:Hide()
		end

		local iconIndex = numPlayers
		for i = 1, #roleCache do
			local roleInfo = roleCache[i]
			if roleInfo then
				local icon = self.Icons[iconIndex]
				icon:SetAtlas(GroupAtlasList[roleInfo[2]])
				icon.role:SetTexture(roleTexes[roleInfo[1]])
				icon.leader:SetShown(roleInfo[3])
				iconIndex = iconIndex - 1
			end
		end

		for i = 1, iconIndex do
			self.Icons[i].role:SetTexture(nil)
		end
	end)

	hooksecurefunc("LFGBrowseSearchEntry_Update", function(self)
		if not self.fontReplaced then
			self.Name:SetFontObject(Game14Font)
			self.ActivityName:SetFontObject(Game12Font)
			self.fontReplaced = true
		end
	end)
end