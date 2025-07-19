-----------------------------------------------
-- oUF_FloatingCombatFeedback, by lightspark
-- NDui MOD
-----------------------------------------------
local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF
assert(oUF, "oUF FloatingCombatFeedback was unable to locate oUF install")

local _G = getfenv(0)
local select, tremove, tinsert, wipe = _G.select, _G.table.remove, _G.table.insert, _G.table.wipe
local m_cos, m_sin, m_pi, m_random = _G.math.cos, _G.math.sin, _G.math.pi, _G.math.random

local UnitGUID = _G.UnitGUID
local GetSpellTexture = _G.C_Spell.GetSpellTexture
local BreakUpLargeNumbers = _G.BreakUpLargeNumbers
local ENTERING_COMBAT = _G.ENTERING_COMBAT
local LEAVING_COMBAT = _G.LEAVING_COMBAT

-- 基础属性定义
local SCHOOL_NONE     = 0x00 -- 0x00 or 0 (灰色)
local SCHOOL_PHYSICAL = 0x01 -- 0x01 or 1 (黄色)
local SCHOOL_HOLY     = 0x02 -- 0x02 or 2 (浅黄色/金色)
local SCHOOL_FIRE     = 0x04 -- 0x04 or 4 (橙色)
local SCHOOL_NATURE   = 0x08 -- 0x08 or 8 (浅绿色)
local SCHOOL_FROST    = 0x10 -- 0x10 or 16 (浅蓝色/青色)
local SCHOOL_SHADOW   = 0x20 -- 0x20 or 32 (紫色)
local SCHOOL_ARCANE   = 0x40 -- 0x40 or 64 (粉色/洋红色)

-- 混合属性的定义（按位或组合）
local SCHOOL_MASK_HOLYFIRE    = SCHOOL_HOLY + SCHOOL_FIRE -- 0x06 or 6
local SCHOOL_MASK_HOLYSTORM   = SCHOOL_HOLY + SCHOOL_NATURE -- 0x0A or 10
local SCHOOL_MASK_FIRESTORM   = SCHOOL_FIRE + SCHOOL_NATURE -- 0x0C or 12
local SCHOOL_MASK_ELEMENTAL   = SCHOOL_FIRE + SCHOOL_NATURE + SCHOOL_FROST -- 0x1C or 28
local SCHOOL_MASK_HOLYFROST   = SCHOOL_HOLY + SCHOOL_FROST -- 0x12 or 18
local SCHOOL_MASK_FROSTFIRE   = SCHOOL_FROST + SCHOOL_FIRE -- 0x14 or 20
local SCHOOL_MASK_FROSTSTORM  = SCHOOL_FROST + SCHOOL_NATURE -- 0x18 or 24
local SCHOOL_MASK_TWILIGHT    = SCHOOL_SHADOW + SCHOOL_HOLY -- 0x22 or 34
local SCHOOL_MASK_SHADOWFLAME = SCHOOL_SHADOW + SCHOOL_FIRE -- 0x24 or 36
local SCHOOL_MASK_SHADOWSTORM = SCHOOL_SHADOW + SCHOOL_NATURE -- 0x28 or 40
local SCHOOL_MASK_SHADOWFROST = SCHOOL_SHADOW + SCHOOL_FROST -- 0x30 or 48
local SCHOOL_MASK_CHROMATIC   = SCHOOL_PHYSICAL + SCHOOL_HOLY + SCHOOL_FIRE + SCHOOL_NATURE + SCHOOL_FROST + SCHOOL_SHADOW -- 0x3E or 62
local SCHOOL_MASK_DIVINE      = SCHOOL_ARCANE + SCHOOL_HOLY -- 0x42 or 66
local SCHOOL_MASK_SPELLFIRE   = SCHOOL_ARCANE + SCHOOL_FIRE -- 0x44 or 68
local SCHOOL_MASK_SPELLSTORM  = SCHOOL_ARCANE + SCHOOL_NATURE -- 0x48 or 72
local SCHOOL_MASK_SPELLFROST  = SCHOOL_ARCANE + SCHOOL_FROST -- 0x50 or 80
local SCHOOL_MASK_SPELLSHADOW = SCHOOL_ARCANE + SCHOOL_SHADOW -- 0x60 or 96
local SCHOOL_MASK_COSMIC      = SCHOOL_HOLY + SCHOOL_SHADOW + SCHOOL_ARCANE -- 0x6A or 106
local SCHOOL_MASK_CHAOS       = SCHOOL_FIRE + SCHOOL_NATURE + SCHOOL_FROST + SCHOOL_SHADOW + SCHOOL_ARCANE -- 0x7C or 124
local SCHOOL_MASK_MAGICAL     = SCHOOL_HOLY + SCHOOL_FIRE + SCHOOL_NATURE + SCHOOL_FROST + SCHOOL_SHADOW + SCHOOL_ARCANE -- 0x7E or 126
local SCHOOL_MASK_ALL         = SCHOOL_PHYSICAL + SCHOOL_HOLY + SCHOOL_FIRE + SCHOOL_NATURE + SCHOOL_FROST + SCHOOL_SHADOW + SCHOOL_ARCANE -- 0x7F or 127

