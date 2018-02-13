local _, ns = ...
local oUF = ns.oUF

local GetNetStats = GetNetStats
local GetTime = GetTime
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo

local function updateSafeZone(self)
	local safeZone = self.SafeZone
	local width = self:GetWidth()
	local _, _, _, ms = GetNetStats()

	local safeZoneRatio = (ms / 1e3) / self.max
	if(safeZoneRatio > 1) then
		safeZoneRatio = 1
	end

	safeZone:SetWidth(width * safeZoneRatio)
end

local function UNIT_SPELLCAST_START(self, event, unit)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	local name, _, text, texture, startTime, endTime, _, castID, notInterruptible, spellID = UnitCastingInfo(unit)
	if(not name) then
		return element:Hide()
	end

	endTime = endTime / 1e3
	startTime = startTime / 1e3
	local max = endTime - startTime

	element.castID = castID
	element.duration = GetTime() - startTime
	element.max = max
	element.delay = 0
	element.casting = true
	element.notInterruptible = notInterruptible
	element.holdTime = 0

	element:SetMinMaxValues(0, max)
	element:SetValue(0)

	if(element.Text) then element.Text:SetText(text) end
	if(element.Icon) then element.Icon:SetTexture(texture) end
	if(element.Time) then element.Time:SetText() end

	local shield = element.Shield
	if(shield and notInterruptible) then
		shield:Show()
	elseif(shield) then
		shield:Hide()
	end

	local sf = element.SafeZone
	if(sf) then
		sf:ClearAllPoints()
		sf:SetPoint(element:GetReverseFill() and 'LEFT' or 'RIGHT')
		sf:SetPoint('TOP')
		sf:SetPoint('BOTTOM')
		updateSafeZone(element)
	end

	if(element.PostCastStart) then
		element:PostCastStart(unit, name, castID, spellID)
	end
	element:Show()
end

local function UNIT_SPELLCAST_FAILED(self, event, unit, spellname, _, castID, spellID)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	if(element.castID ~= castID) then
		return
	end

	local text = element.Text
	if(text) then
		text:SetText(FAILED)
	end

	element.casting = nil
	element.notInterruptible = nil
	element.holdTime = element.timeToHold or 0

	if(element.PostCastFailed) then
		return element:PostCastFailed(unit, spellname, castID, spellID)
	end
end

local function UNIT_SPELLCAST_INTERRUPTED(self, event, unit, spellname, _, castID, spellID)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	if(element.castID ~= castID) then
		return
	end

	local text = element.Text
	if(text) then
		text:SetText(INTERRUPTED)
	end

	element.casting = nil
	element.channeling = nil
	element.holdTime = element.timeToHold or 0

	if(element.PostCastInterrupted) then
		return element:PostCastInterrupted(unit, spellname, castID, spellID)
	end
end

local function UNIT_SPELLCAST_INTERRUPTIBLE(self, event, unit)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	local shield = element.Shield
	if(shield) then
		shield:Hide()
	end

	element.notInterruptible = nil

	if(element.PostCastInterruptible) then
		return element:PostCastInterruptible(unit)
	end
end

local function UNIT_SPELLCAST_NOT_INTERRUPTIBLE(self, event, unit)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	local shield = element.Shield
	if(shield) then
		shield:Show()
	end

	element.notInterruptible = true

	if(element.PostCastNotInterruptible) then
		return element:PostCastNotInterruptible(unit)
	end
end

local function UNIT_SPELLCAST_DELAYED(self, event, unit, _, _, _, spellID)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	local name, _, _, _, startTime, _, _, castID = UnitCastingInfo(unit)
	if(not startTime or not element:IsShown()) then return end

	local duration = GetTime() - (startTime / 1000)
	if(duration < 0) then duration = 0 end

	element.delay = element.delay + element.duration - duration
	element.duration = duration

	element:SetValue(duration)

	if(element.PostCastDelayed) then
		return element:PostCastDelayed(unit, name, castID, spellID)
	end
end

local function UNIT_SPELLCAST_STOP(self, event, unit, spellname, _, castID, spellID)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	if(element.castID ~= castID) then
		return
	end

	element.casting = nil
	element.notInterruptible = nil

	if(element.PostCastStop) then
		return element:PostCastStop(unit, spellname, castID, spellID)
	end
end

