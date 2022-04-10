local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local next, pairs, mod, select = next, pairs, mod, select
local tinsert, strsplit, format = table.insert, string.split, string.format
local IsInGroup, IsInRaid, IsInInstance = IsInGroup, IsInRaid, IsInInstance
local UnitIsGroupLeader, UnitIsGroupAssistant = UnitIsGroupLeader, UnitIsGroupAssistant
local IsPartyLFG, IsLFGComplete, HasLFGRestrictions = IsPartyLFG, IsLFGComplete, HasLFGRestrictions
local GetInstanceInfo, GetNumGroupMembers, GetRaidRosterInfo, GetRaidTargetIndex, SetRaidTarget = GetInstanceInfo, GetNumGroupMembers, GetRaidRosterInfo, GetRaidTargetIndex, SetRaidTarget
local GetSpellCharges, GetSpellInfo, UnitAura = GetSpellCharges, GetSpellInfo, UnitAura
local GetTime, SendChatMessage, IsAddOnLoaded = GetTime, SendChatMessage, IsAddOnLoaded
local IsAltKeyDown, IsControlKeyDown, IsShiftKeyDown, InCombatLockdown = IsAltKeyDown, IsControlKeyDown, IsShiftKeyDown, InCombatLockdown
local UnitExists, UninviteUnit = UnitExists, UninviteUnit
local DoReadyCheck, InitiateRolePoll, GetReadyCheckStatus = DoReadyCheck, InitiateRolePoll, GetReadyCheckStatus
local C_Timer_After = C_Timer.After
local LeaveParty = C_PartyInfo.LeaveParty
local ConvertToRaid = C_PartyInfo.ConvertToRaid
local ConvertToParty = C_PartyInfo.ConvertToParty

function M:RaidTool_Visibility(frame)
	if IsInGroup() then
		frame:Show()
	else
		frame:Hide()
	end
end

function M:RaidTool_Header()
	local frame = CreateFrame("Button", nil, UIParent)
	frame:SetSize(120, 28)
	frame:SetFrameLevel(2)
	B.ReskinMenuButton(frame)
	B.Mover(frame, L["Raid Tool"], "RaidManager", C.Skins.RMPos)

	M:RaidTool_Visibility(frame)
	B:RegisterEvent("GROUP_ROSTER_UPDATE", function()
		M:RaidTool_Visibility(frame)
	end)

	frame:RegisterForClicks("AnyUp")
	frame:SetScript("OnClick", function(self, btn)
		if btn == "LeftButton" then
			local menu = self.menu
			B:TogglePanel(menu)

			if menu:IsShown() then
				menu:ClearAllPoints()
				if M:IsFrameOnTop(self) then
					menu:SetPoint("TOP", self, "BOTTOM", 0, -3)
				else
					menu:SetPoint("BOTTOM", self, "TOP", 0, 3)
				end

				self.buttons[2].text:SetText(IsInRaid() and CONVERT_TO_PARTY or CONVERT_TO_RAID)
			end
		end
	end)
	frame:SetScript("OnDoubleClick", function(_, btn)
		if btn == "RightButton" and (IsPartyLFG() and IsLFGComplete() or not IsInInstance()) then
			LeaveParty()
		end
	end)
	frame:SetScript("OnHide", function(self)
		self.bg:SetBackdropColor(0, 0, 0, .5)
		self.bg:SetBackdropBorderColor(0, 0, 0, 1)
	end)

	return frame
end

function M:IsFrameOnTop(frame)
	local y = select(2, frame:GetCenter())
	local screenHeight = UIParent:GetTop()
	return y > screenHeight/2
end

function M:GetRaidMaxGroup()
	local _, instType, difficulty = GetInstanceInfo()
	if (instType == "party" or instType == "scenario") and not IsInRaid() then
		return 1
	elseif instType ~= "raid" then
		return 8
	elseif difficulty == 8 or difficulty == 1 or difficulty == 2 or difficulty == 24 then
		return 1
	elseif difficulty == 14 or difficulty == 15 then
		return 6
	elseif difficulty == 16 then
		return 4
	elseif difficulty == 3 or difficulty == 5 then
		return 2
	elseif difficulty == 9 then
		return 8
	else
		return 5
	end
