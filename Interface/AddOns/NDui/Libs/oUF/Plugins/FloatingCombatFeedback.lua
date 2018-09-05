-----------------------------------------------
-- oUF_FloatingCombatFeedback, by lightspark
-- NDui MOD
-----------------------------------------------
local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF or oUF
assert(oUF, "oUF FloatingCombatFeedback was unable to locate oUF install")

local _G = getfenv(0)
local pairs = pairs
local cos, sin, mmax = cos, sin, math.max
local tremove, tinsert = table.remove, table.insert
local BreakUpLargeNumbers = _G.BreakUpLargeNumbers

local colors = {
	ABSORB		= {r = 1.00, g = 1.00, b = 1.00},
	BLOCK		= {r = 1.00, g = 1.00, b = 1.00},
	DEFLECT		= {r = 1.00, g = 1.00, b = 1.00},
	DODGE		= {r = 1.00, g = 1.00, b = 1.00},
	ENERGIZE	= {r = 0.41, g = 0.80, b = 0.94},
	EVADE		= {r = 1.00, g = 1.00, b = 1.00},
	HEAL		= {r = 0.10, g = 0.80, b = 0.10},
	IMMUNE		= {r = 1.00, g = 1.00, b = 1.00},
	INTERRUPT	= {r = 1.00, g = 1.00, b = 1.00},
	MISS		= {r = 1.00, g = 1.00, b = 1.00},
	PARRY		= {r = 1.00, g = 1.00, b = 1.00},
	REFLECT		= {r = 1.00, g = 1.00, b = 1.00},
	RESIST		= {r = 1.00, g = 1.00, b = 1.00},
	WOUND		= {r = 0.80, g = 0.10, b = 0.10},
}

local schoolColors = {
	[SCHOOL_MASK_NONE]		= {r = 1.00, g = 1.00, b = 1.00},	-- 0x00 or 0
	[SCHOOL_MASK_PHYSICAL]	= {r = 1.00, g = 1.00, b = 0.00},	-- 0x01 or 1
	[SCHOOL_MASK_HOLY]		= {r = 1.00, g = 0.90, b = 0.50},	-- 0x02 or 2
	[SCHOOL_MASK_FIRE]		= {r = 1.00, g = 0.50, b = 0.00},	-- 0x04 or 4
	[SCHOOL_MASK_NATURE]	= {r = 0.30, g = 1.00, b = 0.30},	-- 0x08 or 8
	[SCHOOL_MASK_FROST]		= {r = 0.50, g = 1.00, b = 1.00},	-- 0x10 or 16
	[SCHOOL_MASK_SHADOW]	= {r = 0.50, g = 0.50, b = 1.00},	-- 0x20 or 32
	[SCHOOL_MASK_ARCANE]	= {r = 1.00, g = 0.50, b = 1.00},	-- 0x40 or 64
}

local function removeString(self, i, string)
	tremove(self.FeedbackToAnimate, i)
	string:SetText(nil)
	string:SetAlpha(0)
	string:Hide()

	return string
end

local function getAvailableString(self)
	for i = 1, self.__max do
		if not self[i]:IsShown() then
			return self[i]
		end
	end

	return removeString(self, 1, self.FeedbackToAnimate[1])
end

local function fountainScroll(self)
	return self.x + self.xDirection * self.scrollHeight * (1 - cos(90 * self.elapsed / self.scrollTime)),
		self.y + self.yDirection * self.scrollHeight * sin(90 * self.elapsed / self.scrollTime)
end

local function standardScroll(self)
	return self.x, self.y + self.yDirection * self.scrollHeight * self.elapsed / self.scrollTime
end

local function onUpdate(self, elapsed)
	for index, string in pairs(self.FeedbackToAnimate) do
		if string.elapsed >= string.scrollTime then
			removeString(self, index, string)
		else
			string.elapsed = string.elapsed + elapsed

			string:SetPoint("CENTER", self, "CENTER", self.Scroll(string))

			if (string.elapsed >= self.fadeout) then
				string:SetAlpha(mmax(1 - (string.elapsed - self.fadeout) / (self.scrollTime - self.fadeout), 0))
			end
		end
	end

	if #self.FeedbackToAnimate == 0 then
		self:SetScript("OnUpdate", nil)
	end
