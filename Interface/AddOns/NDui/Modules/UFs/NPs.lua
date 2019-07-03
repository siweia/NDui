local _, ns = ...
local B, C, L, DB = unpack(ns)
local UF = B:GetModule("UnitFrames")

local strmatch, tonumber, pairs, type, unpack, next, rad = string.match, tonumber, pairs, type, unpack, next, math.rad
local UnitThreatSituation, UnitIsTapDenied, UnitPlayerControlled, UnitIsUnit = UnitThreatSituation, UnitIsTapDenied, UnitPlayerControlled, UnitIsUnit
local UnitReaction, UnitIsConnected, UnitIsPlayer, UnitSelectionColor = UnitReaction, UnitIsConnected, UnitIsPlayer, UnitSelectionColor
local GetInstanceInfo, UnitClassification, UnitGUID, UnitExists, InCombatLockdown = GetInstanceInfo, UnitClassification, UnitGUID, UnitExists, InCombatLockdown
local C_Scenario_GetInfo, C_Scenario_GetStepInfo, C_NamePlate_GetNamePlates, C_MythicPlus_GetCurrentAffixes = C_Scenario.GetInfo, C_Scenario.GetStepInfo, C_NamePlate.GetNamePlates, C_MythicPlus.GetCurrentAffixes
local SetCVar, UIFrameFadeIn, UIFrameFadeOut = SetCVar, UIFrameFadeIn, UIFrameFadeOut

-- Init
function UF:PlateInsideView()
	if NDuiDB["Nameplate"]["InsideView"] then
		SetCVar("nameplateOtherTopInset", .05)
		SetCVar("nameplateOtherBottomInset", .08)
	else
		SetCVar("nameplateOtherTopInset", -1)
		SetCVar("nameplateOtherBottomInset", -1)
	end
end

function UF:UpdatePlateAlpha()
	SetCVar("nameplateMinAlpha", NDuiDB["Nameplate"]["MinAlpha"])
	SetCVar("nameplateMaxAlpha", NDuiDB["Nameplate"]["MinAlpha"])
end

function UF:UpdatePlateRange()
	SetCVar("nameplateMaxDistance", NDuiDB["Nameplate"]["Distance"])
end

function UF:UpdatePlateSpacing()
	SetCVar("nameplateOverlapV", NDuiDB["Nameplate"]["VerticalSpacing"])
end

function UF:SetupCVars()
	UF:PlateInsideView()
	SetCVar("nameplateOverlapH", .5)
	UF:UpdatePlateSpacing()
	UF:UpdatePlateRange()
	UF:UpdatePlateAlpha()
	SetCVar("nameplateSelectedAlpha", 1)
	SetCVar("showQuestTrackingTooltips", 1)

	SetCVar("namePlateMinScale", .8)
	SetCVar("namePlateMaxScale", .8)
	SetCVar("nameplateSelectedScale", 1)
	SetCVar("nameplateLargerScale", 1)

	SetCVar("nameplateShowSelf", 0)
	SetCVar("nameplateResourceOnTarget", 0)
	B.HideOption(InterfaceOptionsNamesPanelUnitNameplatesPersonalResource)
	B.HideOption(InterfaceOptionsNamesPanelUnitNameplatesPersonalResourceOnEnemy)
end

function UF:BlockAddons()
	if not DBM or not DBM.Nameplate then return end

	function DBM.Nameplate:SupportedNPMod()
		return true
	end

	local function showAurasForDBM(_, _, _, spellID)
		if not tonumber(spellID) then return end
		if not C.WhiteList[spellID] then
			C.WhiteList[spellID] = true
		end
	end
	hooksecurefunc(DBM.Nameplate, "Show", showAurasForDBM)
end

function UF:CreateUnitTable()
	if not NDuiDB["Nameplate"]["CustomUnitColor"] then C.CustomUnits = nil return end
	B.SplitList(C.CustomUnits, NDuiDB["Nameplate"]["UnitList"])
end

function UF:CreatePowerUnitTable()
	B.SplitList(C.ShowPowerList, NDuiDB["Nameplate"]["ShowPowerList"])
end

