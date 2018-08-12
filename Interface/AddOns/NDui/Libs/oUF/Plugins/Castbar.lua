local _, ns = ...
local B, C, L, DB = unpack(ns)

local cast = CreateFrame("Frame")
local channelingTicks = {
	-- warlock
	[GetSpellInfo(755)] = 3,		-- health funnel
	[GetSpellInfo(198590)] = 5,		-- drain soul
	[GetSpellInfo(234153)] = 5,		-- drain life
	-- druid
	[GetSpellInfo(740)] = 4,		-- Tranquility
	-- priest
	[GetSpellInfo(15407)] = 4,		-- mind flay
	[GetSpellInfo(47540)] = 3,		-- penance
	[GetSpellInfo(64843)] = 4,		-- divine hymn
	[GetSpellInfo(205065)] = 6,
	-- mage
	[GetSpellInfo(5143)] = 5, 		-- arcane missiles
	[GetSpellInfo(12051)] = 3, 		-- evocation
	[GetSpellInfo(205021)] = 5,
}

if DB.MyClass == "PRIEST" then
	local penance = GetSpellInfo(47540)
	local function updateTicks()
		local numTicks = 3
		if IsPlayerSpell(193134) then numTicks = 4 end	-- Enhanced Mind Flay
		channelingTicks[penance] = numTicks
	end
	B:RegisterEvent("PLAYER_LOGIN", updateTicks)
	B:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", updateTicks)
end

local ticks = {}
local function setBarTicks(castBar, ticknum)
	if ticknum and ticknum > 0 then
		local delta = castBar:GetWidth() / ticknum
		for k = 1, ticknum do
			if not ticks[k] then
				ticks[k] = castBar:CreateTexture(nil, "OVERLAY")
				ticks[k]:SetTexture(DB.normTex)
				ticks[k]:SetVertexColor(0, 0, 0, .7)
				ticks[k]:SetWidth(1.2)
				ticks[k]:SetHeight(castBar:GetHeight())
			end
			ticks[k]:ClearAllPoints()
			ticks[k]:SetPoint("CENTER", castBar, "LEFT", delta * k, 0 )
			ticks[k]:Show()
		end
	else
		for _, v in pairs(ticks) do
			v:Hide()
		end
	end
end

cast.OnCastbarUpdate = function(self, elapsed)
	if not self.Lag then self.Lag = 0 end
	if GetNetStats() == 0 then return end

	if self.casting or self.channeling then
		local mystyle = self.__owner.mystyle
		local decimal = "%.2f"
		if mystyle == "nameplate" or mystyle == "boss" or mystyle == "arena" then decimal = "%.1f" end

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
				if self.SafeZone and self.SafeZone.timeDiff ~= 0 then self.Lag:SetFormattedText("%d ms", self.SafeZone.timeDiff * 1000) end
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

cast.OnCastSent = function(self)
	if not self.Castbar.SafeZone then return end
	self.Castbar.SafeZone.sendTime = GetTime()
	self.Castbar.SafeZone.castSent = true
end

cast.PostCastStart = function(self, unit)
	self:SetAlpha(1)
	self.Spark:Show()
	self:SetStatusBarColor(unpack(self.casting and self.CastingColor or self.ChannelingColor))

	if unit == "vehicle" then 
		self.SafeZone:Hide()
		self.Lag:Hide()
	elseif unit == "player" then
		if GetNetStats() == 0 then return end
		local sf = self.SafeZone
		if not sf then return end

		sf.timeDiff = 0
		if sf.castSent == true then
			sf.timeDiff = GetTime() - sf.sendTime
			sf.timeDiff = sf.timeDiff > self.max and self.max or sf.timeDiff
			sf:SetWidth(self:GetWidth() * (sf.timeDiff + .001) / self.max)
			sf:Show()
			sf.castSent = false
		end

		self.Lag:SetText("")
		if not UnitInVehicle("player") then
			sf:Show()
			self.Lag:Show()
		else
			sf:Hide()
			self.Lag:Hide()
		end

		if self.casting then
			setBarTicks(self, 0)
		else
			local spell = UnitChannelInfo(unit)
			self.channelingTicks = channelingTicks[spell] or 0
			setBarTicks(self, self.channelingTicks)
		end
	elseif not UnitIsUnit(unit, "player") and self.notInterruptible then
		self:SetStatusBarColor(unpack(self.notInterruptibleColor))
	end

	-- Fix for empty icon
	if self.Icon and not self.Icon:GetTexture() then
		self.Icon:SetTexture(136243)
	end
end

cast.PostUpdateInterruptible = function(self, unit)
	if not UnitIsUnit(unit, "player") and self.notInterruptible then
		self:SetStatusBarColor(unpack(self.notInterruptibleColor))
	else
		self:SetStatusBarColor(unpack(self.casting and self.CastingColor or self.ChannelingColor))
	end
end

cast.PostCastStop = function(self)
	if not self.fadeOut then 
		self:SetStatusBarColor(unpack(self.CompleteColor))
		self.fadeOut = true
	end
	self:SetValue(self.max)
	self:Show()
end

cast.PostChannelStop = function(self)
	self.fadeOut = true
	self:SetValue(0)
	self:Show()
end

cast.PostCastFailed = function(self)
	self:SetStatusBarColor(unpack(self.FailColor))
	self:SetValue(self.max)
	if not self.fadeOut then
		self.fadeOut = true
	end
	self:Show()
end

ns.cast = cast