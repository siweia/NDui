local B, C, L, DB = unpack(select(2, ...))
local lib = NDui.lib
local oUF = NDui.oUF or oUF

-- Create UFs
local function CreatePlayerStyle(self)
	self.mystyle = "player"
	lib.init(self)
	self:SetSize(245, 24)
	lib.gen_hpbar(self)
	lib.gen_hpstrings(self)
	lib.gen_highlight(self)
	lib.gen_ppbar(self)
	lib.gen_ppstrings(self)
	lib.gen_castbar(self)
	lib.gen_RaidMark(self)
	lib.gen_InfoIcons(self)
	lib.gen_Resting(self)
	lib.gen_portrait(self)
	lib.HealPrediction(self)
	lib.FloatingCombatText(self)
	if NDuiDB["UFs"]["AddPower"] then lib.genAddPower(self) end
	if NDuiDB["UFs"]["ExpRep"] then
		lib.Experience(self)
		lib.Reputation(self)
	end
	if NDuiDB["UFs"]["PlayerDebuff"] then lib.createDebuffs(self) end
	if NDuiDB["UFs"]["Totems"] then lib.TotemBars(self) end
	if NDuiDB["UFs"]["ResourceBar"] then
		lib.genRunes(self)
		lib.genResourcebar(self)
	end
	if NDuiDB["UFs"]["SwingBar"] then lib.genSwing(self) end
end

local function CreateTargetStyle(self)
	self.mystyle = "target"
	lib.init(self)
	self:SetSize(245, 24)
	lib.gen_hpbar(self)
	lib.gen_hpstrings(self)
	lib.gen_highlight(self)
	lib.gen_ppbar(self)
	lib.gen_ppstrings(self)
	lib.gen_castbar(self)
	lib.gen_mirrorcb(self)
	lib.gen_RaidMark(self)
	lib.gen_InfoIcons(self)
	lib.addQuestIcon(self)
	lib.addPhaseIcon(self)
	lib.createAuras(self)
	lib.gen_portrait(self)
	lib.HealPrediction(self)
	lib.FloatingCombatText(self)
end

local function CreateFocusStyle(self)
	self.mystyle = "focus"
	lib.init(self)
	self:SetSize(200, 22)
	lib.gen_hpbar(self)
	lib.gen_hpstrings(self)
	lib.gen_highlight(self)
	lib.gen_ppbar(self)
	lib.gen_ppstrings(self)
	lib.gen_castbar(self)
	lib.gen_RaidMark(self)
	lib.gen_InfoIcons(self)
	lib.createAuras(self)
	lib.gen_portrait(self)
	lib.HealPrediction(self)
end

local function CreateToTStyle(self)
	self.mystyle = "tot"
	lib.init(self)
	self:SetSize(120, 18)
	lib.gen_hpbar(self)
	lib.gen_hpstrings(self)
	lib.gen_highlight(self)
	lib.gen_ppbar(self)
	lib.gen_RaidMark(self)
	if NDuiDB["UFs"]["ToTAuras"] then lib.createAuras(self) end
end

local function CreateFocusTargetStyle(self)
	self.mystyle = "focustarget"
	lib.init(self)
	self:SetSize(120, 18)
	lib.gen_hpbar(self)
	lib.gen_hpstrings(self)
	lib.gen_highlight(self)
	lib.gen_ppbar(self)
	lib.gen_RaidMark(self)
end

local function CreatePetStyle(self)
	self.mystyle = "pet"
	lib.init(self)
	self:SetSize(120, 18)
	lib.gen_hpbar(self)
	lib.gen_hpstrings(self)
	lib.gen_highlight(self)
	lib.gen_ppbar(self)
	lib.gen_castbar(self)	--Hide Vehicle castbar
	lib.gen_RaidMark(self)
end

local function CreateBossStyle(self)
	self.mystyle = "boss"
	self:SetSize(150, 22)
	lib.gen_hpbar(self)
	lib.gen_hpstrings(self)
	lib.gen_highlight(self)
	lib.gen_ppbar(self)
	lib.gen_ppstrings(self)
	lib.gen_castbar(self)
	lib.gen_RaidMark(self)
	lib.AltPowerBar(self)
	lib.createBuffs(self)
	lib.createDebuffs(self)