local function UNIT_SPELLCAST_CHANNEL_START(self, event, unit, _, _, _, spellID)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	local name, _, _, texture, startTime, endTime, _, notInterruptible = UnitChannelInfo(unit)
	if(not name) then
		return
	end

	endTime = endTime / 1e3
	startTime = startTime / 1e3
	local max = (endTime - startTime)
	local duration = endTime - GetTime()

	element.duration = duration
	element.max = max
	element.delay = 0
	element.channeling = true
	element.notInterruptible = notInterruptible
	element.holdTime = 0

	-- We have to do this, as it's possible for spell casts to never have _STOP
	-- executed or be fully completed by the OnUpdate handler before CHANNEL_START
	-- is called.
	element.casting = nil
	element.castID = nil

	element:SetMinMaxValues(0, max)
	element:SetValue(duration)

	if(element.Text) then element.Text:SetText(name) end
	if(element.Icon) then element.Icon:SetTexture(texture) end
	if(element.Time) then element.Time:SetText() end

	local shield = element.Shield
	if(shield and notInterruptible) then
		shield:Show()
	elseif(shield) then
		shield:Hide()
	end

	local sf = element.SafeZone
	if(sf) then
		sf:ClearAllPoints()
		sf:SetPoint(element:GetReverseFill() and 'RIGHT' or 'LEFT')
		sf:SetPoint('TOP')
		sf:SetPoint('BOTTOM')
		updateSafeZone(element)
	end

	if(element.PostChannelStart) then
		element:PostChannelStart(unit, name, spellID)
	end
	element:Show()
end

local function UNIT_SPELLCAST_CHANNEL_UPDATE(self, event, unit, _, _, _, spellID)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	local name, _, _, _, startTime, endTime = UnitChannelInfo(unit)
	if(not name or not element:IsShown()) then
		return
	end

	local duration = (endTime / 1000) - GetTime()

	element.delay = element.delay + element.duration - duration
	element.duration = duration
	element.max = (endTime - startTime) / 1000

	element:SetMinMaxValues(0, element.max)
	element:SetValue(duration)

	if(element.PostChannelUpdate) then
		return element:PostChannelUpdate(unit, name, spellID)
	end
end

local function UNIT_SPELLCAST_CHANNEL_STOP(self, event, unit, spellname, _, _, spellID)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	if(element:IsShown()) then
		element.channeling = nil
		element.notInterruptible = nil

		if(element.PostChannelStop) then
			return element:PostChannelStop(unit, spellname, spellID)
		end
	end
end

local function onUpdate(self, elapsed)
	if(self.casting) then
		local duration = self.duration + elapsed
		if(duration >= self.max) then
			self.casting = nil
			self:Hide()

			if(self.PostCastStop) then self:PostCastStop(self.__owner.unit) end
			return
		end

		if(self.Time) then
			if(self.delay ~= 0) then
				if(self.CustomDelayText) then
					self:CustomDelayText(duration)
				else
					self.Time:SetFormattedText('%.1f|cffff0000-%.1f|r', duration, self.delay)
				end
			else
				if(self.CustomTimeText) then
					self:CustomTimeText(duration)
				else
					self.Time:SetFormattedText('%.1f', duration)
				end
			end
		end

		self.duration = duration
		self:SetValue(duration)

		if(self.Spark) then
			local horiz = self.horizontal
			local size = self[horiz and 'GetWidth' or 'GetHeight'](self)

			local offset = (duration / self.max) * size
			if(self:GetReverseFill()) then
				offset = size - offset
			end

			self.Spark:SetPoint('CENTER', self, horiz and 'LEFT' or 'BOTTOM', horiz and offset or 0, horiz and 0 or offset)
		end
	elseif(self.channeling) then
		local duration = self.duration - elapsed

		if(duration <= 0) then
			self.channeling = nil
			self:Hide()

			if(self.PostChannelStop) then self:PostChannelStop(self.__owner.unit) end
			return
		end

		if(self.Time) then
			if(self.delay ~= 0) then
				if(self.CustomDelayText) then
					self:CustomDelayText(duration)
				else
					self.Time:SetFormattedText('%.1f|cffff0000-%.1f|r', duration, self.delay)
				end
			else
				if(self.CustomTimeText) then
					self:CustomTimeText(duration)
				else
					self.Time:SetFormattedText('%.1f', duration)
				end
			end
		end

		self.duration = duration
		self:SetValue(duration)
		if(self.Spark) then
			local horiz = self.horizontal
			local size = self[horiz and 'GetWidth' or 'GetHeight'](self)

			local offset = (duration / self.max) * size
			if(self:GetReverseFill()) then
				offset = size - offset
			end

			self.Spark:SetPoint('CENTER', self, horiz and 'LEFT' or 'BOTTOM', horiz and offset or 0, horiz and 0 or offset)
		end
	elseif(self.holdTime > 0) then
		self.holdTime = self.holdTime - elapsed
	else
		self.casting = nil
		self.castID = nil
		self.channeling = nil

		self:Hide()
	end
