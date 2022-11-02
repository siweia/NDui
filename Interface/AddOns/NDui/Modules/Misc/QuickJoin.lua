local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")
local TT = B:GetModule("Tooltip")

--[[
	QuickJoin 优化系统自带的预创建功能
	1.双击搜索结果，快速申请
	2.自动隐藏部分窗口
	3.美化LFG的相关职业图标
	4.自动邀请申请
	5.显示队长分数，并简写集市钥石
]]
local select, wipe, sort, gsub, tremove = select, wipe, sort, gsub, tremove
local StaticPopup_Hide, HideUIPanel, GetTime = StaticPopup_Hide, HideUIPanel, GetTime
local UnitIsGroupLeader, UnitClass, UnitGroupRolesAssigned = UnitIsGroupLeader, UnitClass, UnitGroupRolesAssigned
local C_Timer_After, IsAltKeyDown = C_Timer.After, IsAltKeyDown
local C_LFGList_GetSearchResultInfo = C_LFGList.GetSearchResultInfo
local C_LFGList_GetActivityInfoTable = C_LFGList.GetActivityInfoTable
local C_LFGList_GetSearchResultMemberInfo = C_LFGList.GetSearchResultMemberInfo
local C_ChallengeMode_GetMapUIInfo = C_ChallengeMode.GetMapUIInfo

local HEADER_COLON = _G.HEADER_COLON
local LE_PARTY_CATEGORY_HOME = _G.LE_PARTY_CATEGORY_HOME or 1
local LFG_LIST_GROUP_DATA_ATLASES = _G.LFG_LIST_GROUP_DATA_ATLASES
local scoreFormat = DB.GreyColor.."(%s) |r%s"

local LFGListFrame = _G.LFGListFrame
local ApplicationViewerFrame = LFGListFrame.ApplicationViewer
local searchPanel = LFGListFrame.SearchPanel
local categorySelection = LFGListFrame.CategorySelection

function M:HookApplicationClick()
	if LFGListFrame.SearchPanel.SignUpButton:IsEnabled() then
		LFGListFrame.SearchPanel.SignUpButton:Click()
	end
	if (not IsAltKeyDown()) and LFGListApplicationDialog:IsShown() and LFGListApplicationDialog.SignUpButton:IsEnabled() then
		LFGListApplicationDialog.SignUpButton:Click()
	end
end

local pendingFrame
function M:DialogHideInSecond()
	if not pendingFrame then return end

	if pendingFrame.informational then
		StaticPopupSpecial_Hide(pendingFrame)
	elseif pendingFrame == "LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS" then
		StaticPopup_Hide(pendingFrame)
	end
	pendingFrame = nil
end

function M:HookDialogOnShow()
	pendingFrame = self
	C_Timer_After(1, M.DialogHideInSecond)
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

local function GetPartyMemberInfo(index)
	local unit = "player"
	if index > 1 then unit = "party"..(index-1) end

	local class = select(2, UnitClass(unit))
	if not class then return end
	local role = UnitGroupRolesAssigned(unit)
	if role == "NONE" then role = "DAMAGER" end
	return role, class, UnitIsGroupLeader(unit)
end

local function GetCorrectRoleInfo(frame, i)
	if frame.resultID then
		local role, class = C_LFGList_GetSearchResultMemberInfo(frame.resultID, i)
		return role, class, i == 1
	elseif frame == ApplicationViewerFrame then
		return GetPartyMemberInfo(i)
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

function M:ReplaceGroupRoles(numPlayers, _, disabled)
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
			icon:SetAtlas(LFG_LIST_GROUP_DATA_ATLASES[roleInfo[2]])
			icon.role:SetTexture(roleTexes[roleInfo[1]])
			icon.leader:SetShown(roleInfo[3])
			iconIndex = iconIndex - 1
		end
	end

	for i = 1, iconIndex do
		self.Icons[i].role:SetTexture(nil)
	end
end

function M:QuickJoin_ShowTips()
	local quickJoinInfo = {
		text = L["QuickJoinInfo"],
		buttonStyle = HelpTip.ButtonStyle.GotIt,
		targetPoint = HelpTip.Point.RightEdgeCenter,
		onAcknowledgeCallback = B.HelpInfoAcknowledge,
		callbackArg = "QuickJoin",
	}
	LFGListFrame.SearchPanel.SignUpButton:HookScript("OnShow", function()
		if not NDuiADB["Help"]["QuickJoin"] then
			HelpTip:Show(PVEFrame, quickJoinInfo)
		end
	end)
end