-- Elements
function UF.UpdateColor(element, unit)
	local name = GetUnitName(unit) or UNKNOWN
	local npcID = B.GetNPCID(UnitGUID(unit))
	local customUnit = C.CustomUnits and (C.CustomUnits[name] or C.CustomUnits[npcID])
	local status = UnitThreatSituation("player", unit) or false		-- just in case
	local reaction = UnitReaction(unit, "player")
	local customColor = NDuiDB["Nameplate"]["CustomColor"]
	local secureColor = NDuiDB["Nameplate"]["SecureColor"]
	local transColor = NDuiDB["Nameplate"]["TransColor"]
	local insecureColor = NDuiDB["Nameplate"]["InsecureColor"]
	local revertThreat = NDuiDB["Nameplate"]["DPSRevertThreat"]
	local r, g, b

	if not UnitIsConnected(unit) then
		r, g, b = .7, .7, .7
	else
		if customUnit then
			if type(customUnit) == "table" then
				r, g, b = unpack(customUnit)
			else
				r, g, b = customColor.r, customColor.g, customColor.b
			end
		elseif UnitIsPlayer(unit) and (reaction and reaction >= 5) then
			if NDuiDB["Nameplate"]["FriendlyCC"] then
				r, g, b = B.UnitColor(unit)
			else
				r, g, b = .3, .3, 1
			end
		elseif UnitIsPlayer(unit) and (reaction and reaction <= 4) and NDuiDB["Nameplate"]["HostileCC"] then
			r, g, b = B.UnitColor(unit)
		elseif UnitIsTapDenied(unit) and not UnitPlayerControlled(unit) then
			r, g, b = .6, .6, .6
		else
			r, g, b = UnitSelectionColor(unit, true)
			if status and (NDuiDB["Nameplate"]["TankMode"] or DB.Role == "Tank") then
				if status == 3 then
					if DB.Role ~= "Tank" and revertThreat then
						r, g, b = insecureColor.r, insecureColor.g, insecureColor.b
					else
						r, g, b = secureColor.r, secureColor.g, secureColor.b
					end
				elseif status == 2 or status == 1 then
					r, g, b = transColor.r, transColor.g, transColor.b
				elseif status == 0 then
					if DB.Role ~= "Tank" and revertThreat then
						r, g, b = secureColor.r, secureColor.g, secureColor.b
					else
						r, g, b = insecureColor.r, insecureColor.g, insecureColor.b
					end
				end
			end
		end
	end

	if r or g or b then
		element:SetStatusBarColor(r, g, b)
	end

	if not NDuiDB["Nameplate"]["TankMode"] and DB.Role ~= "Tank" then
		if status and status == 3 then
			element.Shadow:SetBackdropBorderColor(1, 0, 0)
		elseif status and (status == 2 or status == 1) then
			element.Shadow:SetBackdropBorderColor(1, 1, 0)
		else
			element.Shadow:SetBackdropBorderColor(0, 0, 0)
		end
	else
		element.Shadow:SetBackdropBorderColor(0, 0, 0)
	end
end

function UF:UpdateThreatColor(_, unit)
	if unit ~= self.unit then return end
	UF.UpdateColor(self.Health, unit)
end

function UF:UpdateTargetMark()
	local arrow = self.arrowMark
	local mark = self.tarMark

	if UnitIsUnit(self.unit, "target") and not UnitIsUnit(self.unit, "player") then
		if arrow then arrow:Show() end
		if mark then mark:Show() end
	else
		if arrow then arrow:Hide() end
		if mark then mark:Hide() end
	end
end

local unitTip = CreateFrame("GameTooltip", "NDuiQuestUnitTip", nil, "GameTooltipTemplate")

function UF:UpdateQuestUnit(_, unit)
	if not NDuiDB["Nameplate"]["QuestIcon"] then return end
	if IsInInstance() then
		self.questIcon:Hide()
		self.questCount:SetText("")
		return
	end
	unit = unit or self.unit

	local isLootQuest, questProgress
	unitTip:SetOwner(UIParent, "ANCHOR_NONE")
	unitTip:SetUnit(unit)

	for i = 2, unitTip:NumLines() do
		local textLine = _G[unitTip:GetName().."TextLeft"..i]
		local text = textLine:GetText()
		if textLine and text then
			local r, g, b = textLine:GetTextColor()
			local unitName, progressText = strmatch(text, "^ ([^ ]-) ?%- (.+)$")
			if r > .99 and g > .82 and b == 0 then
				isLootQuest = true
			elseif unitName and progressText then
				isLootQuest = false
				if unitName == "" or unitName == DB.MyName then
					local current, goal = strmatch(progressText, "(%d+)/(%d+)")
					local progress = strmatch(progressText, "([%d%.]+)%%")
					if current and goal then
						if tonumber(current) < tonumber(goal) then
							questProgress = goal - current
							break
						end
					elseif progress then
						progress = tonumber(progress)
						if progress and progress < 100 then
							questProgress = progress.."%"
							break
						end
					else
						isLootQuest = true
						break
					end
				end
			end
		end
	end

	if questProgress then
		self.questCount:SetText(questProgress)
		self.questIcon:SetAtlas(DB.objectTex)
		self.questIcon:Show()
	else
		self.questCount:SetText("")
		if isLootQuest then
			self.questIcon:SetAtlas(DB.questTex)
			self.questIcon:Show()
		else
			self.questIcon:Hide()
		end
	end
