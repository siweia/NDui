-------------------------
-- oUF_Swing, by p3lim
-- NDui MOD
-------------------------
local _, ns = ...
local oUF = ns.oUF

local select = select
local GetTime = GetTime
local GetInventoryItemID = GetInventoryItemID
local UnitAttackSpeed = UnitAttackSpeed
local UnitRangedDamage = UnitRangedDamage
local UnitCastingInfo = UnitCastingInfo

local meleeing, rangeing, lasthit
local MainhandID = GetInventoryItemID("player", 16)
local OffhandID = GetInventoryItemID("player", 17)
local RangedID = GetInventoryItemID("player", 18)
local playerGUID = UnitGUID("player")
local AUTO_CAST_TIME = 0
local delayTime = 0

local function SwingStopped(element)
	local bar = element.__owner
	local swing = bar.Twohand
	local swingMH = bar.Mainhand
	local swingOH = bar.Offhand

	if swing:IsShown() then return end
	if swingMH:IsShown() then return end
	if swingOH:IsShown() then return end

	bar:Hide()
end

local function UpdateBarMinMaxValues(self)
	self:SetMinMaxValues(0, self.max - self.min)
end

local function UpdateBarValue(self, value)
	self:SetValue(value)

	if self.Text and self.Text:IsShown() then
		if self.__owner.OverrideText then
			self.__owner.OverrideText(self, value)
		else
			local decimal = rangeing and "%.2f" or "%.1f"
			self.Text:SetFormattedText(decimal, self.max - self.min - value)
		end
	end
end

local OnDurationUpdate
do
	local checkelapsed = 0
	local slamelapsed = 0
	local slamtime = 0
	local slam = GetSpellInfo(1464)
	function OnDurationUpdate(self, elapsed)
		local now = GetTime()

		if meleeing then
			if checkelapsed > .02 then
				-- little hack for detecting melee stop
				-- improve... dw sucks at this point -.-
				if lasthit + self.speed + slamtime < now then
					self:Hide()
					self:SetScript("OnUpdate", nil)
					SwingStopped(self)
					meleeing = false
					rangeing = false
				end
				checkelapsed = 0
			else
				checkelapsed = checkelapsed + elapsed
			end
		end

		if UnitCastingInfo("player") == slam then
			-- slamelapsed: time to add for one slam
			slamelapsed = slamelapsed + elapsed
			-- slamtime: needed for meleeing hack (see some lines above)
			slamtime = slamtime + elapsed
		else
			-- after slam
			if slamelapsed ~= 0 then
				self.min = self.min + slamelapsed
				self.max = self.max + slamelapsed
				slamelapsed = 0
			end

			local currentValue = now - self.min
			local swingTime = self.max - self.min - AUTO_CAST_TIME

			if now > self.max then
				if meleeing then
					if lasthit then
						self.min = self.max
						self.max = self.max + self.speed
						UpdateBarMinMaxValues(self)
						slamtime = 0
					end
				else
					delayTime = 0
					self:Hide()
					self:SetScript("OnUpdate", nil)
					meleeing = false
					rangeing = false
				end
			else
				UpdateBarValue(self, currentValue)
			end

			if self.__owner.bg then
				self.__owner.bg:SetShown(rangeing)
			end
		end
	end
end

