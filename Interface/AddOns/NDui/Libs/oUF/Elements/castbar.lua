--[[
# Element: Castbar

Handles the visibility and updating of spell castbars.

## Widget

Castbar - A `StatusBar` to represent spell cast/channel progress.

## Sub-Widgets

.Icon     - A `Texture` to represent spell icon.
.SafeZone - A `Texture` to represent latency.
.Shield   - A `Texture` to represent if it's possible to interrupt or spell steal.
.Spark    - A `Texture` to represent the castbar's edge.
.Text     - A `FontString` to represent spell name.
.Time     - A `FontString` to represent spell duration.

## Notes

A default texture will be applied to the StatusBar and Texture widgets if they don't have a texture or a color set.

## Options

.timeToHold      - Indicates for how many seconds the castbar should be visible after a _FAILED or _INTERRUPTED
                   event. Defaults to 0 (number)
.hideTradeSkills - Makes the element ignore casts related to crafting professions (boolean)

## Attributes

.castID           - A globally unique identifier of the currently cast spell (string?)
.casting          - Indicates whether the current spell is an ordinary cast (boolean)
.channeling       - Indicates whether the current spell is a channeled cast (boolean)
.empowering       - Indicates whether the current spell is an empowering cast (boolean)
.notInterruptible - Indicates whether the current spell is interruptible (boolean)
.spellID          - The spell identifier of the currently cast/channeled/empowering spell (number)

## Examples

    -- Position and size
    local Castbar = CreateFrame('StatusBar', nil, self)
    Castbar:SetSize(20, 20)
    Castbar:SetPoint('TOP')
    Castbar:SetPoint('LEFT')
    Castbar:SetPoint('RIGHT')

    -- Add a background
    local Background = Castbar:CreateTexture(nil, 'BACKGROUND')
    Background:SetAllPoints(Castbar)
    Background:SetColorTexture(1, 1, 1, .5)

    -- Add a spark
    local Spark = Castbar:CreateTexture(nil, 'OVERLAY')
    Spark:SetSize(20, 20)
    Spark:SetBlendMode('ADD')
    Spark:SetPoint('CENTER', Castbar:GetStatusBarTexture(), 'RIGHT', 0, 0)

    -- Add a timer
    local Time = Castbar:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
    Time:SetPoint('RIGHT', Castbar)

    -- Add spell text
    local Text = Castbar:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
    Text:SetPoint('LEFT', Castbar)

    -- Add spell icon
    local Icon = Castbar:CreateTexture(nil, 'OVERLAY')
    Icon:SetSize(20, 20)
    Icon:SetPoint('TOPLEFT', Castbar, 'TOPLEFT')

    -- Add Shield
    local Shield = Castbar:CreateTexture(nil, 'OVERLAY')
    Shield:SetSize(20, 20)
    Shield:SetPoint('CENTER', Castbar)

    -- Add safezone
    local SafeZone = Castbar:CreateTexture(nil, 'OVERLAY')

    -- Register it with oUF
    Castbar.bg = Background
    Castbar.Spark = Spark
    Castbar.Time = Time
    Castbar.Text = Text
    Castbar.Icon = Icon
    Castbar.Shield = Shield
    Castbar.SafeZone = SafeZone
    self.Castbar = Castbar
--]]

local _, ns = ...
local oUF = ns.oUF

local FALLBACK_ICON = 136243 -- Interface\ICONS\Trade_Engineering
local FAILED = _G.FAILED or 'Failed'
local INTERRUPTED = _G.INTERRUPTED or 'Interrupted'
local CASTBAR_STAGE_DURATION_INVALID = -1 -- defined in FrameXML/CastingBarFrame.lua

local function resetAttributes(self)
	self.castID = nil
	self.casting = nil
	self.channeling = nil
	self.empowering = nil
	self.notInterruptible = nil
	self.spellID = nil
	self.pipStage = nil -- NDui

	for _, pip in next, self.Pips do
		pip:Hide()
	end
end

local function CreatePip(element)
	return CreateFrame('Frame', nil, element, 'CastingBarFrameStagePipTemplate')
end

