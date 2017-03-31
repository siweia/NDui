local B, C, L, DB = unpack(select(2, ...))
-----------------------------
-- Nameplate, by paopao001
-- NDui MOD
-----------------------------

-- Class Nameplate
local function RedrawManaBar()
	local manaBar = ClassNameplateManaBarFrame
	manaBar:SetWidth(NDuiDB["Nameplate"]["Width"])
	manaBar:SetHeight(4)
	manaBar:SetStatusBarTexture(DB.normTex)
	manaBar.SetWidth = B.Dummy
	manaBar.SetHeight = B.Dummy
	manaBar.FullPowerFrame:ClearAllPoints()
	manaBar.FeedbackFrame.BarTexture:SetTexture(DB.normTex)
	manaBar.ManaCostPredictionBar:SetTexture(DB.normTex)

	local f = NDui:EventFrame({"NAME_PLATE_UNIT_ADDED", "NAME_PLATE_UNIT_REMOVED"})
	f:SetScript("OnEvent", function(self, event, unit)
		if GetCVar("nameplateShowSelf") == "0" then return end

		if event == "NAME_PLATE_UNIT_ADDED" and UnitIsUnit(unit, "player") then
			local namePlatePlayer = C_NamePlate.GetNamePlateForUnit("player")
			if namePlatePlayer then
				manaBar:Show()
				manaBar:SetParent(namePlatePlayer)
				manaBar:ClearAllPoints()
				manaBar:SetPoint("TOPLEFT", namePlatePlayer.UnitFrame.healthBar, "BOTTOMLEFT", 0, -2)
				manaBar:SetPoint("TOPRIGHT", namePlatePlayer.UnitFrame.healthBar, "BOTTOMRIGHT", 0, -2)
			else
				manaBar:Hide()
			end
		elseif event == "NAME_PLATE_UNIT_REMOVED" and UnitIsUnit(unit, "player") then
			manaBar:Hide()
		end
	end)
end

