local _, ns = ...
local B, C, L, DB = unpack(ns)
local UF = B:GetModule("UnitFrames")

local unpack, min, format, strupper = unpack, min, format, strupper
local GetTime, UnitName = GetTime, UnitName
local UnitIsUnit, UnitExists = UnitIsUnit, UnitExists

local CastbarCompleteColor = {.1, .8, 0}
local CastbarFailColor = {1, .1, 0}
local NotInterruptColor = {r=1, g=.5, b=.5}

local ticks = {}
local channelingTicks = {
	--First Aid
	[23567] = 8, --Warsong Gulch Runecloth Bandage
	[23696] = 8, --Alterac Heavy Runecloth Bandage
	[24414] = 8, --Arathi Basin Runecloth Bandage
	[18610] = 8, --Heavy Runecloth Bandage
	[18608] = 8, --Runecloth Bandage
	[10839] = 8, --Heavy Mageweave Bandage
	[10838] = 8, --Mageweave Bandage
	[7927] = 8, --Heavy Silk Bandage
	[7926] = 8, --Silk Bandage
	[3268] = 7, --Heavy Wool Bandage
	[3267] = 7, --Wool Bandage
	[1159] = 6, --Heavy Linen Bandage
	[746] = 6, --Linen Bandage
	-- Warlock
	[1120] = 5, -- Drain Soul(Rank 1)
	[8288] = 5, -- Drain Soul(Rank 2)
	[8289] = 5, -- Drain Soul(Rank 3)
	[11675] = 5, -- Drain Soul(Rank 4)
	[27217] = 5, -- Drain Soul(Rank 5)
	[755] = 10, -- Health Funnel(Rank 1)
	[3698] = 10, -- Health Funnel(Rank 2)
	[3699] = 10, -- Health Funnel(Rank 3)
	[3700] = 10, -- Health Funnel(Rank 4)
	[11693] = 10, -- Health Funnel(Rank 5)
	[11694] = 10, -- Health Funnel(Rank 6)
	[11695] = 10, -- Health Funnel(Rank 7)
	[27259] = 10, -- Health Funnel(Rank 8)
	[689] = 5, -- Drain Life(Rank 1)
	[699] = 5, -- Drain Life(Rank 2)
	[709] = 5, -- Drain Life(Rank 3)
	[7651] = 5, -- Drain Life(Rank 4)
	[11699] = 5, -- Drain Life(Rank 5)
	[11700] = 5, -- Drain Life(Rank 6)
	[27219] = 5, -- Drain Life(Rank 7)
	[27220] = 5, -- Drain Life(Rank 8)
	[5740] =  4, --Rain of Fire(Rank 1)
	[6219] =  4, --Rain of Fire(Rank 2)
	[11677] =  4, --Rain of Fire(Rank 3)
	[11678] =  4, --Rain of Fire(Rank 4)
	[27212] =  4, --Rain of Fire(Rank 5)
	[1949] = 15, --Hellfire(Rank 1)
	[11683] = 15, --Hellfire(Rank 2)
	[11684] = 15, --Hellfire(Rank 3)
	[27213] = 15, --Hellfire(Rank 4)
	[5138] = 5, --Drain Mana(Rank 1)
	[6226] = 5, --Drain Mana(Rank 2)
	[11703] = 5, --Drain Mana(Rank 3)
	[11704] = 5, --Drain Mana(Rank 4)
	[27221] = 5, --Drain Mana(Rank 5)
	[30908] = 5, --Drain Mana(Rank 6)
	-- Priest
	[15407] = 3, -- Mind Flay(Rank 1)
	[17311] = 3, -- Mind Flay(Rank 2)
	[17312] = 3, -- Mind Flay(Rank 3)
	[17313] = 3, -- Mind Flay(Rank 4)
	[17314] = 3, -- Mind Flay(Rank 5)
	[18807] = 3, -- Mind Flay(Rank 6)
	[25387] = 3, -- Mind Flay(Rank 7)
	-- Mage
	[10] = 8, --Blizzard(Rank 1)
	[6141] = 8, --Blizzard(Rank 2)
	[8427] = 8, --Blizzard(Rank 3)
	[10185] = 8, --Blizzard(Rank 4)
	[10186] = 8, --Blizzard(Rank 5)
	[10187] = 8, --Blizzard(Rank 6)
	[27085] = 8, --Blizzard(Rank 7)
	[5143] = 3, -- Arcane Missiles(Rank 1)
	[5144] = 4, -- Arcane Missiles(Rank 2)
	[5145] = 5, -- Arcane Missiles(Rank 3)
	[8416] = 5, -- Arcane Missiles(Rank 4)
	[8417] = 5, -- Arcane Missiles(Rank 5)
	[10211] = 5, -- Arcane Missiles(Rank 6)
	[10212] = 5, -- Arcane Missiles(Rank 7)
	[25345] = 5, -- Arcane Missiles(Rank 8)
	[27075] = 5, -- Arcane Missiles(Rank 9)
	[38699] = 5, -- Arcane Missiles(Rank 10)
	[12051] = 4, -- Evocation
	--Druid
	[740] = 5, -- Tranquility(Rank 1)
	[8918] = 5, --Tranquility(Rank 2)
	[9862] = 5, --Tranquility(Rank 3)
	[9863] = 5, --Tranquility(Rank 4)
	[26983] = 5, --Tranquility(Rank 5)
	[16914] = 10, --Hurricane(Rank 1)
	[17401] = 10, --Hurricane(Rank 2)
	[17402] = 10, --Hurricane(Rank 3)
	[27012] = 10, --Hurricane(Rank 4)
	--Hunter
	[1510] = 6, --Volley(Rank 1)
	[14294] = 6, --Volley(Rank 2)
	[14295] = 6, --Volley(Rank 3)
	[27022] = 6, --Volley(Rank 4)
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
	if not UnitIsUnit(unit, "player") and self.notInterruptible then
		--color = C.db["UFs"]["NotInterruptColor"]
		color = NotInterruptColor
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