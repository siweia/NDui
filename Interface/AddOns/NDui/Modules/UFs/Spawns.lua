local _, ns = ...
local B, C, L, DB = unpack(ns)

local oUF = ns.oUF
local UF = B:GetModule("UnitFrames")
local tostring = tostring

-- Units
local UFRangeAlpha = {insideAlpha = 1, outsideAlpha = .4}

local function SetUnitFrameSize(self, unit)
	local width = C.db["UFs"][unit.."Width"]
	local height = C.db["UFs"][unit.."Height"] + C.db["UFs"][unit.."PowerHeight"] + C.mult
	self:SetSize(width, height)
end

local function CreatePlayerStyle(self)
	self.mystyle = "player"
	SetUnitFrameSize(self, "Player")

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreatePowerText(self)
	UF:CreatePortrait(self)
	UF:CreateCastBar(self)
	UF:CreateRaidMark(self)
	UF:CreateIcons(self)
	UF:CreatePrediction(self)
	UF:CreateFCT(self)
	UF:CreateAddPower(self)
	UF:CreateClassPower(self)
	UF:CreateEneryTicker(self)
	UF:CreateAuras(self)
	UF:CreateSwing(self)

	if C.db["UFs"]["Castbars"] then
		UF:ReskinMirrorBars()
		--UF:ReskinTimerTrakcer(self)
	end
	if not C.db["Misc"]["ExpRep"] then UF:CreateExpRepBar(self) end
end

local function CreateTargetStyle(self)
	self.mystyle = "target"
	SetUnitFrameSize(self, "Player")

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreatePowerText(self)
	UF:CreatePortrait(self)
	UF:CreateCastBar(self)
	UF:CreateRaidMark(self)
	UF:CreateIcons(self)
	UF:CreatePrediction(self)
	UF:CreateFCT(self)
	UF:CreateAuras(self)
end

local function CreateFocusStyle(self)
	self.mystyle = "focus"
	SetUnitFrameSize(self, "Focus")

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreatePowerText(self)
	UF:CreatePortrait(self)
	UF:CreateCastBar(self)
	UF:CreateRaidMark(self)
	UF:CreateIcons(self)
	UF:CreatePrediction(self)
	UF:CreateAuras(self)
end

local function CreateToTStyle(self)
	self.mystyle = "tot"
	SetUnitFrameSize(self, "Pet")

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreateRaidMark(self)
	UF:CreateAuras(self)
end

local function CreateToToT(self)
	self.mystyle = "tot"
	SetUnitFrameSize(self, "Pet")

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreateRaidMark(self)
end

local function CreateFocusTargetStyle(self)
	self.mystyle = "focustarget"
	SetUnitFrameSize(self, "Pet")

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreateRaidMark(self)
end

local function CreatePetStyle(self)
	self.mystyle = "pet"
	SetUnitFrameSize(self, "Pet")

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreateRaidMark(self)
	UF:CreateAuras(self)
end

local function CreateArenaStyle(self)
	self.mystyle = "arena"
	SetUnitFrameSize(self, "Boss")

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreatePowerText(self)
	UF:CreateCastBar(self)
	UF:CreateRaidMark(self)
	UF:CreateBuffs(self)
	UF:CreateDebuffs(self)
--	UF:CreatePVPClassify(self)
end

local function CreateRaidStyle(self)
	self.mystyle = "raid"
	self.Range = UFRangeAlpha
	self.disableTooltip = C.db["UFs"]["HideTip"]

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreateRaidMark(self)
	UF:CreateIcons(self)
	UF:CreateTargetBorder(self)
	UF:CreateRaidIcons(self)
	UF:CreatePrediction(self)
	UF:CreateClickSets(self)
	UF:CreateRaidDebuffs(self)
	UF:CreateThreatBorder(self)
	UF:CreateAuras(self)
	UF:CreateBuffs(self)
	UF:CreateDebuffs(self)
	UF:RefreshAurasByCombat(self)
	UF:CreateBuffIndicator(self)
end

local function CreateSimpleRaidStyle(self)
	self.raidType = "simple"
	CreateRaidStyle(self)
end

local function CreatePartyStyle(self)
	self.raidType = "party"
	CreateRaidStyle(self)
end