-- Class Resourcebar
do
	local function multicheck(check, ...)
		for i = 1, select("#", ...) do
			if check == select(i, ...) then return true end
		end
		return false
	end

	local colorTable = {
		["MONK"] = {0, 1, .59},
		["WARLOCK"] = {.58, .51, .79},
		["MAGE"] = {.41, .8, .94},
		["PALADIN"] = {.88, .88, .06},
		["ROGUE"] = {.88, .88, .06},
		["DRUID"] = {.88, .88, .06},
		["DEATHKNIGHT"] = {.77, .12, .23},
	}

	local ClassPowerID, ClassPowerType, RequireSpec
	if(DB.MyClass == "MONK") then
		ClassPowerID = SPELL_POWER_CHI
		ClassPowerType = "CHI"
		RequireSpec = SPEC_MONK_WINDWALKER
	elseif(DB.MyClass == "PALADIN") then
		ClassPowerID = SPELL_POWER_HOLY_POWER
		ClassPowerType = "HOLY_POWER"
		RequireSpec = SPEC_PALADIN_RETRIBUTION
	elseif(DB.MyClass == "MAGE") then
		ClassPowerID = SPELL_POWER_ARCANE_CHARGES
		ClassPowerType = "ARCANE_CHARGES"
		RequireSpec = SPEC_MAGE_ARCANE
	elseif(DB.MyClass == "WARLOCK") then
		ClassPowerID = SPELL_POWER_SOUL_SHARDS
		ClassPowerType = "SOUL_SHARDS"
	elseif(DB.MyClass == "ROGUE" or DB.MyClass == "DRUID") then
		ClassPowerID = SPELL_POWER_COMBO_POINTS
		ClassPowerType = "COMBO_POINTS"
	end

	local Resourcebar = CreateFrame("Frame", nil, UIParent)
	Resourcebar:SetSize(100, 4)
	Resourcebar.__max = 6
	local bars = {}
	for i = 1, Resourcebar.__max do
		bars[i] = CreateFrame("StatusBar", nil, Resourcebar)
		bars[i]:SetSize(15, 4)
		bars[i]:SetStatusBarTexture(DB.normTex)
		bars[i]:SetStatusBarColor(unpack(colorTable[DB.MyClass] or {1, 1, 1}))
		B.CreateSD(bars[i], 3, 3)
		if i == 1 then
			bars[i]:SetPoint("LEFT", Resourcebar)
		else
			bars[i]:SetPoint("LEFT", bars[i-1], "RIGHT", 2, 0)
		end
		bars[i]:Hide()
	end

	Resourcebar:RegisterEvent("PLAYER_TALENT_UPDATE")
	Resourcebar:SetScript("OnEvent", function(self, event, unit, powerType)
		if not NDuiDB["Nameplate"]["Enable"] then
			self:UnregisterAllEvents()
			return
		end

		if event == "PLAYER_TALENT_UPDATE" then
			if multicheck(DB.MyClass, "WARLOCK", "PALADIN", "MONK", "MAGE", "ROGUE", "DRUID", "DEATHKNIGHT") and not RequireSpec or RequireSpec == GetSpecialization() then
				self:RegisterEvent("UNIT_POWER_FREQUENT")
				self:RegisterEvent("PLAYER_ENTERING_WORLD")
				self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
				self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
				self:RegisterEvent("PLAYER_TARGET_CHANGED")
				self:RegisterEvent("RUNE_POWER_UPDATE")
				self:Show()
			else
				self:UnregisterEvent("UNIT_POWER_FREQUENT")
				self:UnregisterEvent("PLAYER_ENTERING_WORLD")
				self:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
				self:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")
				self:UnregisterEvent("PLAYER_TARGET_CHANGED")
				self:UnregisterEvent("RUNE_POWER_UPDATE")
				self:Hide()
			end
		elseif GetCVar("nameplateShowSelf") == "1" then
			if event == "PLAYER_ENTERING_WORLD" and DB.MyClass ~= "DEATHKNIGHT" or (event == "UNIT_POWER_FREQUENT" and unit == "player" and powerType == ClassPowerType) then
				local cur, max, oldMax
				cur = UnitPower("player", ClassPowerID)
				max = UnitPowerMax("player", ClassPowerID)

				if max <= 6 then
					for i = 1, max do
						if i <= cur then
							bars[i]:SetAlpha(1)
						else
							bars[i]:SetAlpha(.3)
						end
						if bars[1]:GetAlpha() == 1 then
							bars[i]:Show()
						else
							bars[i]:Hide()
						end
					end
				else
					if cur <= 5 then
						for i = 1, 5 do
							if i <= cur then
								bars[i]:SetAlpha(1)
							else
								bars[i]:SetAlpha(.3)
							end
							if bars[1]:GetAlpha() == 1 then
								bars[i]:Show()
							else
								bars[i]:Hide()
							end
							bars[i]:SetStatusBarColor(unpack(colorTable[DB.MyClass]))
						end
					else
						for i = 1, 5 do
							bars[i]:Show()
							bars[i]:SetAlpha(1)
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
							if bars[i] then bars[i]:Hide() end
						end
					end
					if max <= 6 then
						for i = 1, 6 do
							bars[i]:SetWidth((100 - (max-1)*2)/max)
							bars[i]:SetStatusBarColor(unpack(colorTable[DB.MyClass]))
						end
					else
						for i = 1, 5 do
							bars[i]:SetWidth((100 - (5-1)*2)/5)
						end
						bars[6]:Hide()
					end
					self.__max = max
				end
			elseif event == "RUNE_POWER_UPDATE" and DB.MyClass == "DEATHKNIGHT" then
				for i = 1, 6 do
					bars[i]:Show()
				end
				self:UnregisterEvent("UNIT_POWER_FREQUENT")
				self:UnregisterEvent("PLAYER_ENTERING_WORLD")

				local rid = unit
				local rune = bars[rid]
				local start, duration, runeReady = GetRuneCooldown(rid)
				if start then
					if runeReady then
						rune:SetMinMaxValues(0, 1)
						rune:SetValue(1)
						rune:SetScript("OnUpdate", nil)
						rune:SetAlpha(1)
					else
						rune.duration = GetTime() - start
						rune.max = duration
						rune:SetMinMaxValues(1, duration)
						rune:SetAlpha(.7)
						rune:SetScript("OnUpdate", function(self, elapsed)
							local duration = self.duration + elapsed
							if(duration >= self.max) then
								return self:SetScript("OnUpdate", nil)
							else
								self.duration = duration
								return self:SetValue(duration)
							end
						end)
					end
				end
			elseif GetCVar("nameplateResourceOnTarget") == "0" then
				if event == "NAME_PLATE_UNIT_ADDED" and UnitIsUnit(unit, "player") then
					local namePlatePlayer = C_NamePlate.GetNamePlateForUnit("player")
					if namePlatePlayer then
						self:SetParent(namePlatePlayer)
						self:ClearAllPoints()
						self:Show()
						self:SetPoint("BOTTOM", namePlatePlayer.UnitFrame.healthBar, "TOP", 0, 2)
					end
				elseif event == "NAME_PLATE_UNIT_REMOVED" and UnitIsUnit(unit, "player") then
					self:Hide()
				end
			elseif GetCVar("nameplateResourceOnTarget") == "1" and (event == "PLAYER_TARGET_CHANGED" or event == "NAME_PLATE_UNIT_ADDED") then
				local namePlateTarget = C_NamePlate.GetNamePlateForUnit("target")
				if namePlateTarget and UnitCanAttack("player", namePlateTarget.UnitFrame.displayedUnit) then
					self:SetParent(namePlateTarget)
					self:ClearAllPoints()
					self:SetPoint("TOP", namePlateTarget.UnitFrame.healthBar, "BOTTOM", 0, 0)
					self:Show()
				else
					self:Hide()
				end
			end
		end
	end)