end

local function CreateArenaStyle(self)
	self.mystyle = "oUF_Arena"
	self:SetSize(150, 22)
	lib.gen_hpbar(self)
	lib.gen_hpstrings(self)
	lib.gen_highlight(self)
	lib.gen_ppbar(self)
	lib.gen_castbar(self)
	lib.gen_RaidMark(self)
	lib.createBuffs(self)
	lib.createDebuffs(self)
	lib.gen_portrait(self)
end

local function CreateRaidStyle(self)
	self.mystyle = "raid"
	self.Range = {
		insideAlpha = 1, outsideAlpha = .35,
	}
	lib.init(self)
	lib.gen_hpbar(self)
	lib.gen_hpstrings(self)
	lib.gen_highlight(self)
	lib.gen_ppbar(self)
	lib.gen_InfoIcons(self)
	lib.gen_RaidMark(self)
	lib.RaidElements(self)
	lib.HealPrediction(self)
	lib.CreateTargetBorder(self)
	if not NDuiDB["UFs"]["SimpleMode"] then
		lib.genRaidDebuffs(self)
		lib.createAuras(self)
	end
end

-- Spawn Units
oUF:RegisterStyle("Player", CreatePlayerStyle)
oUF:RegisterStyle("Target", CreateTargetStyle)
oUF:RegisterStyle("ToT", CreateToTStyle)
oUF:RegisterStyle("Focus", CreateFocusStyle)
oUF:RegisterStyle("FocusTarget", CreateFocusTargetStyle)
oUF:RegisterStyle("Pet", CreatePetStyle)
oUF:RegisterStyle("Boss", CreateBossStyle)
oUF:RegisterStyle("oUF_Arena", CreateArenaStyle)
oUF:RegisterStyle("Raid", CreateRaidStyle)

