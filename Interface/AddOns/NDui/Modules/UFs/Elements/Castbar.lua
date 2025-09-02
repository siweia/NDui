local _, ns = ...
local B, C, L, DB = unpack(ns)
local UF = B:GetModule("UnitFrames")

local unpack, min, format, strupper = unpack, min, format, strupper
local GetTime, UnitName = GetTime, UnitName
local UnitIsUnit, UnitExists = UnitIsUnit, UnitExists

local CastbarCompleteColor = {.1, .8, 0}
local CastbarFailColor = {1, .1, 0}

local ticks = {}
local channelingTicks = {
	-- Warlock
	[1120]		= 6, -- Drain Soul
	[689]		= 6, -- Drain Life
	[5740]		= 6, -- Rain of Fire
	[755]		= 6, -- Health Funnel
	[1949]		= 14, -- Hellfire
	[103103] 	= 4, -- Malefic Grasp
	-- Druid
	[44203]		= 4, -- Tranquility
	[16914]		= 10, -- Hurricane
	-- Priest
	[15407]		= 3, -- Mind Flay
	[129197] 	= 3, -- Mind Flay (Insanity)
	[48045]		= 5, -- Mind Sear
	[47758]		= 3, -- Penance
	[64901]		= 4, -- Hymn of Hope
	[64843]		= 4, -- Divine Hymn
	-- Mage
	[5143]		= 5, -- Arcane Missiles
	[10]		= 8, -- Blizzard
	[12051]		= 4, -- Evocation
	-- Death Knight
	[42650]		= 8, -- Army of the Dead
	-- First Aid
	[102695] 	= 8, -- Heavy Windwool Bandage
    [102694] 	= 8, -- Windwool Bandage
    [74555] 	= 8, -- Dense Embersilk Bandage
    [74554] 	= 8, -- Heavy Embersilk Bandage
    [74553]		= 8, -- Embersilk Bandage
	[45544]		= 8, -- Heavy Frostweave Bandage
	[45543]		= 8, -- Frostweave Bandage
	[27031]		= 8, -- Heavy Netherweave Bandage
	[27030]		= 8, -- Netherweave Bandage
	[23567]		= 8, -- Warsong Gulch Runecloth Bandage
	[23696]		= 8, -- Alterac Heavy Runecloth Bandage
	[24414]		= 8, -- Arathi Basin Runecloth Bandage
	[18610]		= 8, -- Heavy Runecloth Bandage
	[18608]		= 8, -- Runecloth Bandage
	[10839]		= 8, -- Heavy Mageweave Bandage
	[10838]		= 8, -- Mageweave Bandage
	[7927]		= 8, -- Heavy Silk Bandage
	[7926]		= 8, -- Silk Bandage
	[3268]		= 7, -- Heavy Wool Bandage
	[3267]		= 7, -- Wool Bandage
	[1159]		= 6, -- Heavy Linen Bandage
	[746]		= 6 -- Linen Bandage
}

function UF:OnCastbarUpdate(elapsed)
	if self.casting or self.channeling then
		local decimal = self.decimal

		local duration = self.casting and (self.duration + elapsed) or (self.duration - elapsed)
		if (self.casting and duration >= self.max) or (self.channeling and duration <= 0) then
			self.casting = nil
			self.channeling = nil
			return
		end

		if self.__owner.unit == "player" then
			if self.delay ~= 0 then
				self.Time:SetFormattedText(decimal.." | |cffff0000"..decimal, duration, self.casting and self.max + self.delay or self.max - self.delay)
			else
				self.Time:SetFormattedText(decimal.." | "..decimal, duration, self.max)
			end
		else
			if duration > 1e4 then
				self.Time:SetText("∞ | ∞")
			else
				self.Time:SetFormattedText(decimal.." | "..decimal, duration, self.casting and self.max + self.delay or self.max - self.delay)
			end
		end
		self.duration = duration
		self:SetValue(duration)
		self.Spark:SetPoint("CENTER", self, "LEFT", (duration / self.max) * self:GetWidth(), 0)
	elseif self.holdTime > 0 then
		self.holdTime = self.holdTime - elapsed
	else
		self.Spark:Hide()
		local alpha = self:GetAlpha() - .02
		if alpha > 0 then
			self:SetAlpha(alpha)
		else
			self.fadeOut = nil
			self:Hide()
		end
	end