end

-- Auras
local function CreateAuraIcon(parent)
	local button = CreateFrame("Frame", nil, parent)
	button:SetSize(NDuiDB["Nameplate"]["AuraSize"], NDuiDB["Nameplate"]["AuraSize"])
	B.CreateSD(button, 3, 3)

	button.icon = button:CreateTexture(nil, "OVERLAY", nil, 3)
	button.icon:SetAllPoints()
	button.icon:SetTexCoord(unpack(DB.TexCoord))

	button.cd = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
	button.cd:SetAllPoints(button)
	button.cd:SetReverse(true)
	button.count = B.CreateFS(button, 12, "", false, "BOTTOMRIGHT", 6, -3)

	return button
end

local function UpdateAuraIcon(button, unit, index, filter, customIcon)
	local name, _, icon, count, debuffType, duration, expirationTime, _, _, _, spellID = UnitAura(unit, index, filter)

	button.expirationTime = expirationTime
	button.duration = duration
	button.spellID = spellID

	local color = DebuffTypeColor[debuffType] or DebuffTypeColor.none
	if NDuiDB["Nameplate"]["ColorBorder"] then
		button.Shadow:SetBackdropBorderColor(color.r, color.g, color.b)
	else
		button.Shadow:SetBackdropBorderColor(0, 0, 0)
	end

	if duration and duration > 0 then
		button.cd:SetCooldown(expirationTime - duration, duration)
	else
		button.cd:SetCooldown(0, 0)
	end

	if count and count > 1 then
		button.count:SetText(count)
	else
		button.count:SetText("")
	end

	if customIcon then
		button.icon:SetTexture(C.CustomIcons[customIcon]) 
	else
		button.icon:SetTexture(icon)
	end

	button:Show()
end

local function AuraFilter(caster, spellID, unit)
	if caster == "player" then
		--1:none, 2:all, 3:white, 4:black, 5:aurawatch
		if NDuiDB["Nameplate"]["AuraFilter"] == 1 then
			return false
		elseif NDuiDB["Nameplate"]["AuraFilter"] == 2 then
			return true
		elseif NDuiDB["Nameplate"]["AuraFilter"] == 3 and C.WhiteList[spellID] then
			return true
		elseif NDuiDB["Nameplate"]["AuraFilter"] == 4 and not C.BlackList[spellID] then
			return true
		elseif NDuiDB["Nameplate"]["AuraFilter"] == 5 then
			local auraList = C.AuraWatchList[DB.MyClass]
			if auraList then
				for _, value in pairs(auraList) do
					if value.Name == "Target Aura" then
						for _, v in pairs(value.List) do
							if v.AuraID == spellID then
								return true
							end
						end
					end
				end
			end
		end
	else
		--1:none, 2:white
		if NDuiDB["Nameplate"]["OtherFilter"] == 1 then
			return false
		elseif NDuiDB["Nameplate"]["OtherFilter"] == 2 and C.WhiteList[spellID] then
			return true
		end
	end
end