local function MeleeChange(self, _, unit)
	if unit ~= "player" then return end
	if not meleeing then return end

	local bar = self.Swing
	local swing = bar.Twohand
	local swingMH = bar.Mainhand
	local swingOH = bar.Offhand

	local NewMainhandID = GetInventoryItemID("player", 16)
	local NewOffhandID = GetInventoryItemID("player", 17)
	local now = GetTime()
	local mhspeed, ohspeed = UnitAttackSpeed("player")

	if MainhandID ~= NewMainhandID or OffhandID ~= NewOffhandID then
		if ohspeed then
			swing:Hide()
			swing:SetScript("OnUpdate", nil)

			swingMH.min = now
			swingMH.max = swingMH.min + mhspeed
			swingMH.speed = mhspeed
			swingMH:Show()
			UpdateBarMinMaxValues(swingMH)
			swingMH:SetScript("OnUpdate", OnDurationUpdate)

			swingOH.min = now
			swingOH.max = swingOH.min + ohspeed
			swingOH.speed = ohspeed
			if mhspeed ~= ohspeed then
				swingOH:Show()
				UpdateBarMinMaxValues(swingOH)
				swingOH:SetScript("OnUpdate", OnDurationUpdate)
			else
				swingOH:Hide()
				swingOH:SetScript("OnUpdate", nil)
			end
		else
			swing.min = now
			swing.max = swing.min + mhspeed
			swing.speed = mhspeed
			swing:Show()
			UpdateBarMinMaxValues(swing)
			swing:SetScript("OnUpdate", OnDurationUpdate)

			swingMH:Hide()
			swingMH:SetScript("OnUpdate", nil)
			swingOH:Hide()
			swingOH:SetScript("OnUpdate", nil)
		end

		lasthit = now
		MainhandID = NewMainhandID
		OffhandID = NewOffhandID
	else
		if ohspeed then
			if swingMH.speed and swingMH.speed ~= mhspeed then
				local percentage = ((swingMH.max or 10) - now) / (swingMH.speed)
				swingMH.min = now - mhspeed * (1 - percentage)
				swingMH.max = now + mhspeed * percentage
				UpdateBarMinMaxValues(swingMH)
				swingMH.speed = mhspeed
			end
			if swingOH.speed and swingOH.speed ~= ohspeed then
				local percentage = ((swingOH.max or 10)- now) / (swingOH.speed)
				swingOH.min = now - ohspeed * (1 - percentage)
				swingOH.max = now + ohspeed * percentage
				UpdateBarMinMaxValues(swingOH)
				swingOH.speed = ohspeed
			end
		else
			if swing.max and swing.speed ~= mhspeed then
				local percentage = (swing.max - now) / (swing.speed)
				swing.min = now - mhspeed * (1 - percentage)
				swing.max = now + mhspeed * percentage
				UpdateBarMinMaxValues(swing)
				swing.speed = mhspeed
			end
		end
	end
end

local function RangedChange(self, _, unit)
	if unit ~= "player" then return end
	if not rangeing then return end

	local bar = self.Swing
	local swing = bar.Twohand

	local NewRangedID = GetInventoryItemID("player", 18)
	local now = GetTime()
	local speed = UnitRangedDamage("player")

	if RangedID ~= NewRangedID then
		swing.speed = speed
		swing.min = now
		swing.max = swing.min + swing.speed
		swing:Show()
		UpdateBarMinMaxValues(swing)
		swing:SetScript("OnUpdate", OnDurationUpdate)
	else
		if swing.speed ~= speed then
			local percentage = (swing.max - now) / (swing.speed)
			swing.min = now - speed * (1 - percentage)
			swing.max = now + speed * percentage
			swing.speed = speed
		end
	end
end

local function Ranged(self, _, unit, _, spellID)
	if unit ~= "player" then return end
	if spellID ~= 75 and spellID ~= 5019 then return end

	local bar = self.Swing
	local swing = bar.Twohand
	local swingMH = bar.Mainhand
	local swingOH = bar.Offhand

	meleeing = false
	rangeing = true
	bar:Show()

	swing.speed = UnitRangedDamage(unit) * .82
	swing.min = GetTime()
	swing.max = swing.min + swing.speed
	swing:Show()
	UpdateBarMinMaxValues(swing)
	swing:SetScript("OnUpdate", OnDurationUpdate)
	if bar.bg then
		bar.bg:SetWidth(AUTO_CAST_TIME / (swing.max - swing.min) * bar:GetWidth())
	end

	swingMH:Hide()
	swingMH:SetScript("OnUpdate", nil)
	swingOH:Hide()
	swingOH:SetScript("OnUpdate", nil)
end