local function CreatePartyPetStyle(self)
	self.mystyle = "raid"
	self.raidType = "pet"
	self.Range = UFRangeAlpha
	self.disableTooltip = C.db["UFs"]["HideTip"]

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreateRaidMark(self)
	UF:CreateTargetBorder(self)
	UF:CreatePrediction(self)
	UF:CreateClickSets(self)
	UF:CreateThreatBorder(self)
end

-- Spawns
local function GetPartyVisibility()
	local visibility = "[group:party,nogroup:raid] show;hide"
	if C.db["UFs"]["SmartRaid"] then
		visibility = "[@raid6,noexists,group] show;hide"
	end
	if C.db["UFs"]["ShowSolo"] then
		visibility = "[nogroup] show;"..visibility
	end
	return visibility
end

local function GetRaidVisibility()
	local visibility
	if C.db["UFs"]["PartyFrame"] then
		if C.db["UFs"]["SmartRaid"] then
			visibility = "[@raid6,exists] show;hide"
		else
			visibility = "[group:raid] show;hide"
		end
	else
		if C.db["UFs"]["ShowSolo"] then
			visibility = "show"
		else
			visibility = "[group] show;hide"
		end
	end
	return visibility
end

local function GetPartyPetVisibility()
	local visibility
	if C.db["UFs"]["PartyPetVsby"] == 1 then
		if C.db["UFs"]["SmartRaid"] then
			visibility = "[@raid6,noexists,group] show;hide"
		else
			visibility = "[group:party,nogroup:raid] show;hide"
		end
	elseif C.db["UFs"]["PartyPetVsby"] == 2 then
		if C.db["UFs"]["SmartRaid"] then
			visibility = "[@raid6,exists] show;hide"
		else
			visibility = "[group:raid] show;hide"
		end
	elseif C.db["UFs"]["PartyPetVsby"] == 3 then
		visibility = "[group] show;hide"
	end
	if C.db["UFs"]["ShowSolo"] then
		visibility = "[nogroup] show;"..visibility
	end
	return visibility
end

function UF:UpdateAllHeaders()
	if not UF.headers then return end

	for _, header in pairs(UF.headers) do
		if header.groupType == "party" then
			RegisterStateDriver(header, "visibility", GetPartyVisibility())
		elseif header.groupType == "pet" then
			RegisterStateDriver(header, "visibility", GetPartyPetVisibility())
		elseif header.groupType == "raid" then
			if header.__disabled then
				RegisterStateDriver(header, "visibility", "hide")
			else
				RegisterStateDriver(header, "visibility", GetRaidVisibility())
			end
		end
	end
end

local function GetGroupFilterByIndex(numGroups)
	local groupFilter
	for i = 1, numGroups do
		if not groupFilter then
			groupFilter = i
		else
			groupFilter = groupFilter..","..i
		end
	end
	return groupFilter
end

local function ResetHeaderPoints(header)
	for i = 1, header:GetNumChildren() do
		select(i, header:GetChildren()):ClearAllPoints()
	end
end

UF.PartyDirections = {
	[1] = {name = L["GO_DOWN"], point = "TOP", xOffset = 0, yOffset = -5, initAnchor = "TOPLEFT", order = "TANK,HEALER,DAMAGER,NONE"},
	[2] = {name = L["GO_UP"], point = "BOTTOM", xOffset = 0, yOffset = 5, initAnchor = "BOTTOMLEFT", order = "NONE,DAMAGER,HEALER,TANK"},
	[3] = {name = L["GO_RIGHT"], point = "LEFT", xOffset = 5, yOffset = 0, initAnchor = "TOPLEFT", order = "TANK,HEALER,DAMAGER,NONE"},
	[4] = {name = L["GO_LEFT"], point = "RIGHT", xOffset = -5, yOffset = 0, initAnchor = "TOPRIGHT", order = "NONE,DAMAGER,HEALER,TANK"},
}