local function UpdateBuffs(unitFrame)
	local unit = unitFrame.displayedUnit
	local iconsFrame = unitFrame.iconsFrame

	if not iconsFrame or not unit then return end
	if UnitIsUnit(unit, "player") and not NDuiDB["Nameplate"]["PlayerAura"] then
		iconsFrame:Hide()
		return
	else
		iconsFrame:Show()
	end

	local i = 1
	for index = 1, 15 do
		if i <= NDuiDB["Nameplate"]["maxAuras"] then
			local name, _, _, _, _, _, _, caster, _, _, spellID = UnitAura(unit, index, "HELPFUL")
			local matchbuff, customIcon = AuraFilter(caster, spellID, unit)
			if name and matchbuff then
				if not unitFrame.icons[i] then
					unitFrame.icons[i] = CreateAuraIcon(iconsFrame)
				end
				UpdateAuraIcon(unitFrame.icons[i], unit, index, "HELPFUL", customIcon)
				if i ~= 1 then
					if i == 6 then
						unitFrame.icons[6]:SetPoint("BOTTOM", unitFrame.icons[1], "TOP", 0, 4)
					else
						unitFrame.icons[i]:SetPoint("LEFT", unitFrame.icons[i-1], "RIGHT", 4, 0)
					end
				end
				i = i + 1
			end
		end
	end

	for index = 1, 20 do
		if i <= NDuiDB["Nameplate"]["maxAuras"] then
			local name, _, _, _, _, _, _, caster, _, _, spellID = UnitAura(unit, index, "HARMFUL")
			local matchdebuff, customIcon = AuraFilter(caster, spellID, unit)
			if name and matchdebuff then
				if not unitFrame.icons[i] then
					unitFrame.icons[i] = CreateAuraIcon(iconsFrame)
				end
				UpdateAuraIcon(unitFrame.icons[i], unit, index, "HARMFUL", customIcon)
				if i ~= 1 then
					if i == 6 then
						unitFrame.icons[6]:SetPoint("BOTTOM", unitFrame.icons[1], "TOP", 0, 4)
					else
						unitFrame.icons[i]:SetPoint("LEFT", unitFrame.icons[i-1], "RIGHT", 4, 0)
					end
				end
				i = i + 1
			end
		end
	end
	unitFrame.iconnumber = i - 1

	if i > 1 then
		local count = i > 5 and 5 or unitFrame.iconnumber
		unitFrame.icons[1]:SetPoint("BOTTOMLEFT", iconsFrame, "BOTTOM", -((NDuiDB["Nameplate"]["AuraSize"] + 4)*count - 4)/2, 0)
	end
	for index = i, #unitFrame.icons do unitFrame.icons[index]:Hide() end
end

-- Unitframe
local classtex = {
	rare = {"Interface\\MINIMAP\\ObjectIconsAtlas", .398, .463, .725, .79},
	elite = {"Interface\\MINIMAP\\Minimap_skull_elite", 0, 1, 0, 1},
	rareelite = {"Interface\\MINIMAP\\ObjectIconsAtlas", .398, .463, .926, .991},
	worldboss = {"Interface\\MINIMAP\\ObjectIconsAtlas", .07, .13, .27, .33},
}

local function UpdateName(unitFrame)
	local unit = unitFrame.displayedUnit
	local level = UnitLevel(unit)
	local name = GetUnitName(unit, false) or UNKNOWN
	local class = UnitClassification(unit)

	if level and level ~= UnitLevel("player") then
		if level == -1 then
			level = "|cffff0000Boss|r "
		else 
			level = B.HexRGB(GetCreatureDifficultyColor(level))..level.."|r "
		end
	else
		level = ""
	end

	if name then
		if UnitIsUnit(unit, "player") then
			unitFrame.name:SetText("")
		else
			unitFrame.name:SetText(level..name)
		end
	end

	if class and classtex[class] then
		local tex, a, b, c, d = unpack(classtex[class])
		unitFrame.creatureIcon:SetTexture(tex)
		unitFrame.creatureIcon:SetTexCoord(a, b, c, d)
	else
		unitFrame.creatureIcon:SetTexture(nil)
	end
end

local function UpdateHealth(unitFrame)
	local unit = unitFrame.displayedUnit
	local minHealth, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
	local p = minHealth/maxHealth * 100
	unitFrame.healthBar:SetValue(p/100)

	if minHealth == maxHealth or UnitIsUnit(unit, "player") then
		unitFrame.healthBar.value:SetText("")
	else
		unitFrame.healthBar.value:SetText(string.format("%d%%", p))
	end

	if p <= 50 and p >= 35 then
		unitFrame.healthBar.value:SetTextColor(253/255, 238/255, 80/255)
	elseif p < 35 and p >= 20 then
		unitFrame.healthBar.value:SetTextColor(250/255, 130/255, 0/255)
	elseif p < 20 then
		unitFrame.healthBar.value:SetTextColor(200/255, 20/255, 40/255)
	else
		unitFrame.healthBar.value:SetTextColor(1, 1, 1)
	end
end

local function UpdatePower(unitFrame)
	local unit = unitFrame.displayedUnit
	local minPower, maxPower = UnitPower(unit), UnitPowerMax(unit)
	local perc = minPower/maxPower
	local perc_text = math.floor(perc*100)

	if perc > .85 then
		unitFrame.power:SetTextColor(1, .1, .1)
	elseif perc > .5 then
		unitFrame.power:SetTextColor(1, 1, .1)
	else
		unitFrame.power:SetTextColor(.8, .8, 1)
	end
	unitFrame.power:SetText(perc_text)
end

local function IsTapDenied(unitFrame)
	return UnitIsTapDenied(unitFrame.unit) and not UnitPlayerControlled(unitFrame.unit)
end