end

local function Update(self, ...)
	UNIT_SPELLCAST_START(self, ...)
	return UNIT_SPELLCAST_CHANNEL_START(self, ...)
end

local function ForceUpdate(element)
	return Update(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.Castbar
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if(not (unit and unit:match'%wtarget$')) then
			self:RegisterEvent('UNIT_SPELLCAST_START', UNIT_SPELLCAST_START)
			self:RegisterEvent('UNIT_SPELLCAST_FAILED', UNIT_SPELLCAST_FAILED)
			self:RegisterEvent('UNIT_SPELLCAST_STOP', UNIT_SPELLCAST_STOP)
			self:RegisterEvent('UNIT_SPELLCAST_INTERRUPTED', UNIT_SPELLCAST_INTERRUPTED)
			self:RegisterEvent('UNIT_SPELLCAST_INTERRUPTIBLE', UNIT_SPELLCAST_INTERRUPTIBLE)
			self:RegisterEvent('UNIT_SPELLCAST_NOT_INTERRUPTIBLE', UNIT_SPELLCAST_NOT_INTERRUPTIBLE)
			self:RegisterEvent('UNIT_SPELLCAST_DELAYED', UNIT_SPELLCAST_DELAYED)
			self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_START', UNIT_SPELLCAST_CHANNEL_START)
			self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_UPDATE', UNIT_SPELLCAST_CHANNEL_UPDATE)
			self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_STOP', UNIT_SPELLCAST_CHANNEL_STOP)
		end

		element.horizontal = element:GetOrientation() == 'HORIZONTAL'
		element.holdTime = 0
		element:SetScript('OnUpdate', element.OnUpdate or onUpdate)

		if(self.unit == 'player') then
			CastingBarFrame:UnregisterAllEvents()
			CastingBarFrame.Show = CastingBarFrame.Hide
			CastingBarFrame:Hide()

			PetCastingBarFrame:UnregisterAllEvents()
			PetCastingBarFrame.Show = PetCastingBarFrame.Hide
			PetCastingBarFrame:Hide()
		end

		if(element:IsObjectType('StatusBar') and not element:GetStatusBarTexture()) then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		local spark = element.Spark
		if(spark and spark:IsObjectType('Texture') and not spark:GetTexture()) then
			spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
		end

		local shield = element.Shield
		if(shield and shield:IsObjectType('Texture') and not shield:GetTexture()) then
			shield:SetTexture([[Interface\CastingBar\UI-CastingBar-Small-Shield]])
		end

		local safeZone = element.SafeZone
		if(safeZone and safeZone:IsObjectType('Texture') and not safeZone:GetTexture()) then
			safeZone:SetColorTexture(1, 0, 0)
		end

		element:Hide()

		return true
	end
end

local function Disable(self)
	local element = self.Castbar
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_SPELLCAST_START', UNIT_SPELLCAST_START)
		self:UnregisterEvent('UNIT_SPELLCAST_FAILED', UNIT_SPELLCAST_FAILED)
		self:UnregisterEvent('UNIT_SPELLCAST_STOP', UNIT_SPELLCAST_STOP)
		self:UnregisterEvent('UNIT_SPELLCAST_INTERRUPTED', UNIT_SPELLCAST_INTERRUPTED)
		self:UnregisterEvent('UNIT_SPELLCAST_INTERRUPTIBLE', UNIT_SPELLCAST_INTERRUPTIBLE)
		self:UnregisterEvent('UNIT_SPELLCAST_NOT_INTERRUPTIBLE', UNIT_SPELLCAST_NOT_INTERRUPTIBLE)
		self:UnregisterEvent('UNIT_SPELLCAST_DELAYED', UNIT_SPELLCAST_DELAYED)
		self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_START', UNIT_SPELLCAST_CHANNEL_START)
		self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_UPDATE', UNIT_SPELLCAST_CHANNEL_UPDATE)
		self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_STOP', UNIT_SPELLCAST_CHANNEL_STOP)

		element:SetScript('OnUpdate', nil)
	end
end

oUF:AddElement('Castbar', Update, Enable, Disable)