end

function UF:OnCastSent()
	local element = self.Castbar
	if not element.SafeZone then return end
	element.__sendTime = GetTime()
end

local function ResetSpellTarget(self)
	if self.spellTarget then
		self.spellTarget:SetText("")
	end
end

local function UpdateSpellTarget(self, unit)
	if not C.db["Nameplate"]["CastTarget"] then return end
	if not self.spellTarget then return end

	local unitTarget = unit and unit.."target"
	if unitTarget and UnitExists(unitTarget) then
		local nameString
		if UnitIsUnit(unitTarget, "player") then
			nameString = format("|cffff0000%s|r", ">"..strupper(YOU).."<")
		else
			nameString = B.HexRGB(B.UnitColor(unitTarget))..UnitName(unitTarget)
		end
		self.spellTarget:SetText(nameString)
	else
		ResetSpellTarget(self) -- when unit loses target
	end
end

local function UpdateCastBarColor(self, unit)
	local color = C.db["UFs"]["CastingColor"]
	if unit == "player" then
		color = C.db["UFs"]["OwnCastColor"]
	elseif not UnitIsUnit(unit, "player") and self.notInterruptible then
		color = C.db["UFs"]["NotInterruptColor"]
	end
	self:SetStatusBarColor(color.r, color.g, color.b)
end

function UF:PostCastStart(unit)
	self:SetAlpha(1)
	self.Spark:Show()
	local safeZone = self.SafeZone
	local lagString = self.LagString

	if unit == "vehicle" then
		if safeZone then
			safeZone:Hide()
			lagString:Hide()
		end
	elseif unit == "player" then
		if safeZone then
			local sendTime = self.__sendTime
			local timeDiff = sendTime and min((GetTime() - sendTime), self.max)
			if timeDiff and timeDiff ~= 0 then
				safeZone:SetWidth(self:GetWidth() * timeDiff / self.max)
				safeZone:Show()
				lagString:SetFormattedText("%d ms", timeDiff * 1000)
				lagString:Show()
			else
				safeZone:Hide()
				lagString:Hide()
			end
			self.__sendTime = nil
		end

		local numTicks = 0
		if self.channeling then
			numTicks = channelingTicks[self.spellID] or 0
		end
		B:CreateAndUpdateBarTicks(self, ticks, numTicks)
	end

	UpdateCastBarColor(self, unit)

	-- Fix for empty icon
	if self.Icon then
		local texture = self.Icon:GetTexture()
		if not texture or texture == 136235 then
			self.Icon:SetTexture(136243)
		end
	end

	if self.__owner.mystyle == "nameplate" then
		-- Major spells
		if C.db["Nameplate"]["CastbarGlow"] and UF.MajorSpells[self.spellID] then
			B.ShowOverlayGlow(self.glowFrame)
		else
			B.HideOverlayGlow(self.glowFrame)
		end

		-- Spell target
		UpdateSpellTarget(self, unit)
	end
end

function UF:PostCastUpdate(unit)
	UpdateSpellTarget(self, unit)
end

function UF:PostUpdateInterruptible(unit)
	UpdateCastBarColor(self, unit)
end

function UF:PostCastStop()
	if not self.fadeOut then
		self:SetStatusBarColor(unpack(CastbarCompleteColor))
		self.fadeOut = true
	end
	self:Show()
	ResetSpellTarget(self)
end

function UF:PostChannelStop()
	self.fadeOut = true
	self:SetValue(0)
	self:Show()
	ResetSpellTarget(self)
end

function UF:PostCastFailed()
	self:SetStatusBarColor(unpack(CastbarFailColor))
	self:SetValue(self.max or 1)
	self.fadeOut = true
	self:Show()
	ResetSpellTarget(self)
end