local function UpdateHealthColor(unitFrame)
	local hp = unitFrame.healthBar
	local unit = unitFrame.displayedUnit or unitFrame.unit
	local status = UnitThreatSituation("player", unit)
	local r, g, b

	if not UnitIsConnected(unit) then
		r, g, b = .7, .7, .7
	else
		if UnitIsPlayer(unit) and UnitReaction(unit, "player") >= 5 then
			if NDuiDB["Nameplate"]["FriendlyCC"] then
				r, g, b = B.UnitColor(unit)
			else
				r, g, b = .3, .3, 1
			end
		elseif UnitIsPlayer(unit) and UnitReaction(unit, "player") <= 4 and NDuiDB["Nameplate"]["HostileCC"] then
			r, g, b = B.UnitColor(unit)
		elseif IsTapDenied(unitFrame) then
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

	if r ~= unitFrame.r or g ~= unitFrame.g or b ~= unitFrame.b then
		hp:SetStatusBarColor(r, g, b)
		unitFrame.r, unitFrame.g, unitFrame.b = r, g, b
	end

	if not NDuiDB["Nameplate"]["TankMode"] and DB.Role ~= "Tank" then
		if status and status == 3 then
			hp.Shadow:SetBackdropBorderColor(1, 0, 0)
		elseif status and (status == 2 or status == 1) then
			hp.Shadow:SetBackdropBorderColor(1, 1, 0)
		else
			hp.Shadow:SetBackdropBorderColor(0, 0, 0)
		end
	else
		hp.Shadow:SetBackdropBorderColor(0, 0, 0)
	end
end

local function UpdateCastBar(unitFrame)
	local cb = unitFrame.castBar
	if not cb.colored then
		cb.startCastColor = CreateColor(.37, .71, 1)
		cb.startChannelColor = CreateColor(.37, .71, 1)
		cb.finishedCastColor = CreateColor(.1, .8, 0)
		cb.failedCastColor = CreateColor(1, .1, 0)
		cb.nonInterruptibleColor = CreateColor(.78, .25, .25)
		CastingBarFrame_AddWidgetForFade(cb, cb.BorderShield)
		cb.colored = true
	end

	-- Disable Castbar on PlayerPlate
	local unit = unitFrame.displayedUnit
	if UnitIsUnit(unit, "player") then
		unit = nil
	end
	CastingBarFrame_SetUnit(cb, unit, false, true)
end

local function UpdateCastbarTimer(cb, curValue)
	local _, maxValue = cb:GetMinMaxValues()
	local last = cb.last and cb.last or 0
	local finish = (curValue > last) and (maxValue - curValue) or curValue
	cb.timer:SetFormattedText("%.1f ", finish)
	cb.last = curValue
end

local function UpdateSelectionHighlight(unitFrame)
	local unit = unitFrame.displayedUnit
	local arrow, glow, line = unitFrame.redArrow, unitFrame.glowBorder, unitFrame.underLine

	if UnitIsUnit(unit, "target") and not UnitIsUnit(unit, "player") then
		if arrow then arrow:Show() end
		if glow then glow:Show() end
	else
		if arrow then arrow:Hide() end
		if glow then glow:Hide() end
	end

	if NDuiDB["Nameplate"]["Arrow"] then
		if unitFrame.iconnumber and unitFrame.iconnumber > 0 then
			if unitFrame.iconnumber > 5 then
				arrow:SetPoint("BOTTOM", unitFrame.name, "TOP", 0, NDuiDB["Nameplate"]["AuraSize"]*2 + 3)
			else
				arrow:SetPoint("BOTTOM", unitFrame.name, "TOP", 0, NDuiDB["Nameplate"]["AuraSize"] + 3)
			end
		else
			arrow:SetPoint("BOTTOM", unitFrame.name, "TOP", 0, 0)
		end
	end
end

local function UpdateRaidTarget(unitFrame)
	local rtf = unitFrame.RaidTargetFrame
	local icon = rtf.RaidTargetIcon
	local unit = unitFrame.displayedUnit

	local index = GetRaidTargetIndex(unit)
	if index and not UnitIsUnit(unit, "player") then
		SetRaidTargetIconTexture(icon, index)
		icon:Show()
	else
		icon:Hide()
	end

	rtf:SetPoint("TOP", unitFrame.name, "LEFT", -15, 15)
end