local function Melee(self, event, _, sourceGUID)
	if sourceGUID ~= playerGUID then return end

	local bar = self.Swing
	local swing = bar.Twohand
	local swingMH = bar.Mainhand
	local swingOH = bar.Offhand

	-- calculation of new hits is in OnDurationUpdate
	-- workaround, cant differ between mainhand and offhand hits
	local now = GetTime()

	if not meleeing then
		bar:Show()
		swing:Hide()
		swingMH:Hide()
		swingOH:Hide()

		swing:SetScript("OnUpdate", nil)
		swingMH:SetScript("OnUpdate", nil)
		swingOH:SetScript("OnUpdate", nil)

		local mhspeed, ohspeed = UnitAttackSpeed("player")
		if ohspeed then
			swingMH.min = now
			swingMH.max = swingMH.min + mhspeed
			swingMH.speed = mhspeed
			swingMH:Show()
			UpdateBarMinMaxValues(swingMH)
			swingMH:SetScript("OnUpdate", OnDurationUpdate)

			swingOH.min = now
			swingOH.max = swingOH.min + ohspeed
			swingOH.speed = ohspeed
			if mhspeed ~= ohspeed then
				swingOH:Show()
				UpdateBarMinMaxValues(swingOH)
				swingOH:SetScript("OnUpdate", OnDurationUpdate)
			end
		else
			swing.min = now
			swing.max = swing.min + mhspeed
			swing.speed = mhspeed
			swing:Show()
			UpdateBarMinMaxValues(swing)
			swing:SetScript("OnUpdate", OnDurationUpdate)
		end

		meleeing = true
		rangeing = false
	end

	lasthit = now
end

local function GetHasteMult(speed, now, percentage)
	if percentage == 1 then
		return 0
	else
		return (speed - now) * percentage / (1 - percentage)
	end
end

local function ParryHaste(self, ...)
	local destGUID, _, _, _, missType = select(7, ...)

	if destGUID ~= playerGUID then return end
	if not meleeing then return end
	if missType ~= "PARRY" then return end

	local bar = self.Swing
	local swing = bar.Twohand
	local swingMH = bar.Mainhand
	local swingOH = bar.Offhand

	local _, dualwield = UnitAttackSpeed("player")
	local now = GetTime()

	-- needed calculations, so the timer doesnt jump on parryhaste
	if dualwield then
		local percentage = (swingMH.max - now) / swingMH.speed

		if percentage > .6 then
			swingMH.max = now + swingMH.speed * .6
			swingMH.min = now - GetHasteMult(swingMH.max, now, percentage)
			UpdateBarMinMaxValues(swingMH)
		elseif percentage > .2 then
			swingMH.max = now + swingMH.speed * .2
			swingMH.min = now - GetHasteMult(swingMH.max, now, percentage)
			UpdateBarMinMaxValues(swingMH)
		end

		percentage = (swingOH.max - now) / swingOH.speed

		if percentage > .6 then
			swingOH.max = now + swingOH.speed * .6
			swingOH.min = now - GetHasteMult(swingOH.max, now, percentage)
			UpdateBarMinMaxValues(swingOH)
		elseif percentage > .2 then
			swingOH.max = now + swingOH.speed * .2
			swingOH.min = now - GetHasteMult(swingOH.max, now, percentage)
			UpdateBarMinMaxValues(swingOH)
		end
	else
		local percentage = (swing.max - now) / swing.speed

		if percentage > .6 then
			swing.max = now + swing.speed * .6
			swing.min = now - GetHasteMult(swing.max, now, percentage)
			UpdateBarMinMaxValues(swing)
		elseif percentage > .2 then
			swing.max = now + swing.speed * .2
			swing.min = now - GetHasteMult(swing.max, now, percentage)
			UpdateBarMinMaxValues(swing)
		end
	end
end

local function Ooc(self)
	local bar = self.Swing
	-- strange behaviour sometimes...
	meleeing = false
	rangeing = false

	if not bar.hideOoc then return end
	bar:Hide()
	bar.Twohand:Hide()
	bar.Mainhand:Hide()
	bar.Offhand:Hide()
end

