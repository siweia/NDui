local _, ns = ...
local B, C, L, DB = unpack(ns)
local UF = B:GetModule("UnitFrames")

local _G = getfenv(0)
local strmatch, tonumber, pairs, unpack, rad = string.match, tonumber, pairs, unpack, math.rad
local UnitThreatSituation, UnitIsTapDenied, UnitPlayerControlled, UnitIsUnit = UnitThreatSituation, UnitIsTapDenied, UnitPlayerControlled, UnitIsUnit
local UnitReaction, UnitIsConnected, UnitIsPlayer, UnitSelectionColor = UnitReaction, UnitIsConnected, UnitIsPlayer, UnitSelectionColor
local UnitClassification, UnitExists, InCombatLockdown, UnitCanAttack = UnitClassification, UnitExists, InCombatLockdown, UnitCanAttack
local UnitGUID, GetPlayerInfoByGUID, Ambiguate, UnitName, UnitHealth, UnitHealthMax = UnitGUID, GetPlayerInfoByGUID, Ambiguate, UnitName, UnitHealth, UnitHealthMax
local SetCVar, UIFrameFadeIn, UIFrameFadeOut = SetCVar, UIFrameFadeIn, UIFrameFadeOut
local C_NamePlate_GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local C_NamePlate_SetNamePlateEnemyClickThrough = C_NamePlate.SetNamePlateEnemyClickThrough
local C_NamePlate_SetNamePlateFriendlyClickThrough = C_NamePlate.SetNamePlateFriendlyClickThrough
local INTERRUPTED = INTERRUPTED
local _QuestieTooltips, _QuestiePlayer, _QuestieQuest

-- Init
function UF:UpdatePlateCVars()
	SetCVar("ClampTargetNameplateToScreen", C.db["Nameplate"]["ClampTarget"] and 1 or 0)
	SetCVar("nameplateMaxDistance", C.db["Nameplate"]["PlateRange"])
	SetCVar("namePlateMinScale", C.db["Nameplate"]["MinScale"])
	SetCVar("namePlateMaxScale", C.db["Nameplate"]["MinScale"])
	SetCVar("nameplateMinAlpha", C.db["Nameplate"]["MinAlpha"])
	SetCVar("nameplateMaxAlpha", C.db["Nameplate"]["MinAlpha"])
	SetCVar("nameplateNotSelectedAlpha", C.db["Nameplate"]["MinAlpha"])
	SetCVar("nameplateOverlapV", C.db["Nameplate"]["VerticalSpacing"])
	SetCVar("nameplateShowOnlyNames", C.db["Nameplate"]["CVarOnlyNames"] and 1 or 0)
	SetCVar("nameplateShowFriendlyNPCs", C.db["Nameplate"]["CVarShowNPCs"] and 1 or 0)
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
	SetCVar("predictedHealth", 1)
	UF:UpdatePlateClickThru()

	SetCVar("nameplateSelectedScale", 1)
	SetCVar("nameplateLargerScale", 1)
	SetCVar("nameplateGlobalScale", 1)

	--B.HideOption(InterfaceOptionsNamesPanelUnitNameplatesNameplateMaxDistanceSlider) -- Use option in GUI

	if IsAddOnLoaded("Questie") then
		_QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
		_QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
		_QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")
	end
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
local customUnits = {}
function UF:CreateUnitTable()
	wipe(customUnits)
	if not C.db["Nameplate"]["CustomUnitColor"] then return end
	B.CopyTable(C.CustomUnits, customUnits)
	B.SplitList(customUnits, C.db["Nameplate"]["UnitList"])
end

local showPowerList = {}
function UF:CreatePowerUnitTable()
	wipe(showPowerList)
	B.CopyTable(C.ShowPowerList, showPowerList)
	B.SplitList(showPowerList, C.db["Nameplate"]["ShowPowerList"])
end

function UF:UpdateUnitPower()
	local unitName = self.unitName
	local npcID = self.npcID
	local shouldShowPower = showPowerList[unitName] or showPowerList[npcID]
	if shouldShowPower then
		self.powerText:Show()
	else
		self.powerText:Hide()
	end
end