local function UpdateNamePlateEvents(unitFrame)
	-- These are events affected if unit is in a vehicle
	local unit = unitFrame.unit
	local displayedUnit
	if unit ~= unitFrame.displayedUnit then
		displayedUnit = unitFrame.displayedUnit
	end
	unitFrame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", unit, displayedUnit)
	unitFrame:RegisterUnitEvent("UNIT_AURA", unit, displayedUnit)
	unitFrame:RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", unit, displayedUnit)
	if C.ShowPowerUnit[UnitName(unitFrame.displayedUnit)] then
		unitFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", unit, displayedUnit)
		unitFrame.power:Show()
	else
		unitFrame:UnregisterEvent("UNIT_POWER_FREQUENT")
		unitFrame.power:Hide()
	end
end

local function UpdateInVehicle(unitFrame)
	if UnitHasVehicleUI(unitFrame.unit) then
		if not unitFrame.inVehicle then
			unitFrame.inVehicle = true
			local prefix, id, suffix = string.match(unitFrame.unit, "([^%d]+)([%d]*)(.*)")
			unitFrame.displayedUnit = prefix.."pet"..id..suffix
			UpdateNamePlateEvents(unitFrame)
		end
	else
		if unitFrame.inVehicle then
			unitFrame.inVehicle = false
			unitFrame.displayedUnit = unitFrame.unit
			UpdateNamePlateEvents(unitFrame)
		end
	end
end

local function BlockAddons()
	if DBM and DBM.Nameplate then
		function DBM.Nameplate:SupportedNPMod()
			return true
		end
	end
end

local function UpdateAll(unitFrame)
	UpdateInVehicle(unitFrame)
	local unit = unitFrame.displayedUnit

	if UnitExists(unit) then
		UpdateCastBar(unitFrame)
		UpdateSelectionHighlight(unitFrame)
		UpdateName(unitFrame)
		UpdateHealthColor(unitFrame)
		UpdateHealth(unitFrame)
		UpdateBuffs(unitFrame)
		UpdateRaidTarget(unitFrame)
		if C.ShowPowerUnit[UnitName(unit)] then
			UpdatePower(unitFrame)
		end
	end
end

local function NamePlate_OnEvent(self, event, ...)
	if not NDuiDB["Nameplate"]["Enable"] then
		self:UnregisterAllEvents()
		return
	end

	local arg1 = ...
	if event == "PLAYER_TARGET_CHANGED" then
		UpdateName(self)
		UpdateSelectionHighlight(self)
	elseif event == "PLAYER_ENTERING_WORLD" then
		UpdateAll(self)
	elseif arg1 == self.unit or arg1 == self.displayedUnit then
		if event == "UNIT_HEALTH_FREQUENT" then
			UpdateHealth(self)
			UpdateSelectionHighlight(self)
		elseif event == "UNIT_AURA" then
			UpdateBuffs(self)
			UpdateSelectionHighlight(self)
		elseif event == "UNIT_THREAT_LIST_UPDATE" then
			UpdateHealthColor(self)
		elseif event == "UNIT_NAME_UPDATE" then
			UpdateName(self)
		elseif event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" or event == "UNIT_PET" then
			UpdateAll(self)
		elseif event == "UNIT_POWER_FREQUENT" then
			if C.ShowPowerUnit[UnitName(self.displayedUnit)] then
				UpdatePower(self)
			end
		end
	end
end

local function RegisterNamePlateEvents(unitFrame)
	unitFrame:RegisterEvent("UNIT_NAME_UPDATE")
	unitFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	unitFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	unitFrame:RegisterEvent("UNIT_PET")
	unitFrame:RegisterEvent("UNIT_ENTERED_VEHICLE")
	unitFrame:RegisterEvent("UNIT_EXITED_VEHICLE")
	UpdateNamePlateEvents(unitFrame)
	unitFrame:SetScript("OnEvent", NamePlate_OnEvent)
end

local function UnregisterNamePlateEvents(unitFrame)
	unitFrame:UnregisterAllEvents()
	unitFrame:SetScript("OnEvent", nil)
end

local function SetUnit(unitFrame, unit)
	unitFrame.unit = unit
	unitFrame.displayedUnit = unit	 -- For vehicles
	unitFrame.inVehicle = false
	if unit then
		RegisterNamePlateEvents(unitFrame)
	else
		UnregisterNamePlateEvents(unitFrame)
	end
end

-- Driver frame
local function NamePlates_UpdateNamePlateOptions()
	-- Called at VARIABLES_LOADED and by "Larger Nameplates" interface options checkbox
	local baseNamePlateWidth = NDuiDB["Nameplate"]["Width"]
	local baseNamePlateHeight = 40
	local horizontalScale = tonumber(GetCVar("NamePlateHorizontalScale"))
	C_NamePlate.SetNamePlateEnemySize(baseNamePlateWidth * horizontalScale, baseNamePlateHeight)
	C_NamePlate.SetNamePlateFriendlySize(baseNamePlateWidth * horizontalScale, baseNamePlateHeight)
	C_NamePlate.SetNamePlateSelfSize(baseNamePlateWidth, baseNamePlateHeight)

	for i, namePlate in ipairs(C_NamePlate.GetNamePlates()) do
		local unitFrame = namePlate.UnitFrame
		UpdateAll(unitFrame)
	end
