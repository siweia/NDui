local B, C, L, DB = unpack(select(2, ...))
local UF = NDui:GetModule("UnitFrames")

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
	SetCVar("nameplateOccludedAlphaMult", .4)

	SetCVar("namePlateMinScale", .8)
	SetCVar("namePlateMaxScale", .8)
	SetCVar("nameplateSelectedScale", 1)
	SetCVar("nameplateLargerScale", 1)
	SetCVar("nameplateSelfScale", .75)
end

function UF:BlockAddons()
	if DBM and DBM.Nameplate then
		function DBM.Nameplate:SupportedNPMod()
			return true
		end
	end
end

local CustomUnits = {
	["Fel Explosive"] = true,
	["邪能炸药"] = true,
	["魔化炸彈"] = true,
	[EJ_GetSectionInfo(14544)] = true,	-- 海拉加尔观雾者
	[EJ_GetSectionInfo(14595)] = true,	-- 深渊追猎者
	[EJ_GetSectionInfo(16588)] = true,	-- 尖啸反舌鸟
	[EJ_GetSectionInfo(16350)] = true,	-- 瓦里玛萨斯之影
}
function UF:CreateUnitTable()
	if not NDuiDB["Nameplate"]["CustomUnitColor"] then return end

	local list = {string.split(" ", NDuiDB["Nameplate"]["UnitList"])}
	for _, value in pairs(list) do
		CustomUnits[value] = true
	end
end

C.ShowPowerList = {
	[EJ_GetSectionInfo(13015)] = true,	-- 清扫器
	[EJ_GetSectionInfo(15903)] = true,	-- 泰沙拉克的余烬
}
function UF:CreatePowerUnitTable()
	if not NDuiDB["Nameplate"]["ShowUnitPower"] then return end

	local list = {string.split(" ", NDuiDB["Nameplate"]["ShowPowerList"])}
	for _, value in pairs(list) do
		C.ShowPowerList[value] = true
	end
end

-- Elements
local function UpdateColor(element, unit)
	local name = GetUnitName(unit) or UNKNOWN
	local status = UnitThreatSituation("player", unit) or false		-- just in case
	local reaction = UnitReaction(unit, "player")
	local r, g, b

	if not UnitIsConnected(unit) then
		r, g, b = .7, .7, .7
	else
		if UnitIsUnit("player", unit) then	-- PlayerPlate
			r, g, b = 0, .9, 0
		elseif CustomUnits and CustomUnits[name] then
			r, g, b = 0, .8, .3
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
					r, g, b = 1, 0, 1
				elseif status == 2 or status == 1 then
					r, g, b = 1, .8, 0
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
	local mark = self.targetMark
	if not mark then return end

	if UnitIsUnit(self.unit, "target") and not UnitIsUnit(self.unit, "player") then
		mark:SetAlpha(1)
	else
		mark:SetAlpha(0)
	end
end

local function UpdateQuestUnit(self, unit)
	if not NDuiDB["Nameplate"]["QuestIcon"] or unit == "player" then return end
	local name, instType, instID = GetInstanceInfo()
	if name and (instType == "raid" or instID == 8) then self.questIcon:SetAlpha(0) return end

	local isObjectiveQuest, isProgressQuest
	local unitTip = _G["NDuiQuestUnitTip"] or CreateFrame("GameTooltip", "NDuiQuestUnitTip", nil, "GameTooltipTemplate")
	unitTip:SetOwner(WorldFrame, "ANCHOR_NONE")
	unitTip:SetUnit(unit)

	for i = 2, unitTip:NumLines() do
		local textLine = _G["NDuiQuestUnitTipTextLeft"..i]
		local text = textLine:GetText()
		if textLine and text then
			local r, g, b = textLine:GetTextColor()
			if r > .99 and g > .82 and b == 0 then
				isProgressQuest = true
			else
				local unitName, progress = strmatch(text, "^ ([^ ]-) ?%-(.+)$")
				if unitName and (unitName == "" or unitName == UnitName("player")) and progress then
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