local function clamp(v)
	if v > 1 then
		return 1
	elseif v < 0 then
		return 0
	end

	return v
end

local colors = {
	COMBAT_IN  = {r = 1, g = 0, b = 0},
	COMBAT_OUT = {r = 0, g = 1, b = 0},
}

local schoolColors = {
	-- 基础属性颜色
	[SCHOOL_NONE]             = {r = 0.50, g = 0.50, b = 0.50}, -- 0x00 or 0 (灰色)
	[SCHOOL_PHYSICAL]         = {r = 1.00, g = 1.00, b = 0.00}, -- 0x01 or 1 (黄色)
	[SCHOOL_HOLY]             = {r = 1.00, g = 1.00, b = 0.50}, -- 0x02 or 2 (浅黄色/金色)
	[SCHOOL_FIRE]             = {r = 1.00, g = 0.50, b = 0.00}, -- 0x04 or 4 (橙色)
	[SCHOOL_NATURE]           = {r = 0.25, g = 1.00, b = 0.25}, -- 0x08 or 8 (浅绿色)
	[SCHOOL_FROST]            = {r = 0.50, g = 1.00, b = 1.00}, -- 0x10 or 16 (浅蓝色/青色)
	[SCHOOL_SHADOW]           = {r = 0.50, g = 0.50, b = 1.00}, -- 0x20 or 32 (紫色)
	[SCHOOL_ARCANE]           = {r = 1.00, g = 0.50, b = 1.00}, -- 0x40 or 64 (粉色/洋红色)

	-- 混合属性颜色（平均值）
	[SCHOOL_MASK_HOLYFIRE]    = { r = 1.00, g = 0.75, b = 0.25 }, -- 0x06 or 6 (HOLY + FIRE)
	[SCHOOL_MASK_HOLYSTORM]   = { r = 0.63, g = 1.00, b = 0.38 }, -- 0x0A or 10 (HOLY + NATURE)
	[SCHOOL_MASK_FIRESTORM]   = { r = 0.63, g = 0.75, b = 0.13 }, -- 0x0C or 12 (FIRE + NATURE)
	[SCHOOL_MASK_HOLYFROST]   = { r = 0.75, g = 1.00, b = 0.75 }, -- 0x12 or 18 (HOLY + FROST)
	[SCHOOL_MASK_FROSTFIRE]   = { r = 0.75, g = 0.75, b = 0.50 }, -- 0x14 or 20 (FROST + FIRE)
	[SCHOOL_MASK_FROSTSTORM]  = { r = 0.38, g = 1.00, b = 0.63 }, -- 0x18 or 24 (FROST + NATURE)
	[SCHOOL_MASK_ELEMENTAL]   = { r = 0.58, g = 0.83, b = 0.42 }, -- 0x1C or 28 (FIRE + NATURE + FROST)
	[SCHOOL_MASK_TWILIGHT]    = { r = 0.75, g = 0.75, b = 0.75 }, -- 0x22 or 34 (SHADOW + HOLY)
	[SCHOOL_MASK_SHADOWFLAME] = { r = 0.75, g = 0.50, b = 0.50 }, -- 0x24 or 36 (SHADOW + FIRE)
	[SCHOOL_MASK_SHADOWSTORM] = { r = 0.38, g = 0.75, b = 0.63 }, -- 0x28 or 40 (SHADOW + NATURE)
	[SCHOOL_MASK_SHADOWFROST] = { r = 0.50, g = 0.75, b = 1.00 }, -- 0x30 or 48 (SHADOW + FROST)
	[SCHOOL_MASK_CHROMATIC]   = { r = 0.71, g = 0.83, b = 0.46 }, -- 0x3E or 62 (PHYSICAL + HOLY + FIRE + NATURE + FROST + SHADOW)
	[SCHOOL_MASK_DIVINE]      = { r = 1.00, g = 0.75, b = 0.75 }, -- 0x42 or 66 (ARCANE + HOLY)
	[SCHOOL_MASK_SPELLFIRE]   = { r = 1.00, g = 0.50, b = 0.50 }, -- 0x44 or 68 (ARCANE + FIRE)
	[SCHOOL_MASK_SPELLSTORM]  = { r = 0.63, g = 0.75, b = 0.63 }, -- 0x48 or 72 (ARCANE + NATURE)
	[SCHOOL_MASK_SPELLFROST]  = { r = 0.75, g = 0.75, b = 1.00 }, -- 0x50 or 80 (ARCANE + FROST)
	[SCHOOL_MASK_SPELLSHADOW] = { r = 0.75, g = 0.50, b = 1.00 }, -- 0x60 or 96 (ARCANE + SHADOW)
	[SCHOOL_MASK_COSMIC]      = { r = 0.83, g = 0.67, b = 0.83 }, -- 0x6A or 106 (HOLY + SHADOW + ARCANE)
	[SCHOOL_MASK_CHAOS]       = { r = 0.65, g = 0.70, b = 0.65 }, -- 0x7C or 124 (FIRE + NATURE + FROST + SHADOW + ARCANE)
	[SCHOOL_MASK_MAGICAL]     = { r = 0.71, g = 0.75, b = 0.63 }, -- 0x7E or 126 (HOLY + FIRE + NATURE + FROST + SHADOW + ARCANE)
	[SCHOOL_MASK_ALL]         = { r = 1.00, g = 1.00, b = 1.00 }, -- 0x7F or 127 (ALL)
}

