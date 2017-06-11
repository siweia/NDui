-----------------------------------------------
-- oUF_FloatingCombatFeedback, by lightspark
-- NDui MOD
-----------------------------------------------
local B, C, L, DB = unpack(select(2, ...))
local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF FloatingCombatFeedback was unable to locate oUF install")

local _G = _G
local pairs = pairs
local cos, sin, mmax = cos, sin, math.max
local tremove, tinsert = table.remove, table.insert

local BreakUpLargeNumbers = BreakUpLargeNumbers
local MY_PET_FLAGS = bit.bor(COMBATLOG_OBJECT_AFFILIATION_MINE, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PET)
local MY_VEHICLE_FLAGS = bit.bor(COMBATLOG_OBJECT_AFFILIATION_MINE, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_GUARDIAN)

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

local function RemoveString(self, i, string)
	tremove(self.FeedbackToAnimate, i)
	string:SetText(nil)
	string:SetAlpha(0)
	string:Hide()

	return string
end

local function GetAvailableString(self)
	for i = 1, self.maxStrings do
		if not self[i]:IsShown() then
			return self[i]
		end
	end

	return RemoveString(self, 1, self.FeedbackToAnimate[1])
end

local function FountainScroll(self)
	local x = self.x + self.side * 65 * (1 - cos(90 * self.elapsed / self.scrollTime))
	local y = self.y + self.yDirection * 65 * sin(90 * self.elapsed / self.scrollTime)

	return x, y
end

local function StandardScroll(self)
	local x = self.x
	local y = self.y + self.yDirection * self.scrollHeight * self.elapsed / self.scrollTime

	return x, y
end

local function SetScrolling(self, elapsed)
	local x, y

	for index, string in pairs(self.FeedbackToAnimate) do
		if string.elapsed >= string.scrollTime then
			RemoveString(self, index, string)
		else
			string.elapsed = string.elapsed + elapsed
			x, y = self.scrollFunction(string)

			string:SetPoint("CENTER", self, "CENTER", x, y)

			if (string.elapsed >= self.fadeout) then
				string:SetAlpha(mmax(1 - (string.elapsed - self.fadeout) / (self.scrollTime - self.fadeout), 0))
			end
		end
	end

	if #self.FeedbackToAnimate == 0 then
		self:SetScript("OnUpdate", nil)
	end
end

local function OnShow(self)
	for index, string in pairs(self.FeedbackToAnimate) do
		RemoveString(self, index, string)
	end
end

local eventFilter = {
	["SWING_DAMAGE"] = {suffix = "DAMAGE", index = 12, iconType = "swing"},
	["RANGE_DAMAGE"] = {suffix = "DAMAGE", index = 15, iconType = "range"},
	["SPELL_DAMAGE"] = {suffix = "DAMAGE", index = 15, iconType = "spell"},
	["SPELL_PERIODIC_DAMAGE"] = {suffix = "DAMAGE", index = 15, iconType = "spell", isPeriod = true},

	["SPELL_HEAL"] = {suffix = "HEAL", index = 15, iconType = "spell"},
	["SPELL_PERIODIC_HEAL"] = {suffix = "HEAL", index = 15, iconType = "spell", isPeriod = true},

	["SWING_MISSED"] = {suffix = "MISS", index = 12, iconType = "swing"},
	["RANGE_MISSED"] = {suffix = "MISS", index = 15, iconType = "range"},
	["SPELL_MISSED"] = {suffix = "MISS", index = 15, iconType = "spell"},
}

local function GetFloatingIconTexture(iconType, spellID, isPet)
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
	end
	return texture
end