end

function M:RaidTool_RoleCount(parent)
	local roleTexes = {
		DB.tankTex, DB.healTex, DB.dpsTex
	}

	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	local role = {}
	for i = 1, 3 do
		role[i] = frame:CreateTexture(nil, "OVERLAY")
		role[i]:SetPoint("LEFT", 36*i-30, 0)
		role[i]:SetSize(15, 15)
		role[i]:SetTexture(roleTexes[i])
		role[i].text = B.CreateFS(frame, 13, "0")
		role[i].text:ClearAllPoints()
		role[i].text:SetPoint("CENTER", role[i], "RIGHT", 12, 0)
	end

	local raidCounts = {
		totalTANK = 0,
		totalHEALER = 0,
		totalDAMAGER = 0
	}

	local function updateRoleCount()
		for k in pairs(raidCounts) do
			raidCounts[k] = 0
		end

		local maxgroup = M:GetRaidMaxGroup()
		for i = 1, GetNumGroupMembers() do
			local name, _, subgroup, _, _, _, _, online, isDead, _, _, assignedRole = GetRaidRosterInfo(i)
			if name and online and subgroup <= maxgroup and not isDead and assignedRole ~= "NONE" then
				raidCounts["total"..assignedRole] = raidCounts["total"..assignedRole] + 1
			end
		end

		role[1].text:SetText(raidCounts.totalTANK)
		role[2].text:SetText(raidCounts.totalHEALER)
		role[3].text:SetText(raidCounts.totalDAMAGER)
	end

	local eventList = {
		"GROUP_ROSTER_UPDATE",
		"UPDATE_ACTIVE_BATTLEFIELD",
		"UNIT_FLAGS",
		"PLAYER_FLAGS_CHANGED",
		"PLAYER_ENTERING_WORLD",
	}
	for _, event in next, eventList do
		B:RegisterEvent(event, updateRoleCount)
	end

	parent.roleFrame = frame
end