local function removeString(self, i, string)
	tremove(self.FeedbackToAnimate, i)
	string:SetText("")
	string:SetAlpha(0)
	string:Hide()

	return string
end

local function getAvailableString(self)
	for i = 1, #self do
		if not self[i]:IsShown() then
			return self[i]
		end
	end

	return removeString(self, 1, self.FeedbackToAnimate[1])
end

local animations = {
	["fountain"] = function(self)
		return self.x + self.xDirection * self.radius * (1 - m_cos(m_pi / 2 * self.progress)),
			self.y + self.yDirection * self.radius * m_sin(m_pi / 2 * self.progress)
	end,
	["vertical"] = function(self)
		return self.x, self.y + self.yDirection * self.radius * self.progress
	end,
	["horizontal"] = function(self)
		return self.x + self.xDirection * self.radius * self.progress, self.y
	end,
	["diagonal"] = function(self)
		return self.x + self.xDirection * self.radius * self.progress,
			self.y + self.yDirection * self.radius * self.progress
	end,
	["static"] = function(self)
		return self.x, self.y
	end,
	["random"] = function(self)
		if self.elapsed == 0 then
			self.x, self.y = m_random(-self.radius * 0.66, self.radius * 0.66), m_random(-self.radius * 0.66, self.radius * 0.66)
		end

		return self.x, self.y
	end,
}

local xOffsetsByAnimation = {
	["diagonal"  ] = 24,
	["fountain"  ] = 24,
	["horizontal"] = 8,
	["random"    ] = 0,
	["static"    ] = 0,
	["vertical"  ] = 50,
}

local yOffsetsByAnimation = {
	["diagonal"  ] = 8,
	["fountain"  ] = 8,
	["horizontal"] = 8,
	["random"    ] = 0,
	["static"    ] = 0,
	["vertical"  ] = 8,
}

local function onUpdate(self, elapsed)
	for index, string in next, self.FeedbackToAnimate do
		if string.elapsed >= self.scrollTime then
			removeString(self, index, string)
		else
			string.progress = string.elapsed / self.scrollTime
			string:SetPoint("CENTER", self, "CENTER", string:GetXY())

			string.elapsed = string.elapsed + elapsed
			string:SetAlpha(clamp(1 - (string.elapsed - self.fadeTime) / (self.scrollTime - self.fadeTime)))
		end
	end

	if #self.FeedbackToAnimate == 0 then
		self:SetScript("OnUpdate", nil)
	end
end

local function flush(self)
	wipe(self.FeedbackToAnimate)

	for i = 1, #self do
		self[i]:SetText("")
		self[i]:SetAlpha(0)
		self[i]:Hide()
	end
end