local function Update(self, event, ...)
	local fcf = self.FloatingCombatFeedback
	local multiplier = 1
	local text, color, texture, critMark
	local unit = self.unit

	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, eventType, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellID, spellName, school = ...
		local isPlayer = UnitGUID("player") == sourceGUID
		local atTarget = UnitGUID("target") == destGUID
		local atPlayer = UnitGUID("player") == destGUID
		local isVehicle = fcf.showPets and sourceFlags == MY_VEHICLE_FLAGS
		local isPet = fcf.showPets and sourceFlags == MY_PET_FLAGS

		if (unit == "target" and (isPlayer or isPet or isVehicle) and atTarget) or (unit == "player" and atPlayer) then
			local value = eventFilter[eventType]
			if not value then return end

			if value.suffix == "DAMAGE" then
				if value.isPeriod and not fcf.showHots then return end

				local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(value.index, ...)
				texture = GetFloatingIconTexture(value.iconType, spellID, isPet)
				text = "-"..(fcf.abbreviateNumbers and B.Numb(amount) or BreakUpLargeNumbers(amount))

				if critical or crushing then
					multiplier = 1.25
					critMark = true
				end
			elseif value.suffix == "HEAL" then
				if value.isPeriod and not fcf.showHots then return end

				local amount, overhealing, absorbed, critical = select(value.index, ...)
				texture = GetFloatingIconTexture(value.iconType, spellID)
				text = "+"..(fcf.abbreviateNumbers and B.Numb(amount) or BreakUpLargeNumbers(amount))

				if critical then
					multiplier = 1.25
					critMark = true
				end
			elseif value.suffix == "MISS" then
				local missType, isOffHand, amountMissed = select(value.index, ...)
				texture = GetFloatingIconTexture(value.iconType, spellID, isPet)
				text = _G["COMBAT_TEXT_"..missType]
			end

			color = schoolColors[school] or schoolColors[0]
		end
	elseif event == "PLAYER_REGEN_DISABLED" then
		texture = ""
		text = _G.ENTERING_COMBAT
		color = colors.WOUND
	elseif event == "PLAYER_REGEN_ENABLED" then
		texture = ""
		text = _G.LEAVING_COMBAT
		color = colors.HEAL
	end

	if text and texture then
		local string = GetAvailableString(fcf)

		string:SetFont(DB.Font[1], fcf.fontHeight * multiplier, DB.Font[3])
		string:SetFormattedText("|T%s:18:18:-2:0:64:64:5:59:5:59|t%s", texture, (critMark and "*" or "")..text)
		string:SetTextColor(color.r, color.g, color.b)
		string.elapsed = 0
		string.scrollHeight = fcf.scrollHeight
		string.scrollTime = fcf.scrollTime
		string.side = fcf.side
		string.yDirection = fcf.yDirection
		string.x = fcf.xOffset * string.side
		string.y = fcf.yOffset * string.yDirection
		string:SetPoint("CENTER", fcf, "CENTER", string.x, string.y)
		string:SetAlpha(1)
		string:Show()

		tinsert(fcf.FeedbackToAnimate, string)

		fcf.side = fcf.side * -1

		if not fcf:GetScript("OnUpdate") then
			fcf:SetScript("OnUpdate", SetScrolling)
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
	local fcf = self.FloatingCombatFeedback

	if not fcf then return end

	fcf.__owner = self
	fcf.maxStrings = #fcf
	fcf.side = 1
	fcf.scrollHeight = 160
	fcf.scrollTime = fcf.scrollTime or 2
	fcf.fadeout = fcf.scrollTime / 3
	fcf.yDirection = fcf.yDirection or 1
	fcf.fontHeight = fcf.fontHeight or 18
	fcf.abbreviateNumbers = fcf.abbreviateNumbers
	fcf.ForceUpdate = ForceUpdate
	fcf.FeedbackToAnimate = {}

	if fcf.mode == "Fountain" then
		fcf.scrollFunction = FountainScroll
		fcf.xOffset = fcf.xOffset or 6
		fcf.yOffset = fcf.yOffset or 8
	else
		fcf.scrollFunction = StandardScroll
		fcf.xOffset = fcf.xOffset or 30
		fcf.yOffset = fcf.yOffset or 8
	end

	for i = 1, fcf.maxStrings do
		fcf[i]:Hide()
	end

	fcf:HookScript("OnShow", OnShow)

	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Path)
	if unit == "player" then
		self:RegisterEvent("PLAYER_REGEN_DISABLED", Path)
		self:RegisterEvent("PLAYER_REGEN_ENABLED", Path)
	end

	return true
end

local function Disable(self)
	local fcf = self.FloatingCombatFeedback

	if fcf then
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Path)
		self:UnregisterEvent("PLAYER_REGEN_DISABLED", Path)
		self:UnregisterEvent("PLAYER_REGEN_ENABLED", Path)
	end
end

oUF:AddElement("FloatingCombatFeedback", Path, Enable, Disable)