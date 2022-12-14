local _, ns = ...
local B, C, L, DB = unpack(ns)
local UF = B:GetModule("UnitFrames")

local _G = getfenv(0)
local floor, strmatch, tonumber, pairs, unpack, rad = floor, string.match, tonumber, pairs, unpack, math.rad
local UnitThreatSituation, UnitIsTapDenied, UnitPlayerControlled, UnitIsUnit = UnitThreatSituation, UnitIsTapDenied, UnitPlayerControlled, UnitIsUnit
local UnitReaction, UnitIsConnected, UnitIsPlayer, UnitSelectionColor = UnitReaction, UnitIsConnected, UnitIsPlayer, UnitSelectionColor
local UnitClassification, UnitExists, InCombatLockdown, UnitCanAttack = UnitClassification, UnitExists, InCombatLockdown, UnitCanAttack
local C_Scenario_GetInfo, C_Scenario_GetStepInfo = C_Scenario.GetInfo, C_Scenario.GetStepInfo
local C_ChallengeMode_GetActiveKeystoneInfo = C_ChallengeMode.GetActiveKeystoneInfo
local UnitGUID, GetPlayerInfoByGUID, Ambiguate = UnitGUID, GetPlayerInfoByGUID, Ambiguate
local SetCVar, UIFrameFadeIn, UIFrameFadeOut = SetCVar, UIFrameFadeIn, UIFrameFadeOut
local IsInRaid, IsInGroup, UnitName, UnitHealth, UnitHealthMax = IsInRaid, IsInGroup, UnitName, UnitHealth, UnitHealthMax
local GetNumGroupMembers, GetNumSubgroupMembers, UnitGroupRolesAssigned = GetNumGroupMembers, GetNumSubgroupMembers, UnitGroupRolesAssigned
local C_NamePlate_GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local GetSpellCooldown, GetTime = GetSpellCooldown, GetTime
local UnitNameplateShowsWidgetsOnly = UnitNameplateShowsWidgetsOnly
local INTERRUPTED, THREAT_TOOLTIP = INTERRUPTED, THREAT_TOOLTIP
local C_NamePlate_SetNamePlateEnemySize = C_NamePlate.SetNamePlateEnemySize
local C_NamePlate_SetNamePlateFriendlySize = C_NamePlate.SetNamePlateFriendlySize
local C_NamePlate_SetNamePlateEnemyClickThrough = C_NamePlate.SetNamePlateEnemyClickThrough
local C_NamePlate_SetNamePlateFriendlyClickThrough = C_NamePlate.SetNamePlateFriendlyClickThrough

-- Init
function UF:UpdatePlateCVars()
	if C.db["Nameplate"]["InsideView"] then
		SetCVar("nameplateOtherTopInset", .05)
		SetCVar("nameplateOtherBottomInset", .08)
	elseif GetCVar("nameplateOtherTopInset") == "0.05" and GetCVar("nameplateOtherBottomInset") == "0.08" then
		SetCVar("nameplateOtherTopInset", -1)
		SetCVar("nameplateOtherBottomInset", -1)
	end

	SetCVar("namePlateMinScale", C.db["Nameplate"]["MinScale"])
	SetCVar("namePlateMaxScale", C.db["Nameplate"]["MinScale"])
	SetCVar("nameplateMinAlpha", C.db["Nameplate"]["MinAlpha"])
	SetCVar("nameplateMaxAlpha", C.db["Nameplate"]["MinAlpha"])
	SetCVar("nameplateOverlapV", C.db["Nameplate"]["VerticalSpacing"])
	SetCVar("nameplateShowOnlyNames", C.db["Nameplate"]["CVarOnlyNames"] and 1 or 0)
	SetCVar("nameplateShowFriendlyNPCs", C.db["Nameplate"]["CVarShowNPCs"] and 1 or 0)
end

function UF:UpdateClickableSize()
	if InCombatLockdown() then return end

	local uiScale = NDuiADB["UIScale"]
	local harmWidth, harmHeight = C.db["Nameplate"]["HarmWidth"], C.db["Nameplate"]["HarmHeight"]
	local helpWidth, helpHeight = C.db["Nameplate"]["HelpWidth"], C.db["Nameplate"]["HelpHeight"]

	C_NamePlate_SetNamePlateEnemySize(harmWidth*uiScale, harmHeight*uiScale)
	C_NamePlate_SetNamePlateFriendlySize(helpWidth*uiScale, helpHeight*uiScale)
end

function UF:UpdatePlateClickThru()
	if InCombatLockdown() then return end

	C_NamePlate_SetNamePlateEnemyClickThrough(C.db["Nameplate"]["EnemyThru"])
	C_NamePlate_SetNamePlateFriendlyClickThrough(C.db["Nameplate"]["FriendlyThru"])
end

function UF:SetupCVars()
	UF:UpdatePlateCVars()
	SetCVar("nameplateOverlapH", .8)
	SetCVar("nameplateSelectedAlpha", 1)
	SetCVar("showQuestTrackingTooltips", 1)

	SetCVar("nameplateSelectedScale", 1)
	SetCVar("nameplateLargerScale", 1)
	SetCVar("nameplateGlobalScale", 1)

	SetCVar("nameplateShowSelf", 0)
	SetCVar("nameplateResourceOnTarget", 0)
	UF:UpdateClickableSize()
	hooksecurefunc(NamePlateDriverFrame, "UpdateNamePlateOptions", UF.UpdateClickableSize)
	UF:UpdatePlateClickThru()
end

function UF:BlockAddons()
	if not C.db["Nameplate"]["BlockDBM"] then return end
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

-- Elements
local function refreshNameplateUnits(VALUE)
	wipe(UF[VALUE])
	if not C.db["Nameplate"]["Show"..VALUE] then return end

	for npcID in pairs(C[VALUE]) do
		if C.db["Nameplate"][VALUE][npcID] == nil then
			UF[VALUE][npcID] = true
		end
	end
	for npcID, value in pairs(C.db["Nameplate"][VALUE]) do
		if value then
			UF[VALUE][npcID] = true
		end
	end
end

UF.CustomUnits = {}
function UF:CreateUnitTable()
	refreshNameplateUnits("CustomUnits")
end

UF.PowerUnits = {}
function UF:CreatePowerUnitTable()
	refreshNameplateUnits("PowerUnits")
end

function UF:UpdateUnitPower()
	local unitName = self.unitName
	local npcID = self.npcID
	local shouldShowPower = UF.PowerUnits[unitName] or UF.PowerUnits[npcID]
	self.powerText:SetShown(shouldShowPower)