function UF:CreateClassBar()
	local ClassPowerID, ClassPowerType, RequireSpec, RequirePower
	-- Data
	if DB.MyClass == "MONK" then
		ClassPowerID = SPELL_POWER_CHI
		ClassPowerType = "CHI"
		RequireSpec = SPEC_MONK_WINDWALKER
	elseif DB.MyClass == "PALADIN" then
		ClassPowerID = SPELL_POWER_HOLY_POWER
		ClassPowerType = "HOLY_POWER"
		RequireSpec = SPEC_PALADIN_RETRIBUTION
	elseif DB.MyClass == "WARLOCK" then
		ClassPowerID = SPELL_POWER_SOUL_SHARDS
		ClassPowerType = "SOUL_SHARDS"
	elseif DB.MyClass == "ROGUE" or DB.MyClass == "DRUID" then
		ClassPowerID = SPELL_POWER_COMBO_POINTS
		ClassPowerType = "COMBO_POINTS"

		if DB.MyClass == "DRUID" then
			RequirePower = SPELL_POWER_ENERGY
		end
	elseif DB.MyClass == "MAGE" then
		ClassPowerID = SPELL_POWER_ARCANE_CHARGES
		ClassPowerType = "ARCANE_CHARGES"
		RequireSpec = SPEC_MAGE_ARCANE
	elseif DB.MyClass == "DEATHKNIGHT" then
		ClassPowerID = true
	end
	if not ClassPowerID then return end

	-- Create Bar
	local width, height, margin = NDuiDB["Nameplate"]["Width"] * 1.4, 5, 3
	local colorTable = {
		["MONK"] = {0, 1, .59},
		["WARLOCK"] = {.58, .51, .79},
		["MAGE"] = {.41, .8, .94},
		["PALADIN"] = {.88, .88, .06},
		["ROGUE"] = {.88, .88, .06},
		["DRUID"] = {.88, .88, .06},
		["DEATHKNIGHT"] = {.77, .12, .23},
	}

	local bar, bars = CreateFrame("Frame", "NDui_NPClassPower", UIParent), {}
	bar:SetSize(width, height)
	bar.__max = 6
	for i = 1, bar.__max do
		bars[i] = CreateFrame("StatusBar", nil, bar)
		bars[i]:SetHeight(height)
		bars[i]:SetWidth((width - 5*margin) / 6)
		bars[i]:SetStatusBarTexture(DB.normTex)
		bars[i]:SetStatusBarColor(unpack(colorTable[DB.MyClass] or {1, 1, 1}))
		B.CreateSD(bars[i], 3, 3)
		if i == 1 then
			bars[i]:SetPoint("LEFT")
		else
			bars[i]:SetPoint("LEFT", bars[i-1], "RIGHT", margin, 0)
		end
	end

	-- Update bars
	local function UpdateClassPower(self, event, unit, powerType)
		if event and (unit ~= "player" or powerType ~= ClassPowerType) then return end

		local cur = UnitPower("player", ClassPowerID)
		local max = UnitPowerMax("player", ClassPowerID)
		local mod = UnitPowerDisplayMod(ClassPowerID)
		local oldMax

		cur = mod == 0 and 0 or cur / mod
		if ClassPowerType == "SOUL_SHARDS" and GetSpecialization() ~= SPEC_WARLOCK_DESTRUCTION then
			cur = cur - cur % 1
		end

		local numActive = cur + 0.9
		if max <= 6 then
			for i = 1, max do
				if(i > numActive) then
					bars[i]:Hide()
					bars[i]:SetValue(0)
				else
					bars[i]:Show()
					bars[i]:SetValue(cur - i + 1)
				end
				bars[i]:SetStatusBarColor(unpack(colorTable[DB.MyClass]))
			end
		else
			for i = 1, 5 do bars[i]:SetValue(1) end
			bars[6]:Hide()

			if cur <= 5 then
				for i = 1, 5 do
					if i <= cur then
						bars[i]:Show()
					else
						bars[i]:Hide()
					end
					bars[i]:SetStatusBarColor(unpack(colorTable[DB.MyClass]))
				end
			else
				for i = 1, 5 do
					bars[i]:Show()
				end
				for i = 1, cur - 5 do
					bars[i]:SetStatusBarColor(1, 0, 0)
				end
				for i = cur - 4, 5 do
					bars[i]:SetStatusBarColor(unpack(colorTable[DB.MyClass]))
				end
			end
		end

		oldMax = self.__max
		if(max ~= oldMax) then
			if(max < oldMax) then
				for i = max + 1, oldMax do
					if bars[i] then
						bars[i]:Hide()
						bars[i]:SetValue(0)
					end
				end
			end
			if max <= 6 then
				for i = 1, 6 do
					bars[i]:SetWidth((width - (max-1)*margin)/max)
				end
			else
				for i = 1, 5 do
					bars[i]:SetWidth((width - 4*margin)/5)
				end
				bars[6]:Hide()
			end

			self.__max = max
		end
	end

	local function UpdateRune(_, _, runeID, energized)
		local rune = bars[runeID]
		if not rune then return end

		if UnitHasVehicleUI("player") then
			rune:Hide()
		else
			local start, duration, runeReady = GetRuneCooldown(runeID)
			if not start then return end

			if energized or runeReady then
				rune:SetMinMaxValues(0, 1)
				rune:SetValue(1)
				rune:SetScript("OnUpdate", nil)
				rune:SetAlpha(1)
			else
				rune.duration = GetTime() - start
				rune.max = duration
				rune:SetMinMaxValues(0, duration)
				rune:SetValue(0)
				rune:SetScript("OnUpdate", function(self, elapsed)
					local duration = self.duration + elapsed
					self.duration = duration
					self:SetValue(duration)
				end)
				rune:SetAlpha(.7)
			end
			rune:Show()
		end
	end

	local function UpdateVisibility(self)
		if (RequireSpec and RequireSpec ~= GetSpecialization()) or (RequirePower and RequirePower ~= UnitPowerType("player")) then
			self:UnregisterEvent("UNIT_POWER_FREQUENT")
			self:UnregisterEvent("UNIT_MAXPOWER")
			for i = 1, 6 do bars[i]:Hide() end
		else
			self:RegisterEvent("UNIT_POWER_FREQUENT")
			self:RegisterEvent("UNIT_MAXPOWER")
			UpdateClassPower(self)
		end
	end

	-- OnEvent
	if DB.MyClass == "DEATHKNIGHT" then
		bar:RegisterEvent("RUNE_POWER_UPDATE")
	else
		bar:RegisterEvent("PLAYER_ENTERING_WORLD")
		bar:RegisterEvent("UNIT_POWER_FREQUENT")
		bar:RegisterEvent("UNIT_MAXPOWER")
		if RequireSpec then
			bar:RegisterEvent("PLAYER_TALENT_UPDATE")
		end
		if RequirePower then
			bar:RegisterEvent("UNIT_DISPLAYPOWER")
		end
	end
	bar:SetScript("OnEvent", function(self, event, ...)
		if not GetCVarBool("nameplateShowSelf") then return end
		if event == "RUNE_POWER_UPDATE" then
			UpdateRune(self, event, ...)
		elseif event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER" then
			UpdateClassPower(self, event, ...)
		elseif event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_TALENT_UPDATE" or event == "UNIT_DISPLAYPOWER" then
			UpdateVisibility(self)
		end
	end)