end

local cache = {}
function UF:UpdateDungeonProgress(unit)
	if not self.progressText or not AngryKeystones_Data then return end
	if unit ~= self.unit then return end
	self.progressText:SetText("")

	local name, _, _, _, _, _, _, _, _, scenarioType = C_Scenario_GetInfo()
	if scenarioType == LE_SCENARIO_TYPE_CHALLENGE_MODE then
		local npcID = B.GetNPCID(UnitGUID(unit))
		local info = AngryKeystones_Data.progress[npcID]
		if info then
			local numCriteria = select(3, C_Scenario_GetStepInfo())
			local total = cache[name]
			if not total then
				for criteriaIndex = 1, numCriteria do
					local _, _, _, _, totalQuantity, _, _, _, _, _, _, _, isWeightedProgress = C_Scenario.GetCriteriaInfo(criteriaIndex)
					if isWeightedProgress then
						cache[name] = totalQuantity
						total = cache[name]
						break
					end
				end
			end

			local value, valueCount
			for amount, count in pairs(info) do
				if not valueCount or count > valueCount or (count == valueCount and amount < value) then
					value = amount
					valueCount = count
				end
			end

			if value and total then
				self.progressText:SetText(format("+%.2f", value/total*100))
			end
		end
	end
end

local classify = {
	rare = {1, 1, 1, true},
	elite = {1, 1, 1},
	rareelite = {1, .1, .1},
	worldboss = {0, 1, 0},
}

function UF:UpdateUnitClassify(unit)
	local class = UnitClassification(unit)
	if self.creatureIcon then
		if class and classify[class] then
			local r, g, b, desature = unpack(classify[class])
			self.creatureIcon:SetVertexColor(r, g, b)
			self.creatureIcon:SetDesaturated(desature)
			self.creatureIcon:SetAlpha(1)
		else
			self.creatureIcon:SetAlpha(0)
		end
	end
end

local explosiveCount, hasExplosives = 0
local id = 120651
function UF:ScalePlates()
	for _, nameplate in next, C_NamePlate_GetNamePlates() do
		local unitFrame = nameplate.unitFrame
		local npcID = B.GetNPCID(UnitGUID(unitFrame.unit))
		if explosiveCount > 0 and npcID == id or explosiveCount == 0 then
			unitFrame:SetWidth(NDuiDB["Nameplate"]["Width"] * 1.4)
		else
			unitFrame:SetWidth(NDuiDB["Nameplate"]["Width"] * .9)
		end
	end
end

function UF:UpdateExplosives(event, unit)
	if not hasExplosives or unit ~= self.unit then return end

	local npcID = B.GetNPCID(UnitGUID(unit))
	if event == "NAME_PLATE_UNIT_ADDED" and npcID == id then
		explosiveCount = explosiveCount + 1
	elseif event == "NAME_PLATE_UNIT_REMOVED" and npcID == id then
		explosiveCount = explosiveCount - 1
	end
	UF:ScalePlates()
end

local function checkInstance()
	local name, _, instID = GetInstanceInfo()
	if name and instID == 8 then
		hasExplosives = true
	else
		hasExplosives = false
		explosiveCount = 0
	end
end

function UF:CheckExplosives()
	if not NDuiDB["Nameplate"]["ExplosivesScale"] then return end

	local function checkAffixes(event)
		local affixes = C_MythicPlus_GetCurrentAffixes()
		if not affixes then return end
		if affixes[3] and affixes[3].id == 13 then
			checkInstance()
			B:RegisterEvent(event, checkInstance)
			B:RegisterEvent("CHALLENGE_MODE_START", checkInstance)
		end
		B:UnregisterEvent(event, checkAffixes)
	end
	B:RegisterEvent("PLAYER_ENTERING_WORLD", checkAffixes)
end

