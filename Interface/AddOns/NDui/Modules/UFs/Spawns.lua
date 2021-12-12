local _, ns = ...
local B, C, L, DB = unpack(ns)

local oUF = ns.oUF
local UF = B:GetModule("UnitFrames")
local format, tostring = string.format, tostring

-- Units
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
	UF:CreateQuestSync(self)
	UF:CreateClassPower(self)
	UF:StaggerBar(self)
	UF:CreateAuras(self)

	if C.db["UFs"]["Castbars"] then
		UF:ReskinMirrorBars()
		UF:ReskinTimerTrakcer(self)
	end
	if not C.db["Misc"]["ExpRep"] then UF:CreateExpRepBar(self) end
	if C.db["UFs"]["SwingBar"] then UF:CreateSwing(self) end
	if C.db["UFs"]["QuakeTimer"] then UF:CreateQuakeTimer(self) end
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
	UF:DemonicGatewayIcon(self)
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
end

local function CreateBossStyle(self)
	self.mystyle = "boss"
	SetUnitFrameSize(self, "Boss")

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreatePowerText(self)
	UF:CreateCastBar(self)
	UF:CreateRaidMark(self)
	UF:CreateAltPower(self)
	UF:CreateBuffs(self)
	UF:CreateDebuffs(self)
	UF:CreateClickSets(self)
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
	UF:CreatePVPClassify(self)
end

local function CreateRaidStyle(self)
	self.mystyle = "raid"
	self.Range = {
		insideAlpha = 1, outsideAlpha = .4,
	}

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
	self.isSimpleMode = true
	CreateRaidStyle(self)
end

local function CreatePartyStyle(self)
	self.isPartyFrame = true
	CreateRaidStyle(self)
	UF:InterruptIndicator(self)
	UF:CreatePartyAltPower(self)
end

local function CreatePartyPetStyle(self)
	self.mystyle = "raid"
	self.isPartyPet = true
	self.Range = {
		insideAlpha = 1, outsideAlpha = .4,
	}

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
	local visibility = "[group:party,nogroup:raid] show;hide"
	if C.db["UFs"]["PartyPetVsby"] == 2 then
		visibility = "[group:raid] show;hide"
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
			RegisterStateDriver(header, "visibility", GetRaidVisibility())
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