end

-- Off-tank threat color
local groupRoles, isInGroup = {}
local function refreshGroupRoles()
	local isInRaid = IsInRaid()
	isInGroup = isInRaid or IsInGroup()
	wipe(groupRoles)

	if isInGroup then
		local numPlayers = (isInRaid and GetNumGroupMembers()) or GetNumSubgroupMembers()
		local unit = (isInRaid and "raid") or "party"
		for i = 1, numPlayers do
			local index = unit..i
			if UnitExists(index) then
				groupRoles[UnitName(index)] = UnitGroupRolesAssigned(index)
			end
		end
	end
end

local function resetGroupRoles()
	isInGroup = IsInRaid() or IsInGroup()
	wipe(groupRoles)
end

function UF:UpdateGroupRoles()
	refreshGroupRoles()
	B:RegisterEvent("GROUP_ROSTER_UPDATE", refreshGroupRoles)
	B:RegisterEvent("GROUP_LEFT", resetGroupRoles)
end

function UF:CheckThreatStatus(unit)
	if not UnitExists(unit) then return end

	local unitTarget = unit.."target"
	local unitRole = isInGroup and UnitExists(unitTarget) and not UnitIsUnit(unitTarget, "player") and groupRoles[UnitName(unitTarget)] or "NONE"
	if DB.Role == "Tank" and unitRole == "TANK" then
		return true, UnitThreatSituation(unitTarget, unit)
	else
		return false, UnitThreatSituation("player", unit)
	end
end

-- Update unit color
function UF:UpdateColor(_, unit)
	if not unit or self.unit ~= unit then return end

	local element = self.Health
	local name = self.unitName
	local npcID = self.npcID
	local isCustomUnit = UF.CustomUnits[name] or UF.CustomUnits[npcID]
	local isPlayer = self.isPlayer
	local isFriendly = self.isFriendly
	local isOffTank, status = UF:CheckThreatStatus(unit)
	local customColor = C.db["Nameplate"]["CustomColor"]
	local secureColor = C.db["Nameplate"]["SecureColor"]
	local transColor = C.db["Nameplate"]["TransColor"]
	local insecureColor = C.db["Nameplate"]["InsecureColor"]
	local revertThreat = C.db["Nameplate"]["DPSRevertThreat"]
	local offTankColor = C.db["Nameplate"]["OffTankColor"]
	local executeRatio = C.db["Nameplate"]["ExecuteRatio"]
	local healthPerc = UnitHealth(unit) / (UnitHealthMax(unit) + .0001) * 100
	local targetColor = C.db["Nameplate"]["TargetColor"]
	local focusColor = C.db["Nameplate"]["FocusColor"]
	local dotColor = C.db["Nameplate"]["DotColor"]
	local r, g, b

	if not UnitIsConnected(unit) then
		r, g, b = .7, .7, .7
	else
		if C.db["Nameplate"]["ColoredTarget"] and UnitIsUnit(unit, "target") then
			r, g, b = targetColor.r, targetColor.g, targetColor.b
		elseif C.db["Nameplate"]["ColoredFocus"] and UnitIsUnit(unit, "focus") then
			r, g, b = focusColor.r, focusColor.g, focusColor.b
		elseif isCustomUnit then
			r, g, b = customColor.r, customColor.g, customColor.b
		elseif self.Auras.hasTheDot then
			r, g, b = dotColor.r, dotColor.g, dotColor.b
		elseif isPlayer and isFriendly then
			if C.db["Nameplate"]["FriendlyCC"] then
				r, g, b = B.UnitColor(unit)
			else
				r, g, b = .3, .3, 1
			end
		elseif isPlayer and (not isFriendly) and C.db["Nameplate"]["HostileCC"] then
			r, g, b = B.UnitColor(unit)
		elseif UnitIsTapDenied(unit) and not UnitPlayerControlled(unit) or C.TrashUnits[npcID] then
			r, g, b = .6, .6, .6
		else
			r, g, b = UnitSelectionColor(unit, true)
			if status and (C.db["Nameplate"]["TankMode"] or DB.Role == "Tank") then
				if status == 3 then
					if DB.Role ~= "Tank" and revertThreat then
						r, g, b = insecureColor.r, insecureColor.g, insecureColor.b
					else
						if isOffTank then
							r, g, b = offTankColor.r, offTankColor.g, offTankColor.b
						else
							r, g, b = secureColor.r, secureColor.g, secureColor.b
						end
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

	self.ThreatIndicator:Hide()
	if status and (isCustomUnit or (not C.db["Nameplate"]["TankMode"] and DB.Role ~= "Tank")) then
		if status == 3 then
			self.ThreatIndicator:SetBackdropBorderColor(1, 0, 0)
			self.ThreatIndicator:Show()
		elseif status == 2 or status == 1 then
			self.ThreatIndicator:SetBackdropBorderColor(1, 1, 0)
			self.ThreatIndicator:Show()
		end
	end

	if executeRatio > 0 and healthPerc <= executeRatio then
		self.nameText:SetTextColor(1, 0, 0)
	else
		self.nameText:SetTextColor(1, 1, 1)
	end
end

function UF:UpdateThreatColor(_, unit)
	if unit ~= self.unit then return end

	UF.UpdateColor(self, _, unit)
end

function UF:CreateThreatColor(self)
	local threatIndicator = B.CreateSD(self.backdrop, nil, true)
	threatIndicator:Hide()
	self.backdrop.__shadow = nil

	self.ThreatIndicator = threatIndicator
	self.ThreatIndicator.Override = UF.UpdateThreatColor
end

function UF:UpdateFocusColor()
	if C.db["Nameplate"]["ColoredFocus"] then
		UF.UpdateThreatColor(self, _, self.unit)
	end
end

-- Target indicator
function UF:UpdateTargetChange()
	local element = self.TargetIndicator
	local unit = self.unit

	if C.db["Nameplate"]["TargetIndicator"] ~= 1 then
		if UnitIsUnit(unit, "target") and not UnitIsUnit(unit, "player") then
			element:Show()
			if element.Arrow:IsShown() and not element.ArrowAnimGroup:IsPlaying() then
				element.ArrowAnimGroup:Play()
			end
		else
			element:Hide()
			if element.ArrowAnimGroup:IsPlaying() then
				element.ArrowAnimGroup:Stop()
			end
		end
	end
	if C.db["Nameplate"]["ColoredTarget"] then
		UF.UpdateThreatColor(self, _, unit)
	end
end

local points = {-15, -5, 0, 5, 0}

