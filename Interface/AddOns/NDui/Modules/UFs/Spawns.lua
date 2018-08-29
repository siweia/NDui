local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF or oUF
local UF = B:GetModule("UnitFrames")

-- Units
local function CreatePlayerStyle(self)
	self.mystyle = "player"
	self:SetSize(245, 24*NDuiDB["UFs"]["HeightScale"])

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
	UF:ReskinMirrorBars()
	UF:CreateAddPower(self)

	if not NDuiDB["Nameplate"]["ShowPlayerPlate"] then UF:CreateClassPower(self) end
	if not NDuiDB["Misc"]["ExpRep"] then UF:CreateExpRepBar(self) end
	if NDuiDB["UFs"]["PlayerDebuff"] then UF:CreateDebuffs(self) end
	if NDuiDB["UFs"]["SwingBar"] then UF:CreateSwing(self) end
end

local function CreateTargetStyle(self)
	self.mystyle = "target"
	self:SetSize(245, 24*NDuiDB["UFs"]["HeightScale"])

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
	self:SetSize(200, 22*NDuiDB["UFs"]["HeightScale"])

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
	self:SetSize(120, 18*NDuiDB["UFs"]["HeightScale"])

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreateRaidMark(self)

	if NDuiDB["UFs"]["ToTAuras"] then UF:CreateAuras(self) end
end

local function CreateFocusTargetStyle(self)
	self.mystyle = "focustarget"
	self:SetSize(120, 18*NDuiDB["UFs"]["HeightScale"])

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreateRaidMark(self)
end

local function CreatePetStyle(self)
	self.mystyle = "pet"
	self:SetSize(120, 18*NDuiDB["UFs"]["HeightScale"])

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreateCastBar(self)
	UF:CreateRaidMark(self)
end

local function CreateBossStyle(self)
	self.mystyle = "boss"
	self:SetSize(150, 22*NDuiDB["UFs"]["HeightScale"])

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
end

local function CreateArenaStyle(self)
	self.mystyle = "arena"
	self:SetSize(150, 22*NDuiDB["UFs"]["HeightScale"])

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreateCastBar(self)
	UF:CreateRaidMark(self)
	UF:CreateBuffs(self)
	UF:CreateDebuffs(self)
	UF:CreateFactionIcon(self)
end