end

-- Create Nameplates
local function CreatePlates(self, unit)
	self.mystyle = "nameplate"
	if unit:match("nameplate") then
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
		UF:CreatePowerBar(self)

		self.powerText = B.CreateFS(self, 15, "", false, "LEFT", 0, 0)
		self.powerText:SetPoint("LEFT", self, "RIGHT", 2, 0)
		self:Tag(self.powerText, "[nppp]")

		if NDuiDB["Nameplate"]["Arrow"] then
			local arrow = self:CreateTexture(nil, "OVERLAY")
			arrow:SetSize(50, 50)
			arrow:SetTexture(DB.arrowTex)
			arrow:SetPoint("BOTTOM", self, "TOP", 0, 14)
			arrow:SetAlpha(0)
			self.targetMark = arrow
		else
			local glow = CreateFrame("Frame", nil, self)
			glow:SetPoint("TOPLEFT", -5, 5)
			glow:SetPoint("BOTTOMRIGHT", 5, -5)
			glow:SetBackdrop({edgeFile = DB.glowTex, edgeSize = 4})
			glow:SetBackdropBorderColor(1, 1, 1)
			glow:SetFrameLevel(0)
			glow:SetAlpha(0)
			self.targetMark = glow
		end
		self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateTargetMark)

		local cicon = self:CreateTexture(nil, "OVERLAY")
		cicon:SetPoint("LEFT", self, "TOPLEFT", 1, 1)
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
	end
end
UF.CreatePlates = CreatePlates

local function enableElement(self, name, element)
	if not self:IsElementEnabled(name) then
		self:EnableElement(name)
		element:ForceUpdate()
	end
end

local function disableElement(self, name)
	if self:IsElementEnabled(name) then
		self:DisableElement(name)
	end
end

local function UpdatePlates(self, event, unit)
	-- Update Elements
	UpdateTargetMark(self)
	UpdateQuestUnit(self, unit)
	UpdateUnitClassify(self, unit)

	-- Update PlayerPlate
	if event == "NAME_PLATE_UNIT_ADDED" then
		if UnitIsUnit(unit, "player") then
			self.nameFrame:Hide()
			enableElement(self, "Power", self.Power)
			disableElement(self, "Castbar")
		else
			self.nameFrame:Show()
			disableElement(self, "Power")
			enableElement(self, "Castbar", self.Castbar)
		end
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		self.nameFrame:Hide()
		disableElement(self, "Power")
		disableElement(self, "Castbar")
	end

	-- Update ClassPowerBar
	local bar = NDui_NPClassPower
	if not bar then return end
	if GetCVar("nameplateShowSelf") == "0" then return end

	if event == "NAME_PLATE_UNIT_ADDED" and UnitIsUnit(unit, "player") then
		local namePlatePlayer = C_NamePlate.GetNamePlateForUnit("player")
		if namePlatePlayer then
			if bar:GetParent() ~= self then
				bar:SetParent(self)
				bar:ClearAllPoints()
				bar:SetPoint("BOTTOM", self.Health, "TOP", 0, 3)
			end
			bar:Show()
		end
	elseif event == "NAME_PLATE_UNIT_REMOVED" and UnitIsUnit(unit, "player") then
		bar:Hide()
	end
end
UF.PostUpdatePlates = UpdatePlates