function UF:UpdateTargetIndicator()
	local style = C.db["Nameplate"]["TargetIndicator"]
	local element = self.TargetIndicator
	local isNameOnly = self.plateType == "NameOnly"
	if style == 1 then
		element:Hide()
	else
		if style == 2 then
			element.Arrow:ClearAllPoints()
			element.Arrow:SetPoint("BOTTOM", element, "TOP", 0, 20)
			element.Arrow:SetRotation(0)
			element.Arrow:Show()
			for i = 1, 5 do
				element.ArrowAnim.points[i]:SetOffset(0, points[i])
			end
			element.Glow:Hide()
			element.nameGlow:Hide()
		elseif style == 3 then
			element.Arrow:ClearAllPoints()
			element.Arrow:SetPoint("LEFT", element, "RIGHT", 3, 0)
			element.Arrow:SetRotation(rad(-90))
			element.Arrow:Show()
			for i = 1, 5 do
				element.ArrowAnim.points[i]:SetOffset(points[i], 0)
			end
			element.Glow:Hide()
			element.nameGlow:Hide()
		elseif style == 4 then
			element.Arrow:Hide()
			if isNameOnly then
				element.Glow:Hide()
				element.nameGlow:Show()
			else
				element.Glow:Show()
				element.nameGlow:Hide()
			end
		elseif style == 5 then
			element.Arrow:ClearAllPoints()
			element.Arrow:SetPoint("BOTTOM", element, "TOP", 0, 20)
			element.Arrow:SetRotation(0)
			element.Arrow:Show()
			for i = 1, 5 do
				element.ArrowAnim.points[i]:SetOffset(0, points[i])
			end
			if isNameOnly then
				element.Glow:Hide()
				element.nameGlow:Show()
			else
				element.Glow:Show()
				element.nameGlow:Hide()
			end
		elseif style == 6 then
			element.Arrow:ClearAllPoints()
			element.Arrow:SetPoint("LEFT", element, "RIGHT", 3, 0)
			element.Arrow:SetRotation(rad(-90))
			element.Arrow:Show()
			for i = 1, 5 do
				element.ArrowAnim.points[i]:SetOffset(points[i], 0)
			end
			if isNameOnly then
				element.Glow:Hide()
				element.nameGlow:Show()
			else
				element.Glow:Show()
				element.nameGlow:Hide()
			end
		end
		element:Show()
	end
end

function UF:AddTargetIndicator(self)
	local frame = CreateFrame("Frame", nil, self)
	frame:SetAllPoints()
	frame:SetFrameLevel(0)
	frame:Hide()

	frame.Arrow = frame:CreateTexture(nil, "BACKGROUND", nil, -5)
	frame.Arrow:SetSize(50, 50)
	frame.Arrow:SetTexture(DB.arrowTex)

	local animGroup = frame.Arrow:CreateAnimationGroup()
	animGroup:SetLooping("REPEAT")
	local anim = animGroup:CreateAnimation("Path")
	anim:SetDuration(1)
	anim.points = {}
	for i = 1, 5 do
		anim.points[i] = anim:CreateControlPoint()
		anim.points[i]:SetOrder(i)
	end
	frame.ArrowAnim = anim
	frame.ArrowAnimGroup = animGroup

	frame.Glow = B.CreateSD(frame, 8, true)
	frame.Glow:SetOutside(self.backdrop, 8, 8)
	frame.Glow:SetBackdropBorderColor(1, 1, 1)
	frame.Glow:SetFrameLevel(0)

	frame.nameGlow = frame:CreateTexture(nil, "BACKGROUND", nil, -5)
	frame.nameGlow:SetSize(150, 80)
	frame.nameGlow:SetTexture("Interface\\GLUES\\Models\\UI_Draenei\\GenericGlow64")
	frame.nameGlow:SetVertexColor(0, .6, 1)
	frame.nameGlow:SetBlendMode("ADD")
	frame.nameGlow:SetPoint("CENTER", self, "BOTTOM")

	self.TargetIndicator = frame
	self:RegisterEvent("PLAYER_TARGET_CHANGED", UF.UpdateTargetChange, true)
	UF.UpdateTargetIndicator(self)
end

-- Quest progress
local isInInstance
local function CheckInstanceStatus()
	isInInstance = IsInInstance()
end

function UF:QuestIconCheck()
	CheckInstanceStatus()
	B:RegisterEvent("PLAYER_ENTERING_WORLD", CheckInstanceStatus)
end

local function isQuestTitle(textLine)
	local r, g, b = textLine:GetTextColor()
	if r > .99 and g > .8 and b == 0 then
		return true
	end
end

function UF:UpdateQuestUnit(_, unit)
	if not C.db["Nameplate"]["QuestIndicator"] then return end
	if isInInstance then
		self.questIcon:Hide()
		self.questCount:SetText("")
		return
	end

	unit = unit or self.unit
	local startLooking, isLootQuest, questProgress -- FIXME: isLootQuest in old expansion

	local data = C_TooltipInfo.GetUnit(unit)
	if data then
		for i = 1, #data.lines do
			local lineData = data.lines[i]
			local argVal = lineData and lineData.args
			if argVal[1] and argVal[1].intVal == 8 then
				local text = argVal[2] and argVal[2].stringVal -- progress string
				if text then
					local current, goal = strmatch(text, "(%d+)/(%d+)")
					local progress = strmatch(text, "(%d+)%%")
					if current and goal then
						local diff = floor(goal - current)
						if diff > 0 then
							questProgress = diff
							break
						end
					elseif progress then
						if floor(100 - progress) > 0 then
							questProgress = progress.."%" -- lower priority on progress, keep looking
						end
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

function UF:AddQuestIcon(self)
	if not C.db["Nameplate"]["QuestIndicator"] then return end

	local qicon = self:CreateTexture(nil, "OVERLAY", nil, 2)
	qicon:SetPoint("LEFT", self, "RIGHT", -1, 0)
	qicon:SetSize(30, 30)
	qicon:SetAtlas(DB.questTex)
	qicon:Hide()
	local count = B.CreateFS(self, 20, "", nil, "LEFT", 0, 0)
	count:SetPoint("LEFT", qicon, "RIGHT", -4, 0)
	count:SetTextColor(.6, .8, 1)

	self.questIcon = qicon
	self.questCount = count
	self:RegisterEvent("QUEST_LOG_UPDATE", UF.UpdateQuestUnit, true)
end