local function UpdatePips(element, numStages)
	local stageTotalDuration = 0
	local stageMaxValue = element.max * 1000
	local isHoriz = element:GetOrientation() == 'HORIZONTAL'
	local elementSize = isHoriz and element:GetWidth() or element:GetHeight()

	for stage = 1, numStages do
		local duration
		if(stage > numStages) then
			duration = GetUnitEmpowerHoldAtMaxTime(element.__owner.unit)
		else
			duration = GetUnitEmpowerStageDuration(element.__owner.unit, stage - 1)
		end

		if(duration > CASTBAR_STAGE_DURATION_INVALID) then
			stageTotalDuration = stageTotalDuration + duration

			local portion = stageTotalDuration / stageMaxValue
			local offset = elementSize * portion

			local pip = element.Pips[stage]
			if(not pip) then
				--[[ Override: Castbar:CreatePip(stage)
				Creates a "pip" for the given stage, used for empowered casts.

				* self - the Castbar widget

				## Returns

				* pip - a frame used to depict an empowered stage boundary, typically with a line texture (frame)
				--]]
				pip = (element.CreatePip or CreatePip) (element, stage)
				element.Pips[stage] = pip
			end

			pip:ClearAllPoints()
			pip:Show()

			if(isHoriz) then
				pip:RotateTextures(0)

				if(element:GetReverseFill()) then
					pip:SetPoint('TOP', element, 'TOPRIGHT', -offset, 0)
					pip:SetPoint('BOTTOM', element, 'BOTTOMRIGHT', -offset, 0)
				else
					pip:SetPoint('TOP', element, 'TOPLEFT', offset, 0)
					pip:SetPoint('BOTTOM', element, 'BOTTOMLEFT', offset, 0)
				end
			else
				pip:RotateTextures(1.5708)

				if(element:GetReverseFill()) then
					pip:SetPoint('LEFT', element, 'TOPLEFT', 0, -offset)
					pip:SetPoint('RIGHT', element, 'TOPRIGHT', 0, -offset)
				else
					pip:SetPoint('LEFT', element, 'BOTTOMLEFT', 0, offset)
					pip:SetPoint('RIGHT', element, 'BOTTOMRIGHT', 0, offset)
				end
			end

			if element.PostUpdatePip then -- NDui
				element:PostUpdatePip(pip, stage, stageTotalDuration)
			end
		end
	end
end