-- Update unit color
function UF:UpdateColor(_, unit)
	if not unit or self.unit ~= unit then return end

	local element = self.Health
	local name = self.unitName
	local npcID = self.npcID
	local isCustomUnit = customUnits[name] or customUnits[npcID]
	local isPlayer = self.isPlayer
	local isFriendly = self.isFriendly
	local status = UnitThreatSituation("player", unit) or false -- just in case
	local customColor = C.db["Nameplate"]["CustomColor"]
	local secureColor = C.db["Nameplate"]["SecureColor"]
	local transColor = C.db["Nameplate"]["TransColor"]
	local insecureColor = C.db["Nameplate"]["InsecureColor"]
	local executeRatio = C.db["Nameplate"]["ExecuteRatio"]
	local healthPerc = UnitHealth(unit) / (UnitHealthMax(unit) + .0001) * 100
	local targetColor = C.db["Nameplate"]["TargetColor"]
	local focusColor = C.db["Nameplate"]["FocusColor"]
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
		elseif isPlayer and isFriendly then
			if C.db["Nameplate"]["FriendlyCC"] then
				r, g, b = B.UnitColor(unit)
			else
				r, g, b = .3, .3, 1
			end
		elseif isPlayer and (not isFriendly) and C.db["Nameplate"]["HostileCC"] then
			r, g, b = B.UnitColor(unit)
		elseif UnitIsTapDenied(unit) and not UnitPlayerControlled(unit) then
			r, g, b = .6, .6, .6
		else
			r, g, b = UnitSelectionColor(unit, true)
			if status and C.db["Nameplate"]["TankMode"] then
				if status == 3 then
					r, g, b = secureColor.r, secureColor.g, secureColor.b
				elseif status == 2 or status == 1 then
					r, g, b = transColor.r, transColor.g, transColor.b
				elseif status == 0 then
					r, g, b = insecureColor.r, insecureColor.g, insecureColor.b
				end
			end
		end
	end

	if r or g or b then
		element:SetStatusBarColor(r, g, b)
	end

	if isCustomUnit or not C.db["Nameplate"]["TankMode"] then
		if status and status == 3 then
			self.ThreatIndicator:SetBackdropBorderColor(1, 0, 0)
			self.ThreatIndicator:Show()
		elseif status and (status == 2 or status == 1) then
			self.ThreatIndicator:SetBackdropBorderColor(1, 1, 0)
			self.ThreatIndicator:Show()
		else
			self.ThreatIndicator:Hide()
		end
	else
		self.ThreatIndicator:Hide()
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
	local threatIndicator = B.CreateSD(self, 3, true)
	threatIndicator:SetOutside(self.Health.backdrop, 3, 3)
	threatIndicator:Hide()

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
	frame.Glow:SetOutside(self.Health.backdrop, 8, 8)
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

function UF:UpdateQuestUnit(_, unit)
	if not C.db["Nameplate"]["QuestIndicator"] then return end
	if isInInstance then
		self.questIcon:Hide()
		self.questCount:SetText("")
		return
	end

	unit = unit or self.unit

	local isLootQuest, questProgress
	B.ScanTip:SetOwner(UIParent, "ANCHOR_NONE")
	B.ScanTip:SetUnit(unit)

	for i = 2, B.ScanTip:NumLines() do
		local textLine = _G["NDui_ScanTooltipTextLeft"..i]
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

function UF:UpdateForQuestie(npcID)
	local data = _QuestieTooltips.lookupByKey and _QuestieTooltips.lookupByKey["m_"..npcID]
	if data then
		local foundObjective, progressText
		for _, tooltip in pairs(data) do
			local questID = tooltip.questId
			if questID then
				_QuestieQuest:UpdateQuest(questID)

				if _QuestiePlayer.currentQuestlog[questID] then
					foundObjective = true

					if tooltip.objective and tooltip.objective.Needed then
						progressText = tooltip.objective.Needed - tooltip.objective.Collected
						if progressText == 0 then
							foundObjective = nil
						end
						break
					end
				end
			end
		end

		if foundObjective then
			self.questIcon:Show()
			self.questCount:SetText(progressText)
		end
	end
end

function UF:UpdateCodexQuestUnit(name)
	if name and CodexMap.tooltips[name] then
		for _, meta in pairs(CodexMap.tooltips[name]) do
			local questData = meta["quest"]
			local quests = CodexDB.quests.loc

			if questData then
				for questIndex = 1, GetNumQuestLogEntries() do
					local _, _, _, header, _, _, _, questId = GetQuestLogTitle(questIndex)
					if not header and quests[questId] and questData == quests[questId].T then
						local objectives = GetNumQuestLeaderBoards(questIndex)
						local foundObjective, progressText = nil
						if objectives then
							for i = 1, objectives do
								local text, type = GetQuestLogLeaderBoard(i, questIndex)
								if type == "monster" then
									local _, _, monsterName, objNum, objNeeded = strfind(text, Codex:SanitizePattern(QUEST_MONSTERS_KILLED))
									if meta["spawn"] == monsterName then
										progressText = objNeeded - objNum
										foundObjective = true
										break
									end
								elseif table.getn(meta["item"]) > 0 and type == "item" and meta["dropRate"] then
									local _, _, itemName, objNum, objNeeded = strfind(text, Codex:SanitizePattern(QUEST_OBJECTS_FOUND))
									for _, item in pairs(meta["item"]) do
										if item == itemName then
											progressText = objNeeded - objNum
											foundObjective = true
											break
										end
									end
								end
							end
						end

						if foundObjective and progressText > 0 then
							self.questIcon:Show()
							self.questCount:SetText(progressText)
						elseif not foundObjective then
							self.questIcon:Show()
						end
					end
				end
			end
		end
	end