-- Dungeon progress, AngryKeystones required
function UF:AddDungeonProgress(self)
	if not C.db["Nameplate"]["AKSProgress"] then return end

	self.progressText = B.CreateFS(self, 16, "", false, "LEFT", 0, 0)
	self.progressText:SetPoint("LEFT", self, "RIGHT", 5, 0)
end

local cache = {}
function UF:UpdateDungeonProgress(unit)
	if not self.progressText or not AngryKeystones_Data then return end
	if unit ~= self.unit then return end
	self.progressText:SetText("")

	local name, _, _, _, _, _, _, _, _, scenarioType = C_Scenario_GetInfo()
	if scenarioType == LE_SCENARIO_TYPE_CHALLENGE_MODE then
		local npcID = self.npcID
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

-- Unit classification
local NPClassifies = {
	rare = {1, 1, 1, true},
	elite = {1, 1, 1},
	rareelite = {1, .1, .1},
	worldboss = {0, 1, 0},
}

function UF:AddCreatureIcon(self)
	local icon = self:CreateTexture(nil, "ARTWORK")
	icon:SetTexture(DB.starTex)
	icon:SetPoint("RIGHT", self.nameText, "LEFT", 10, 0)
	icon:SetSize(18, 18)
	icon:Hide()

	self.ClassifyIndicator = icon
end

function UF:UpdateUnitClassify(unit)
	if not self.ClassifyIndicator then return end
	if not unit then unit = self.unit end

	self.ClassifyIndicator:Hide()

	if self.__tagIndex > 3 then
		local class = UnitClassification(unit)
		local classify = class and NPClassifies[class]
		if classify then
			local r, g, b, desature = unpack(classify)
			self.ClassifyIndicator:SetVertexColor(r, g, b)
			self.ClassifyIndicator:SetDesaturated(desature)
			self.ClassifyIndicator:Show()
		end
	end
end

-- Scale plates for explosives
local hasExplosives
local EXPLOSIVE_ID = 120651
function UF:UpdateExplosives(event, unit)
	if not hasExplosives or unit ~= self.unit then return end

	local npcID = self.npcID
	if event == "NAME_PLATE_UNIT_ADDED" and npcID == EXPLOSIVE_ID then
		self:SetScale(NDuiADB["UIScale"]*1.5)
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		self:SetScale(NDuiADB["UIScale"])
	end
end

local function checkAffixes(event)
	local _, affixes = C_ChallengeMode_GetActiveKeystoneInfo()
	if affixes[3] and affixes[3] == 13 then
		hasExplosives = true
	else
		hasExplosives = false
	end
end

function UF:CheckExplosives()
	if not C.db["Nameplate"]["ExplosivesScale"] then return end

	checkAffixes()
	B:RegisterEvent("ZONE_CHANGED_NEW_AREA", checkAffixes)
	B:RegisterEvent("CHALLENGE_MODE_START", checkAffixes)
end

-- Mouseover indicator
function UF:IsMouseoverUnit()
	if not self or not self.unit then return end

	if self:IsVisible() and UnitExists("mouseover") then
		return UnitIsUnit("mouseover", self.unit)
	end
	return false
end

function UF:UpdateMouseoverShown()
	if not self or not self.unit then return end

	if self:IsShown() and UnitIsUnit("mouseover", self.unit) then
		self.HighlightIndicator:Show()
		self.HighlightUpdater:Show()
	else
		self.HighlightUpdater:Hide()
	end
end

function UF:HighlightOnUpdate(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > .1 then
		if not UF.IsMouseoverUnit(self.__owner) then
			self:Hide()
		end
		self.elapsed = 0
	end
end

function UF:HighlightOnHide()
	self.__owner.HighlightIndicator:Hide()
end

function UF:MouseoverIndicator(self)
	local highlight = CreateFrame("Frame", nil, self.Health)
	highlight:SetAllPoints(self)
	highlight:Hide()
	local texture = highlight:CreateTexture(nil, "ARTWORK")
	texture:SetAllPoints()
	texture:SetColorTexture(1, 1, 1, .25)

	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", UF.UpdateMouseoverShown, true)

	local updater = CreateFrame("Frame", nil, self)
	updater.__owner = self
	updater:SetScript("OnUpdate", UF.HighlightOnUpdate)
	updater:HookScript("OnHide", UF.HighlightOnHide)

	self.HighlightIndicator = highlight
	self.HighlightUpdater = updater
end

-- Interrupt info on castbars
function UF:UpdateSpellInterruptor(...)
	if not C.db["Nameplate"]["Interruptor"] then return end

	local _, _, sourceGUID, sourceName, _, _, destGUID = ...
	if destGUID == self.unitGUID and sourceGUID and sourceName and sourceName ~= "" then
		local _, class = GetPlayerInfoByGUID(sourceGUID)
		local r, g, b = B.ClassColor(class)
		local color = B.HexRGB(r, g, b)
		local sourceName = Ambiguate(sourceName, "short")
		self.Castbar.Text:SetText(INTERRUPTED.." > "..color..sourceName)
		self.Castbar.Time:SetText("")
	end
end

function UF:SpellInterruptor(self)
	if not self.Castbar then return end
	self:RegisterCombatEvent("SPELL_INTERRUPT", UF.UpdateSpellInterruptor)
end

function UF:ShowUnitTargeted(self)
	local tex = self:CreateTexture()
	tex:SetSize(20, 20)
	tex:SetPoint("LEFT", self, "RIGHT", 5, 0)
	tex:SetAtlas("target")
	tex:Hide()
	local count = B.CreateFS(self, 22)
	count:SetPoint("LEFT", tex, "RIGHT", 1, 0)
	count:SetTextColor(1, .8, 0)

	self.tarByTex = tex
	self.tarBy = count
end

-- Create Nameplates
local platesList = {}
function UF:CreatePlates()
	self.mystyle = "nameplate"
	self:SetSize(C.db["Nameplate"]["PlateWidth"], C.db["Nameplate"]["PlateHeight"])
	self:SetPoint("CENTER")
	self:SetScale(NDuiADB["UIScale"])

	local health = CreateFrame("StatusBar", nil, self)
	health:SetAllPoints()
	health:SetStatusBarTexture(DB.normTex)
	self.backdrop = B.SetBD(health)
	self.backdrop.__shadow = nil
	B:SmoothBar(health)

	self.Health = health
	self.Health.UpdateColor = UF.UpdateColor

	local tarName = B.CreateFS(self, C.db["Nameplate"]["NameTextSize"]+4)
	tarName:ClearAllPoints()
	tarName:SetPoint("TOP", self, "BOTTOM", 0, -10)
	tarName:Hide()
	self:Tag(tarName, "[tarname]")
	self.tarName = tarName

	UF:CreateHealthText(self)
	UF:CreateCastBar(self)
	UF:CreateRaidMark(self)
	UF:CreatePrediction(self)
	UF:CreateAuras(self)
	UF:CreatePVPClassify(self)
	UF:CreateThreatColor(self)

	self.Auras.showStealableBuffs = C.db["Nameplate"]["DispellMode"] == 1
	self.Auras.alwaysShowStealable = C.db["Nameplate"]["DispellMode"] == 2
	self.powerText = B.CreateFS(self, 22)
	self.powerText:ClearAllPoints()
	self.powerText:SetPoint("TOP", self.Castbar, "BOTTOM", 0, -4)
	self:Tag(self.powerText, "[nppp]")

	local title = B.CreateFS(self, C.db["Nameplate"]["NameOnlyTitleSize"])
	title:ClearAllPoints()
	title:SetPoint("TOP", self.nameText, "BOTTOM", 0, -3)
	title:Hide()
	self:Tag(title, "[npctitle]")
	self.npcTitle = title

	UF:MouseoverIndicator(self)
	UF:AddTargetIndicator(self)
	UF:AddCreatureIcon(self)
	UF:AddQuestIcon(self)
	UF:AddDungeonProgress(self)
	UF:SpellInterruptor(self)
	UF:ShowUnitTargeted(self)

	self:RegisterEvent("PLAYER_FOCUS_CHANGED", UF.UpdateFocusColor, true)

	platesList[self] = self:GetName()
end

function UF:ToggleNameplateAuras()
	if C.db["Nameplate"]["PlateAuras"] then
		if not self:IsElementEnabled("Auras") then
			self:EnableElement("Auras")
		end
	else
		if self:IsElementEnabled("Auras") then
			self:DisableElement("Auras")
		end
	end
end

function UF:UpdateNameplateAuras()
	UF.ToggleNameplateAuras(self)

	if not C.db["Nameplate"]["PlateAuras"] then return end

	local element = self.Auras
	if C.db["Nameplate"]["TargetPower"] then
		element:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 10 + C.db["Nameplate"]["PPBarHeight"])
	else
		element:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 5)
	end
	element.numTotal = C.db["Nameplate"]["maxAuras"]
	element.size = C.db["Nameplate"]["AuraSize"]
	element.fontSize = C.db["Nameplate"]["FontSize"]
	element.showDebuffType = C.db["Nameplate"]["DebuffColor"]
	element.showStealableBuffs = C.db["Nameplate"]["DispellMode"] == 1
	element.alwaysShowStealable = C.db["Nameplate"]["DispellMode"] == 2
	element.desaturateDebuff = C.db["Nameplate"]["Desaturate"]
	UF:UpdateAuraContainer(self, element, element.numTotal)
	element:ForceUpdate()