end

local function HideBlizzard()
	NamePlateDriverFrame:UnregisterAllEvents()
	NamePlateDriverFrame.SetupClassNameplateBars = B.Dummy
	NamePlateDriverFrame.UpdateNamePlateOptions = B.Dummy
	hooksecurefunc(NamePlateDriverFrame, "SetupClassNameplateBar", function()
		NamePlateTargetResourceFrame:Hide()
		NamePlatePlayerResourceFrame:Hide()
	end)

	-- CVars (Default: .08, .1, 60, .8, 1.1, .5)
	if NDuiDB["Nameplate"]["InsideView"] then
		SetCVar("nameplateOtherTopInset", .05)
		SetCVar("nameplateOtherBottomInset", .08)
	else
		SetCVar("nameplateOtherTopInset", -1)
		SetCVar("nameplateOtherBottomInset", -1)
	end
	SetCVar("nameplateMaxDistance", NDuiDB["Nameplate"]["Distance"])
	SetCVar("nameplateOverlapH", .5)
	SetCVar("nameplateOverlapV", .7)
	SetCVar("nameplateMinAlpha", NDuiDB["Nameplate"]["MinAlpha"])
	C_NamePlate.SetNamePlateFriendlyClickThrough(false)

	-- No more smallplates
	local checkBox = InterfaceOptionsNamesPanelUnitNameplatesMakeLarger
	SetCVar("NamePlateHorizontalScale", checkBox.largeHorizontalScale)
	SetCVar("NamePlateVerticalScale", checkBox.largeVerticalScale)
	checkBox:Hide()
end

local function OnUnitFactionChanged(unit)
	-- This would make more sense as a unitFrame:RegisterUnitEvent
	local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
	if namePlate then
		UpdateName(namePlate.UnitFrame)
		UpdateHealthColor(namePlate.UnitFrame)
	end
end

local function OnRaidTargetUpdate()
	for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
		UpdateRaidTarget(namePlate.UnitFrame)
	end
end