function UF:IsMouseoverUnit()
	if not self or not self.unit then return end

	if self:IsVisible() and UnitExists("mouseover") and not UnitIsUnit("target", self.unit) then
		return UnitIsUnit("mouseover", self.unit)
	end
	return false
end

function UF:UpdateMouseoverShown()
	if not self or not self.unit then return end

	if self:IsShown() and UnitIsUnit("mouseover", self.unit) and not UnitIsUnit("target", self.unit) then
		self.glow:Show()
		self.HighlightIndicator:Show()
	else
		self.HighlightIndicator:Hide()
	end
end

local function AddMouseoverIndicator(self)
	local glow = CreateFrame("Frame", nil, UIParent)
	glow:SetPoint("TOPLEFT", self, -6, 6)
	glow:SetPoint("BOTTOMRIGHT", self, 6, -6)
	glow:SetBackdrop({edgeFile = DB.glowTex, edgeSize = 4})
	glow:SetBackdropBorderColor(1, 1, 1)
	glow:Hide()

	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", UF.UpdateMouseoverShown, true)
	self:RegisterEvent("PLAYER_TARGET_CHANGED", UF.UpdateMouseoverShown, true)

	local f = CreateFrame("Frame", nil, self)
	f:SetScript("OnUpdate", function(_, elapsed)
		f.elapsed = (f.elapsed or 0) + elapsed
		if f.elapsed > .1 then
			if not UF.IsMouseoverUnit(self) then
				f:Hide()
			end
			f.elapsed = 0
		end
	end)
	f:HookScript("OnHide", function()
		glow:Hide()
	end)

	self.glow = glow
	self.HighlightIndicator = f
end

function UF:AddFollowerXP(self)
	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetSize(NDuiDB["Nameplate"]["Width"], NDuiDB["Nameplate"]["Height"])
	bar:SetPoint("TOP", self.Castbar, "BOTTOM", 0, -5)
	B.CreateSB(bar, false, 0, .7, 1)
	bar.progressText = B.CreateFS(bar, 9)

	self.NazjatarFollowerXP = bar
end

-- Create Nameplates
function UF:CreatePlates(unit)
	self.mystyle = "nameplate"
	if strmatch(unit, "nameplate") then
		self:SetSize(NDuiDB["Nameplate"]["Width"] * 1.4, NDuiDB["Nameplate"]["Height"])
		self:SetPoint("CENTER", 0, -3)

		local health = CreateFrame("StatusBar", nil, self)
		health:SetAllPoints()
		health:SetFrameLevel(self:GetFrameLevel() - 2)
		B.CreateSB(health)
		B.SmoothBar(health)
		self.Health = health
		self.Health.frequentUpdates = true
		self.Health.UpdateColor = UF.UpdateColor

		UF:CreateHealthText(self)
		UF:CreateCastBar(self)
		UF:CreateRaidMark(self)
		UF:CreatePrediction(self)
		UF:CreateAuras(self)
		UF:CreatePVPClassify(self)
		UF:AddFollowerXP(self)

		self.powerText = B.CreateFS(self, 15, "", false, "LEFT", 0, 0)
		self.powerText:SetPoint("LEFT", self, "RIGHT", 2, 0)
		self:Tag(self.powerText, "[nppp]")

		if NDuiDB["Nameplate"]["TarArrow"] < 3 then
			local arrow = self:CreateTexture(nil, "OVERLAY", nil, 1)
			arrow:SetSize(40, 40)
			arrow:SetTexture(DB.arrowTex)
			if NDuiDB["Nameplate"]["TarArrow"] == 2 then
				arrow:SetPoint("LEFT", self, "RIGHT", 3, 0)
				arrow:SetRotation(rad(-90))
			else
				arrow:SetPoint("BOTTOM", self, "TOP", 0, 14)
			end
			arrow:Hide()
			self.arrowMark = arrow
		end
		local mark = self.Health:CreateTexture(nil, "BACKGROUND", nil, -1)
		mark:SetHeight(12)
		mark:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", -20, -2)
		mark:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 20, -2)
		mark:SetTexture("Interface\\GLUES\\Models\\UI_Draenei\\GenericGlow64")
		mark:SetVertexColor(0, .6, 1)
		mark:Hide()
		self.tarMark = mark
		self:RegisterEvent("PLAYER_TARGET_CHANGED", UF.UpdateTargetMark, true)

		local iconFrame = CreateFrame("Frame", nil, self)
		iconFrame:SetAllPoints()
		iconFrame:SetFrameLevel(self:GetFrameLevel() + 2)
		local cicon = iconFrame:CreateTexture(nil, "ARTWORK")
		cicon:SetAtlas("VignetteKill")
		cicon:SetPoint("BOTTOMLEFT", self, "LEFT", 0, -4)
		cicon:SetSize(18, 18)
		cicon:SetAlpha(0)
		self.creatureIcon = cicon

		if NDuiDB["Nameplate"]["QuestIcon"] then
			local qicon = self:CreateTexture(nil, "OVERLAY", nil, 2)
			qicon:SetPoint("LEFT", self, "RIGHT", -1, 0)
			qicon:SetSize(20, 20)
			qicon:SetAtlas(DB.questTex)
			qicon:Hide()
			local count = B.CreateFS(self, 12, "", nil, "LEFT", 0, 0)
			count:SetPoint("LEFT", qicon, "RIGHT", -4, 0)
			count:SetTextColor(.6, .8, 1)

			self.questIcon = qicon
			self.questCount = count
			self:RegisterEvent("QUEST_LOG_UPDATE", UF.UpdateQuestUnit, true)
		end

		if NDuiDB["Nameplate"]["AKSProgress"] then
			self.progressText = B.CreateFS(self, 12, "", false, "LEFT", 0, 0)
			self.progressText:SetPoint("LEFT", self, "RIGHT", 5, 0)
		end

		local threatIndicator = CreateFrame("Frame", nil, self)
		self.ThreatIndicator = threatIndicator
		self.ThreatIndicator.Override = UF.UpdateThreatColor

		AddMouseoverIndicator(self)
	end