end

UF.PlateNameTags = {
	[1] = "",
	[2] = "[name]",
	[3] = "[nplevel][name]",
	[4] = "[nprare][name]",
	[5] = "[nprare][nplevel][name]",
}
function UF:UpdateNameplateSize()
	local plateWidth, plateHeight = C.db["Nameplate"]["PlateWidth"], C.db["Nameplate"]["PlateHeight"]
	local plateCBHeight, plateCBOffset = C.db["Nameplate"]["PlateCBHeight"], C.db["Nameplate"]["PlateCBOffset"]
	local nameTextSize, CBTextSize = C.db["Nameplate"]["NameTextSize"], C.db["Nameplate"]["CBTextSize"]
	local healthTextSize = C.db["Nameplate"]["HealthTextSize"]
	local healthTextOffset = C.db["Nameplate"]["HealthTextOffset"]
	if C.db["Nameplate"]["FriendPlate"] and self.isFriendly and not C.db["Nameplate"]["NameOnlyMode"] then -- cannot use plateType here
		plateWidth, plateHeight = C.db["Nameplate"]["FriendPlateWidth"], C.db["Nameplate"]["FriendPlateHeight"]
		plateCBHeight, plateCBOffset = C.db["Nameplate"]["FriendPlateCBHeight"], C.db["Nameplate"]["FriendPlateCBOffset"]
		nameTextSize, CBTextSize = C.db["Nameplate"]["FriendNameSize"], C.db["Nameplate"]["FriendCBTextSize"]
		healthTextSize = C.db["Nameplate"]["FriendHealthSize"]
		healthTextOffset = C.db["Nameplate"]["FriendHealthOffset"]
	end
	local iconSize = plateHeight + plateCBHeight + 5
	local nameType = C.db["Nameplate"]["NameType"]
	local nameOnlyTextSize, nameOnlyTitleSize = C.db["Nameplate"]["NameOnlyTextSize"], C.db["Nameplate"]["NameOnlyTitleSize"]

	if self.plateType == "NameOnly" then
		B.SetFontSize(self.nameText, nameOnlyTextSize)
		self:Tag(self.nameText, "[nprare][nplevel][color][name]")
		self.__tagIndex = 6
		B.SetFontSize(self.npcTitle, nameOnlyTitleSize)
		self.npcTitle:UpdateTag()
	else
		B.SetFontSize(self.nameText, nameTextSize)
		self:Tag(self.nameText, UF.PlateNameTags[nameType])
		self.__tagIndex = nameType

		self:SetSize(plateWidth, plateHeight)
		B.SetFontSize(self.tarName, nameTextSize+4)
		self.Castbar.Icon:SetSize(iconSize, iconSize)
		self.Castbar.glowFrame:SetSize(iconSize+8, iconSize+8)
		self.Castbar:SetHeight(plateCBHeight)
		B.SetFontSize(self.Castbar.Time, CBTextSize)
		self.Castbar.Time:SetPoint("TOPRIGHT", self.Castbar, "RIGHT", 0, plateCBOffset)
		B.SetFontSize(self.Castbar.Text, CBTextSize)
		self.Castbar.Text:SetPoint("TOPLEFT", self.Castbar, "LEFT", 0, plateCBOffset)
		self.Castbar.Shield:SetPoint("TOP", self.Castbar, "CENTER", 0, plateCBOffset)
		self.Castbar.Shield:SetSize(CBTextSize + 4, CBTextSize + 4)
		B.SetFontSize(self.Castbar.spellTarget, CBTextSize+3)
		B.SetFontSize(self.healthValue, healthTextSize)
		self.healthValue:SetPoint("RIGHT", self, 0, healthTextOffset)
		self:Tag(self.healthValue, "[VariousHP("..UF.VariousTagIndex[C.db["Nameplate"]["HealthType"]]..")]")
		self.healthValue:UpdateTag()
	end
	self.nameText:UpdateTag()
