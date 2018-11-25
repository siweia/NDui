local _, ns = ...
local B, C, L, DB = unpack(ns)
local UF = B:GetModule("UnitFrames")
local strmatch, tonumber = string.match, tonumber

-- Init
function UF:SetupCVars()
	if NDuiDB["Nameplate"]["InsideView"] then
		SetCVar("nameplateOtherTopInset", .05)
		SetCVar("nameplateOtherBottomInset", .08)
	else
		SetCVar("nameplateOtherTopInset", -1)
		SetCVar("nameplateOtherBottomInset", -1)
	end
	SetCVar("nameplateOverlapH", .5)
	SetCVar("nameplateOverlapV", NDuiDB["Nameplate"]["VerticalSpacing"])
	SetCVar("nameplateMaxDistance", NDuiDB["Nameplate"]["Distance"])

	SetCVar("nameplateMinAlpha", NDuiDB["Nameplate"]["MinAlpha"])
	SetCVar("nameplateMaxAlpha", NDuiDB["Nameplate"]["MinAlpha"])
	SetCVar("nameplateSelectedAlpha", 1)

	SetCVar("namePlateMinScale", .8)
	SetCVar("namePlateMaxScale", .8)
	SetCVar("nameplateSelectedScale", 1)
	SetCVar("nameplateLargerScale", 1)
	SetCVar("nameplateSelfScale", 1)

	SetCVar("nameplateShowSelf", 0)
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

local function GetSectionInfo(id)
	return C_EncounterJournal.GetSectionInfo(id).title
end

local CustomUnits = {
	[GetSectionInfo(14544)] = true,	-- 海拉加尔观雾者
	[GetSectionInfo(14595)] = true,	-- 深渊追猎者
	[GetSectionInfo(16588)] = true,	-- 尖啸反舌鸟
	[GetSectionInfo(16350)] = true,	-- 瓦里玛萨斯之影
	[GetSectionInfo(18540)] = true,	-- 纳兹曼尼鲜血妖术师
	[GetSectionInfo(18104)] = true,	-- 散疫触须
	[GetSectionInfo(18232)] = true,	-- 艾什凡炮手
	[GetSectionInfo(18499)] = true,	-- 凝结之血
	[GetSectionInfo(18078)] = true,	-- 蛛魔编织者
	[GetSectionInfo(18007)] = true,	-- 瘟疫聚合体
	[GetSectionInfo(18053)] = true,	-- 灵魂荆棘
	[120651] = true, -- 爆炸物
	[141851] = true, -- 戈霍恩之嗣
}
function UF:CreateUnitTable()
	if not NDuiDB["Nameplate"]["CustomUnitColor"] then CustomUnits = nil return end

	B.SplitList(CustomUnits, NDuiDB["Nameplate"]["UnitList"])
end

C.ShowPowerList = {
	[GetSectionInfo(13015)] = true,	-- 清扫器
	[GetSectionInfo(15903)] = true,	-- 泰沙拉克的余烬
	[GetSectionInfo(18540)] = true,	-- 纳兹曼尼鲜血妖术师
}
function UF:CreatePowerUnitTable()
	B.SplitList(C.ShowPowerList, NDuiDB["Nameplate"]["ShowPowerList"])
end

-- Elements
local function UpdateColor(element, unit)
	local name = GetUnitName(unit) or UNKNOWN
	local npcID = B.GetNPCID(UnitGUID(unit))
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
		if CustomUnits and (CustomUnits[name] or CustomUnits[npcID]) then
			r, g, b = customColor.r, customColor.g, customColor.b
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

local function UpdateThreatColor(self, _, unit)
	if unit ~= self.unit then return end
	UpdateColor(self.Health, unit)
end

local function UpdateTargetMark(self)
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