local function OnNamePlateCreated(namePlate)
	local unitFrame = CreateFrame("Button", "$parentUnitFrame", namePlate)
	unitFrame:SetAllPoints(namePlate)
	unitFrame:SetFrameLevel(namePlate:GetFrameLevel())
	unitFrame.name = B.CreateFS(unitFrame, 11, "", false, "TOPLEFT", 5, -5)
	unitFrame.name:SetPoint("BOTTOMRIGHT", unitFrame, "TOPRIGHT", -5, -15)
	namePlate.UnitFrame = unitFrame

	local hp = CreateFrame("StatusBar", nil, unitFrame)
	hp:SetHeight(NDuiDB["Nameplate"]["Height"])
	hp:SetPoint("TOPLEFT", 0, -20)
	hp:SetPoint("TOPRIGHT", 0, -20)
	hp:SetMinMaxValues(0, 1)
	B.CreateSB(hp)
	B.SmoothBar(hp)
	hp.value = B.CreateFS(hp, 11, "", false, "TOPRIGHT", 0, 7)
	unitFrame.healthBar = hp

	unitFrame.power = B.CreateFS(hp, 15, "", false, "LEFT", 0, 0)
	unitFrame.power:SetPoint("LEFT", hp, "RIGHT", 2, 0)

	local cicon = hp:CreateTexture(nil, "OVERLAY")
	cicon:SetPoint("LEFT", hp, "TOPLEFT", 0, 2)
	cicon:SetSize(15, 15)
	cicon:SetAlpha(.75)
	unitFrame.creatureIcon = cicon

	local cb = CreateFrame("StatusBar", nil, unitFrame)
	cb:Hide()
	cb.iconWhenNoninterruptible = false
	cb:SetHeight(5)
	cb:SetPoint("TOPLEFT", hp, "BOTTOMLEFT", 0, -5)
	cb:SetPoint("TOPRIGHT", hp, "BOTTOMRIGHT", 0, -5)
	B.CreateSB(cb, true)
	cb:SetStatusBarColor(.5, .5, .5)
	cb.Text = B.CreateFS(cb, 11, "", false, "CENTER", 0, -5)
	cb.timer = B.CreateFS(cb, 11, "", false, "BOTTOMRIGHT", 0, -7)
	unitFrame.castBar = cb

	local cbicon = cb:CreateTexture(nil, "OVERLAY", 1)
	cbicon:SetPoint("BOTTOMRIGHT", cb, "BOTTOMLEFT", -4, -1)
	cbicon:SetTexCoord(unpack(DB.TexCoord))
	cbicon:SetSize(20, 20)
	B.CreateSD(cbicon, 3, 3)
	cb.Icon = cbicon

	local cbshield = cb:CreateTexture(nil, "OVERLAY", 1)
	cbshield:SetAtlas("nameplates-InterruptShield")
	cbshield:SetSize(15, 15)
	cbshield:SetPoint("LEFT", cb, "LEFT", 5, -5)
	cb.BorderShield = cbshield

	local flash = cb:CreateTexture(nil, "OVERLAY")
	flash:SetAllPoints()
	flash:SetTexture(DB.normTex)
	flash:SetBlendMode("ADD")
	cb.Flash = flash

	CastingBarFrame_OnLoad(cb, nil, false, true)
	cb:SetScript("OnEvent", CastingBarFrame_OnEvent)
	cb:SetScript("OnUpdate", CastingBarFrame_OnUpdate)
	cb:SetScript("OnShow", CastingBarFrame_OnShow)
	cb:HookScript("OnValueChanged", UpdateCastbarTimer)

	local rtf = CreateFrame("Frame", nil, unitFrame)
	rtf:SetSize(30, 30)
	rtf:SetPoint("TOP", unitFrame.name, "LEFT", -15, 15)
	unitFrame.RaidTargetFrame = rtf

	local ricon = rtf:CreateTexture(nil, "OVERLAY")
	ricon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
	ricon:SetAllPoints()
	ricon:Hide()
	rtf.RaidTargetIcon = ricon

	if NDuiDB["Nameplate"]["Arrow"] then
		local arrow = unitFrame:CreateTexture(nil, "OVERLAY")
		arrow:SetSize(50, 50)
		arrow:SetTexture(DB.arrowTex)
		arrow:SetPoint("CENTER")
		arrow:Hide()
		unitFrame.redArrow = arrow
	else
		local glow = CreateFrame("Frame", nil, hp)
		glow:SetPoint("TOPLEFT", hp, -5, 5)
		glow:SetPoint("BOTTOMRIGHT", hp, 5, -5)
		glow:SetBackdrop({edgeFile = DB.glowTex, edgeSize = 4})
		glow:SetBackdropBorderColor(1, 1, 1)
		glow:SetFrameLevel(0)
		unitFrame.glowBorder = glow
	end

	local icons = CreateFrame("Frame", nil, unitFrame)
	icons:SetPoint("BOTTOM", unitFrame, "TOP")
	icons:SetSize(140, 25)
	icons:SetFrameLevel(unitFrame:GetFrameLevel() + 2)
	unitFrame.iconsFrame = icons
	unitFrame.icons = {}

	unitFrame:EnableMouse(false)
end

local function OnNamePlateAdded(unit)
	local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
	local unitFrame = namePlate.UnitFrame
	SetUnit(unitFrame, unit)
	UpdateAll(unitFrame)
end

local function OnNamePlateRemoved(unit)
	local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
	local unitFrame = namePlate.UnitFrame
	SetUnit(unitFrame, nil)
	CastingBarFrame_SetUnit(unitFrame.castBar, nil, false, true)
end

local function NamePlates_OnEvent(self, event, ...)
	if not NDuiDB["Nameplate"]["Enable"] then
		self:UnregisterAllEvents()
		return
	end

	local arg1 = ...
	if event == "VARIABLES_LOADED" then
		HideBlizzard()
		BlockAddons()
		RedrawManaBar()
		NamePlates_UpdateNamePlateOptions()
	elseif event == "NAME_PLATE_CREATED" then
		OnNamePlateCreated(arg1)
	elseif event == "NAME_PLATE_UNIT_ADDED" then
		OnNamePlateAdded(arg1)
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		OnNamePlateRemoved(arg1)
	elseif event == "RAID_TARGET_UPDATE" then
		OnRaidTargetUpdate()
	elseif event == "DISPLAY_SIZE_CHANGED" then
		NamePlates_UpdateNamePlateOptions()
	elseif event == "UNIT_FACTION" then
		OnUnitFactionChanged(arg1)
	end
end

local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("VARIABLES_LOADED")
EventFrame:RegisterEvent("NAME_PLATE_CREATED")
EventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
EventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
EventFrame:RegisterEvent("RAID_TARGET_UPDATE")
EventFrame:RegisterEvent("DISPLAY_SIZE_CHANGED")
EventFrame:RegisterEvent("UNIT_FACTION")
EventFrame:SetScript("OnEvent", NamePlates_OnEvent)