end

function UF:RefreshNameplats()
	for nameplate in pairs(platesList) do
		UF.UpdateNameplateSize(nameplate)
		UF.UpdateUnitClassify(nameplate)
		UF.UpdateNameplateAuras(nameplate)
		UF.UpdateTargetIndicator(nameplate)
		UF.UpdateTargetChange(nameplate)
	end
	UF:UpdateClickableSize()
end

function UF:RefreshAllPlates()
	UF:ResizePlayerPlate()
	UF:RefreshNameplats()
	UF:ResizeTargetPower()
end

local DisabledElements = {
	"Health", "Castbar", "HealPredictionAndAbsorb", "PvPClassificationIndicator", "ThreatIndicator"
}
function UF:UpdatePlateByType()
	local name = self.nameText
	local hpval = self.healthValue
	local title = self.npcTitle
	local raidtarget = self.RaidTargetIndicator
	local questIcon = self.questIcon

	name:SetShown(not self.widgetsOnly)
	name:ClearAllPoints()
	raidtarget:ClearAllPoints()

	if self.plateType == "NameOnly" then
		for _, element in pairs(DisabledElements) do
			if self:IsElementEnabled(element) then
				self:DisableElement(element)
			end
		end

		name:SetJustifyH("CENTER")
		name:SetPoint("CENTER", self, "BOTTOM")
		hpval:Hide()
		title:Show()

		raidtarget:SetPoint("TOP", title, "BOTTOM", 0, -5)
		if questIcon then questIcon:SetPoint("LEFT", name, "RIGHT", -1, 0) end

		if self.widgetContainer then
			self.widgetContainer:ClearAllPoints()
			self.widgetContainer:SetPoint("TOP", title, "BOTTOM", 0, -5)
		end
	else
		for _, element in pairs(DisabledElements) do
			if not self:IsElementEnabled(element) then
				self:EnableElement(element)
			end
		end

		name:SetJustifyH("LEFT")
		name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 5)
		name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 5)
		hpval:Show()
		title:Hide()

		raidtarget:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", 0, 3)
		if questIcon then questIcon:SetPoint("LEFT", self, "RIGHT", -1, 0) end

		if self.widgetContainer then
			self.widgetContainer:ClearAllPoints()
			self.widgetContainer:SetPoint("TOP", self.Castbar, "BOTTOM", 0, -5)
		end
	end

	UF.UpdateNameplateSize(self)
	UF.UpdateTargetIndicator(self)
	UF.ToggleNameplateAuras(self)
end

function UF:RefreshPlateType(unit)
	self.reaction = UnitReaction(unit, "player")
	self.isFriendly = self.reaction and self.reaction >= 4 and not UnitCanAttack("player", unit)
	self.isSoftTarget = GetCVarBool("SoftTargetIconGameObject") and UnitIsUnit(unit, "softinteract")
	if C.db["Nameplate"]["NameOnlyMode"] and self.isFriendly or self.widgetsOnly or self.isSoftTarget then
		self.plateType = "NameOnly"
	elseif C.db["Nameplate"]["FriendPlate"] and self.isFriendly then
		self.plateType = "FriendPlate"
	else
		self.plateType = "None"
	end

	if self.previousType == nil or self.previousType ~= self.plateType then
		UF.UpdatePlateByType(self)
		self.previousType = self.plateType
	end
end

function UF:OnUnitFactionChanged(unit)
	local nameplate = C_NamePlate_GetNamePlateForUnit(unit)
	local unitFrame = nameplate and nameplate.unitFrame
	if unitFrame and unitFrame.unitName then
		UF.RefreshPlateType(unitFrame, unit)
	end
end

function UF:OnUnitSoftTargetChanged(previousTarget, currentTarget)
	if not GetCVarBool("SoftTargetIconGameObject") then return end

	for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
		local unitFrame = nameplate and nameplate.unitFrame
		local guid = unitFrame and unitFrame.unitGUID
		if guid and (guid == previousTarget or guid == currentTarget) then
			unitFrame.previousType = nil
			UF.RefreshPlateType(unitFrame, unitFrame.unit)
			UF.UpdateTargetChange(unitFrame)
			unitFrame.RaidTargetIndicator:ForceUpdate()
		end
	end
end

local targetedList = {}

local function GetGroupUnit(index, maxGroups, isInRaid)
	if isInRaid then
		return "raid"..index
	elseif index == maxGroups then
		return "player"
	else
		return "party"..index
	end
end

function UF:OnUnitTargetChanged()
	if not isInInstance then return end

	wipe(targetedList)

	local maxGroups = GetNumGroupMembers()
	if maxGroups > 1 then
		local isInRaid = IsInRaid()
		for i = 1, maxGroups do
			local member = GetGroupUnit(i, maxGroups, isInRaid)
			local memberTarget = member.."target"
			if not UnitIsDeadOrGhost(member) and UnitExists(memberTarget) then
				local unitGUID = UnitGUID(memberTarget)
				targetedList[unitGUID] = (targetedList[unitGUID] or 0) + 1
			end
		end
	end

	for nameplate in pairs(platesList) do
		nameplate.tarBy:SetText(targetedList[nameplate.unitGUID] or "")
		nameplate.tarByTex:SetShown(targetedList[nameplate.unitGUID])
	end
end

function UF:RefreshPlateByEvents()
	B:RegisterEvent("UNIT_FACTION", UF.OnUnitFactionChanged)
	B:RegisterEvent("PLAYER_SOFT_INTERACT_CHANGED", UF.OnUnitSoftTargetChanged)

	if C.db["Nameplate"]["UnitTargeted"] then
		UF:OnUnitTargetChanged()
		B:RegisterEvent("UNIT_TARGET", UF.OnUnitTargetChanged)
		B:RegisterEvent("PLAYER_TARGET_CHANGED", UF.OnUnitTargetChanged)
	else
		for nameplate in pairs(platesList) do
			nameplate.tarBy:SetText("")
			nameplate.tarByTex:Hide()
		end
		B:UnregisterEvent("UNIT_TARGET", UF.OnUnitTargetChanged)
		B:UnregisterEvent("PLAYER_TARGET_CHANGED", UF.OnUnitTargetChanged)
	end
end