end

function UF:UpdateQuestIndicator()
	if not C.db["Nameplate"]["QuestIndicator"] then return end

	self.questIcon:Hide()
	self.questCount:SetText("")

	if CodexMap then
		UF.UpdateCodexQuestUnit(self, self.unitName)
	elseif _QuestieTooltips then
		UF.UpdateForQuestie(self, self.npcID)
	end
end

function UF:AddQuestIcon(self)
	if not C.db["Nameplate"]["QuestIndicator"] then return end

	local qicon = self:CreateTexture(nil, "OVERLAY", nil, 2)
	qicon:SetPoint("LEFT", self, "RIGHT", 4, 0)
	qicon:SetSize(30, 30)
	qicon:SetAtlas(DB.questTex)
	qicon:Hide()
	local count = B.CreateFS(self, 20, "", nil, "LEFT", 0, 0)
	count:SetPoint("LEFT", qicon, "RIGHT", -4, 0)
	count:SetTextColor(.6, .8, 1)

	self.questIcon = qicon
	self.questCount = count
	--self:RegisterEvent("QUEST_LOG_UPDATE", UF.UpdateQuestUnit, true)
	self:RegisterEvent("QUEST_LOG_UPDATE", UF.UpdateQuestIndicator, true)
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
	icon:SetAtlas("auctionhouse-icon-favorite")
	icon:SetPoint("RIGHT", self.nameText, "LEFT", 10, 0)
	icon:SetSize(20, 20)
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
	health.backdrop = B.SetBD(health) -- don't mess up with libs
	B:SmoothBar(health)

	self.Health = health
	self.Health.frequentUpdates = true
	self.Health.UpdateColor = UF.UpdateColor

	UF:CreateHealthText(self)
	UF:CreateCastBar(self)
	UF:CreateRaidMark(self)
	UF:CreatePrediction(self)
	UF:CreateAuras(self)
	UF:CreateThreatColor(self)

	self.Auras.showStealableBuffs = C.db["Nameplate"]["Dispellable"]
	self.powerText = B.CreateFS(self, 22)
	self.powerText:ClearAllPoints()
	self.powerText:SetPoint("TOP", self.Castbar, "BOTTOM", 0, -4)
	self:Tag(self.powerText, "[nppp]")

	local title = B.CreateFS(self, C.db["Nameplate"]["NameTextSize"]-1)
	title:ClearAllPoints()
	title:SetPoint("TOP", self.nameText, "BOTTOM", 0, -3)
	title:Hide()
	self:Tag(title, "[npctitle]")
	self.npcTitle = title

	UF:MouseoverIndicator(self)
	UF:AddTargetIndicator(self)
	UF:AddCreatureIcon(self)
	UF:AddQuestIcon(self)
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
	element.showDebuffType = C.db["Nameplate"]["DebuffColor"]
	element.showStealableBuffs = C.db["Nameplate"]["Dispellable"]
	element.desaturateDebuff = C.db["Nameplate"]["Desaturate"]
	element:SetWidth(self:GetWidth())
	element:SetHeight((element.size + element.spacing) * 2)
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
	local font, fontFlag = DB.Font[1], DB.Font[3]
	local iconSize = plateHeight + plateCBHeight + 5
	local nameType = C.db["Nameplate"]["NameType"]
	local nameOnlyTextSize, nameOnlyTitleSize = C.db["Nameplate"]["NameOnlyTextSize"], C.db["Nameplate"]["NameOnlyTitleSize"]

	if self.plateType == "NameOnly" then
		self.nameText:SetFont(font, nameOnlyTextSize, fontFlag)
		self:Tag(self.nameText, "[nprare][nplevel][color][name]")
		self.__tagIndex = 6
		self.npcTitle:SetFont(font, nameOnlyTitleSize, fontFlag)
		self.npcTitle:UpdateTag()
	else
		self.nameText:SetFont(font, nameTextSize, fontFlag)
		self:Tag(self.nameText, UF.PlateNameTags[nameType])
		self.__tagIndex = nameType

		self:SetSize(plateWidth, plateHeight)
		self.Castbar.Icon:SetSize(iconSize, iconSize)
		self.Castbar.glowFrame:SetSize(iconSize+8, iconSize+8)
		self.Castbar:SetHeight(plateCBHeight)
		self.Castbar.Time:SetFont(font, CBTextSize, fontFlag)
		self.Castbar.Time:SetPoint("TOPRIGHT", self.Castbar, "RIGHT", 0, plateCBOffset)
		self.Castbar.Text:SetFont(font, CBTextSize, fontFlag)
		self.Castbar.Text:SetPoint("TOPLEFT", self.Castbar, "LEFT", 0, plateCBOffset)
		self.Castbar.Shield:SetPoint("TOP", self.Castbar, "CENTER", 0, plateCBOffset)
		self.Castbar.Shield:SetSize(CBTextSize + 4, CBTextSize + 4)
		self.Castbar.spellTarget:SetFont(font, CBTextSize+3, fontFlag)
		self.healthValue:SetFont(font, healthTextSize, fontFlag)
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
end