local function Enable(self, unit)
	local bar = self.Swing

	if bar and unit == "player" then
		local normTex = bar.texture or [=[Interface\TargetingFrame\UI-StatusBar]=]
		local bgTex = bar.textureBG or [=[Interface\TargetingFrame\UI-StatusBar]=]
		local r, g, b, a, r2, g2, b2, a2

		if bar.color then
			r, g, b, a = unpack(bar.color)
		else
			r, g, b, a = 1, 1, 1, 1
		end

		if bar.colorBG then
			r2, g2, b2, a2 = unpack(bar.colorBG)
		else
			r2, g2, b2, a2 = 0, 0, 0, 1
		end

		if not bar.Twohand then
			bar.Twohand = CreateFrame("StatusBar", nil, bar)
			bar.Twohand:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
			bar.Twohand:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0)
			bar.Twohand:SetStatusBarTexture(normTex)
			bar.Twohand:SetStatusBarColor(r, g, b, a)
			bar.Twohand:SetFrameLevel(20)
			bar.Twohand:Hide()
			bar.Twohand.bg = bar.Twohand:CreateTexture(nil, "BACKGROUND")
			bar.Twohand.bg:SetAllPoints(bar.Twohand)
			bar.Twohand.bg:SetTexture(bgTex)
			bar.Twohand.bg:SetVertexColor(r2, g2, b2, a2)
		end
		bar.Twohand.__owner = bar

		if not bar.Mainhand then
			bar.Mainhand = CreateFrame("StatusBar", nil, bar)
			bar.Mainhand:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
			bar.Mainhand:SetPoint("BOTTOMRIGHT", bar, "RIGHT", 0, 0)
			bar.Mainhand:SetStatusBarTexture(normTex)
			bar.Mainhand:SetStatusBarColor(r, g, b, a)
			bar.Mainhand:SetFrameLevel(20)
			bar.Mainhand:Hide()
			bar.Mainhand.bg = bar.Mainhand:CreateTexture(nil, "BACKGROUND")
			bar.Mainhand.bg:SetAllPoints(bar.Mainhand)
			bar.Mainhand.bg:SetTexture(bgTex)
			bar.Mainhand.bg:SetVertexColor(r2, g2, b2, a2)
		end
		bar.Mainhand.__owner = bar

		if not bar.Offhand then
			bar.Offhand = CreateFrame("StatusBar", nil, bar)
			bar.Offhand:SetPoint("TOPLEFT", bar, "LEFT", 0, 0)
			bar.Offhand:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0)
			bar.Offhand:SetStatusBarTexture(normTex)
			bar.Offhand:SetStatusBarColor(r, g, b, a)
			bar.Offhand:SetFrameLevel(20)
			bar.Offhand:Hide()
			bar.Offhand.bg = bar.Offhand:CreateTexture(nil, "BACKGROUND")
			bar.Offhand.bg:SetAllPoints(bar.Offhand)
			bar.Offhand.bg:SetTexture(bgTex)
			bar.Offhand.bg:SetVertexColor(r2, g2, b2, a2)
		end
		bar.Offhand.__owner = bar

		if bar.Text then
			bar.Twohand.Text = bar.Text
			bar.Twohand.Text:SetParent(bar.Twohand)
		end
		if bar.TextMH then
			bar.Mainhand.Text = bar.TextMH
			bar.Mainhand.Text:SetParent(bar.Mainhand)
		end
		if bar.TextOH then
			bar.Offhand.Text = bar.TextOH
			bar.Offhand.Text:SetParent(bar.Offhand)
		end
		if bar.OverrideText then
			bar.Twohand.OverrideText = bar.OverrideText
			bar.Mainhand.OverrideText = bar.OverrideText
			bar.Offhand.OverrideText = bar.OverrideText
		end
		if not bar.disableRanged then
			self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", Ranged)
			self:RegisterEvent("UNIT_RANGEDDAMAGE", RangedChange)
		end
		if not bar.disableMelee then
			self:RegisterCombatEvent("SWING_DAMAGE", Melee)
			self:RegisterCombatEvent("SWING_MISSED", Melee)
			self:RegisterCombatEvent("SWING_MISSED", ParryHaste)
			self:RegisterEvent("UNIT_ATTACK_SPEED", MeleeChange)
		end
		self:RegisterEvent("PLAYER_REGEN_ENABLED", Ooc, true)

		return true
	end
end

local function Disable(self)
	local bar = self.Swing
	if bar then
		if not bar.disableRanged then
			self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", Ranged)
			self:UnregisterEvent("UNIT_RANGEDDAMAGE", RangedChange)
		end
		if not bar.disableMelee then
			self:UnregisterCombatEvent("SWING_DAMAGE", Melee)
			self:UnregisterCombatEvent("SWING_MISSED", Melee)
			self:UnregisterCombatEvent("SWING_MISSED", ParryHaste)
			self:UnregisterEvent("UNIT_ATTACK_SPEED", MeleeChange)
		end
		self:UnregisterEvent("PLAYER_REGEN_ENABLED", Ooc)

		bar:Hide()
	end
end

oUF:AddElement("Swing", nil, Enable, Disable)