end

local function onShow(self)
	for index, string in pairs(self.FeedbackToAnimate) do
		removeString(self, index, string)
	end
end

local eventFilter = {
	["SWING_DAMAGE"] = {suffix = "DAMAGE", index = 12, iconType = "swing", autoAttack = true},
	["RANGE_DAMAGE"] = {suffix = "DAMAGE", index = 15, iconType = "range", autoAttack = true},
	["SPELL_DAMAGE"] = {suffix = "DAMAGE", index = 15, iconType = "spell"},
	["SPELL_PERIODIC_DAMAGE"] = {suffix = "DAMAGE", index = 15, iconType = "spell", isPeriod = true},

	["SPELL_HEAL"] = {suffix = "HEAL", index = 15, iconType = "spell"},
	["SPELL_PERIODIC_HEAL"] = {suffix = "HEAL", index = 15, iconType = "spell", isPeriod = true},

	["SWING_MISSED"] = {suffix = "MISS", index = 12, iconType = "swing", autoAttack = true},
	["RANGE_MISSED"] = {suffix = "MISS", index = 15, iconType = "range", autoAttack = true},
	["SPELL_MISSED"] = {suffix = "MISS", index = 15, iconType = "spell"},

	["ENVIRONMENTAL_DAMAGE"] = {suffix = "ENVIRONMENT", index = 12, iconType = "env"},
}

local envTexture = {
	["Drowning"] = "spell_shadow_demonbreath",
	["Falling"] = "ability_rogue_quickrecovery",
	["Fatigue"] = "ability_creature_cursed_05",
	["Fire"] = "spell_fire_fire",
	["Lava"] = "ability_rhyolith_lavapool",
	["Slime"] = "inv_misc_slime_02",
}

local function getFloatingIconTexture(iconType, spellID, isPet)
	local texture
	if iconType == "spell" then
		texture = GetSpellTexture(spellID)
	elseif iconType == "swing" then
		if isPet then
			texture = PET_ATTACK_TEXTURE
		else
			texture = GetSpellTexture(6603)
		end
	elseif iconType == "range" then
		texture = GetSpellTexture(75)
	elseif iconType == "env" then
		texture = envTexture[spellID] or "ability_creature_cursed_05"
		texture = "Interface\\Icons\\"..texture
	end

	return texture
end

local function formatNumber(self, amount)
	local element = self.FloatingCombatFeedback

	if element.abbreviateNumbers then
		return B.Numb(amount)
	else
		return BreakUpLargeNumbers(amount)
	end
end