function UF:PostUpdatePlates(event, unit)
	if not self then return end

	if event == "NAME_PLATE_UNIT_ADDED" then
		self.unitName = UnitName(unit)
		self.unitGUID = UnitGUID(unit)
		self.isPlayer = UnitIsPlayer(unit)
		self.npcID = B.GetNPCID(self.unitGUID)
		self.widgetsOnly = UnitNameplateShowsWidgetsOnly(unit)

		local blizzPlate = self:GetParent().UnitFrame
		if blizzPlate then
			self.widgetContainer = blizzPlate.WidgetContainer
			if self.widgetContainer then
				self.widgetContainer:SetParent(self)
				self.widgetContainer:SetScale(1/NDuiADB["UIScale"])
			end

			self.softTargetFrame = blizzPlate.SoftTargetFrame
			if self.softTargetFrame then
				self.softTargetFrame:SetParent(self)
				self.softTargetFrame:SetScale(1/NDuiADB["UIScale"])
			end
		end

		UF.RefreshPlateType(self, unit)
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		self.npcID = nil
		self.tarBy:SetText("")
		self.tarByTex:Hide()
	end

	if event ~= "NAME_PLATE_UNIT_REMOVED" then
		UF.UpdateUnitPower(self)
		UF.UpdateTargetChange(self)
		UF.UpdateQuestUnit(self, event, unit)
		UF.UpdateUnitClassify(self, unit)
		UF.UpdateDungeonProgress(self, unit)
		UF:UpdateTargetClassPower()

		self.tarName:SetShown(C.ShowTargetNPCs[self.npcID])
	end
	UF.UpdateExplosives(self, event, unit)
end

-- Player Nameplate
function UF:PlateVisibility(event)
	local alpha = C.db["Nameplate"]["PPFadeoutAlpha"]
	if (event == "PLAYER_REGEN_DISABLED" or InCombatLockdown()) and UnitIsUnit("player", self.unit) then
		UIFrameFadeIn(self.Health, .3, self.Health:GetAlpha(), 1)
		UIFrameFadeIn(self.Health.bg, .3, self.Health.bg:GetAlpha(), 1)
		UIFrameFadeIn(self.Power, .3, self.Power:GetAlpha(), 1)
		UIFrameFadeIn(self.Power.bg, .3, self.Power.bg:GetAlpha(), 1)
		UIFrameFadeIn(self.predicFrame, .3, self:GetAlpha(), 1)
	else
		UIFrameFadeOut(self.Health, 2, self.Health:GetAlpha(), alpha)
		UIFrameFadeOut(self.Health.bg, 2, self.Health.bg:GetAlpha(), alpha)
		UIFrameFadeOut(self.Power, 2, self.Power:GetAlpha(), alpha)
		UIFrameFadeOut(self.Power.bg, 2, self.Power.bg:GetAlpha(), alpha)
		UIFrameFadeOut(self.predicFrame, 2, self:GetAlpha(), alpha)
	end
end

function UF:ResizePlayerPlate()
	local plate = _G.oUF_PlayerPlate
	if plate then
		local barWidth = C.db["Nameplate"]["PPWidth"]
		local barHeight = C.db["Nameplate"]["PPBarHeight"]
		local healthHeight = C.db["Nameplate"]["PPHealthHeight"]
		local powerHeight = C.db["Nameplate"]["PPPowerHeight"]

		plate:SetSize(barWidth, healthHeight + powerHeight + C.mult)
		plate.mover:SetSize(barWidth, healthHeight + powerHeight + C.mult)
		plate.Health:SetHeight(healthHeight)
		plate.Power:SetHeight(powerHeight)

		local bars = plate.ClassPower or plate.Runes
		if bars then
			plate.ClassPowerBar:SetSize(barWidth, barHeight)
			local max = bars.__max
			for i = 1, max do
				bars[i]:SetHeight(barHeight)
				bars[i]:SetWidth((barWidth - (max-1)*C.margin) / max)
			end
		end
		if plate.Stagger then
			plate.Stagger:SetSize(barWidth, barHeight)
		end
		if plate.lumos then
			local iconSize = (barWidth+2*C.mult - C.margin*4)/5
			for i = 1, 5 do
				plate.lumos[i]:SetSize(iconSize, iconSize)
			end
		end
		if plate.dices then
			local parent = C.db["Nameplate"]["TargetPower"] and plate.Health or plate.ClassPowerBar
			local size = (barWidth - 10)/6
			for i = 1, 6 do
				local dice = plate.dices[i]
				dice:SetSize(size, size/2)
				if i == 1 then
					dice:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", 0, C.margin)
				end
			end
		end
	end
end

function UF:CreatePlayerPlate()
	self.mystyle = "PlayerPlate"
	self:EnableMouse(false)
	local healthHeight, powerHeight = C.db["Nameplate"]["PPHealthHeight"], C.db["Nameplate"]["PPPowerHeight"]
	self:SetSize(C.db["Nameplate"]["PPWidth"], healthHeight + powerHeight + C.mult)

	UF:CreateHealthBar(self)
	UF:CreatePowerBar(self)
	UF:CreatePrediction(self)
	UF:CreateClassPower(self)
	UF:StaggerBar(self)
	if C.db["Auras"]["ClassAuras"] then
		local AURA = B:GetModule("Auras")
		if AURA then
			AURA:CreateLumos(self)
		end
	end

	local textFrame = CreateFrame("Frame", nil, self.Power)
	textFrame:SetAllPoints()
	textFrame:SetFrameLevel(self:GetFrameLevel() + 5)
	self.powerText = B.CreateFS(textFrame, 14)
	self:Tag(self.powerText, "[pppower]")
	UF:TogglePlatePower()

	UF:CreateGCDTicker(self)
	UF:TogglePlateVisibility()
end

function UF:TogglePlayerPlate()
	local plate = _G.oUF_PlayerPlate
	if not plate then return end

	if C.db["Nameplate"]["ShowPlayerPlate"] then
		plate:Enable()
	else
		plate:Disable()
	end
end

function UF:TogglePlatePower()
	local plate = _G.oUF_PlayerPlate
	if not plate then return end

	plate.powerText:SetShown(C.db["Nameplate"]["PPPowerText"])
end