local eventFilter = {
	["SWING_DAMAGE"] = {suffix = "DAMAGE", index = 10, iconType = "swing", autoAttack = true},
	["RANGE_DAMAGE"] = {suffix = "DAMAGE", index = 13, iconType = "range", autoAttack = true},
	["SPELL_DAMAGE"] = {suffix = "DAMAGE", index = 13, iconType = "spell"},
	["SPELL_PERIODIC_DAMAGE"] = {suffix = "DAMAGE", index = 13, iconType = "spell", isPeriod = true},
	["SPELL_BUILDING_DAMAGE"] = {suffix = "DAMAGE", index = 13, iconType = "spell"},

	["SPELL_HEAL"] = {suffix = "HEAL", index = 13, iconType = "spell"},
	["SPELL_PERIODIC_HEAL"] = {suffix = "HEAL", index = 13, iconType = "spell", isPeriod = true},
	["SPELL_BUILDING_HEAL"] = {suffix = "HEAL", index = 13, iconType = "spell"},

	["SWING_MISSED"] = {suffix = "MISS", index = 10, iconType = "swing", autoAttack = true},
	["RANGE_MISSED"] = {suffix = "MISS", index = 13, iconType = "range", autoAttack = true},
	["SPELL_MISSED"] = {suffix = "MISS", index = 13, iconType = "spell"},
	["SPELL_PERIODIC_MISSED"] = {suffix = "MISS", index = 13, iconType = "spell", isPeriod = true},

	["ENVIRONMENTAL_DAMAGE"] = {suffix = "ENVIRONMENT", index = 10, iconType = "env"},
}

local envTexture = {
	["Drowning"] = "spell_shadow_demonbreath",
	["Falling"] = "ability_rogue_quickrecovery",
	["Fatigue"] = "ability_creature_cursed_05",
	["Fire"] = "spell_fire_fire",
	["Lava"] = "ability_rhyolith_lavapool",
	["Slime"] = "inv_misc_slime_02",
}

local iconCache = {}
local function getTexture(spellID)
	if spellID and not iconCache[spellID] then
		local texture = GetSpellTexture(spellID)
		iconCache[spellID] = texture
	end
	return iconCache[spellID]
end

local function getFloatingIconTexture(iconType, spellID, isPet)
	local texture
	if iconType == "spell" then
		texture = getTexture(spellID)
	elseif iconType == "swing" then
		if isPet then
			texture = 132152
		else
			texture = 132147
		end
	elseif iconType == "range" then
		texture = 132369
	elseif iconType == "env" then
		texture = envTexture[spellID] or "trade_engineering"
		texture = "Interface\\Icons\\"..texture
	end

	return texture
end

local missCache = {}
local function getMissText(missType)
	if missType and not missCache[missType] then
		missCache[missType] = _G["COMBAT_TEXT_"..missType]
	end
	return missCache[missType]
end

local function formatNumber(self, amount)
	local element = self.FloatingCombatFeedback

	if element.abbreviateNumbers then
		return B.Numb(amount)
	else
		return BreakUpLargeNumbers(amount)
	end
end

local playerGUID = UnitGUID("player")