local function Update(self, event)
	local element = self.FloatingCombatFeedback
	local multiplier = 1
	local text, color, texture, critMark
	local unit = self.unit

	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, eventType, _, sourceGUID, _, sourceFlags, _, destGUID, _, _, _, spellID, _, school = CombatLogGetCurrentEventInfo()
		local isPlayer = UnitGUID("player") == sourceGUID
		local atTarget = UnitGUID("target") == destGUID
		local atPlayer = UnitGUID("player") == destGUID
		local isVehicle = element.showPets and sourceFlags == DB.GuardianFlags
		local isPet = element.showPets and sourceFlags == DB.MyPetFlags

		if (unit == "target" and (isPlayer or isPet or isVehicle) and atTarget) or (unit == "player" and atPlayer) then
			local value = eventFilter[eventType]
			if not value then return end

			if value.suffix == "DAMAGE" then
				if value.autoAttack and not element.showAutoAttack then return end
				if value.isPeriod and not element.showHots then return end

				local amount, _, _, _, _, _, critical, _, crushing = select(value.index, CombatLogGetCurrentEventInfo())
				texture = getFloatingIconTexture(value.iconType, spellID, isPet)
				text = "-"..formatNumber(self, amount)

				if critical or crushing then
					multiplier = 1.25
					critMark = true
				end
			elseif value.suffix == "HEAL" then
				if value.isPeriod and not element.showHots then return end

				local amount, overhealing, _, critical = select(value.index, CombatLogGetCurrentEventInfo())
				texture = getFloatingIconTexture(value.iconType, spellID)
				local overhealText = ""
				if overhealing > 0 then
					amount = amount - overhealing
					overhealText = " ("..formatNumber(self, overhealing)..")"
				end
				if amount == 0 and not element.showOverHealing then return end
				text = "+"..formatNumber(self, amount)..overhealText

				if critical then
					multiplier = 1.25
					critMark = true
				end
			elseif value.suffix == "MISS" then
				local missType = select(value.index, CombatLogGetCurrentEventInfo())
				texture = getFloatingIconTexture(value.iconType, spellID, isPet)
				text = _G["COMBAT_TEXT_"..missType]
			elseif value.suffix == "ENVIRONMENT" then
				local envType, amount = select(value.index, CombatLogGetCurrentEventInfo())
				texture = getFloatingIconTexture(value.iconType, envType)
				text = "-"..formatNumber(self, amount)
			end

			color = schoolColors[school] or schoolColors[0]
		end
	elseif event == "PLAYER_REGEN_DISABLED" then
		texture = ""
		text = _G.ENTERING_COMBAT
		color = colors.WOUND
		multiplier = 1.25
	elseif event == "PLAYER_REGEN_ENABLED" then
		texture = ""
		text = _G.LEAVING_COMBAT
		color = colors.HEAL
		multiplier = 1.25
	end

	if text and texture then
		local string = getAvailableString(element)

		string:SetFont(DB.Font[1], element.fontHeight * multiplier, DB.Font[3])
		string:SetFormattedText("|T%s:18:18:-2:0:64:64:5:59:5:59|t%s", texture, (critMark and "*" or "")..text)
		string:SetTextColor(color.r, color.g, color.b)
		string.elapsed = 0
		string.scrollHeight = element.scrollHeight
		string.scrollTime = element.scrollTime
		string.xDirection = element.xDirection
		string.yDirection = element.yDirection
		string.x = element.xOffset * string.xDirection
		string.y = element.yOffset * string.yDirection
		string:SetPoint("CENTER", element, "CENTER", string.x, string.y)
		string:SetAlpha(1)
		string:Show()

		tinsert(element.FeedbackToAnimate, string)

		element.xDirection = element.xDirection * -1

		if not element:GetScript("OnUpdate") then
			element.Scroll = element.mode == "Fountain" and fountainScroll or standardScroll

			element:SetScript("OnUpdate", onUpdate)
		end
	end
end

local function Path(self, ...)
	return (self.FloatingCombatFeedback.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.FloatingCombatFeedback

	if not element then return end

	element.__owner = self
	element.__max = #element
	element.xDirection = 1
	element.scrollHeight = 160
	element.scrollTime = element.scrollTime or 2
	element.fadeout = element.scrollTime / 3
	element.yDirection = element.yDirection or 1
	element.fontHeight = element.fontHeight or 18
	element.abbreviateNumbers = element.abbreviateNumbers
	element.ForceUpdate = ForceUpdate
	element.FeedbackToAnimate = {}

	if element.mode == "Fountain" then
		element.Scroll = fountainScroll
		element.xOffset = element.xOffset or 6
		element.yOffset = element.yOffset or 8
	else
		element.Scroll = standardScroll
		element.xOffset = element.xOffset or 30
		element.yOffset = element.yOffset or 8
	end

	for i = 1, element.__max do
		element[i]:Hide()
	end

	element:HookScript("OnShow", onShow)

	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Path)
	if unit == "player" then
		self:RegisterEvent("PLAYER_REGEN_DISABLED", Path)
		self:RegisterEvent("PLAYER_REGEN_ENABLED", Path)
	end

	return true
end

local function Disable(self)
	local element = self.FloatingCombatFeedback

	if element then
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Path)
		self:UnregisterEvent("PLAYER_REGEN_DISABLED", Path)
		self:UnregisterEvent("PLAYER_REGEN_ENABLED", Path)
	end
end

oUF:AddElement("FloatingCombatFeedback", Path, Enable, Disable)