local function CreateRaidStyle(self)
	self.mystyle = "raid"
	self.Range = {
		insideAlpha = 1, outsideAlpha = .35,
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

	if not NDuiDB["UFs"]["SimpleMode"] then UF:CreateAuras(self) end
end

-- Spawns
function UF:OnLogin()
	if NDuiDB["Nameplate"]["Enable"] then
		self:SetupCVars()
		self:BlockAddons()
		self:CreateUnitTable()
		self:CreatePowerUnitTable()

		oUF:RegisterStyle("Nameplates", UF.CreatePlates)
		oUF:SetActiveStyle("Nameplates")
		oUF:SpawnNamePlates("oUF_NPs", UF.PostUpdatePlates)
	end

	if NDuiDB["Nameplate"]["ShowPlayerPlate"] then
		oUF:RegisterStyle("PlayerPlate", UF.CreatePlayerPlate)
		oUF:SetActiveStyle("PlayerPlate")
		local plate = oUF:Spawn("player", "oUF_PlayerPlate", true)
		B.Mover(plate, L["PlayerNP"], "PlayerPlate", C.UFs.PlayerPlate, plate:GetWidth(), 20)
	end

	-- Default Clicksets for RaidFrame
	self:DefaultClickSets()

	if NDuiDB["UFs"]["Enable"] then
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
		B.Mover(player, L["PlayerUF"], "PlayerUF", C.UFs.PlayerPos, 245, 30)

		oUF:SetActiveStyle("Target")
		local target = oUF:Spawn("target", "oUF_Target")
		B.Mover(target, L["TargetUF"], "TargetUF", C.UFs.TargetPos, 245, 30)

		oUF:SetActiveStyle("ToT")
		local targettarget = oUF:Spawn("targettarget", "oUF_ToT")
		B.Mover(targettarget, L["TotUF"], "TotUF", C.UFs.ToTPos, 120, 30)

		oUF:SetActiveStyle("Pet")
		local pet = oUF:Spawn("pet", "oUF_Pet")
		B.Mover(pet, L["PetUF"], "PetUF", C.UFs.PetPos, 120, 30)

		oUF:SetActiveStyle("Focus")
		local focus = oUF:Spawn("focus", "oUF_Focus")
		B.Mover(focus, L["FocusUF"], "FocusUF", C.UFs.FocusPos, 200, 30)

		oUF:SetActiveStyle("FocusTarget")
		local focustarget = oUF:Spawn("focustarget", "oUF_FocusTarget")
		B.Mover(focustarget, L["FotUF"], "FotUF", C.UFs.FoTPos, 120, 30)

		if NDuiDB["UFs"]["Boss"] then
			oUF:RegisterStyle("Boss", CreateBossStyle)
			oUF:SetActiveStyle("Boss")
			local boss = {}
			for i = 1, MAX_BOSS_FRAMES do
				boss[i] = oUF:Spawn("boss"..i, "oUF_Boss"..i)
				if i == 1 then
					B.Mover(boss[i], L["BossFrame"]..i, "Boss1", {"RIGHT", UIParent, "RIGHT", -350, -90}, 150, 30)
				else
					B.Mover(boss[i], L["BossFrame"]..i, "Boss"..i, {"BOTTOM", boss[i-1], "TOP", 0, 50}, 150, 30)
				end
			end
		end

		if NDuiDB["UFs"]["Arena"] then
			oUF:RegisterStyle("Arena", CreateArenaStyle)
			oUF:SetActiveStyle("Arena")
			local arena = {}
			for i = 1, 5 do
				arena[i] = oUF:Spawn("arena"..i, "oUF_Arena"..i)
				if i == 1 then
					B.Mover(arena[i], L["ArenaFrame"]..i, "Arena1", {"RIGHT", UIParent, "RIGHT", -120, -90}, 150, 30)
				else
					B.Mover(arena[i], L["ArenaFrame"]..i, "Arena"..i, {"BOTTOM", arena[i-1], "TOP", 0, 50}, 150, 30)
				end
			end

			local bars = {}
			for i = 1, 5 do
				local bar = CreateFrame("Frame", nil, UIParent)
				bar:SetAllPoints(arena[i])
				B.CreateSD(bar, 3, 3)
				bar:Hide()

				bar.Health = CreateFrame("StatusBar", nil, bar)
				bar.Health:SetAllPoints()
				bar.Health:SetStatusBarTexture(DB.normTex)
				bar.Health:SetStatusBarColor(.3, .3, .3)
				bar.SpecClass = B.CreateFS(bar.Health, 12, "")

				bars[i] = bar
			end

			local function UpdateArenaPreps(event)
				if event == "ARENA_OPPONENT_UPDATE" then
					for i = 1, 5 do bars[i]:Hide() end
				else
					local numOpps = GetNumArenaOpponentSpecs()
					if numOpps > 0 then
						for i = 1, 5 do
							local s = GetArenaOpponentSpec(i)
							local _, spec, class
							if s and s > 0 then 
								_, spec, _, _, _, class = GetSpecializationInfoByID(s)
							end
							if i <= numOpps and class and spec then
								bars[i].Health:SetStatusBarColor(B.ClassColor(class))
								bars[i].SpecClass:SetText(spec.."  -  "..LOCALIZED_CLASS_NAMES_MALE[class] or "UNKNOWN")
								bars[i]:Show()
							else
								bars[i]:Hide()
							end
						end
					else
						for i = 1, 5 do bars[i]:Hide() end
					end
				end
			end
			B:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateArenaPreps)
			B:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS", UpdateArenaPreps)
			B:RegisterEvent("ARENA_OPPONENT_UPDATE", UpdateArenaPreps)
		end
	end

	if NDuiDB["UFs"]["RaidFrame"] then
		-- Disable Default RaidFrame
		B.HideObject(CompactRaidFrameContainer)
		B.HideObject(CompactRaidFrameManager)
		RaidOptionsFrame_UpdatePartyFrames = B.Dummy	-- need reviewed

		-- Group Styles
		oUF:RegisterStyle("Raid", CreateRaidStyle)
		oUF:SetActiveStyle("Raid")

		local numGroups = NDuiDB["UFs"]["NumGroups"]
		local horizon = NDuiDB["UFs"]["HorizonRaid"]
		local scale = NDuiDB["UFs"]["RaidScale"]
		local reverse = NDuiDB["UFs"]["ReverseRaid"]
		local raidMover

		if NDuiDB["UFs"]["SimpleMode"] then
			local function CreateGroup(name, i)
				local group = oUF:SpawnHeader(name, nil, "solo,party,raid",
				"showPlayer", true,
				"showSolo", false,
				"showParty", true,
				"showRaid", true,
				"xoffset", 5,
				"yOffset", -10,
				"groupFilter", tostring(i),
				"groupingOrder", "1,2,3,4,5,6,7,8",
				"groupBy", "GROUP",
				"sortMethod", "INDEX",
				"maxColumns", 2,
				"unitsPerColumn", 20,
				"columnSpacing", 5,
				"point", "TOP",
				"columnAnchorPoint", "LEFT",
				"oUF-initialConfigFunction", ([[
				self:SetWidth(%d)
				self:SetHeight(%d)
				]]):format(100*scale, 20*scale))
				return group
			end

			local groupFilter
			if numGroups == 4 then
				groupFilter = "1,2,3,4"
			elseif numGroups == 5 then
				groupFilter = "1,2,3,4,5"
			elseif numGroups == 6 then
				groupFilter = "1,2,3,4,5,6"
			elseif numGroups == 7 then
				groupFilter = "1,2,3,4,5,6,7"
			elseif numGroups == 8 then
				groupFilter = "1,2,3,4,5,6,7,8"
			end

			local group = CreateGroup("oUF_Raid", groupFilter)
			raidMover = B.Mover(group, L["RaidFrame"], "RaidFrame", {"TOPLEFT", UIParent, 35, -50}, 140*scale, 30*20*scale)
		else
			local function CreateGroup(name, i)
				local group = oUF:SpawnHeader(name, nil, "solo,party,raid",
				"showPlayer", true,
				"showSolo", false,
				"showParty", true,
				"showRaid", true,
				"xoffset", 5,
				"yOffset", -10,
				"groupFilter", tostring(i),
				"groupingOrder", "1,2,3,4,5,6,7,8",
				"groupBy", "GROUP",
				"sortMethod", "INDEX",
				"maxColumns", 1,
				"unitsPerColumn", 5,
				"columnSpacing", 5,
				"point", horizon and "LEFT" or "TOP",
				"columnAnchorPoint", "LEFT",
				"oUF-initialConfigFunction", ([[
				self:SetWidth(%d)
				self:SetHeight(%d)
				]]):format(80*scale, 32*scale))
				return group
			end

			local groups = {}
			for i = 1, numGroups do
				groups[i] = CreateGroup("oUF_Raid"..i, i)
				if i == 1 then
					if horizon then
						raidMover = B.Mover(groups[i], L["RaidFrame"], "RaidFrame", {"TOPLEFT", UIParent, 35, -50}, 84*5*scale, 40*numGroups*scale)
						if reverse then
							groups[i]:ClearAllPoints()
							groups[i]:SetPoint("BOTTOMLEFT", raidMover)
						end
					else
						raidMover = B.Mover(groups[i], L["RaidFrame"], "RaidFrame", {"TOPLEFT", UIParent, 35, -50}, 85*numGroups*scale, 42*5*scale)
						if reverse then
							groups[i]:ClearAllPoints()
							groups[i]:SetPoint("TOPRIGHT", raidMover)
						end
					end
				else
					if horizon then
						if reverse then
							groups[i]:SetPoint("BOTTOMLEFT", groups[i-1], "TOPLEFT", 0, NDuiDB["UFs"]["ShowTeamIndex"] and 25 or 15)
						else
							groups[i]:SetPoint("TOPLEFT", groups[i-1], "BOTTOMLEFT", 0, NDuiDB["UFs"]["ShowTeamIndex"] and -25 or -15)
						end
					else
						if reverse then
							groups[i]:SetPoint("TOPRIGHT", groups[i-1], "TOPLEFT", -5, 0)
						else
							groups[i]:SetPoint("TOPLEFT", groups[i-1], "TOPRIGHT", 5, 0)
						end
					end
				end

				if NDuiDB["UFs"]["ShowTeamIndex"] then
					local parent = _G["oUF_Raid"..i.."UnitButton1"]
					local teamIndex = B.CreateFS(parent, 12, format(GROUP_NUMBER, i))
					teamIndex:ClearAllPoints()
					teamIndex:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", 0, 5)
					teamIndex:SetTextColor(.6, .8, 1)
				end
			end
		end

		if raidMover then
			if not NDuiDB["UFs"]["SpecRaidPos"] then return end

			local function UpdateSpecPos(event, ...)
				local unit, _, spellID = ...
				if (event == "UNIT_SPELLCAST_SUCCEEDED" and unit == "player" and spellID == 200749) or event == "PLAYER_ENTERING_WORLD" then
					if not GetSpecialization() then return end
					local specIndex = GetSpecialization()
					if not NDuiDB["Mover"]["RaidPos"..specIndex] then
						NDuiDB["Mover"]["RaidPos"..specIndex] = {"TOPLEFT", "UIParent", "TOPLEFT", 35, -50}
					end
					raidMover:ClearAllPoints()
					raidMover:SetPoint(unpack(NDuiDB["Mover"]["RaidPos"..specIndex]))
				end
			end
			B:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateSpecPos)
			B:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", UpdateSpecPos)

			raidMover:HookScript("OnDragStop", function()
				if not GetSpecialization() then return end
				local specIndex = GetSpecialization()
				NDuiDB["Mover"]["RaidPos"..specIndex] = NDuiDB["Mover"]["RaidFrame"]
			end)
		end
	end
end