function M:RaidTool_UpdateRes(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > .1 then
		local charges, _, started, duration = GetSpellCharges(20484)
		if charges then
			local timer = duration - (GetTime() - started)
			if timer < 0 then
				self.Timer:SetText("--:--")
			else
				self.Timer:SetFormattedText("%d:%.2d", timer/60, timer%60)
			end
			self.Count:SetText(charges)
			if charges == 0 then
				self.Count:SetTextColor(1, 0, 0)
			else
				self.Count:SetTextColor(0, 1, 0)
			end
			self.__owner.resFrame:SetAlpha(1)
			self.__owner.roleFrame:SetAlpha(0)
		else
			self.__owner.resFrame:SetAlpha(0)
			self.__owner.roleFrame:SetAlpha(1)
		end

		self.elapsed = 0
	end
end

function M:RaidTool_CombatRes(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	frame:SetAlpha(0)
	local res = CreateFrame("Frame", nil, frame)
	res:SetSize(22, 22)
	res:SetPoint("LEFT", 5, 0)
	B.PixelIcon(res, GetSpellTexture(20484))
	res.__owner = parent

	res.Count = B.CreateFS(res, 16, "0")
	res.Count:ClearAllPoints()
	res.Count:SetPoint("LEFT", res, "RIGHT", 10, 0)
	res.Timer = B.CreateFS(frame, 16, "00:00", false, "RIGHT", -5, 0)
	res:SetScript("OnUpdate", M.RaidTool_UpdateRes)

	parent.resFrame = frame
end

function M:RaidTool_ReadyCheck(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetPoint("TOP", parent, "BOTTOM", 0, -3)
	frame:SetSize(120, 50)
	frame:Hide()
	frame:SetScript("OnMouseUp", function(self) self:Hide() end)
	B.SetBD(frame)
	B.CreateFS(frame, 14, READY_CHECK, true, "TOP", 0, -8)
	local rc = B.CreateFS(frame, 14, "", false, "TOP", 0, -28)

	local count, total
	local function hideRCFrame()
		frame:Hide()
		rc:SetText("")
		count, total = 0, 0
	end

	local function updateReadyCheck(event)
		if event == "READY_CHECK_FINISHED" then
			if count == total then
				rc:SetTextColor(0, 1, 0)
			else
				rc:SetTextColor(1, 0, 0)
			end
			C_Timer_After(5, hideRCFrame)
		else
			count, total = 0, 0

			frame:ClearAllPoints()
			if M:IsFrameOnTop(parent) then
				frame:SetPoint("TOP", parent, "BOTTOM", 0, -3)
			else
				frame:SetPoint("BOTTOM", parent, "TOP", 0, 3)
			end
			frame:Show()

			local maxgroup = M:GetRaidMaxGroup()
			for i = 1, GetNumGroupMembers() do
				local name, _, subgroup, _, _, _, _, online = GetRaidRosterInfo(i)
				if name and online and subgroup <= maxgroup then
					total = total + 1
					local status = GetReadyCheckStatus(name)
					if status and status == "ready" then
						count = count + 1
					end
				end
			end
			rc:SetText(count.." / "..total)
			if count == total then
				rc:SetTextColor(0, 1, 0)
			else
				rc:SetTextColor(1, 1, 0)
			end
		end
	end
	B:RegisterEvent("READY_CHECK", updateReadyCheck)
	B:RegisterEvent("READY_CHECK_CONFIRM", updateReadyCheck)
	B:RegisterEvent("READY_CHECK_FINISHED", updateReadyCheck)
end

function M:RaidTool_Marker(parent)
	local markerButton = CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
	if not markerButton then
		for _, addon in next, {"Blizzard_CUFProfiles", "Blizzard_CompactRaidFrames"} do
			EnableAddOn(addon)
			LoadAddOn(addon)
		end
	end
	if markerButton then
		markerButton:ClearAllPoints()
		markerButton:SetPoint("RIGHT", parent, "LEFT", -3, 0)
		markerButton:SetParent(parent)
		markerButton:SetSize(28, 28)
		if not markerButton.__bg then
			B.Reskin(markerButton)
		end
		markerButton.__bg:Hide()
		B.ReskinMenuButton(markerButton)
		markerButton:SetNormalTexture("Interface\\RaidFrame\\Raid-WorldPing")
		markerButton:GetNormalTexture():SetVertexColor(DB.r, DB.g, DB.b)
		markerButton:HookScript("OnMouseUp", function()
			if (IsInGroup() and not IsInRaid()) or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then return end
			UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_LEADER)
		end)
	end
end

function M:RaidTool_BuffChecker(parent)
	local frame = CreateFrame("Button", nil, parent)
	frame:SetPoint("LEFT", parent, "RIGHT", 3, 0)
	frame:SetSize(28, 28)
	B.CreateFS(frame, 16, "!", true)
	B.ReskinMenuButton(frame)

	local BuffName = {L["Flask"], L["Food"], SPELL_STAT4_NAME, RAID_BUFF_2, RAID_BUFF_3, RUNES}
	local NoBuff, numGroups, numPlayer = {}, 6, 0
	for i = 1, numGroups do NoBuff[i] = {} end

	local debugMode = false
	local function sendMsg(text)
		if debugMode then
			print(text)
		else
			SendChatMessage(text, IsPartyLFG() and "INSTANCE_CHAT" or IsInRaid() and "RAID" or "PARTY")
		end
	end

	local function sendResult(i)
		local count = #NoBuff[i]
		if count > 0 then
			if count >= numPlayer then
				sendMsg(L["Lack"]..BuffName[i]..": "..ALL..PLAYER)
			elseif count >= 5 and i > 2 then
				sendMsg(L["Lack"]..BuffName[i]..": "..format(L["Player Count"], count))
			else
				local str = L["Lack"]..BuffName[i]..": "
				for j = 1, count do
					str = str..NoBuff[i][j]..(j < #NoBuff[i] and ", " or "")
					if #str > 230 then
						sendMsg(str)
						str = ""
					end
				end
				sendMsg(str)
			end
		end
	end

	local function scanBuff()
		for i = 1, numGroups do wipe(NoBuff[i]) end
		numPlayer = 0

		local maxgroup = M:GetRaidMaxGroup()
		for i = 1, GetNumGroupMembers() do
			local name, _, subgroup, _, _, _, _, online, isDead = GetRaidRosterInfo(i)
			if name and online and subgroup <= maxgroup and not isDead then
				numPlayer = numPlayer + 1
				for j = 1, numGroups do
					local HasBuff
					local buffTable = DB.BuffList[j]
					for k = 1, #buffTable do
						local buffName = GetSpellInfo(buffTable[k])
						for index = 1, 32 do
							local currentBuff = UnitAura(name, index)
							if currentBuff and currentBuff == buffName then
								HasBuff = true
								break
							end
						end
					end
					if not HasBuff then
						name = strsplit("-", name)	-- remove realm name
						tinsert(NoBuff[j], name)
					end
				end
			end
		end
		if not C.db["Misc"]["RMRune"] then NoBuff[numGroups] = {} end

		if #NoBuff[1] == 0 and #NoBuff[2] == 0 and #NoBuff[3] == 0 and #NoBuff[4] == 0 and #NoBuff[5] == 0 and #NoBuff[6] == 0 then
			sendMsg(L["Buffs Ready"])
		else
			sendMsg(L["Raid Buff Check"])
			for i = 1, 5 do sendResult(i) end
			if C.db["Misc"]["RMRune"] then sendResult(numGroups) end
		end
	end

	local potionCheck = IsAddOnLoaded("MRT")

	frame:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(L["Raid Tool"], 0,.6,1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(DB.LeftButton..DB.InfoColor..READY_CHECK)
		GameTooltip:AddDoubleLine(DB.ScrollButton..DB.InfoColor..L["Count Down"])
		GameTooltip:AddDoubleLine(DB.RightButton.."(Ctrl) "..DB.InfoColor..L["Check Status"])
		if potionCheck then
			GameTooltip:AddDoubleLine(DB.RightButton.."(Alt) "..DB.InfoColor..L["MRT Potioncheck"])
		end
		GameTooltip:Show()
	end)
	frame:HookScript("OnLeave", B.HideTooltip)

	local reset = true
	B:RegisterEvent("PLAYER_REGEN_ENABLED", function() reset = true end)

	frame:HookScript("OnMouseDown", function(_, btn)
		if btn == "RightButton" then
			if IsAltKeyDown() and potionCheck then
				SlashCmdList["mrtSlash"]("potionchat")
			elseif IsControlKeyDown() then
				scanBuff()
			end
		elseif btn == "LeftButton" then
			if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end
			if IsInGroup() and (UnitIsGroupLeader("player") or (UnitIsGroupAssistant("player") and IsInRaid())) then
				DoReadyCheck()
			else
				UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_LEADER)
			end
		else
			if IsInGroup() and (UnitIsGroupLeader("player") or (UnitIsGroupAssistant("player") and IsInRaid())) then
				if IsAddOnLoaded("DBM-Core") then
					if reset then
						SlashCmdList["DEADLYBOSSMODS"]("pull "..C.db["Misc"]["DBMCount"])
					else
						SlashCmdList["DEADLYBOSSMODS"]("pull 0")
					end
					reset = not reset
				elseif IsAddOnLoaded("BigWigs") then
					if not SlashCmdList["BIGWIGSPULL"] then LoadAddOn("BigWigs_Plugins") end
					if reset then
						SlashCmdList["BIGWIGSPULL"](C.db["Misc"]["DBMCount"])
					else
						SlashCmdList["BIGWIGSPULL"]("0")
					end
					reset = not reset
				else
					UIErrorsFrame:AddMessage(DB.InfoColor..L["DBM Required"])
				end
			else
				UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_LEADER)
			end
		end
	end)
end

function M:RaidTool_CreateMenu(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetPoint("TOP", parent, "BOTTOM", 0, -3)
	frame:SetSize(182, 70)
	B.SetBD(frame)
	frame:Hide()

	local function updateDelay(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed > .1 then
			if not frame:IsMouseOver() then
				self:Hide()
				self:SetScript("OnUpdate", nil)
			end

			self.elapsed = 0
		end
	end

	frame:SetScript("OnLeave", function(self)
		self:SetScript("OnUpdate", updateDelay)
	end)

	StaticPopupDialogs["Group_Disband"] = {
		text = L["Disband Info"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end
			if IsInRaid() then
				SendChatMessage(L["Disband Process"], "RAID")
				for i = 1, GetNumGroupMembers() do
					local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
					if online and name ~= DB.MyName then
						UninviteUnit(name)
					end
				end
			else
				for i = MAX_PARTY_MEMBERS, 1, -1 do
					if UnitExists("party"..i) then
						UninviteUnit(UnitName("party"..i))
					end
				end
			end
			LeaveParty()
		end,
		timeout = 0,
		whileDead = 1,
	}

	local buttons = {
		{TEAM_DISBAND, function()
			if UnitIsGroupLeader("player") then
				StaticPopup_Show("Group_Disband")
			else
				UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_LEADER)
			end
		end},
		{CONVERT_TO_RAID, function()
			if UnitIsGroupLeader("player") and not HasLFGRestrictions() and GetNumGroupMembers() <= 5 then
				if IsInRaid() then ConvertToParty() else ConvertToRaid() end
				frame:Hide()
				frame:SetScript("OnUpdate", nil)
			else
				UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_LEADER)
			end
		end},
		{ROLE_POLL, function()
			if IsInGroup() and not HasLFGRestrictions() and (UnitIsGroupLeader("player") or (UnitIsGroupAssistant("player") and IsInRaid())) then
				InitiateRolePoll()
			else
				UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_LEADER)
			end
		end},
		{RAID_CONTROL, function() ToggleFriendsFrame(3) end},
	}

	local bu = {}
	for i, j in pairs(buttons) do
		bu[i] = B.CreateButton(frame, 84, 28, j[1], 12)
		bu[i]:SetPoint(mod(i, 2) == 0 and "TOPRIGHT" or "TOPLEFT", mod(i, 2) == 0 and -5 or 5, i > 2 and -37 or -5)
		bu[i]:SetScript("OnClick", j[2])
	end

	parent.menu = frame
	parent.buttons = bu
end

function M:RaidTool_EasyMarker()
	local menuList = {}

	local function GetMenuTitle(color, text)
		return (color and B.HexRGB(color) or "")..text
	end

	local function SetRaidTargetByIndex(_, arg1)
		SetRaidTarget("target", arg1)
	end

	if DB.isNewPatch then
		local mixins = {
			UnitPopupRaidTarget8ButtonMixin,
			UnitPopupRaidTarget7ButtonMixin,
			UnitPopupRaidTarget6ButtonMixin,
			UnitPopupRaidTarget5ButtonMixin, 
			UnitPopupRaidTarget4ButtonMixin,
			UnitPopupRaidTarget3ButtonMixin,
			UnitPopupRaidTarget2ButtonMixin,
			UnitPopupRaidTarget1ButtonMixin,
			UnitPopupRaidTargetNoneButtonMixin
		}
		for index, mixin in pairs(mixins) do
			local texCoords = mixin:GetTextureCoords()
			menuList[index] = {
				text = GetMenuTitle(mixin:GetColor(), mixin:GetText()),
				icon = mixin:GetIcon(),
				tCoordLeft = texCoords.tCoordLeft,
				tCoordRight = texCoords.tCoordRight,
				tCoordTop = texCoords.tCoordTop,
				tCoordBottom = texCoords.tCoordBottom,
				arg1 = 9 - index,
				func = SetRaidTargetByIndex,
			}
		end
	else
		local order = {"8", "7", "6", "5", "4", "3", "2", "1", "NONE"}
		for index, value in pairs(order) do
			local blizz = _G.UnitPopupButtons["RAID_TARGET_"..value]
			menuList[index] = {
				text = GetMenuTitle(blizz.color, blizz.text),
				icon = blizz.icon,
				tCoordLeft = blizz.tCoordLeft,
				tCoordRight = blizz.tCoordRight,
				tCoordTop = blizz.tCoordTop,
				tCoordBottom = blizz.tCoordBottom,
				arg1 = 9 - index,
				func = SetRaidTargetByIndex,
			}
		end
	end

	local function GetModifiedState()
		local index = C.db["Misc"]["EasyMarkKey"]
		if index == 1 then
			return IsControlKeyDown()
		elseif index == 2 then
			return IsAltKeyDown()
		elseif index == 3 then
			return IsShiftKeyDown()
		elseif index == 4 then
			return false
		end
	end

	WorldFrame:HookScript("OnMouseDown", function(_, btn)
		if btn == "LeftButton" and GetModifiedState() and UnitExists("mouseover") then
			if not IsInGroup() or (IsInGroup() and not IsInRaid()) or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
				local index = GetRaidTargetIndex("mouseover")
				for i = 1, 8 do
					local menu = menuList[i]
					if menu.arg1 == index then
						menu.checked = true
					else
						menu.checked = false
					end
				end
				EasyMenu(menuList, B.EasyMenu, "cursor", 0, 0, "MENU", 1)
			end
		end
	end)
end

function M:RaidTool_WorldMarker()
	local iconTexture = {
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_6",
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_7",
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_1",
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_2",
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_5",
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_8",
		"Interface\\Buttons\\UI-GroupLoot-Pass-Up",
	}

	local frame = CreateFrame("Frame", "NDui_WorldMarkers", UIParent)
	frame:SetPoint("RIGHT", -100, 0)
	B.CreateMF(frame, nil, true)
	B.RestoreMF(frame)
	B.SetBD(frame)
	frame.buttons = {}

	for i = 1, 9 do
		local button = CreateFrame("Button", nil, frame, "SecureActionButtonTemplate")
		button:SetSize(28, 28)
		B.PixelIcon(button, iconTexture[i], true)
		button.Icon:SetTexture(iconTexture[i])

		if i ~= 9 then
			button:RegisterForClicks("AnyDown")
			button:SetAttribute("type", "macro")
			button:SetAttribute("macrotext1", format("/wm %d", i))
			button:SetAttribute("macrotext2", format("/cwm %d", i))
		else
			button:SetScript("OnClick", ClearRaidMarker)
		end
		frame.buttons[i] = button
	end

	M:RaidTool_UpdateGrid()
end

local markerTypeToRow = {
	[1] = 3,
	[2] = 9,
	[3] = 1,
	[4] = 3,
}
function M:RaidTool_UpdateGrid()
	local frame = _G["NDui_WorldMarkers"]
	if not frame then return end

	local size, margin = C.db["Misc"]["MarkerSize"], 5
	local showType = C.db["Misc"]["ShowMarkerBar"]
	local perRow = markerTypeToRow[showType]

	for i = 1, 9 do
		local button = frame.buttons[i]
		button:SetSize(size, size)
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("TOPLEFT", frame, margin, -margin)
		elseif mod(i-1, perRow) ==  0 then
			button:SetPoint("TOP", frame.buttons[i-perRow], "BOTTOM", 0, -margin)
		else
			button:SetPoint("LEFT", frame.buttons[i-1], "RIGHT", margin, 0)
		end
	end

	local column = min(9, perRow)
	local rows = ceil(9/perRow)
	frame:SetWidth(column*size + (column-1)*margin + 2*margin)
	frame:SetHeight(size*rows + (rows-1)*margin + 2*margin)
	frame:SetShown(showType ~= 4)
end

function M:RaidTool_Misc()
	-- UIWidget reanchor
	if not UIWidgetTopCenterContainerFrame:IsMovable() then -- can be movable for some addons, eg BattleInfo
		UIWidgetTopCenterContainerFrame:ClearAllPoints()
		UIWidgetTopCenterContainerFrame:SetPoint("TOP", 0, -35)
	end
end

function M:RaidTool_Init()
	if not C.db["Misc"]["RaidTool"] then return end

	local frame = M:RaidTool_Header()
	M:RaidTool_RoleCount(frame)
	M:RaidTool_CombatRes(frame)
	M:RaidTool_ReadyCheck(frame)
	M:RaidTool_Marker(frame)
	M:RaidTool_BuffChecker(frame)
	M:RaidTool_CreateMenu(frame)

	M:RaidTool_EasyMarker()
	M:RaidTool_WorldMarker()
	M:RaidTool_Misc()
end
M:RegisterMisc("RaidTool", M.RaidTool_Init)