function M:AddAutoAcceptButton()
	local bu = B.CreateCheckBox(ApplicationViewerFrame)
	bu:SetSize(24, 24)
	bu:SetHitRectInsets(0, -130, 0, 0)
	bu:SetPoint("BOTTOMLEFT", ApplicationViewerFrame.InfoBackground, 12, 5)
	B.CreateFS(bu, 14, _G.LFG_LIST_AUTO_ACCEPT, "system", "LEFT", 24, 0)

	local lastTime = 0
	B:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED", function()
		if not bu:GetChecked() then return end
		if not UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) then return end

		local buttons = ApplicationViewerFrame.ScrollFrame.buttons
		for i = 1, #buttons do
			local button = buttons[i]
			if button.applicantID and button.InviteButton:IsEnabled() then
				button.InviteButton:Click()
			end
		end

		if ApplicationViewerFrame:IsShown() then
			local now = GetTime()
			if now - lastTime > 1 then
				lastTime = now
				ApplicationViewerFrame.RefreshButton:Click()
			end
		end
	end)

	hooksecurefunc("LFGListApplicationViewer_UpdateInfo", function(self)
		bu:SetShown(UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) and not self.AutoAcceptButton:IsShown())
	end)
end

local factionStr = {
	[0] = "Horde",
	[1] = "Alliance",
}
function M:ShowLeaderOverallScore()
	local resultID = self.resultID
	local searchResultInfo = resultID and C_LFGList_GetSearchResultInfo(resultID)
	if searchResultInfo then
		local activityInfo = C_LFGList_GetActivityInfoTable(searchResultInfo.activityID, nil, searchResultInfo.isWarMode)
		if activityInfo then
			local showScore = activityInfo.isMythicPlusActivity and searchResultInfo.leaderOverallDungeonScore
				or activityInfo.isRatedPvpActivity and searchResultInfo.leaderPvpRatingInfo and searchResultInfo.leaderPvpRatingInfo.rating
			if showScore then
				local oldName = self.ActivityName:GetText()
				oldName = gsub(oldName, ".-"..HEADER_COLON, "") -- Tazavesh
				self.ActivityName:SetFormattedText(scoreFormat, TT.GetDungeonScore(showScore), oldName)

				if not self.crossFactionLogo then
					local logo = self:CreateTexture(nil, "OVERLAY")
					logo:SetPoint("TOPLEFT", -6, 5)
					logo:SetSize(24, 24)
					self.crossFactionLogo = logo
				end
			end
		end

		if self.crossFactionLogo then
			if searchResultInfo.crossFactionListing then
				self.crossFactionLogo:Hide()
			else
				self.crossFactionLogo:SetTexture("Interface\\Timer\\"..factionStr[searchResultInfo.leaderFactionGroup].."-Logo")
				self.crossFactionLogo:Show()
			end
		end
	end
end

function M:ReplaceFindGroupButton()
	if not IsAddOnLoaded("PremadeGroupsFilter") then return end

	categorySelection.FindGroupButton:Hide()

	local bu = CreateFrame("Button", nil, categorySelection, "LFGListMagicButtonTemplate")
	bu:SetText(LFG_LIST_FIND_A_GROUP)
	bu:SetSize(135, 22)
	bu:SetPoint("BOTTOMRIGHT", -3, 4)

	local lastCategory = 0
	bu:SetScript("OnClick", function()
		local selectedCategory = categorySelection.selectedCategory
		if not selectedCategory then return end

		if lastCategory ~= selectedCategory then
			categorySelection.FindGroupButton:Click()
		else
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			LFGListSearchPanel_SetCategory(searchPanel, selectedCategory, categorySelection.selectedFilters, LFGListFrame.baseFilters)
			LFGListSearchPanel_DoSearch(searchPanel)
			LFGListFrame_SetActivePanel(LFGListFrame, searchPanel)
		end
		lastCategory = selectedCategory
	end)

	if C.db["Skins"]["BlizzardSkins"] then B.Reskin(bu) end
end

