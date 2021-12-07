local _, ns = ...
local B, C, L, DB = unpack(ns)
local UF

local unpack, pairs, min, format, strupper = unpack, pairs, min, format, strupper
local GetTime, IsPlayerSpell, UnitName = GetTime, IsPlayerSpell, UnitName
local UnitInVehicle, UnitIsUnit, UnitExists = UnitInVehicle, UnitIsUnit, UnitExists

local CastbarCompleteColor = {.1, .8, 0}
local CastbarFailColor = {1, .1, 0}

local channelingTicks = {
	[740] = 4,		-- 宁静
	[755] = 5,		-- 生命通道
	[5143] = 4, 	-- 奥术飞弹
	[12051] = 6, 	-- 唤醒
	[15407] = 6,	-- 精神鞭笞
	[47757] = 3,	-- 苦修
	[47758] = 3,	-- 苦修
	[48045] = 6,	-- 精神灼烧
	[64843] = 4,	-- 神圣赞美诗
	[120360] = 15,	-- 弹幕射击
	[198013] = 10,	-- 眼棱
	[198590] = 5,	-- 吸取灵魂
	[205021] = 5,	-- 冰霜射线
	[205065] = 6,	-- 虚空洪流
	[206931] = 3,	-- 饮血者
	[212084] = 10,	-- 邪能毁灭
	[234153] = 5,	-- 吸取生命
	[257044] = 7,	-- 急速射击
	[291944] = 6,	-- 再生，赞达拉巨魔
	[314791] = 4,	-- 变易幻能
	[324631] = 8,	-- 血肉铸造，盟约
}

if DB.MyClass == "PRIEST" then
	local function updateTicks()
		local numTicks = 3
		if IsPlayerSpell(193134) then numTicks = 4 end
		channelingTicks[47757] = numTicks
		channelingTicks[47758] = numTicks
	end
	B:RegisterEvent("PLAYER_LOGIN", updateTicks)
	B:RegisterEvent("PLAYER_TALENT_UPDATE", updateTicks)
end

local ticks = {}
local function updateCastBarTicks(bar, numTicks)
	if numTicks and numTicks > 0 then
		local delta = bar:GetWidth() / numTicks
		for i = 1, numTicks do
			if not ticks[i] then
				ticks[i] = bar:CreateTexture(nil, "OVERLAY")
				ticks[i]:SetTexture(DB.normTex)
				ticks[i]:SetVertexColor(0, 0, 0, .7)
				ticks[i]:SetWidth(C.mult)
				ticks[i]:SetHeight(bar:GetHeight())
			end
			ticks[i]:ClearAllPoints()
			ticks[i]:SetPoint("CENTER", bar, "LEFT", delta * i, 0 )
			ticks[i]:Show()
		end
	else
		for _, tick in pairs(ticks) do
			tick:Hide()
		end
	end
end

function B:OnCastbarUpdate(elapsed)
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

function B:OnCastSent()
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

function B:PostCastStart(unit)
	self:SetAlpha(1)
	self.Spark:Show()

	local safeZone = self.SafeZone
	local lagString = self.LagString

	if unit == "vehicle" or UnitInVehicle("player") then
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
		updateCastBarTicks(self, numTicks)
	end

	UpdateCastBarColor(self, unit)

	if self.__owner.mystyle == "nameplate" then
		-- Major spells
		if not UF then UF = B:GetModule("UnitFrames") end

		if C.db["Nameplate"]["CastbarGlow"] and UF.MajorSpells[self.spellID] then
			B.ShowOverlayGlow(self.glowFrame)
		else
			B.HideOverlayGlow(self.glowFrame)
		end

		-- Spell target
		UpdateSpellTarget(self, unit)
	end
end

function B:PostCastUpdate(unit)
	UpdateSpellTarget(self, unit)
end

function B:PostUpdateInterruptible(unit)
	UpdateCastBarColor(self, unit)
end

function B:PostCastStop()
	if not self.fadeOut then
		self:SetStatusBarColor(unpack(CastbarCompleteColor))
		self.fadeOut = true
	end
	self:Show()
	ResetSpellTarget(self)
end

function B:PostCastFailed()
	self:SetStatusBarColor(unpack(CastbarFailColor))
	self:SetValue(self.max)
	self.fadeOut = true
	self:Show()
	ResetSpellTarget(self)
end