UF.RaidDirections = {
	[1] = {name = L["DOWN_RIGHT"], point = "TOP", xOffset = 0, yOffset = -5, initAnchor = "TOPLEFT", relAnchor = "TOPRIGHT", x = 5, y = 0, columnAnchorPoint = "LEFT", multX = 1, multY = -1},
	[2] = {name = L["DOWN_LEFT"], point = "TOP", xOffset = 0, yOffset = -5, initAnchor = "TOPRIGHT", relAnchor = "TOPLEFT", x = -5, y = 0, columnAnchorPoint = "RIGHT", multX = -1, multY = -1},
	[3] = {name = L["UP_RIGHT"], point = "BOTTOM", xOffset = 0, yOffset = 5, initAnchor = "BOTTOMLEFT", relAnchor = "BOTTOMRIGHT", x = 5, y = 0, columnAnchorPoint = "LEFT", multX = 1, multY = 1},
	[4] = {name = L["UP_LEFT"], point = "BOTTOM", xOffset = 0, yOffset = 5, initAnchor = "BOTTOMRIGHT", relAnchor = "BOTTOMLEFT", x = -5, y = 0, columnAnchorPoint = "RIGHT", multX = -1, multY = 1},
	[5] = {name = L["RIGHT_DOWN"], point = "LEFT", xOffset = 5, yOffset = 0, initAnchor = "TOPLEFT", relAnchor = "BOTTOMLEFT", x = 0, y = -5, columnAnchorPoint = "TOP", multX = 1, multY = -1},
	[6] = {name = L["RIGHT_UP"], point = "LEFT", xOffset = 5, yOffset = 0, initAnchor = "BOTTOMLEFT", relAnchor = "TOPLEFT", x = 0, y = 5, columnAnchorPoint = "BOTTOM", multX = 1, multY = 1},
	[7] = {name = L["LEFT_DOWN"], point = "RIGHT", xOffset = -5, yOffset = 0, initAnchor = "TOPRIGHT", relAnchor = "BOTTOMRIGHT", x = 0, y = -5, columnAnchorPoint = "TOP", multX = -1, multY = -1},
	[8] = {name = L["LEFT_UP"], point = "RIGHT", xOffset = -5, yOffset = 0, initAnchor = "BOTTOMRIGHT", relAnchor = "TOPRIGHT", x = 0, y = 5, columnAnchorPoint = "BOTTOM", multX = -1, multY = 1},
}

function UF:OnLogin()
	if C.db["Nameplate"]["Enable"] then
		UF:SetupCVars()
		UF:BlockAddons()
		UF:CreateUnitTable()
		UF:CreatePowerUnitTable()
		UF:QuestIconCheck()
		UF:RefreshPlateByEvents()
		UF:RefreshMajorSpells()

		oUF:RegisterStyle("Nameplates", UF.CreatePlates)
		oUF:SetActiveStyle("Nameplates")
		oUF:SpawnNamePlates("oUF_NPs", UF.PostUpdatePlates)
	end

	do -- a playerplate-like PlayerFrame
		oUF:RegisterStyle("PlayerPlate", UF.CreatePlayerPlate)
		oUF:SetActiveStyle("PlayerPlate")
		local plate = oUF:Spawn("player", "oUF_PlayerPlate", true)
		plate.mover = B.Mover(plate, L["PlayerPlate"], "PlayerPlate", C.UFs.PlayerPlate)
		UF:TogglePlayerPlate()
	end

	do	-- fake nameplate for target class power
		oUF:RegisterStyle("TargetPlate", UF.CreateTargetPlate)
		oUF:SetActiveStyle("TargetPlate")
		oUF:Spawn("player", "oUF_TargetPlate", true)
		UF:ToggleTargetClassPower()
	end

	-- Default Clicksets for RaidFrame
	UF:DefaultClickSets()

	if C.db["UFs"]["Enable"] then
		-- Register
		oUF:RegisterStyle("Player", CreatePlayerStyle)
		oUF:RegisterStyle("Target", CreateTargetStyle)
		oUF:RegisterStyle("ToT", CreateToTStyle)
		--oUF:RegisterStyle("Focus", CreateFocusStyle)
		oUF:RegisterStyle("FocusTarget", CreateFocusTargetStyle)
		oUF:RegisterStyle("Pet", CreatePetStyle)

		-- Loader
		oUF:SetActiveStyle("Player")
		local player = oUF:Spawn("player", "oUF_Player")
		B.Mover(player, L["PlayerUF"], "PlayerUF", C.UFs.PlayerPos)
		UF.ToggleCastBar(player, "Player")

		oUF:SetActiveStyle("Target")
		local target = oUF:Spawn("target", "oUF_Target")
		B.Mover(target, L["TargetUF"], "TargetUF", C.UFs.TargetPos)
		UF.ToggleCastBar(target, "Target")

		oUF:SetActiveStyle("ToT")
		local targettarget = oUF:Spawn("targettarget", "oUF_ToT")
		B.Mover(targettarget, L["TotUF"], "TotUF", C.UFs.ToTPos)

		oUF:SetActiveStyle("Pet")
		local pet = oUF:Spawn("pet", "oUF_Pet")
		B.Mover(pet, L["PetUF"], "PetUF", C.UFs.PetPos)