function M:AddDungeonsFilter()
	local mapData = {
		[0] = {mapID = 166, aID = 183},  -- 车站
		[1] = {mapID = 169, aID = 180},  -- 码头
		[2] = {mapID = 234, aID = 473},  -- 卡上
		[3] = {mapID = 227, aID = 471},  -- 卡下
		[4] = {mapID = 369, aID = 679},  -- 垃圾场
		[5] = {mapID = 370, aID = 683},  -- 车间
		[6] = {mapID = 391, aID = 1016}, -- 街道
		[7] = {mapID = 392, aID = 1017}, -- 宏图
	}

	local function GetDungeonNameByID(mapID)
		local name = C_ChallengeMode_GetMapUIInfo(mapID)
		name = gsub(name, ".-"..HEADER_COLON, "") -- abbr Tazavesh
		return name
	end

	local allOn
	local filterIDs = {}

	local function toggleAll()
		allOn = not allOn
		for i = 0, 7 do
			mapData[i].isOn = allOn
			filterIDs[mapData[i].aID] = allOn
		end
		UIDropDownMenu_Refresh(B.EasyMenu)
		LFGListSearchPanel_DoSearch(searchPanel)
	end

	local menuList = {
		[1] = {text = _G.SPECIFIC_DUNGEONS, isTitle = true, notCheckable = true},
		[2] = {text = _G.SWITCH, notCheckable = true, keepShownOnClick = true, func = toggleAll},
	}

	local function onClick(self, index, aID)
		allOn = true
		mapData[index].isOn = not mapData[index].isOn
		filterIDs[aID] = mapData[index].isOn
		LFGListSearchPanel_DoSearch(searchPanel)
	end

	local function onCheck(self)
		return mapData[self.arg1].isOn
	end

	for i = 0, 7 do
		local value = mapData[i]
		menuList[i+3] = {
			text = GetDungeonNameByID(value.mapID),
			arg1 = i,
			arg2 = value.aID,
			func = onClick,
			checked = onCheck,
			keepShownOnClick = true,
		}
		filterIDs[value.aID] = false
	end

	searchPanel.RefreshButton:HookScript("OnMouseDown", function(self, btn)
		if btn ~= "RightButton" then return end
		EasyMenu(menuList, B.EasyMenu, self, 25, 50, "MENU")
	end)

	searchPanel.RefreshButton:HookScript("OnEnter", function()
		GameTooltip:AddLine(DB.RightButton.._G.SPECIFIC_DUNGEONS)
		GameTooltip:Show()
	end)

	hooksecurefunc("LFGListUtil_SortSearchResults", function(results)
		if categorySelection.selectedCategory ~= 2 then return end
		if not allOn then return end

		for i = #results, 1, -1 do
			local resultID = results[i]
			local searchResultInfo = C_LFGList_GetSearchResultInfo(resultID)
			local aID = searchResultInfo and searchResultInfo.activityID
			if aID and not filterIDs[aID] then
				tremove(results, i)
			end
		end
		searchPanel.totalResults = #results

		return true
	end)
end

local function clickSortButton(self)
	self.__owner.Sorting.SortingExpression:SetText(self.sortStr)
	self.__owner.RefreshButton:Click()
end

local function createSortButton(parent, texture, sortStr)
	local bu = B.CreateButton(parent, 24, 24, true, texture)
	bu.sortStr = sortStr
	bu.__owner = parent
	bu:SetScript("OnClick", clickSortButton)
	B.AddTooltip(bu, "ANCHOR_RIGHT", CLUB_FINDER_SORT_BY)

	tinsert(parent.__sortBu, bu)
end

function M:AddPGFSortingExpression()
	if not IsAddOnLoaded("PremadeGroupsFilter") then return end

	local PGFDialog = _G.PremadeGroupsFilterDialog
	PGFDialog.__sortBu = {}

	createSortButton(PGFDialog, 525134, "mprating desc")
	createSortButton(PGFDialog, 1455894, "pvprating desc")
	createSortButton(PGFDialog, 237538, "age asc")

	for i = 1, #PGFDialog.__sortBu do
		local bu = PGFDialog.__sortBu[i]
		if i == 1 then
			bu:SetPoint("BOTTOMLEFT", PGFDialog, "BOTTOMRIGHT", 3, 0)
		else
			bu:SetPoint("BOTTOM", PGFDialog.__sortBu[i-1], "TOP", 0, 3)
		end
	end

	if PremadeGroupsFilterSettings then
		PremadeGroupsFilterSettings.classBar = false
		PremadeGroupsFilterSettings.classCircle = false
		PremadeGroupsFilterSettings.leaderCrown = false
		PremadeGroupsFilterSettings.ratingInfo = false
	end
end

function M:QuickJoin()
	if not C.db["Misc"]["QuickJoin"] then return end

	hooksecurefunc(LFGListFrame.SearchPanel.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if child.Name and not child.hooked then
				child.Name:SetFontObject(Game14Font)
				child.ActivityName:SetFontObject(Game12Font)
				child:HookScript("OnDoubleClick", M.HookApplicationClick)

				child.hooked = true
			end
		end
	end)
	M:QuickJoin_ShowTips()

	hooksecurefunc("LFGListInviteDialog_Accept", function()
		if PVEFrame:IsShown() then HideUIPanel(PVEFrame) end
	end)

	hooksecurefunc("StaticPopup_Show", M.HookDialogOnShow)
	hooksecurefunc("LFGListInviteDialog_Show", M.HookDialogOnShow)

	hooksecurefunc("LFGListGroupDataDisplayEnumerate_Update", M.ReplaceGroupRoles)
	hooksecurefunc("LFGListSearchEntry_Update", M.ShowLeaderOverallScore)

	M:AddAutoAcceptButton()
	M:ReplaceFindGroupButton()
	M:AddDungeonsFilter()
	M:AddPGFSortingExpression()
end
M:RegisterMisc("QuickJoin", M.QuickJoin)