local function Update(self, event, ...)
	local element = self.FloatingCombatFeedback
	local unit = self.unit

	local unitGUID = UnitGUID(unit)
	if unitGUID ~= element.unitGUID then
		flush(element)
		element.unitGUID = unitGUID
	end
	local multiplier = 1
	local text, color, texture, critMark

	if eventFilter[event] then
		local _, sourceGUID, _, sourceFlags, _, destGUID, _, _, _, spellID, _, school = ...
		local isPlayer = playerGUID == sourceGUID
		local isRightUnit = element.unitGUID == destGUID
		local isPet = C.db["UFs"]["PetCombatText"] and DB:IsMyPet(sourceFlags)

		if isRightUnit and (unit == "target" and (isPlayer or isPet) or unit == "player") then
			local value = eventFilter[event]
			if not value then return end

			if value.suffix == "DAMAGE" then
				if value.autoAttack and not C.db["UFs"]["AutoAttack"] then return end
				if value.isPeriod and not C.db["UFs"]["HotsDots"] then return end

				local amount, _, _, _, _, _, critical, _, crushing = select(value.index, ...)
				texture = getFloatingIconTexture(value.iconType, spellID, (isPet and not isPlayer))
				text = "-"..formatNumber(self, amount)

				if critical or crushing then
					multiplier = 1.25
					critMark = true
				end
			elseif value.suffix == "HEAL" then
				if value.isPeriod and not C.db["UFs"]["HotsDots"] then return end

				local amount, overhealing, _, critical = select(value.index, ...)
				texture = getFloatingIconTexture(value.iconType, spellID)
				local overhealText = ""
				if overhealing > 0 then
					amount = amount - overhealing
					overhealText = " ("..formatNumber(self, overhealing)..")"
				end
				if amount == 0 and not C.db["UFs"]["FCTOverHealing"] then return end
				text = "+"..formatNumber(self, amount)..overhealText

				if critical then
					multiplier = 1.25
					critMark = true
				end
			elseif value.suffix == "MISS" then
				local missType = select(value.index, ...)
				texture = getFloatingIconTexture(value.iconType, spellID, isPet)
				text = getMissText(missType)
			elseif value.suffix == "ENVIRONMENT" then
				local envType, amount = select(value.index, ...)
				texture = getFloatingIconTexture(value.iconType, envType)
				text = "-"..formatNumber(self, amount)
			end

			color = schoolColors[school] or schoolColors[0]
		end
	elseif event == "PLAYER_REGEN_DISABLED" then
		texture = ""
		text = ENTERING_COMBAT
		color = colors.COMBAT_IN
		multiplier = 1.25
		critMark = true
	elseif event == "PLAYER_REGEN_ENABLED" then
		texture = ""
		text = LEAVING_COMBAT
		color = colors.COMBAT_OUT
		multiplier = 1.25
		critMark = true
	end

	if text and texture then
		local animation = element.defaultMode
		if C.db["UFs"]["ScrollingCT"] then
			element.Scrolling:AddMessage(format(element.format, texture, B.HexRGB(color)..(critMark and "*" or "")..text))
		else
			local string = getAvailableString(element)

			string:SetFont(element.font, C.db["UFs"]["FCTFontSize"] * multiplier, element.fontFlags)
			string:SetFormattedText(element.format, texture, (critMark and "*" or "")..text)
			string:SetTextColor(color.r, color.g, color.b)
			string.elapsed = 0
			string.GetXY = animations[animation]
			string.radius = element.radius
			string.scrollTime = element.scrollTime
			string.xDirection = element.xDirection
			string.yDirection = element.yDirection
			string.x = element.xDirection * xOffsetsByAnimation[animation] * (critMark and -1 or 1)
			string.y = element.yDirection * yOffsetsByAnimation[animation]
			string:SetPoint("CENTER", element, "CENTER", string.x, string.y)
			string:SetAlpha(0)
			string:Show()

			tinsert(element.FeedbackToAnimate, string)

			if not element:GetScript("OnUpdate") then
				element:SetScript("OnUpdate", onUpdate)
			end
		end
	end
end

local function Path(self, ...)
	return (self.FloatingCombatFeedback.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.FloatingCombatFeedback
	if not element then return end

	element.__owner = self
	element.ForceUpdate = ForceUpdate
	element.defaultMode = "vertical"
	element.format = "|T%s:18:18:-2:0:64:64:5:59:5:59|t%s"
	element.xDirection = 1
	element.yDirection = element.yDirection or 1
	element.scrollTime = element.scrollTime or 2
	element.radius = element.radius or 100
	element.fadeTime = element.scrollTime / 3
	element.fontHeight = element.fontHeight or 18
	element.abbreviateNumbers = element.abbreviateNumbers
	element.FeedbackToAnimate = {}

	for i = 1, #element do
		element[i]:SetFont(element.font, element.fontHeight, element.fontFlags)
		element[i]:Hide()
	end

	element:SetScript("OnHide", flush)
	element:SetScript("OnShow", flush)

	for event in pairs(eventFilter) do
		self:RegisterCombatEvent(event, Path)
	end

	if unit == "player" then
		element.xDirection = -1
		self:RegisterEvent("PLAYER_REGEN_DISABLED", Path, true)
		self:RegisterEvent("PLAYER_REGEN_ENABLED", Path, true)
	end

	return true
end

local function Disable(self)
	local element = self.FloatingCombatFeedback

	if element then
		flush(element)
		element:SetScript("OnHide", nil)
		element:SetScript("OnShow", nil)
		element:SetScript("OnUpdate", nil)

		for event in pairs(eventFilter) do
			self:UnregisterCombatEvent(event, Path)
		end
		self:UnregisterEvent("PLAYER_REGEN_DISABLED", Path)
		self:UnregisterEvent("PLAYER_REGEN_ENABLED", Path)
	end
end

oUF:AddElement("FloatingCombatFeedback", Path, Enable, Disable)