oUF:Factory(function(self)
	if not NDuiDB["UFs"]["Enable"] then return end

	self:SetActiveStyle("Player")
	local player = self:Spawn("player", "oUF_Player")
	B.Mover(player, L["PlayerUF"], "PlayerUF", C.UFs.PlayerPos, 245, 30)

	self:SetActiveStyle("Target")
	local target = self:Spawn("Target", "oUF_Target")
	B.Mover(target, L["TargetUF"], "TargetUF", C.UFs.TargetPos, 245, 30)

	self:SetActiveStyle("ToT")
	local targettarget = self:Spawn("targettarget", "oUF_tot")
	B.Mover(targettarget, L["TotUF"], "TotUF", C.UFs.ToTPos, 120, 30)

	self:SetActiveStyle("Pet")
	local pet = self:Spawn("pet", "oUF_pet")
	B.Mover(pet, L["PetUF"], "PetUF", C.UFs.PetPos, 120, 30)

	self:SetActiveStyle("Focus")
	local focus = self:Spawn("focus", "oUF_focus")
	B.Mover(focus, L["FocusUF"], "FocusUF", C.UFs.FocusPos, 200, 30)

	self:SetActiveStyle("FocusTarget")
	local focustarget = self:Spawn("focustarget", "oUF_focustarget")
	B.Mover(focustarget, L["FotUF"], "FotUF", C.UFs.FoTPos, 120, 30)

  	if NDuiDB["UFs"]["Boss"] then
		self:SetActiveStyle("Boss")
		local boss = {}
		for i = 1, MAX_BOSS_FRAMES do
			boss[i] = self:Spawn("boss"..i, "oUF_Boss"..i)
			if i == 1 then
				B.Mover(boss[i], L["Boss1"], "Boss1", {"RIGHT", UIParent, "RIGHT", -100, -90}, 150, 30)
			else
				B.Mover(boss[i], L["Boss"..i], "Boss"..i, {"BOTTOM", boss[i-1], "TOP", 0, 50}, 150, 30)
			end
		end
	end

	if NDuiDB["UFs"]["Arena"] then
		self:SetActiveStyle("oUF_Arena")
		local arena = {}
		for i = 1, 5 do
			arena[i] = self:Spawn("arena"..i, "oUF_Arena"..i)
			if i == 1 then
				B.Mover(arena[i], L["Arena1"], "Arena1", {"TOP", UIParent, "BOTTOM", 500, 550}, 150, 30)
			else
				B.Mover(arena[i], L["Arena"..i], "Arena"..i, {"BOTTOM", arena[i-1], "TOP", 0, 50}, 150, 30)
			end
		end

		local bars = {}
		for i = 1, 5 do
			bars[i] = CreateFrame("Frame", nil, UIParent)
			bars[i]:SetAllPoints(arena[i])
			B.CreateSD(bars[i], 3, 3)
			bars[i]:Hide()

			bars[i].Health = CreateFrame("StatusBar", nil, bars[i])
			bars[i].Health:SetAllPoints()
			bars[i].Health:SetStatusBarTexture(DB.normTex)
			bars[i].Health:SetStatusBarColor(.3, .3, .3)
			bars[i].SpecClass = B.CreateFS(bars[i].Health, 12, "")
		end

		local f = NDui:EventFrame({"PLAYER_ENTERING_WORLD", "ARENA_PREP_OPPONENT_SPECIALIZATIONS", "ARENA_OPPONENT_UPDATE"})
		f:SetScript("OnEvent", function(self, event)
			if event == "ARENA_OPPONENT_UPDATE" then
				for i = 1, 5 do
					bars[i]:Hide()
				end
			else
				local numOpps = GetNumArenaOpponentSpecs()
				if numOpps > 0 then
					for i = 1, 5 do
						local s = GetArenaOpponentSpec(i)
						local _, spec, class
						if s and s > 0 then 
							_, spec, _, _, _, class = GetSpecializationInfoByID(s)
						end
						if (i <= numOpps) then
							if class and spec then
								bars[i].Health:SetStatusBarColor(B.ClassColor(class))
								bars[i].SpecClass:SetText(spec.."  -  "..LOCALIZED_CLASS_NAMES_MALE[class] or "UNKNOWN")
								bars[i]:Show()
							end
						else
							bars[i]:Hide()
						end
					end
				else
					for i = 1, 5 do
						bars[i]:Hide()
					end
				end
			end
		end)
	end

	if NDuiDB["UFs"]["RaidFrame"] then
		-- Disable Default RaidFrame
		CompactRaidFrameContainer:UnregisterAllEvents()
		CompactRaidFrameContainer:Hide() 
		CompactRaidFrameManager:UnregisterAllEvents()
		CompactRaidFrameManager:Hide()

		-- Group Styles
		self:SetActiveStyle("Raid")

		local numGroups = NDuiDB["UFs"]["NumGroups"]
		local horizon = NDuiDB["UFs"]["HorizonRaid"]
		local scale = NDuiDB["UFs"]["RaidScale"]

		if NDuiDB["UFs"]["SimpleMode"] then
			local function CreateGroup(name, i)
				local group = self:SpawnHeader(name, nil, "solo,party,raid",
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
				groupFilter = "1,2,3,4,5,7"
			elseif numGroups == 8 then
				groupFilter = "1,2,3,4,5,8"
			end

			local group = CreateGroup("oUF_Raid", groupFilter)
			B.Mover(group, L["RaidFrame"], "RaidFrame", {"TOPLEFT", UIParent, 35, -50}, 140*scale, 30*20*scale)
		else
			local function CreateGroup(name, i)
				local group = self:SpawnHeader(name, nil, "solo,party,raid",
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
						B.Mover(groups[i], L["RaidFrame"], "RaidFrame", {"TOPLEFT", UIParent, 35, -50}, 84*5*scale, 40*numGroups*scale)
					else
						B.Mover(groups[i], L["RaidFrame"], "RaidFrame", {"TOPLEFT", UIParent, 35, -50}, 85*numGroups*scale, 42*5*scale)
					end
				else
					if horizon then
						groups[i]:SetPoint("TOPLEFT", groups[i-1], "BOTTOMLEFT", 0, -10)
					else
						groups[i]:SetPoint("TOPLEFT", groups[i-1], "TOPRIGHT", 5, 0)
					end
				end
			end
		end
	end
end)