end

function UF:PostUpdatePlates(event, unit)
	if not self then return end
	UF.UpdateTargetMark(self)
	UF.UpdateQuestUnit(self, event, unit)
	UF.UpdateUnitClassify(self, unit)
	UF.UpdateExplosives(self, event, unit)
	UF.UpdateDungeonProgress(self, unit)
end

-- Player Nameplate
local auras = B:GetModule("Auras")

function UF:PlateVisibility(event)
	if (event == "PLAYER_REGEN_DISABLED" or InCombatLockdown()) and UnitIsUnit("player", self.unit) then
		UIFrameFadeIn(self.Health, .3, self.Health:GetAlpha(), 1)
		UIFrameFadeIn(self.Health.bg, .3, self.Health.bg:GetAlpha(), 1)
		UIFrameFadeIn(self.Power, .3, self.Power:GetAlpha(), 1)
		UIFrameFadeIn(self.Power.bg, .3, self.Power.bg:GetAlpha(), 1)
	else
		UIFrameFadeOut(self.Health, 2, self.Health:GetAlpha(), .1)
		UIFrameFadeOut(self.Health.bg, 2, self.Health.bg:GetAlpha(), .1)
		UIFrameFadeOut(self.Power, 2, self.Power:GetAlpha(), .1)
		UIFrameFadeOut(self.Power.bg, 2, self.Power.bg:GetAlpha(), .1)
	end
end

function UF:CreatePlayerPlate()
	self.mystyle = "PlayerPlate"
	local iconSize, margin = NDuiDB["Nameplate"]["PPIconSize"], 2
	self:SetSize(iconSize*5 + margin*4, NDuiDB["Nameplate"]["PPHeight"])
	self:EnableMouse(false)
	self.iconSize = iconSize

	UF:CreateHealthBar(self)
	UF:CreatePowerBar(self)
	UF:CreateClassPower(self)
	UF:StaggerBar(self)
	if NDuiDB["Auras"]["ClassAuras"] then auras:CreateLumos(self) end

	if NDuiDB["Nameplate"]["PPPowerText"] then
		local textFrame = CreateFrame("Frame", nil, self.Power)
		textFrame:SetAllPoints()
		local power = B.CreateFS(textFrame, 14, "")
		self:Tag(power, "[pppower]")
	end

	if NDuiDB["Nameplate"]["PPHideOOC"] then
		self:RegisterEvent("UNIT_EXITED_VEHICLE", UF.PlateVisibility)
		self:RegisterEvent("UNIT_ENTERED_VEHICLE", UF.PlateVisibility)
		self:RegisterEvent("PLAYER_REGEN_ENABLED", UF.PlateVisibility, true)
		self:RegisterEvent("PLAYER_REGEN_DISABLED", UF.PlateVisibility, true)
		self:RegisterEvent("PLAYER_ENTERING_WORLD", UF.PlateVisibility, true)
	end
end