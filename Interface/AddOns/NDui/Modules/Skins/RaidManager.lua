local B, C, L, DB = unpack(select(2, ...))
local module = NDui:GetModule("Skins")

-- RM Control Panel
function module:CreateRM()
	if not NDuiDB["Skins"]["RM"] then return end

	local RaidManager = CreateFrame("Frame", "RaidManager", UIParent)
	RaidManager:SetSize(200, 85)
	B.CreateBD(RaidManager)
	B.CreateTex(RaidManager)
	RaidManager.State = false

	-- RM Open Button
	local RMOpen = CreateFrame("Button", "RMOpen", UIParent)
	RMOpen:SetScript("OnClick", function() RaidManager:Show() RMOpen:Hide() RaidManager.State = true end)
	RMOpen:SetSize(120, 30)
	B.CreateBD(RMOpen)
	B.CreateFS(RMOpen, 14, L["Raid Tool"], true)
	B.CreateBC(RMOpen, .5)

	-- RM Close Button
	local RMClose = CreateFrame("Button", "RMClose", RaidManager)
	RMClose:SetPoint("TOP", RaidManager, "BOTTOM", 0, 2)
	RMClose:SetScript("OnClick", function() RaidManager:Hide() RMOpen:Show() RaidManager.State = false end)
	RMClose:SetSize(40, 20)
	B.CreateBD(RMClose)
	B.CreateBC(RMClose, .5)
	local icon = RMClose:CreateTexture(nil, "ARTWORK")
	icon:SetPoint("CENTER", 1, 3)
	icon:SetSize(20, 25)
	icon:SetTexture("Interface\\buttons\\Arrow-Up-Up")

	-- RM Mover
	local function RaidManagerGo()
		RaidManager.Mover = B.Mover(RaidManager, L["Raid Tool"], "RaidManager", C.Skins.RMPos, 200, 50)
		RMOpen:SetPoint("TOP", RaidManager.Mover)
	end

	-- Group Disband Button
	local RMDisband = CreateFrame("Button", "RMDisband", RaidManager, "UIMenuButtonStretchTemplate")
	RMDisband:SetPoint("TOPLEFT", RaidManager, "TOPLEFT", 5, -5)
	RMDisband:SetSize(95, 25)
	B.CreateBD(RMDisband, .3)
	B.CreateFS(RMDisband, 12, L["Goup Disband"], true)
	B.CreateBC(RMDisband)
	local GroupDisband = function()
		if InCombatLockdown() then return end
		if IsInRaid() then
			SendChatMessage(L["Disband Process"], "RAID")
			for i = 1, GetNumGroupMembers() do
				local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
				if online and name ~= UnitName("player") then
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
	end
	StaticPopupDialogs["Group_Disband"] = {
		text = L["Disband Info"],
		button1 = YES,
		button2 = NO,
		OnAccept = GroupDisband,
		timeout = 0,
		whileDead = 1,
	}
	RMDisband:SetScript("OnClick", function()
		StaticPopup_Show("Group_Disband")
	end)

	-- Convert Grouptype Button
	local RMConvert = CreateFrame("Button", "RMConvert", RaidManager, "UIMenuButtonStretchTemplate")
	RMConvert:SetPoint("TOPRIGHT", RaidManager, "TOPRIGHT", -5, -5)
	RMConvert:SetSize(95, 25)
	B.CreateBD(RMConvert, .3)
	RMConvert.Text = B.CreateFS(RMConvert, 12, "", true)
	B.CreateBC(RMConvert)
	RMConvert:SetScript("OnClick", function()
		if IsInRaid() then
			ConvertToParty()
		else
			ConvertToRaid()
		end
	end)

	-- Role Check Button
	local RMRole = CreateFrame("Button", "RMRole", RaidManager, "UIMenuButtonStretchTemplate")
	RMRole:SetPoint("TOP", RMDisband, "BOTTOM", 0, 0)
	RMRole:SetSize(95, 25)
	B.CreateBD(RMRole, .3)
	B.CreateFS(RMRole, 12, ROLE_POLL, true)
	B.CreateBC(RMRole)
	RMRole:SetScript("OnClick", InitiateRolePoll)

	-- Ready Check Button
	local RMReady = CreateFrame("Button", "RMReady", RaidManager, "UIMenuButtonStretchTemplate")
	RMReady:SetPoint("TOP", RMConvert, "BOTTOM", 0, 0)
	RMReady:SetSize(95, 25)
	B.CreateBD(RMReady, .3)
	B.CreateFS(RMReady, 12, READY_CHECK, true)
	B.CreateBC(RMReady)
	RMReady:SetScript("OnClick", DoReadyCheck)

	-- Raid Control Button
	local RMControl = CreateFrame("Button", "RMControl", RaidManager, "UIMenuButtonStretchTemplate")
	RMControl:SetPoint("TOP", RMRole, "BOTTOM", 0, 0)
	RMControl:SetSize(95, 25)
	B.CreateBD(RMControl, .3)
	B.CreateFS(RMControl, 12, RAID_CONTROL, true)
	B.CreateBC(RMControl)
	RMControl:SetScript("OnClick", function() ToggleFriendsFrame(4) end)

	-- Everyone Assist Button
	local RMEveryone = CreateFrame("Frame", "RMEveryone", RaidManager)
	RMEveryone:SetPoint("LEFT", RMControl, "RIGHT", 10, 0)
	RMEveryone:SetSize(55, 25)
	B.CreateFS(RMEveryone, 12, ALL_ASSIST_LABEL, true)
	RMEveryone:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(ALL_ASSIST_DESCRIPTION, 1, .8, 0, 1)
		if not RaidFrameAllAssistCheckButton:IsEnabled() then
			GameTooltip:AddLine(ALL_ASSIST_NOT_LEADER_ERROR, 1, 0, 0)
		end
		GameTooltip:Show()
	end)
	RMEveryone:SetScript("OnLeave", GameTooltip_Hide)

	local RMEveryoneCB = CreateFrame("CheckButton", "RMEveryoneCB", RaidManager, "OptionsCheckButtonTemplate")
	RMEveryoneCB:SetPoint("LEFT", RMEveryone, "RIGHT", 0, 0)
	B.CreateCB(RMEveryoneCB, .3)
	RMEveryoneCB:SetScript("OnClick", function(self)
		if self.enabled then
			PlaySound("igMainMenuOptionCheckBoxOn")
		else
			PlaySound("igMainMenuOptionCheckBoxOff")
		end
		SetEveryoneIsAssistant(self:GetChecked())
	end)

	-- World Marker Button
	local RMWmark = CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
	RMWmark:ClearAllPoints()
	RMWmark:SetPoint("RIGHT", RMOpen, "LEFT", 0, 0)
	RMWmark:SetParent(RMOpen)
	RMWmark:SetSize(30, 30)
	RMWmark:GetNormalTexture():SetVertexColor(DB.cc.r, DB.cc.g, DB.cc.b)
	RMWmark.SetNormalTexture = function() end
	RMWmark.SetPushedTexture = function() end
	B.CreateBD(RMWmark)
	B.CreateBC(RMWmark)
	RMWmark:HookScript("OnMouseUp", function(self, btn)
		self:SetBackdropColor(0, 0, 0, .3)
		if btn == "RightButton" then
			ClearRaidMarker()
		end
	end)

	-- Buff Check Button
	local RMBuff = CreateFrame("Button", "RMBuff", RMOpen, "UIMenuButtonStretchTemplate")
	RMBuff:SetPoint("LEFT", RMOpen, "RIGHT", 0, 0)
	RMBuff:SetSize(30, 30)
	B.CreateBD(RMBuff)
	B.CreateFS(RMBuff, 16, "!", true)
	B.CreateBC(RMBuff, .5)

	local function GetRaidMaxGroup()
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

	local BuffName = {
		L["Flask"], L["Food"], RUNES
	}

	local function ScanBuff()
		local NoBuff, numPlayer = {}, 0
		for i = 1, 3 do NoBuff[i] = {} end
		for i = 1, GetNumGroupMembers() do
			local name, _, subgroup, _, _, class, _, online, isDead = GetRaidRosterInfo(i)
			local maxgroup = GetRaidMaxGroup()
			if name and online and subgroup <= maxgroup and not isDead then
				numPlayer = numPlayer + 1
				for j = 1, 3 do
					local HasBuff
					local buffTable = DB.BuffList[j]
					for k = 1, #buffTable do
						local buffname = GetSpellInfo(buffTable[k])
						if UnitAura(name, buffname) then
							HasBuff = true
							break
						end
					end
					if not HasBuff then
						name = strsplit("-", name)	-- remove realm name
						table.insert(NoBuff[j], name)
					end
				end
			end
		end
		if not NDuiDB["Skins"]["RMRune"] then NoBuff[3] = {} end

		local debugMode = false
		local function SendMsg(text)
			if debugMode then
				print(text)
			else
				SendChatMessage(text, IsPartyLFG() and "INSTANCE_CHAT" or IsInRaid() and "RAID" or "PARTY")
			end
		end
		local function SendResult(i)
			if #NoBuff[i] > 0 then
				if #NoBuff[i] >= numPlayer then
					SendMsg(L["Lack"]..BuffName[i]..": "..ALL..PLAYER)
				else
					SendMsg(L["Lack"]..BuffName[i]..": "..table.concat(NoBuff[i], ", "))
				end
			end
		end

		if #NoBuff[1] == 0 and #NoBuff[2] == 0 and #NoBuff[3] == 0 then
			SendMsg(L["Buffs Ready"])
		else
			SendMsg(L["Raid Buff Check"])
			for i = 1, 2 do SendResult(i) end
			if NDuiDB["Skins"]["RMRune"] then SendResult(3) end
		end
	end

	RMBuff:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(L["Raid Tool"], 0,.6,1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(DB.LeftButton..DB.InfoColor..READY_CHECK)
		GameTooltip:AddLine(DB.ScrollButton..DB.InfoColor..L["Count Down"])
		GameTooltip:AddLine(DB.RightButton..DB.InfoColor..L["Check Status"])
		GameTooltip:Show()
		self:SetBackdropBorderColor(DB.cc.r, DB.cc.g, DB.cc.b, 1)
	end)
	RMBuff:HookScript("OnLeave", GameTooltip_Hide)

	local reset = true
	RMBuff:RegisterForClicks("AnyUp")
	RMBuff:SetScript("OnClick", function(self, button)
		if button == "RightButton" then
			ScanBuff()
		elseif button == "LeftButton" then
			if InCombatLockdown() then return end
			DoReadyCheck()
		else
			if IsAddOnLoaded("DBM-Core") then
				if reset then
					SlashCmdList["DEADLYBOSSMODS"]("pull "..NDuiDB["Skins"]["DBMCount"])
				else
					SlashCmdList["DEADLYBOSSMODS"]("pull 0")
				end
				reset = not reset
			else
				UIErrorsFrame:AddMessage(DB.InfoColor..L["DBM Required"])
			end
		end
	end)
	RMBuff:RegisterEvent("PLAYER_REGEN_ENABLED")
	RMBuff:SetScript("OnEvent", function(self) reset = true end)

	-- Reskin Buttons
	do
		local rmbtns = {
			"RMOpen",
			"RMClose",
			"RMDisband",
			"RMConvert",
			"RMRole",
			"RMReady",
			"RMControl",
			"RMBuff",
			"CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton"
		}
		for _, button in pairs(rmbtns) do
			local f = _G[button]
			for i = 1, 9 do
				select(i, f:GetRegions()):SetAlpha(0)
			end
		end
	end

	-- Event
	RaidManager:RegisterEvent("GROUP_ROSTER_UPDATE")
	RaidManager:RegisterEvent("PLAYER_ENTERING_WORLD")
	RaidManager:SetScript("OnEvent", function(self)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		if not self.styled then
			RaidManagerGo()
			self.styled = true
		end
		if self.styled then
			-- MainPanel
			if IsInGroup() then
				if RaidManager.State then
					self:Show()
					RMOpen:Hide()
				else
					self:Hide()
					RMOpen:Show()
				end
			else
				self:Hide()
				RMOpen:Hide()
			end
			-- Disband Button
			if UnitIsGroupLeader("player") then
				RMDisband:Enable()
				RMDisband:SetAlpha(1)
			else
				RMDisband:Disable()
				RMDisband:SetAlpha(.5)
			end
			-- Grouptype Convert
			if IsInRaid() then
				RMConvert.Text:SetText(CONVERT_TO_PARTY)
			else
				RMConvert.Text:SetText(CONVERT_TO_RAID)
			end
			if UnitIsGroupLeader("player") and not HasLFGRestrictions() then
				RMConvert:Enable()
				RMConvert:SetAlpha(1)
			else
				RMConvert:Disable()
				RMConvert:SetAlpha(.5)
			end
			-- Role Pole
			if IsInGroup() and not HasLFGRestrictions() and (UnitIsGroupLeader("player") or (UnitIsGroupAssistant("player") and IsInRaid())) then
				RMRole:Enable()
				RMRole:SetAlpha(1)
			else
				RMRole:Disable()
				RMRole:SetAlpha(.5)
			end
			-- Ready Check
			if IsInGroup() and (UnitIsGroupLeader("player") or (UnitIsGroupAssistant("player") and IsInRaid())) then
				RMReady:Enable()
				RMReady:SetAlpha(1)
			else
				RMReady:Disable()
				RMReady:SetAlpha(.5)
			end
			-- World Marker
			if (IsInGroup() and not IsInRaid()) or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
				RMWmark:Enable()
				RMWmark:SetAlpha(1)
			else
				RMWmark:Disable()
				RMWmark:SetAlpha(.5)
			end
			-- All Assist Checkbox
			RMEveryoneCB:SetChecked(RaidFrameAllAssistCheckButton:GetChecked())
			if IsInRaid() and UnitIsGroupLeader("player") then
				RMEveryoneCB:Enable()
				RMEveryoneCB:SetAlpha(1)
				RMEveryone:SetAlpha(1)
			else
				RMEveryoneCB:Disable()
				RMEveryoneCB:SetAlpha(.5)
				RMEveryone:SetAlpha(.5)
			end
		end
	end)