--[[
		oUF:SetActiveStyle("Focus")
		local focus = oUF:Spawn("focus", "oUF_Focus")
		B.Mover(focus, L["FocusUF"], "FocusUF", C.UFs.FocusPos)
		UF.ToggleCastBar(focus, "Focus")

		oUF:SetActiveStyle("FocusTarget")
		local focustarget = oUF:Spawn("focustarget", "oUF_FocusTarget")
		B.Mover(focustarget, L["FotUF"], "FotUF", {"TOPLEFT", oUF_Focus, "TOPRIGHT", 5, 0})]]

		if C.db["UFs"]["ToToT"] then
			oUF:RegisterStyle("ToToT", CreateToToT)
			oUF:SetActiveStyle("ToToT")
			local targettargettarget = oUF:Spawn("targettargettarget", "oUF_ToToT")
			B.Mover(targettargettarget, L["TototUF"], "TototUF", C.UFs.ToToTPos)
		end
--[[
		if C.db["UFs"]["Arena"] then
			oUF:RegisterStyle("Arena", CreateArenaStyle)
			oUF:SetActiveStyle("Arena")
			local arena = {}
			for i = 1, 5 do
				arena[i] = oUF:Spawn("arena"..i, "oUF_Arena"..i)
				local moverWidth, moverHeight = arena[i]:GetWidth(), arena[i]:GetHeight()+8
				if i == 1 then
					arena[i].mover = B.Mover(arena[i], L["ArenaFrame"]..i, "Arena1", {"RIGHT", UIParent, "RIGHT", -350, -90}, moverWidth, moverHeight)
				else
					arena[i].mover = B.Mover(arena[i], L["ArenaFrame"]..i, "Arena"..i, {"BOTTOMLEFT", arena[i-1], "TOPLEFT", 0, 50}, moverWidth, moverHeight)
				end
			end
		end]]

		UF:ToggleSwingBars()
		UF:ToggleUFClassPower()
		UF:UpdateTextScale()
		UF:ToggleAllAuras()
	end

	if C.db["UFs"]["RaidFrame"] then
		UF:AddClickSetsListener()
		UF:UpdateCornerSpells()
		UF:BuildNameListFromID()
		UF.headers = {}

		-- Hide Default RaidFrame
		if CompactRaidFrameManager_SetSetting then
			CompactRaidFrameManager_SetSetting("IsShown", "0")
			UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")
			CompactRaidFrameManager:UnregisterAllEvents()
			CompactRaidFrameManager:SetParent(B.HiddenFrame)
		end

		-- Group Styles
		local partyMover
		if C.db["UFs"]["PartyFrame"] then
			local party
			oUF:RegisterStyle("Party", CreatePartyStyle)
			oUF:SetActiveStyle("Party")

			local function CreatePartyHeader(name, width, height)
				local group = oUF:SpawnHeader(name, nil, nil,
				"showPlayer", true,
				"showSolo", true,
				"showParty", true,
				"showRaid", true,
				"sortMethod", "NAME",
				"columnAnchorPoint", "LEFT",
				"oUF-initialConfigFunction", ([[
					self:SetWidth(%d)
					self:SetHeight(%d)
				]]):format(width, height))
				return group
			end

			function UF:CreateAndUpdatePartyHeader()
				local index = C.db["UFs"]["PartyDirec"]
				local sortData = UF.PartyDirections[index]
				local partyWidth, partyHeight = C.db["UFs"]["PartyWidth"], C.db["UFs"]["PartyHeight"]
				local partyFrameHeight = partyHeight + C.db["UFs"]["PartyPowerHeight"] + C.mult

				if not party then
					party = CreatePartyHeader("oUF_Party", partyWidth, partyFrameHeight)
					party.groupType = "party"
					tinsert(UF.headers, party)
					RegisterStateDriver(party, "visibility", GetPartyVisibility())
					partyMover = B.Mover(party, L["PartyFrame"], "PartyFrame", {"LEFT", UIParent, 350, 0})
				end

				local moverWidth = index < 3 and partyWidth or (partyWidth+5)*5-5
				local moverHeight = index < 3 and (partyFrameHeight+5)*5-5 or partyFrameHeight
				partyMover:SetSize(moverWidth, moverHeight)
				party:ClearAllPoints()
				party:SetPoint(sortData.initAnchor, partyMover)

				ResetHeaderPoints(party)
				party:SetAttribute("point", sortData.point)
				party:SetAttribute("xOffset", sortData.xOffset)
				party:SetAttribute("yOffset", sortData.yOffset)
				party:SetAttribute("groupingOrder", sortData.order)
				party:SetAttribute("groupBy", "ASSIGNEDROLE")
			end

			UF:CreateAndUpdatePartyHeader()

			if C.db["UFs"]["PartyPetFrame"] then
				local partyPet, petMover
				oUF:RegisterStyle("PartyPet", CreatePartyPetStyle)
				oUF:SetActiveStyle("PartyPet")

				local function CreatePetGroup(name, width, height)
					local group = oUF:SpawnHeader(name, "SecureGroupPetHeaderTemplate", nil,
					"showPlayer", true,
					"showSolo", true,
					"showParty", true,
					"showRaid", true,
					"columnSpacing", 5,
					"oUF-initialConfigFunction", ([[
						self:SetWidth(%d)
						self:SetHeight(%d)
					]]):format(width, height))
					return group
				end

				function UF:UpdatePartyPetHeader()
					local petWidth, petHeight, petPowerHeight = C.db["UFs"]["PartyPetWidth"], C.db["UFs"]["PartyPetHeight"], C.db["UFs"]["PartyPetPowerHeight"]
					local petFrameHeight = petHeight + petPowerHeight + C.mult
					local petsPerColumn = C.db["UFs"]["PartyPetPerCol"]
					local maxColumns = C.db["UFs"]["PartyPetMaxCol"]
					local index = C.db["UFs"]["PetDirec"]
					local sortData = UF.RaidDirections[index]

					if not partyPet then
						partyPet = CreatePetGroup("oUF_PartyPet", petWidth, petFrameHeight)
						partyPet.groupType = "pet"
						tinsert(UF.headers, partyPet)
						RegisterStateDriver(partyPet, "visibility", GetPartyPetVisibility())
						petMover = B.Mover(partyPet, L["PartyPetFrame"], "PartyPet", {"TOPLEFT", partyMover, "BOTTOMLEFT", 0, -5})
					end
					ResetHeaderPoints(partyPet)

					partyPet:SetAttribute("point", sortData.point)
					partyPet:SetAttribute("xOffset", sortData.xOffset)
					partyPet:SetAttribute("yOffset", sortData.yOffset)
					partyPet:SetAttribute("columnAnchorPoint", sortData.columnAnchorPoint)
					partyPet:SetAttribute("unitsPerColumn", petsPerColumn)
					partyPet:SetAttribute("maxColumns", maxColumns)

					local moverWidth = (petWidth+5)*maxColumns - 5
					local moverHeight = (petFrameHeight+5)*petsPerColumn - 5
					if index > 4 then
						moverWidth = (petWidth+5)*petsPerColumn - 5
						moverHeight = (petFrameHeight+5)*maxColumns - 5
					end
					petMover:SetSize(moverWidth, moverHeight)
					partyPet:ClearAllPoints()
					partyPet:SetPoint(sortData.initAnchor, petMover)
				end

				UF:UpdatePartyPetHeader()
			end
		end

		local raidMover
		if C.db["UFs"]["SimpleMode"] then
			oUF:RegisterStyle("Raid", CreateSimpleRaidStyle)
			oUF:SetActiveStyle("Raid")

			local scale = C.db["UFs"]["SMRScale"]/10
			local sortData = UF.RaidDirections[C.db["UFs"]["SMRDirec"]]

			local function CreateGroup(name)
				local group = oUF:SpawnHeader(name, nil, nil,
				"showPlayer", true,
				"showSolo", true,
				"showParty", true,
				"showRaid", true,
				"point", sortData.point,
				"xOffset", sortData.xOffset,
				"yOffset", sortData.yOffset,
				"columnSpacing", 5,
				"columnAnchorPoint", sortData.columnAnchorPoint,
				"oUF-initialConfigFunction", ([[
					self:SetWidth(%d)
					self:SetHeight(%d)
				]]):format(100*scale, 20*scale))
				return group
			end

			local group = CreateGroup("oUF_Raid")
			group.groupType = "raid"
			tinsert(UF.headers, group)
			RegisterStateDriver(group, "visibility", GetRaidVisibility())
			raidMover = B.Mover(group, L["RaidFrame"], "RaidFrame", {"TOPLEFT", UIParent, 35, -50})
			group:ClearAllPoints()
			group:SetPoint(sortData.initAnchor, raidMover)

			local groupByTypes = {
				[1] = {"1,2,3,4,5,6,7,8", "GROUP", "INDEX"},
				[2] = {"WARRIOR,ROGUE,PALADIN,DRUID,SHAMAN,HUNTER,PRIEST,MAGE,WARLOCK", "CLASS", "NAME"},
			}
			function UF:UpdateSimpleModeHeader()
				ResetHeaderPoints(group)

				local groupByIndex = C.db["UFs"]["SMRGroupBy"]
				local unitsPerColumn = C.db["UFs"]["SMRPerCol"]
				local numGroups = C.db["UFs"]["SMRGroups"]
				local scale = C.db["UFs"]["SMRScale"]/10
				local maxColumns = ceil(numGroups*5 / unitsPerColumn)

				group:SetAttribute("groupingOrder", groupByTypes[groupByIndex][1])
				group:SetAttribute("groupBy", groupByTypes[groupByIndex][2])
				group:SetAttribute("sortMethod", groupByTypes[groupByIndex][3])
				group:SetAttribute("groupFilter", GetGroupFilterByIndex(numGroups))
				group:SetAttribute("unitsPerColumn", unitsPerColumn)
				group:SetAttribute("maxColumns", maxColumns)

				local moverWidth = (100*scale*maxColumns + 5*(maxColumns-1))
				local moverHeight = 20*scale*unitsPerColumn + 5*(unitsPerColumn-1)
				raidMover:SetSize(moverWidth, moverHeight)
			end

			UF:UpdateSimpleModeHeader()
		else
			oUF:RegisterStyle("Raid", CreateRaidStyle)
			oUF:SetActiveStyle("Raid")

			local function CreateGroup(name, i, width, height)
				local group = oUF:SpawnHeader(name, nil, nil,
				"showPlayer", true,
				"showSolo", true,
				"showParty", true,
				"showRaid", true,
				"groupFilter", tostring(i),
				"groupingOrder", "1,2,3,4,5,6,7,8",
				"groupBy", "GROUP",
				"sortMethod", "INDEX",
				"maxColumns", 1,
				"unitsPerColumn", 5,
				"columnSpacing", 5,
				"columnAnchorPoint", "LEFT",
				"oUF-initialConfigFunction", ([[
					self:SetWidth(%d)
					self:SetHeight(%d)
				]]):format(width, height))
				return group
			end

			local teamIndexes = {}
			local teamIndexAnchor = {
				[1] = {"BOTTOM", "TOP", 0, 5},
				[2] = {"BOTTOM", "TOP", 0, 5},
				[3] = {"TOP", "BOTTOM", 0, -5},
				[4] = {"TOP", "BOTTOM", 0, -5},
				[5] = {"RIGHT", "LEFT", -5, 0},
				[6] = {"RIGHT", "LEFT", -5, 0},
				[7] = {"LEFT", "RIGHT", 5, 0},
				[8] = {"LEFT", "RIGHT", 5, 0},
			}

			local function UpdateTeamIndex(teamIndex, showIndex, direc)
				if not showIndex then
					teamIndex:Hide()
				else
					teamIndex:Show()
					teamIndex:ClearAllPoints()
					local anchor = teamIndexAnchor[direc]
					teamIndex:SetPoint(anchor[1], teamIndex.__owner, anchor[2], anchor[3], anchor[4])
				end
			end

			local function CreateTeamIndex(header)
				local showIndex = C.db["UFs"]["TeamIndex"]
				local direc = C.db["UFs"]["RaidDirec"]
				local parent = _G[header:GetName().."UnitButton1"]
				if parent and not parent.teamIndex then
					local teamIndex = B.CreateFS(parent, 14, header.index)
					teamIndex:SetTextColor(.6, .8, 1)
					teamIndex.__owner = parent
					UpdateTeamIndex(teamIndex, showIndex, direc)
					teamIndexes[header.index] = teamIndex

					parent.teamIndex = teamIndex
				end
			end

			function UF:UpdateRaidTeamIndex()
				local showIndex = C.db["UFs"]["TeamIndex"]
				local direc = C.db["UFs"]["RaidDirec"]
				for _, teamIndex in pairs(teamIndexes) do
					UpdateTeamIndex(teamIndex, showIndex, direc)
				end
			end

			local groups = {}

			function UF:CreateAndUpdateRaidHeader(direction)
				local index = C.db["UFs"]["RaidDirec"]
				local rows = C.db["UFs"]["RaidRows"]
				local numGroups = C.db["UFs"]["NumGroups"]
				local raidWidth, raidHeight = C.db["UFs"]["RaidWidth"], C.db["UFs"]["RaidHeight"]
				local raidFrameHeight = raidHeight + C.db["UFs"]["RaidPowerHeight"] + C.mult
				local indexSpacing = C.db["UFs"]["TeamIndex"] and 20 or 0

				local sortData = UF.RaidDirections[index]
				for i = 1, numGroups do
					local group = groups[i]
					if not group then
						group = CreateGroup("oUF_Raid"..i, i, raidWidth, raidFrameHeight)
						group.index = i
						group.groupType = "raid"
						tinsert(UF.headers, group)
						RegisterStateDriver(group, "visibility", "show")
						RegisterStateDriver(group, "visibility", GetRaidVisibility())
						CreateTeamIndex(group)

						groups[i] = group
					end

					if not raidMover and i == 1 then
						raidMover = B.Mover(groups[i], L["RaidFrame"], "RaidFrame", {"TOPLEFT", UIParent, 35, -50})
					end

					local groupWidth = index < 5 and raidWidth+5 or (raidWidth+5)*5
					local groupHeight = index < 5 and (raidFrameHeight+5)*5 or raidFrameHeight+5
					local numX = ceil(numGroups/rows)
					local numY = min(rows, numGroups)
					local indexSpacings = indexSpacing*(numY-1)
					if index < 5 then
						raidMover:SetSize(groupWidth*numX - 5, groupHeight*numY - 5 + indexSpacings)
					else
						raidMover:SetSize(groupWidth*numY - 5 + indexSpacings, groupHeight*numX - 5)
					end

					if direction then
						ResetHeaderPoints(group)
						group:SetAttribute("point", sortData.point)
						group:SetAttribute("xOffset", sortData.xOffset)
						group:SetAttribute("yOffset", sortData.yOffset)
					end

					group:ClearAllPoints()
					if i == 1 then
						group:SetPoint(sortData.initAnchor, raidMover)
					elseif (i-1) % rows == 0 then
						group:SetPoint(sortData.initAnchor, groups[i-rows], sortData.relAnchor, sortData.x, sortData.y)
					else
						local x = floor((i-1)/rows)
						local y = (i-1)%rows
						if index < 5 then
							group:SetPoint(sortData.initAnchor, raidMover, sortData.initAnchor, sortData.multX*groupWidth*x, sortData.multY*(groupHeight+indexSpacing)*y)
						else
							group:SetPoint(sortData.initAnchor, raidMover, sortData.initAnchor, sortData.multX*(groupWidth+indexSpacing)*y, sortData.multY*groupHeight*x)
						end
					end
				end

				for i = 1, 8 do
					local group = groups[i]
					if group then
						group.__disabled = i > C.db["UFs"]["NumGroups"]
					end
				end
			end

			UF:CreateAndUpdateRaidHeader(true)
			UF:UpdateRaidTeamIndex()
		end

		UF:UpdateRaidHealthMethod()
	end
end