function UF:TogglePlateVisibility()
	local plate = _G.oUF_PlayerPlate
	if not plate then return end

	if C.db["Nameplate"]["PPFadeout"] then
		plate:RegisterEvent("UNIT_EXITED_VEHICLE", UF.PlateVisibility)
		plate:RegisterEvent("UNIT_ENTERED_VEHICLE", UF.PlateVisibility)
		plate:RegisterEvent("PLAYER_REGEN_ENABLED", UF.PlateVisibility, true)
		plate:RegisterEvent("PLAYER_REGEN_DISABLED", UF.PlateVisibility, true)
		plate:RegisterEvent("PLAYER_ENTERING_WORLD", UF.PlateVisibility, true)
		UF.PlateVisibility(plate)
	else
		plate:UnregisterEvent("UNIT_EXITED_VEHICLE", UF.PlateVisibility)
		plate:UnregisterEvent("UNIT_ENTERED_VEHICLE", UF.PlateVisibility)
		plate:UnregisterEvent("PLAYER_REGEN_ENABLED", UF.PlateVisibility)
		plate:UnregisterEvent("PLAYER_REGEN_DISABLED", UF.PlateVisibility)
		plate:UnregisterEvent("PLAYER_ENTERING_WORLD", UF.PlateVisibility)
		UF.PlateVisibility(plate, "PLAYER_REGEN_DISABLED")
	end
end

-- Target nameplate
function UF:CreateTargetPlate()
	self.mystyle = "targetplate"
	self:EnableMouse(false)
	self:SetSize(10, 10)

	UF:CreateClassPower(self)
end

function UF:UpdateTargetClassPower()
	local plate = _G.oUF_TargetPlate
	if not plate then return end

	local bar = plate.ClassPowerBar
	local nameplate = C_NamePlate_GetNamePlateForUnit("target")
	if nameplate then
		bar:SetParent(nameplate.unitFrame)
		bar:ClearAllPoints()
		bar:SetPoint("BOTTOM", nameplate.unitFrame.nameText, "TOP", 0, 5)
		bar:Show()
	else
		bar:Hide()
	end
end

function UF:ToggleTargetClassPower()
	local plate = _G.oUF_TargetPlate
	if not plate then return end

	local playerPlate = _G.oUF_PlayerPlate
	if C.db["Nameplate"]["TargetPower"] then
		plate:Enable()
		if plate.ClassPower then
			if not plate:IsElementEnabled("ClassPower") then
				plate:EnableElement("ClassPower")
				plate.ClassPower:ForceUpdate()
			end
			if playerPlate then
				if playerPlate:IsElementEnabled("ClassPower") then
					playerPlate:DisableElement("ClassPower")
				end
			end
		end
		if plate.Runes then
			if not plate:IsElementEnabled("Runes") then
				plate:EnableElement("Runes")
				plate.Runes:ForceUpdate()
			end
			if playerPlate then
				if playerPlate:IsElementEnabled("Runes") then
					playerPlate:DisableElement("Runes")
				end
			end
		end
	else
		plate:Disable()
		if plate.ClassPower then
			if plate:IsElementEnabled("ClassPower") then
				plate:DisableElement("ClassPower")
			end
			if playerPlate then
				if not playerPlate:IsElementEnabled("ClassPower") then
					playerPlate:EnableElement("ClassPower")
					playerPlate.ClassPower:ForceUpdate()
				end
			end
		end
		if plate.Runes then
			if plate:IsElementEnabled("Runes") then
				plate:DisableElement("Runes")
			end
			if playerPlate then
				if not playerPlate:IsElementEnabled("Runes") then
					playerPlate:EnableElement("Runes")
					playerPlate.Runes:ForceUpdate()
				end
			end
		end
	end
end

function UF:ResizeTargetPower()
	local plate = _G.oUF_TargetPlate
	if not plate then return end

	local barWidth = C.db["Nameplate"]["PlateWidth"]
	local barHeight = C.db["Nameplate"]["PPBarHeight"]
	local bars = plate.ClassPower or plate.Runes
	if bars then
		plate.ClassPowerBar:SetSize(barWidth, barHeight)
		local max = bars.__max
		for i = 1, max do
			bars[i]:SetHeight(barHeight)
			bars[i]:SetWidth((barWidth - (max-1)*C.margin) / max)
		end
	end
end

function UF:UpdateGCDTicker()
	local start, duration = GetSpellCooldown(61304)
	if start > 0 and duration > 0 then
		if self.duration ~= duration then
			self:SetMinMaxValues(0, duration)
			self.duration = duration
		end
		self:SetValue(GetTime() - start)
		self.spark:Show()
	else
		self.spark:Hide()
	end
end

function UF:CreateGCDTicker(self)
	local ticker = CreateFrame("StatusBar", nil, self.Power)
	ticker:SetFrameLevel(self:GetFrameLevel() + 3)
	ticker:SetStatusBarTexture(DB.normTex)
	ticker:GetStatusBarTexture():SetAlpha(0)
	ticker:SetAllPoints()

	local spark = ticker:CreateTexture(nil, "OVERLAY")
	spark:SetTexture(DB.sparkTex)
	spark:SetBlendMode("ADD")
	spark:SetPoint("TOPLEFT", ticker:GetStatusBarTexture(), "TOPRIGHT", -10, 10)
	spark:SetPoint("BOTTOMRIGHT", ticker:GetStatusBarTexture(), "BOTTOMRIGHT", 10, -10)
	ticker.spark = spark

	ticker:SetScript("OnUpdate", UF.UpdateGCDTicker)
	self.GCDTicker = ticker

	UF:ToggleGCDTicker()
end

function UF:ToggleGCDTicker()
	local plate = _G.oUF_PlayerPlate
	local ticker = plate and plate.GCDTicker
	if not ticker then return end

	ticker:SetShown(C.db["Nameplate"]["PPGCDTicker"])
end

UF.MajorSpells = {}
function UF:RefreshMajorSpells()
	wipe(UF.MajorSpells)

	for spellID in pairs(C.MajorSpells) do
		local name = GetSpellInfo(spellID)
		if name then
			local modValue = NDuiADB["MajorSpells"][spellID]
			if modValue == nil then
				UF.MajorSpells[spellID] = true
			end
		end
	end

	for spellID, value in pairs(NDuiADB["MajorSpells"]) do
		if value then
			UF.MajorSpells[spellID] = true
		end
	end
end

UF.NameplateWhite = {}
UF.NameplateBlack = {}

local function RefreshNameplateFilter(list, key)
	wipe(UF[key])

	for spellID in pairs(list) do
		local name = GetSpellInfo(spellID)
		if name then
			if NDuiADB[key][spellID] == nil then
				UF[key][spellID] = true
			end
		end
	end

	for spellID, value in pairs(NDuiADB[key]) do
		if value then
			UF[key][spellID] = true
		end
	end
end

function UF:RefreshNameplateFilters()
	RefreshNameplateFilter(C.WhiteList, "NameplateWhite")
	RefreshNameplateFilter(C.BlackList, "NameplateBlack")
end