function UF:RefreshAllPlates()
	UF:ResizePlayerPlate()
	UF:RefreshNameplats()
	UF:ResizeTargetPower()
end

local DisabledElements = {
	"Health", "Castbar", "HealthPrediction", "ThreatIndicator"
}
function UF:UpdatePlateByType()
	local name = self.nameText
	local hpval = self.healthValue
	local title = self.npcTitle
	local raidtarget = self.RaidTargetIndicator
	local questIcon = self.questIcon

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
	end

	UF.UpdateNameplateSize(self)
	UF.UpdateTargetIndicator(self)
	UF.ToggleNameplateAuras(self)
end

function UF:RefreshPlateType(unit)
	self.reaction = UnitReaction(unit, "player")
	self.isFriendly = self.reaction and self.reaction >= 4 and not UnitCanAttack("player", unit)
	if C.db["Nameplate"]["NameOnlyMode"] and self.isFriendly or self.widgetsOnly then
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
		self.npcID = B.GetNPCID(self.unitGUID)
		self.isPlayer = UnitIsPlayer(unit)

		UF.RefreshPlateType(self, unit)
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		self.npcID = nil
	end

	if event ~= "NAME_PLATE_UNIT_REMOVED" then
		UF.UpdateUnitPower(self)
		UF.UpdateTargetChange(self)
		--UF.UpdateQuestUnit(self, event, unit)
		UF.UpdateQuestIndicator(self)
		UF.UpdateUnitClassify(self, unit)
		UF:UpdateTargetClassPower()
	end
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

		local bars = plate.ClassPower
		if bars then
			plate.ClassPowerBar:SetSize(barWidth, barHeight)
			local max = bars.__max
			for i = 1, max do
				bars[i]:SetHeight(barHeight)
				bars[i]:SetWidth((barWidth - (max-1)*C.margin) / max)
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
	UF:CreateEneryTicker(self)
	--if C.db["Auras"]["ClassAuras"] then
	--	B:GetModule("Auras"):CreateLumos(self)
	--end

	local textFrame = CreateFrame("Frame", nil, self.Power)
	textFrame:SetAllPoints()
	textFrame:SetFrameLevel(self:GetFrameLevel() + 5)
	self.powerText = B.CreateFS(textFrame, 14)
	self:Tag(self.powerText, "[pppower]")
	self.powerText:SetShown(C.db["Nameplate"]["PPPowerText"])

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

	plate.powerText:SetShown(C.db["Nameplate"]["PPPowerText"])
	UF.ToggleEnergyTicker(plate, C.db["Nameplate"]["EnergyTicker"])
end

function UF:TogglePlateVisibility()
	local plate = _G.oUF_PlayerPlate
	if not plate then return end

	if C.db["Nameplate"]["PPFadeout"] then
		plate:RegisterEvent("PLAYER_REGEN_ENABLED", UF.PlateVisibility, true)
		plate:RegisterEvent("PLAYER_REGEN_DISABLED", UF.PlateVisibility, true)
		plate:RegisterEvent("PLAYER_ENTERING_WORLD", UF.PlateVisibility, true)
		UF.PlateVisibility(plate)
	else
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
	end
end

function UF:ResizeTargetPower()
	local plate = _G.oUF_TargetPlate
	if not plate then return end

	local barWidth = C.db["Nameplate"]["PlateWidth"]
	local barHeight = C.db["Nameplate"]["PPBarHeight"]
	local bars = plate.ClassPower
	if bars then
		plate.ClassPowerBar:SetSize(barWidth, barHeight)
		local max = bars.__max
		for i = 1, max do
			bars[i]:SetHeight(barHeight)
			bars[i]:SetWidth((barWidth - (max-1)*C.margin) / max)
		end
	end
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