local function UpdateQuestUnit(self, unit)
	if not NDuiDB["Nameplate"]["QuestIcon"] or unit == "player" then return end
	local name, instType, instID = GetInstanceInfo()
	if name and (instType == "raid" or instID == 8) then self.questIcon:SetAlpha(0) return end

	local isObjectiveQuest, isProgressQuest
	unitTip:SetOwner(WorldFrame, "ANCHOR_NONE")
	unitTip:SetUnit(unit)

	for i = 2, unitTip:NumLines() do
		local textLine = _G[unitTip:GetName().."TextLeft"..i]
		local text = textLine:GetText()
		if textLine and text then
			local r, g, b = textLine:GetTextColor()
			if r > .99 and g > .82 and b == 0 then
				isProgressQuest = true
			else
				local unitName, progress = strmatch(text, "^ ([^ ]-) ?%-(.+)$")
				if unitName and (unitName == "" or unitName == DB.MyName) and progress then
					local current, goal = strmatch(progress, "(%d+)/(%d+)")
					if current and goal and current ~= goal then
						isObjectiveQuest = true
					end
				end
			end
		end
	end

	if isObjectiveQuest or isProgressQuest then
		self.questIcon:SetAlpha(1)
	else
		self.questIcon:SetAlpha(0)
	end
end

local classify = {
	rare = {.7, .7, .7},
	elite = {1, 1, 0},
	rareelite = {1, .1, .1},
	worldboss = {0, 1, 0},
}

local function UpdateUnitClassify(self, unit)
	local class = UnitClassification(unit)
	if self.creatureIcon then
		if class and classify[class] then
			local r, g, b = unpack(classify[class])
			self.creatureIcon:SetVertexColor(r, g, b)
			self.creatureIcon:SetAlpha(1)
		else
			self.creatureIcon:SetAlpha(0)
		end
	end
end

local explosiveCount, hasExplosives = 0
--local id = 126023 --test
local id = 120651
local function scalePlates()
	for _, nameplate in next, C_NamePlate.GetNamePlates() do
		local unitFrame = nameplate.unitFrame
		local npcID = B.GetNPCID(UnitGUID(unitFrame.unit))
		if explosiveCount > 0 and npcID == id or explosiveCount == 0 then
			unitFrame:SetWidth(NDuiDB["Nameplate"]["Width"] * 1.4)
		else
			unitFrame:SetWidth(NDuiDB["Nameplate"]["Width"] * .9)
		end
	end
end

local function UpdateExplosives(self, event, unit)
	if not hasExplosives or unit ~= self.unit then return end

	local npcID = B.GetNPCID(UnitGUID(unit))
	if event == "NAME_PLATE_UNIT_ADDED" and npcID == id then
		explosiveCount = explosiveCount + 1
	elseif event == "NAME_PLATE_UNIT_REMOVED" and npcID == id then
		explosiveCount = explosiveCount - 1
	end
	scalePlates()
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
		local affixes = C_MythicPlus.GetCurrentAffixes()
		if not affixes then return end
		if affixes[3] == 13 then
			checkInstance()
			B:RegisterEvent(event, checkInstance)
			B:RegisterEvent("CHALLENGE_MODE_START", checkInstance)
		end
		B:UnregisterEvent(event, checkAffixes)
	end
	B:RegisterEvent("PLAYER_ENTERING_WORLD", checkAffixes)
end

local function isMouseoverUnit(self)
	if not self or not self.unit then return end

	if self:IsVisible() and UnitExists("mouseover") and not UnitIsUnit("target", self.unit) then
		return UnitIsUnit("mouseover", self.unit)
	end
	return false
end

