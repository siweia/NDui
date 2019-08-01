local _, ns = ...
local B, C, L, DB = unpack(ns)

local unpack, GetTime, IsPlayerSpell = unpack, GetTime, IsPlayerSpell
local UnitChannelInfo, UnitInVehicle, UnitIsUnit = UnitChannelInfo, UnitInVehicle, UnitIsUnit

local function GetSpellName(spellID)
	local name = GetSpellInfo(spellID)
	if not name then
		print("oUF-Plugins-Castbar: ".. spellID.." not found.")
		return 0
	end
	return name
end

local channelingTicks = {
	[GetSpellName(740)] = 4,		-- 宁静
	[GetSpellName(755)] = 3,		-- 生命通道
	[GetSpellName(5143)] = 5, 		-- 奥术飞弹
	[GetSpellName(12051)] = 3, 		-- 唤醒
	[GetSpellName(15407)] = 4,		-- 精神鞭笞
	[GetSpellName(47540)] = 3,		-- 苦修
	[GetSpellName(64843)] = 4,		-- 神圣赞美诗
	[GetSpellName(198590)] = 5,		-- 吸取灵魂
	[GetSpellName(205021)] = 5,		-- 冰霜射线
	[GetSpellName(205065)] = 6,		-- 虚空洪流
	[GetSpellName(234153)] = 5,		-- 吸取生命
	[GetSpellName(291944)] = 6,		-- 再生
}

if DB.MyClass == "PRIEST" then
	local penance = GetSpellName(47540)
	local function updateTicks()
		local numTicks = 3
		if IsPlayerSpell(193134) then numTicks = 4 end	-- Enhanced Mind Flay
		channelingTicks[penance] = numTicks
	end
	B:RegisterEvent("PLAYER_LOGIN", updateTicks)
	B:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", updateTicks)
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

		local duration = self.casting and self.duration + elapsed or self.duration - elapsed
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
				if self.Lag and self.SafeZone and self.SafeZone.timeDiff and self.SafeZone.timeDiff ~= 0 then
					self.Lag:SetFormattedText("%d ms", self.SafeZone.timeDiff * 1000)
				end
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
	element.SafeZone.sendTime = GetTime()
	element.SafeZone.castSent = true
end

function B:PostCastStart(unit)
	self:SetAlpha(1)
	self.Spark:Show()
	self:SetStatusBarColor(unpack(self.casting and self.CastingColor or self.ChannelingColor))

	if unit == "vehicle" or UnitInVehicle("player") then
		if self.SafeZone then self.SafeZone:Hide() end
		if self.Lag then self.Lag:Hide() end
	elseif unit == "player" then
		local safeZone = self.SafeZone
		if not safeZone then return end

		safeZone.timeDiff = 0
		if safeZone.castSent then
			safeZone.timeDiff = GetTime() - safeZone.sendTime
			safeZone.timeDiff = safeZone.timeDiff > self.max and self.max or safeZone.timeDiff
			safeZone:SetWidth(self:GetWidth() * (safeZone.timeDiff + .001) / self.max)
			safeZone:Show()
			safeZone.castSent = false
		end

		local numTicks = 0
		if self.channeling then
			local spellID = UnitChannelInfo(unit)
			numTicks = channelingTicks[spellID] or 0
		end
		updateCastBarTicks(self, numTicks)
	elseif not UnitIsUnit(unit, "player") and self.notInterruptible then
		self:SetStatusBarColor(unpack(self.notInterruptibleColor))
	end

	-- Fix for empty icon
	if self.Icon and not self.Icon:GetTexture() then
		self.Icon:SetTexture(136243)
	end
end

function B:PostUpdateInterruptible(unit)
	if not UnitIsUnit(unit, "player") and self.notInterruptible then
		self:SetStatusBarColor(unpack(self.notInterruptibleColor))
	else
		self:SetStatusBarColor(unpack(self.casting and self.CastingColor or self.ChannelingColor))
	end
end

function B:PostCastStop()
	if not self.fadeOut then
		self:SetStatusBarColor(unpack(self.CompleteColor))
		self.fadeOut = true
	end
	self:SetValue(self.max)
	self:Show()
end

function B:PostChannelStop()
	self.fadeOut = true
	self:SetValue(0)
	self:Show()
end

function B:PostCastFailed()
	self:SetStatusBarColor(unpack(self.FailColor))
	self:SetValue(self.max)
	self.fadeOut = true
	self:Show()
end