local function CastStart(self, event, unit)
	if(self.unit ~= unit) then return end

	local element = self.Castbar

	local numStages, _
	local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = UnitCastingInfo(unit)
	event = 'UNIT_SPELLCAST_START'
	if(not name) then
		name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID, _, numStages = UnitChannelInfo(unit)
		event = (numStages and numStages > 0) and 'UNIT_SPELLCAST_EMPOWER_START' or 'UNIT_SPELLCAST_CHANNEL_START'
	end

	if(not name or (isTradeSkill and element.hideTradeSkills)) then
		resetAttributes(element)
		element:Hide()

		return
	end

	element.casting = event == 'UNIT_SPELLCAST_START'
	element.channeling = event == 'UNIT_SPELLCAST_CHANNEL_START'
	element.empowering = event == 'UNIT_SPELLCAST_EMPOWER_START'

	if(element.empowering) then
		endTime = endTime + GetUnitEmpowerHoldAtMaxTime(unit)
	end

	endTime = endTime / 1000
	startTime = startTime / 1000

	element.max = endTime - startTime
	element.startTime = startTime
	element.delay = 0
	element.notInterruptible = notInterruptible
	element.holdTime = 0
	element.castID = castID
	element.spellID = spellID
	element.numStages = numStages -- NDui

	if(element.channeling) then
		element.duration = endTime - GetTime()
	else
		element.duration = GetTime() - startTime
	end

	element:SetMinMaxValues(0, element.max)
	element:SetValue(element.duration)

	if(element.Icon) then element.Icon:SetTexture(texture or FALLBACK_ICON) end
	if(element.Shield) then element.Shield:SetShown(notInterruptible) end
	if(element.Spark) then element.Spark:Show() end
	if(element.Text) then element.Text:SetText(text) end
	if(element.Time) then element.Time:SetText() end

	local safeZone = element.SafeZone
	if(safeZone) then
		local isHoriz = element:GetOrientation() == 'HORIZONTAL'

		safeZone:ClearAllPoints()
		safeZone:SetPoint(isHoriz and 'TOP' or 'LEFT')
		safeZone:SetPoint(isHoriz and 'BOTTOM' or 'RIGHT')

		if(element.channeling) then
			safeZone:SetPoint(element:GetReverseFill() and (isHoriz and 'RIGHT' or 'TOP') or (isHoriz and 'LEFT' or 'BOTTOM'))
		else
			safeZone:SetPoint(element:GetReverseFill() and (isHoriz and 'LEFT' or 'BOTTOM') or (isHoriz and 'RIGHT' or 'TOP'))
		end

		local ratio = (select(4, GetNetStats()) / 1000) / element.max
		if(ratio > 1) then
			ratio = 1
		end

		safeZone[isHoriz and 'SetWidth' or 'SetHeight'](safeZone, element[isHoriz and 'GetWidth' or 'GetHeight'](element) * ratio)
	end

	if(element.empowering) then
		--[[ Override: Castbar:UpdatePips(numStages)
		Handles updates for stage separators (pips) in an empowered cast.

		* self      - the Castbar widget
		* numStages - the number of stages in the current cast (number)
		--]]
		(element.UpdatePips or UpdatePips) (element, numStages)
	end

	--[[ Callback: Castbar:PostCastStart(unit)
	Called after the element has been updated upon a spell cast or channel start.

	* self - the Castbar widget
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PostCastStart) then
		element:PostCastStart(unit)
	end

	element:Show()
end

local function CastUpdate(self, event, unit, castID, spellID)
	if(self.unit ~= unit) then return end

	local element = self.Castbar
	if(not element:IsShown() or element.castID ~= castID or element.spellID ~= spellID) then
		return
	end

	local name, startTime, endTime, _
	if(event == 'UNIT_SPELLCAST_DELAYED') then
		name, _, _, startTime, endTime = UnitCastingInfo(unit)
	else
		name, _, _, startTime, endTime = UnitChannelInfo(unit)
	end

	if(not name) then return end

	if(element.empowering) then
		endTime = endTime + GetUnitEmpowerHoldAtMaxTime(unit)
	end

	endTime = endTime / 1000
	startTime = startTime / 1000

	local delta
	if(element.channeling) then
		delta = element.startTime - startTime

		element.duration = endTime - GetTime()
	else
		delta = startTime - element.startTime

		element.duration = GetTime() - startTime
	end

	if(delta < 0) then
		delta = 0
	end

	element.max = endTime - startTime
	element.startTime = startTime
	element.delay = element.delay + delta

	element:SetMinMaxValues(0, element.max)
	element:SetValue(element.duration)

	--[[ Callback: Castbar:PostCastUpdate(unit)
	Called after the element has been updated when a spell cast or channel has been updated.

	* self - the Castbar widget
	* unit - the unit that the update has been triggered (string)
	--]]
	if(element.PostCastUpdate) then
		return element:PostCastUpdate(unit)
	end
end

local function CastStop(self, event, unit, castID, spellID)
	if(self.unit ~= unit) then return end

	local element = self.Castbar
	if(not element:IsShown() or element.castID ~= castID or element.spellID ~= spellID) then
		return
	end

	resetAttributes(element)

	--[[ Callback: Castbar:PostCastStop(unit, spellID)
	Called after the element has been updated when a spell cast or channel has stopped.

	* self    - the Castbar widget
	* unit    - the unit for which the update has been triggered (string)
	* spellID - the ID of the spell (number)
	--]]
	if(element.PostCastStop) then
		return element:PostCastStop(unit, spellID)
	end
end

local function CastFail(self, event, unit, castID, spellID)
	if(self.unit ~= unit) then return end

	local element = self.Castbar
	if(not element:IsShown() or element.castID ~= castID or element.spellID ~= spellID) then
		return
	end

	if(element.Text) then
		element.Text:SetText(event == 'UNIT_SPELLCAST_FAILED' and FAILED or INTERRUPTED)
	end

	if(element.Spark) then element.Spark:Hide() end

	element.holdTime = element.timeToHold or 0

	resetAttributes(element)
	element:SetValue(element.max)

	--[[ Callback: Castbar:PostCastFail(unit, spellID)
	Called after the element has been updated upon a failed or interrupted spell cast.

	* self    - the Castbar widget
	* unit    - the unit for which the update has been triggered (string)
	* spellID - the ID of the spell (number)
	--]]
	if(element.PostCastFail) then
		return element:PostCastFail(unit, spellID)
	end
end

local function CastInterruptible(self, event, unit)
	if(self.unit ~= unit) then return end

	local element = self.Castbar
	if(not element:IsShown()) then return end

	element.notInterruptible = event == 'UNIT_SPELLCAST_NOT_INTERRUPTIBLE'

	if(element.Shield) then element.Shield:SetShown(element.notInterruptible) end

	--[[ Callback: Castbar:PostCastInterruptible(unit)
	Called after the element has been updated when a spell cast has become interruptible or uninterruptible.

	* self - the Castbar widget
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PostCastInterruptible) then
		return element:PostCastInterruptible(unit)
	end
end

local function onUpdate(self, elapsed)
	if(self.casting or self.channeling or self.empowering) then
		local isCasting = self.casting or self.empowering
		if(isCasting) then
			self.duration = self.duration + elapsed
			if(self.duration >= self.max) then
				local spellID = self.spellID

				resetAttributes(self)
				self:Hide()

				if(self.PostCastStop) then
					self:PostCastStop(self.__owner.unit, spellID)
				end

				return
			end
		else
			self.duration = self.duration - elapsed
			if(self.duration <= 0) then
				local spellID = self.spellID

				resetAttributes(self)
				self:Hide()

				if(self.PostCastStop) then
					self:PostCastStop(self.__owner.unit, spellID)
				end

				return
			end
		end

		if(self.Time) then
			if(self.delay ~= 0) then
				if(self.CustomDelayText) then
					self:CustomDelayText(self.duration)
				else
					self.Time:SetFormattedText('%.1f|cffff0000%s%.2f|r', self.duration, isCasting and '+' or '-', self.delay)
				end
			else
				if(self.CustomTimeText) then
					self:CustomTimeText(self.duration)
				else
					self.Time:SetFormattedText('%.1f', self.duration)
				end
			end
		end

		self:SetValue(self.duration)
	elseif(self.holdTime > 0) then
		self.holdTime = self.holdTime - elapsed
	else
		resetAttributes(self)
		self:Hide()
	end
end

local function Update(...)
	CastStart(...)
end

local function ForceUpdate(element)
	return Update(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.Castbar
	if(element and unit and not unit:match('%wtarget$')) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_SPELLCAST_START', CastStart)
		self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_START', CastStart)
		self:RegisterEvent('UNIT_SPELLCAST_EMPOWER_START', CastStart)
		self:RegisterEvent('UNIT_SPELLCAST_STOP', CastStop)
		self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_STOP', CastStop)
		self:RegisterEvent('UNIT_SPELLCAST_EMPOWER_STOP', CastStop)
		self:RegisterEvent('UNIT_SPELLCAST_DELAYED', CastUpdate)
		self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_UPDATE', CastUpdate)
		self:RegisterEvent('UNIT_SPELLCAST_EMPOWER_UPDATE', CastUpdate)
		self:RegisterEvent('UNIT_SPELLCAST_FAILED', CastFail)
		self:RegisterEvent('UNIT_SPELLCAST_INTERRUPTED', CastFail)
		self:RegisterEvent('UNIT_SPELLCAST_INTERRUPTIBLE', CastInterruptible)
		self:RegisterEvent('UNIT_SPELLCAST_NOT_INTERRUPTIBLE', CastInterruptible)

		element.holdTime = 0
		element.Pips = {}

		element:SetScript('OnUpdate', element.OnUpdate or onUpdate)

		if(self.unit == 'player' and not (self.hasChildren or self.isChild or self.isNamePlate)) then
			PlayerCastingBarFrame:SetUnit(nil)
			PetCastingBarFrame:SetUnit(nil)
			PetCastingBarFrame:UnregisterEvent('UNIT_PET')
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

		self:UnregisterEvent('UNIT_SPELLCAST_START', CastStart)
		self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_START', CastStart)
		self:UnregisterEvent('UNIT_SPELLCAST_EMPOWER_START', CastStart)
		self:UnregisterEvent('UNIT_SPELLCAST_STOP', CastStop)
		self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_STOP', CastStop)
		self:UnregisterEvent('UNIT_SPELLCAST_EMPOWER_STOP', CastStop)
		self:UnregisterEvent('UNIT_SPELLCAST_DELAYED', CastUpdate)
		self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_UPDATE', CastUpdate)
		self:UnregisterEvent('UNIT_SPELLCAST_EMPOWER_UPDATE', CastUpdate)
		self:UnregisterEvent('UNIT_SPELLCAST_FAILED', CastFail)
		self:UnregisterEvent('UNIT_SPELLCAST_INTERRUPTED', CastFail)
		self:UnregisterEvent('UNIT_SPELLCAST_INTERRUPTIBLE', CastInterruptible)
		self:UnregisterEvent('UNIT_SPELLCAST_NOT_INTERRUPTIBLE', CastInterruptible)

		element:SetScript('OnUpdate', nil)

		if(self.unit == 'player' and not (self.hasChildren or self.isChild or self.isNamePlate)) then
			PlayerCastingBarFrame:OnLoad()
			PetCastingBarFrame:PetCastingBar_OnLoad()
		end
	end
end

oUF:AddElement('Castbar', Update, Enable, Disable)