local function updateMouseoverShown(self)
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

	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", updateMouseoverShown)
	self:RegisterEvent("PLAYER_TARGET_CHANGED", updateMouseoverShown)

	local f = CreateFrame("Frame", nil, self)
	f:SetScript("OnUpdate", function(_, elapsed)
		f.elapsed = (f.elapsed or 0) + elapsed
		if f.elapsed > .1 then
			if not isMouseoverUnit(self) then
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
		self.Health.UpdateColor = UpdateColor

		UF:CreateHealthText(self)
		UF:CreateCastBar(self)
		UF:CreateRaidMark(self)
		UF:CreatePrediction(self)
		UF:CreateAuras(self)

		self.powerText = B.CreateFS(self, 15, "", false, "LEFT", 0, 0)
		self.powerText:SetPoint("LEFT", self, "RIGHT", 2, 0)
		self:Tag(self.powerText, "[nppp]")

		if NDuiDB["Nameplate"]["Arrow"] then
			local arrow = self:CreateTexture(nil, "OVERLAY")
			arrow:SetSize(50, 50)
			arrow:SetTexture(DB.arrowTex)
			arrow:SetPoint("BOTTOM", self, "TOP", 0, 14)
			arrow:Hide()
			self.arrowMark = arrow
		end
		local mark = self.Health:CreateTexture(nil, "BACKGROUND", nil, -1)
		mark:SetHeight(12)
		mark:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", -20, -2)
		mark:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 20, -2)
		mark:SetTexture("Interface\\GLUES\\Models\\UI_Draenei\\GenericGlow64")
		mark:SetVertexColor(0, .6, 1)
		mark:SetBlendMode("ADD")
		mark:Hide()
		self.tarMark = mark
		self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateTargetMark)

		local cicon = self:CreateTexture(nil, "OVERLAY")
		cicon:SetPoint("LEFT", self, 1, 5)
		cicon:SetSize(12, 12)
		cicon:SetTexture("Interface\\MINIMAP\\ObjectIcons")
		cicon:SetTexCoord(.391, .487, .644, .74)
		cicon:SetAlpha(0)
		self.creatureIcon = cicon

		if NDuiDB["Nameplate"]["QuestIcon"] then
			local qicon = self:CreateTexture(nil, "OVERLAY")
			qicon:SetPoint("LEFT", self, "RIGHT", -1, 0)
			qicon:SetSize(20, 20)
			qicon:SetTexture(DB.questTex)
			qicon:SetAlpha(0)
			self.questIcon = qicon
		end

		local threatIndicator = CreateFrame("Frame", nil, self)
		self.ThreatIndicator = threatIndicator
		self.ThreatIndicator.Override = UpdateThreatColor

		AddMouseoverIndicator(self)
	end
end

function UF:PostUpdatePlates(event, unit)
	if not self then return end
	UpdateTargetMark(self)
	UpdateQuestUnit(self, unit)
	UpdateUnitClassify(self, unit)
	UpdateExplosives(self, event, unit)
end

-- Player Nameplate
local iconSize, margin = C.Auras.IconSize, 5
local auras = B:GetModule("Auras")

local function PlateVisibility(self, event)
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
	self:SetSize(iconSize*5 + margin*4, NDuiDB["Nameplate"]["PPHeight"])
	self:EnableMouse(false)
	self.iconSize = iconSize

	UF:CreateHealthBar(self)
	UF:CreatePowerBar(self)
	UF:CreateClassPower(self)
	if NDuiDB["Auras"]["ClassAuras"] then auras:CreateLumos(self) end

	if NDuiDB["Nameplate"]["PPPowerText"] then
		local textFrame = CreateFrame("Frame", nil, self.Power)
		textFrame:SetAllPoints()
		local power = B.CreateFS(textFrame, 14, "")
		self:Tag(power, "[pppower]")
	end

	self:RegisterEvent("PLAYER_ENTERING_WORLD", PlateVisibility)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", PlateVisibility)
	self:RegisterEvent("PLAYER_REGEN_DISABLED", PlateVisibility)
	self:RegisterEvent("UNIT_ENTERED_VEHICLE", PlateVisibility)
	self:RegisterEvent("UNIT_EXITED_VEHICLE", PlateVisibility)
end