end

-- Easymarking Menu
local menuFrame = CreateFrame("Frame", "NDui_EastMarking", UIParent, "UIDropDownMenuTemplate")
local menuList = {
	{text = RAID_TARGET_NONE, func = function() SetRaidTarget("target", 0) end},
	{text = B.HexRGB(1, .92, 0)..RAID_TARGET_1.." "..ICON_LIST[1].."12|t", func = function() SetRaidTarget("target", 1) end},
	{text = B.HexRGB(.98, .57, 0)..RAID_TARGET_2.." "..ICON_LIST[2].."12|t", func = function() SetRaidTarget("target", 2) end},
	{text = B.HexRGB(.83, .22, .9)..RAID_TARGET_3.." "..ICON_LIST[3].."12|t", func = function() SetRaidTarget("target", 3) end},
	{text = B.HexRGB(.04, .95, 0)..RAID_TARGET_4.." "..ICON_LIST[4].."12|t", func = function() SetRaidTarget("target", 4) end},
	{text = B.HexRGB(.7, .82, .875)..RAID_TARGET_5.." "..ICON_LIST[5].."12|t", func = function() SetRaidTarget("target", 5) end},
	{text = B.HexRGB(0, .71, 1)..RAID_TARGET_6.." "..ICON_LIST[6].."12|t", func = function() SetRaidTarget("target", 6) end},
	{text = B.HexRGB(1, .24, .168)..RAID_TARGET_7.." "..ICON_LIST[7].."12|t", func = function() SetRaidTarget("target", 7) end},
	{text = B.HexRGB(.98, .98, .98)..RAID_TARGET_8.." "..ICON_LIST[8].."12|t", func = function() SetRaidTarget("target", 8) end},
}

WorldFrame:HookScript("OnMouseDown", function(self, btn)
	if not NDuiDB["Skins"]["EasyMarking"] then return end
	if btn == "LeftButton" and IsControlKeyDown() and UnitExists("mouseover") then
		if not IsInGroup() or (IsInGroup() and not IsInRaid()) or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
			local ricon = GetRaidTargetIndex("mouseover")
			for i = 1, 8 do
				if ricon == i then
					menuList[i+1].checked = true
				else
					menuList[i+1].checked = false
				end
			end
			EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 1)
		end
	end
end)