function UF:OnLogin()
	if C.db["Nameplate"]["Enable"] then
		UF:SetupCVars()
		UF:BlockAddons()
		UF:CreateUnitTable()
		UF:CreatePowerUnitTable()
		UF:CheckExplosives()
		UF:UpdateGroupRoles()
		UF:QuestIconCheck()
		UF:RefreshPlateOnFactionChanged()
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
		oUF:RegisterStyle("Focus", CreateFocusStyle)
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

		oUF:SetActiveStyle("Focus")
		local focus = oUF:Spawn("focus", "oUF_Focus")
		B.Mover(focus, L["FocusUF"], "FocusUF", C.UFs.FocusPos)
		UF.ToggleCastBar(focus, "Focus")

		oUF:SetActiveStyle("FocusTarget")
		local focustarget = oUF:Spawn("focustarget", "oUF_FocusTarget")
		B.Mover(focustarget, L["FotUF"], "FotUF", {"TOPLEFT", oUF_Focus, "TOPRIGHT", 5, 0})

		oUF:RegisterStyle("Boss", CreateBossStyle)
		oUF:SetActiveStyle("Boss")
		local boss = {}
		for i = 1, MAX_BOSS_FRAMES do
			boss[i] = oUF:Spawn("boss"..i, "oUF_Boss"..i)
			local moverWidth, moverHeight = boss[i]:GetWidth(), boss[i]:GetHeight()+8
			if i == 1 then
				boss[i].mover = B.Mover(boss[i], L["BossFrame"]..i, "Boss1", {"RIGHT", UIParent, "RIGHT", -350, -90}, moverWidth, moverHeight)
			else
				boss[i].mover = B.Mover(boss[i], L["BossFrame"]..i, "Boss"..i, {"BOTTOM", boss[i-1], "TOP", 0, 50}, moverWidth, moverHeight)
			end
		end

		if C.db["UFs"]["Arena"] then
			oUF:RegisterStyle("Arena", CreateArenaStyle)
			oUF:SetActiveStyle("Arena")
			local arena = {}
			for i = 1, 5 do
				arena[i] = oUF:Spawn("arena"..i, "oUF_Arena"..i)
				arena[i]:SetPoint("TOPLEFT", boss[i].mover)
			end
		end

		UF:ToggleUFClassPower()
		UF:UpdateTextScale()
		UF:ToggleAllAuras()
	end

	if C.db["UFs"]["RaidFrame"] then
		UF:AddClickSetsListener()
		UF:UpdateCornerSpells()
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
			UF:SyncWithZenTracker()
			UF:UpdatePartyWatcherSpells()

			oUF:RegisterStyle("Party", CreatePartyStyle)
			oUF:SetActiveStyle("Party")

			local xOffset, yOffset = 5, 5
			local horizonParty = C.db["UFs"]["HorizonParty"]
			local partyWidth, partyHeight = C.db["UFs"]["PartyWidth"], C.db["UFs"]["PartyHeight"]
			local partyFrameHeight = partyHeight + C.db["UFs"]["PartyPowerHeight"] + C.mult
			local moverWidth = horizonParty and (partyWidth*5+xOffset*4) or partyWidth
			local moverHeight = horizonParty and partyFrameHeight or (partyFrameHeight*5+yOffset*4)
			local groupingOrder = horizonParty and "TANK,HEALER,DAMAGER,NONE" or "NONE,DAMAGER,HEALER,TANK"

			local party = oUF:SpawnHeader("oUF_Party", nil, nil,
			"showPlayer", true,
			"showSolo", true,
			"showParty", true,
			"showRaid", true,
			"xoffset", xOffset,
			"yOffset", yOffset,
			"groupingOrder", groupingOrder,
			"groupBy", "ASSIGNEDROLE",
			"sortMethod", "NAME",
			"point", horizonParty and "LEFT" or "BOTTOM",
			"columnAnchorPoint", "LEFT",
			"oUF-initialConfigFunction", ([[
				self:SetWidth(%d)
				self:SetHeight(%d)
			]]):format(partyWidth, partyFrameHeight))

			party.groupType = "party"
			tinsert(UF.headers, party)
			RegisterStateDriver(party, "visibility", GetPartyVisibility())

			partyMover = B.Mover(party, L["PartyFrame"], "PartyFrame", {"LEFT", UIParent, 350, 0}, moverWidth, moverHeight)
			party:ClearAllPoints()
			party:SetPoint("BOTTOMLEFT", partyMover)

			if C.db["UFs"]["PartyPetFrame"] then
				oUF:RegisterStyle("PartyPet", CreatePartyPetStyle)
				oUF:SetActiveStyle("PartyPet")

				local petWidth, petHeight, petPowerHeight = C.db["UFs"]["PartyPetWidth"], C.db["UFs"]["PartyPetHeight"], C.db["UFs"]["PartyPetPowerHeight"]
				local petFrameHeight = petHeight + petPowerHeight + C.mult

				local partyPet = oUF:SpawnHeader("oUF_PartyPet", "SecureGroupPetHeaderTemplate", nil,
				"showPlayer", true,
				"showSolo", true,
				"showParty", true,
				"showRaid", true,
				"xoffset", 5,
				"yOffset", -5,
				"columnSpacing", 5,
				"point", "TOP",
				"columnAnchorPoint", "LEFT",
				"oUF-initialConfigFunction", ([[
					self:SetWidth(%d)
					self:SetHeight(%d)
				]]):format(petWidth, petFrameHeight))

				partyPet.groupType = "pet"
				tinsert(UF.headers, partyPet)
				RegisterStateDriver(partyPet, "visibility", GetPartyPetVisibility())

				local petMover = B.Mover(partyPet, L["PartyPetFrame"], "PartyPet", {"TOPLEFT", partyMover, "BOTTOMLEFT", 0, -5})

				function UF:UpdatePartyPetHeader()
					ResetHeaderPoints(partyPet)

					local petWidth, petHeight, petPowerHeight = C.db["UFs"]["PartyPetWidth"], C.db["UFs"]["PartyPetHeight"], C.db["UFs"]["PartyPetPowerHeight"]
					local petFrameHeight = petHeight + petPowerHeight + C.mult
					local petsPerColumn = C.db["UFs"]["PartyPetPerCol"]
					local maxColumns = C.db["UFs"]["PartyPetMaxCol"]

					partyPet:SetAttribute("unitsPerColumn", petsPerColumn)
					partyPet:SetAttribute("maxColumns", maxColumns)

					local moverWidth = (petWidth*maxColumns + 5*(maxColumns-1))
					local moverHeight = petFrameHeight*petsPerColumn + 5*(petsPerColumn-1)
					petMover:SetSize(moverWidth, moverHeight)
				end

				UF:UpdatePartyPetHeader()
			end
		end

		local raidMover
		if C.db["UFs"]["SimpleMode"] then
			oUF:RegisterStyle("Raid", CreateSimpleRaidStyle)
			oUF:SetActiveStyle("Raid")

			local scale = C.db["UFs"]["SMRScale"]/10

			local function CreateGroup(name)
				local group = oUF:SpawnHeader(name, nil, nil,
				"showPlayer", true,
				"showSolo", true,
				"showParty", true,
				"showRaid", true,
				"xoffset", 5,
				"yOffset", -5,
				"columnSpacing", 5,
				"point", "TOP",
				"columnAnchorPoint", "LEFT",
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

			local groupByTypes = {
				[1] = {"1,2,3,4,5,6,7,8", "GROUP", "INDEX"},
				[2] = {"DEATHKNIGHT,WARRIOR,DEMONHUNTER,ROGUE,MONK,PALADIN,DRUID,SHAMAN,HUNTER,PRIEST,MAGE,WARLOCK", "CLASS", "NAME"},
				[3] = {"TANK,HEALER,DAMAGER,NONE", "ASSIGNEDROLE", "NAME"},
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

			local numGroups = C.db["UFs"]["NumGroups"]
			local reverse = C.db["UFs"]["ReverseRaid"]
			local horizonRaid = C.db["UFs"]["HorizonRaid"]
			local showTeamIndex = C.db["UFs"]["ShowTeamIndex"]
			local raidWidth, raidHeight = C.db["UFs"]["RaidWidth"], C.db["UFs"]["RaidHeight"]
			local raidFrameHeight = raidHeight + C.db["UFs"]["RaidPowerHeight"] + C.mult

			local function CreateGroup(name, i)
				local group = oUF:SpawnHeader(name, nil, nil,
				"showPlayer", true,
				"showSolo", true,
				"showParty", true,
				"showRaid", true,
				"xoffset", 5,
				"yOffset", -5,
				"groupFilter", tostring(i),
				"groupingOrder", "1,2,3,4,5,6,7,8",
				"groupBy", "GROUP",
				"sortMethod", "INDEX",
				"maxColumns", 1,
				"unitsPerColumn", 5,
				"columnSpacing", 5,
				"point", horizonRaid and "LEFT" or "TOP",
				"columnAnchorPoint", "LEFT",
				"oUF-initialConfigFunction", ([[
					self:SetWidth(%d)
					self:SetHeight(%d)
				]]):format(raidWidth, raidFrameHeight))
				return group
			end

			local function CreateTeamIndex(header)
				local parent = _G[header:GetName().."UnitButton1"]
				if parent and not parent.teamIndex then
					local teamIndex = B.CreateFS(parent, 12, format(GROUP_NUMBER, header.index))
					teamIndex:ClearAllPoints()
					teamIndex:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", 0, 5)
					teamIndex:SetTextColor(.6, .8, 1)

					parent.teamIndex = teamIndex
				end
			end

			local groups = {}
			for i = 1, numGroups do
				groups[i] = CreateGroup("oUF_Raid"..i, i)
				groups[i].index = i
				groups[i].groupType = "raid"
				tinsert(UF.headers, groups[i])
				RegisterStateDriver(groups[i], "visibility", GetRaidVisibility())

				if i == 1 then
					if horizonRaid then
						raidMover = B.Mover(groups[i], L["RaidFrame"], "RaidFrame", {"TOPLEFT", UIParent, 35, -50}, (raidWidth+5)*5-5, (raidFrameHeight+(showTeamIndex and 20 or 5))*numGroups - (showTeamIndex and 20 or 5))
						if reverse then
							groups[i]:ClearAllPoints()
							groups[i]:SetPoint("BOTTOMLEFT", raidMover)
						end
					else
						raidMover = B.Mover(groups[i], L["RaidFrame"], "RaidFrame", {"TOPLEFT", UIParent, 35, -50}, (raidWidth+5)*numGroups-5, (raidFrameHeight+5)*5-5)
						if reverse then
							groups[i]:ClearAllPoints()
							groups[i]:SetPoint("TOPRIGHT", raidMover)
						end
					end
				else
					if horizonRaid then
						if reverse then
							groups[i]:SetPoint("BOTTOMLEFT", groups[i-1], "TOPLEFT", 0, showTeamIndex and 20 or 5)
						else
							groups[i]:SetPoint("TOPLEFT", groups[i-1], "BOTTOMLEFT", 0, showTeamIndex and -20 or -5)
						end
					else
						if reverse then
							groups[i]:SetPoint("TOPRIGHT", groups[i-1], "TOPLEFT", -5, 0)
						else
							groups[i]:SetPoint("TOPLEFT", groups[i-1], "TOPRIGHT", 5, 0)
						end
					end
				end

				if showTeamIndex then
					CreateTeamIndex(groups[i])
					groups[i]:HookScript("OnShow", CreateTeamIndex)
				end
			end
		end

		UF:UpdateRaidHealthMethod()

		if C.db["UFs"]["SpecRaidPos"] then
			local function UpdateSpecPos(event, ...)
				local unit, _, spellID = ...
				if (event == "UNIT_SPELLCAST_SUCCEEDED" and unit == "player" and spellID == 200749) or event == "ON_LOGIN" then
					local specIndex = GetSpecialization()
					if not specIndex then return end

					if not C.db["Mover"]["RaidPos"..specIndex] then
						C.db["Mover"]["RaidPos"..specIndex] = {"TOPLEFT", "UIParent", "TOPLEFT", 35, -50}
					end
					if raidMover then
						raidMover:ClearAllPoints()
						raidMover:SetPoint(unpack(C.db["Mover"]["RaidPos"..specIndex]))
					end

					if not C.db["Mover"]["PartyPos"..specIndex] then
						C.db["Mover"]["PartyPos"..specIndex] = {"LEFT", "UIParent", "LEFT", 350, 0}
					end
					if partyMover then
						partyMover:ClearAllPoints()
						partyMover:SetPoint(unpack(C.db["Mover"]["PartyPos"..specIndex]))
					end
				end
			end
			UpdateSpecPos("ON_LOGIN")
			B:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", UpdateSpecPos)

			if raidMover then
				raidMover:HookScript("OnDragStop", function()
					local specIndex = GetSpecialization()
					if not specIndex then return end
					C.db["Mover"]["RaidPos"..specIndex] = C.db["Mover"]["RaidFrame"]
				end)
			end
			if partyMover then
				partyMover:HookScript("OnDragStop", function()
					local specIndex = GetSpecialization()
					if not specIndex then return end
					C.db["Mover"]["PartyPos"..specIndex] = C.db["Mover"]["PartyFrame"]
				end)
			end
		end
	end
end