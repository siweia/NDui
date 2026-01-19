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
.smoothing       - Which status bar smoothing method to use, defaults to `Enum.StatusBarInterpolation.Immediate` (number)

## Attributes

.castID           - A unique identifier of the currently cast spell (number?)
.casting          - Indicates whether the current spell is an ordinary cast (boolean)
.channeling       - Indicates whether the current spell is a channeled cast (boolean)
.empowering       - Indicates whether the current spell is an empowering cast (boolean)
.notInterruptible - Indicates whether the current spell is interruptible (boolean)
.spellID          - The spell identifier of the currently cast/channeled/empowering spell (number)
.spellName        - The name of the spell currently being cast/channeled/empowered (string)

## Examples

    -- Position and size
    local Castbar = CreateFrame('StatusBar', nil, self)
    Castbar:SetSize(20, 20)
    Castbar:SetPoint('TOP')
    Castbar:SetPoint('LEFT')
    Castbar:SetPoint('RIGHT')

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

local function resetAttributes(self)
	self.castID = nil
	self.casting = nil
	self.channeling = nil
	self.empowering = nil
	self.notInterruptible = nil
	self.spellID = nil
	self.spellName = nil

	for _, pip in next, self.Pips do
		pip:Hide()
	end
end

local function CreatePip(element)
	return CreateFrame('Frame', nil, element, 'CastingBarFrameStagePipTemplate')
end

local function UpdatePips(element, stages)
	local isHoriz = element:GetOrientation() == 'HORIZONTAL'
	local elementSize = isHoriz and element:GetWidth() or element:GetHeight()

	local lastOffset = 0
	for stage, stageSection in next, stages do
		local offset = lastOffset + (elementSize * stageSection)
		lastOffset = offset

		local pip = element.Pips[stage]
		if(not pip) then
			--[[ Override: Castbar:CreatePip(stage)
			Creates a "pip" for the given stage, used for empowered casts.

			* self  - the Castbar widget
			* stage - the empowered stage for which the pip should be created (number)

			## Returns

			* pip - a frame used to depict an empowered stage boundary, typically with a line texture (frame)
			--]]
			pip = (element.CreatePip or CreatePip) (element, stage)
			element.Pips[stage] = pip
		end

		pip:ClearAllPoints()
		pip:Show()

		if(isHoriz) then
			if(pip.RotateTextures) then
				pip:RotateTextures(0)
			end

			if(element:GetReverseFill()) then
				pip:SetPoint('TOP', element, 'TOPRIGHT', -offset, 0)
				pip:SetPoint('BOTTOM', element, 'BOTTOMRIGHT', -offset, 0)
			else
				pip:SetPoint('TOP', element, 'TOPLEFT', offset, 0)
				pip:SetPoint('BOTTOM', element, 'BOTTOMLEFT', offset, 0)
			end
		else
			if(pip.RotateTextures) then
				pip:RotateTextures(1.5708)
			end

			if(element:GetReverseFill()) then
				pip:SetPoint('LEFT', element, 'TOPLEFT', 0, -offset)
				pip:SetPoint('RIGHT', element, 'TOPRIGHT', 0, -offset)
			else
				pip:SetPoint('LEFT', element, 'BOTTOMLEFT', 0, offset)
				pip:SetPoint('RIGHT', element, 'BOTTOMRIGHT', 0, offset)
			end
		end
	end

	--[[ Callback: Castbar:PostUpdatePips(stages)
	Called after the element has updated stage separators (pips) in an empowered cast.

	* self   - the Castbar widget
	* stages - stages with percentage of each stage (table)
	--]]
	if(element.PostUpdatePips) then
		element:PostUpdatePips(stages)
	end
end

--[[ Override: Castbar:ShouldShow(unit)
Handles check for which unit the castbar should show for.  
Defaults to the object unit.

* self - the Castbar widget
* unit - the unit for which the update has been triggered (string)
--]]
local function ShouldShow(element, unit)
	return element.__owner.unit == unit
end

local function CastStart(self, event, unit)
	local element = self.Castbar
	if(not (element.ShouldShow or ShouldShow) (element, unit)) then
		return
	end

	local direction, duration = Enum.StatusBarTimerDirection.ElapsedTime
	local name, text, texture, startTime, endTime, isTradeSkill, _, notInterruptible, spellID, castID = UnitCastingInfo(unit)
	if(name) then
		element.casting = true
		duration = UnitCastingDuration(unit)
	else
		local isEmpowered
		name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID, isEmpowered, _, castID = UnitChannelInfo(unit)
		if(isEmpowered) then
			element.empowering = true
			duration = UnitEmpoweredChannelDuration(unit)
		else
			element.channeling = true
			duration = UnitChannelDuration(unit)
			direction = Enum.StatusBarTimerDirection.RemainingTime
		end
	end

	if(not name or (isTradeSkill and element.hideTradeSkills)) then
		-- don't cancel hold time when we swap targets
		if(not (event == 'PLAYER_TARGET_CHANGED' and element.holdTime and element.holdTime > 0)) then
			resetAttributes(element)
			element:Hide()
		end

		return
	end

	element.delay = 0
	element.notInterruptible = notInterruptible
	element.holdTime = 0
	element.castID = castID
	element.spellID = spellID
	element.spellName = text

	if(unit == 'player') then
		-- we can only read these variables for players
		element.startTime = startTime / 1000
		if(self.empowering) then
			element.endTime = (endTime + GetUnitEmpowerHoldAtMaxTime(unit)) / 1000
		else
			element.endTime = endTime / 1000
		end
	end

	element:SetTimerDuration(duration, element.smoothing, direction)

	if(element.Icon) then element.Icon:SetTexture(texture or FALLBACK_ICON) end
	if(element.Shield) then element.Shield:SetAlphaFromBoolean(notInterruptible, 1, 0) end
	if(element.Spark) then element.Spark:Show() end
	if(element.Text) then element.Text:SetText(text) end
	if(element.Time) then element.Time:SetText() end

	local safeZone = element.SafeZone
	if(safeZone and unit == 'player') then
		local isHoriz = element:GetOrientation() == 'HORIZONTAL'

		safeZone:ClearAllPoints()
		safeZone:SetPoint(isHoriz and 'TOP' or 'LEFT')
		safeZone:SetPoint(isHoriz and 'BOTTOM' or 'RIGHT')

		if(element.channeling) then
			safeZone:SetPoint(element:GetReverseFill() and (isHoriz and 'RIGHT' or 'TOP') or (isHoriz and 'LEFT' or 'BOTTOM'))
		else
			safeZone:SetPoint(element:GetReverseFill() and (isHoriz and 'LEFT' or 'BOTTOM') or (isHoriz and 'RIGHT' or 'TOP'))
		end

		if(element.empowering) then
			endTime = endTime + GetUnitEmpowerHoldAtMaxTime(unit)
		end

		local ratio = (select(4, GetNetStats())) / (endTime - startTime)
		if(ratio > 1) then
			ratio = 1
		end

		safeZone[isHoriz and 'SetWidth' or 'SetHeight'](safeZone, element[isHoriz and 'GetWidth' or 'GetHeight'](element) * ratio)
	end

	if(element.empowering) then
		--[[ Override: Castbar:UpdatePips(stages)
		Handles updates for stage separators (pips) in an empowered cast.

		* self   - the Castbar widget
		* stages - stages with percentage of each stage (table)
		--]]
		(element.UpdatePips or UpdatePips) (element, UnitEmpoweredStagePercentages(unit))
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

local function CastUpdate(self, event, unit, _, _, castID)
	local element = self.Castbar
	if(not (element.ShouldShow or ShouldShow) (element, unit)) then
		return
	end

	if(not element:IsShown() or not castID or element.castID ~= castID) then
		return
	end

	local direction, duration, name, startTime, _ = Enum.StatusBarTimerDirection.ElapsedTime
	if(event == 'UNIT_SPELLCAST_DELAYED') then
		name, _, _, startTime = UnitCastingInfo(unit)
		duration = UnitCastingDuration(unit)
	else
		name, _, _, startTime = UnitChannelInfo(unit)
		if(event == 'UNIT_SPELLCAST_EMPOWER_UPDATE') then
			duration = UnitEmpoweredChannelDuration(unit)
		else
			duration = UnitChannelDuration(unit)
			direction = Enum.StatusBarTimerDirection.RemainingTime
		end
	end

	if(not name) then return end

	if(unit == 'player') then
		-- we can only calculate delay for players
		startTime = startTime / 1000

		local delta
		if(element.channeling) then
			delta = element.startTime - startTime
		else
			delta = startTime - element.startTime
		end

		if(delta < 0) then
			delta = 0
		end

		element.delay = element.delay + delta
	end

	element:SetTimerDuration(duration, element.smoothing, direction)

	--[[ Callback: Castbar:PostCastUpdate(unit)
	Called after the element has been updated when a spell cast or channel has been updated.

	* self - the Castbar widget
	* unit - the unit that the update has been triggered (string)
	--]]
	if(element.PostCastUpdate) then
		return element:PostCastUpdate(unit)
	end
end

local function CastStop(self, event, unit, _, _, ...)
	local element = self.Castbar
	if(not (element.ShouldShow or ShouldShow) (element, unit)) then
		return
	end

	local castID, interruptedBy, empowerComplete
	if(event == 'UNIT_SPELLCAST_STOP') then
		castID = ...
	elseif(event == 'UNIT_SPELLCAST_EMPOWER_STOP') then
		empowerComplete, interruptedBy, castID = ...
	elseif(event == 'UNIT_SPELLCAST_CHANNEL_STOP') then
		interruptedBy, castID = ...
	end

	if(not element:IsShown() or not castID or element.castID ~= castID) then
		return
	end

	if(element.Spark) then element.Spark:Hide() end

	if(interruptedBy) then
		if(element.Text) then element.Text:SetText(INTERRUPTED) end

		element.holdTime = element.timeToHold or 0

		-- force filled castbar
		element:SetMinMaxValues(0, 1)
		element:SetValue(1)
	end

	if(interruptedBy) then
		--[[ Callback: Castbar:PostCastInterrupted(unit, interruptedBy)
		Called after the element has been updated when a spell cast or channel has stopped.

		* self          - the Castbar widget
		* unit          - the unit for which the update has been triggered (string)
		* interruptedBy - GUID of whomever interrupted the cast (string)
		--]]
		if(element.PostCastInterrupted) then
			element:PostCastInterrupted(unit, interruptedBy)
		end
	else
		--[[ Callback: Castbar:PostCastStop(unit[, empowerComplete])
		Called after the element has been updated when a spell cast or channel has stopped.

		* self            - the Castbar widget
		* unit            - the unit for which the update has been triggered (string)
		* empowerComplete - if the empowered cast was complete (boolean?)
		--]]
		if(element.PostCastStop) then
			element:PostCastStop(unit, empowerComplete)
		end
	end

	resetAttributes(element)
end

local function CastFail(self, event, unit, _, _, ...)
	local element = self.Castbar
	if(not (element.ShouldShow or ShouldShow) (element, unit)) then
		return
	end

	local castID, interruptedBy
	if(event == 'UNIT_SPELLCAST_INTERRUPTED') then
		interruptedBy, castID = ...
	elseif(event == 'UNIT_SPELLCAST_FAILED') then
		castID = ...
	end

	if(not element:IsShown() or not castID or element.castID ~= castID) then
		return
	end

	if(element.Text) then
		element.Text:SetText(event == 'UNIT_SPELLCAST_FAILED' and FAILED or INTERRUPTED)
	end

	if(element.Spark) then element.Spark:Hide() end

	element.holdTime = element.timeToHold or 0

	-- force filled castbar
	element:SetMinMaxValues(0, 1)
	element:SetValue(1)

	if(interruptedBy) then
		if(element.PostCastInterrupted) then
			element:PostCastInterrupted(unit, interruptedBy)
		end
	else
		--[[ Callback: Castbar:PostCastFail(unit)
		Called after the element has been updated upon a failed or interrupted spell cast.

		* self - the Castbar widget
		* unit - the unit for which the update has been triggered (string)
		--]]
		if(element.PostCastFail) then
			element:PostCastFail(unit)
		end
	end

	resetAttributes(element)
end

local function CastInterruptible(self, event, unit)
	local element = self.Castbar
	if(not (element.ShouldShow or ShouldShow) (element, unit)) then
		return
	end

	if(not element:IsShown()) then return end
	-- ISSUE: we can't verify if this is for an active cast/channel/empower without castID

	element.notInterruptible = event == 'UNIT_SPELLCAST_NOT_INTERRUPTIBLE'

	if(element.Shield) then element.Shield:SetAlphaFromBoolean(element.notInterruptible, 1, 0) end

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
		if(self.Time) then
			local durationObject = self:GetTimerDuration() -- can be nil
			if durationObject then
				if(self.delay ~= 0) then
					--[[ Override: Castbar:CustomDelayText(duration)
					Used to completely override the updating of the .Time sub-widget when there is a delay to adjust for.

					* self     - the Castbar widget
					* duration - a [Duration](https://warcraft.wiki.gg/wiki/ScriptObject_DurationObject) object for the Castbar
					--]]
					if(self.CustomDelayText) then
						self:CustomDelayText(durationObject)
					else
						local duration = durationObject:GetRemainingDuration()
						self.Time:SetFormattedText('%.1f|cffff0000%s%.2f|r', duration, self.channeling and '-' or '+', self.delay)
					end
				else
					--[[ Override: Castbar:CustomTimeText(duration)
					Used to completely override the updating of the .Time sub-widget.

					* self     - the Castbar widget
					* duration - a [Duration](https://warcraft.wiki.gg/wiki/ScriptObject_DurationObject) object for the Castbar
					--]]
					if(self.CustomTimeText) then
						self:CustomTimeText(durationObject)
					else
						self.Time:SetFormattedText('%.1f', durationObject:GetRemainingDuration())
					end
				end
			end
		end

		-- ISSUE: we have no way to get this information any more, Blizzard is aware
		-- --[[ Callback: Castbar:PostUpdateStage(stage)
		-- Called after the current stage changes.

		-- * self - the Castbar widget
		-- * stage - the stage of the empowered cast (number)
		-- --]]
		-- if(self.empowering and self.PostUpdateStage) then
		-- 	local old = self.curStage
		-- 	for i = old + 1, self.numStages do
		-- 		if(self.stagePoints[i]) then
		-- 			if(self.duration > self.stagePoints[i]) then
		-- 				self.curStage = i

		-- 				if(self.curStage ~= old) then
		-- 					self:PostUpdateStage(i)
		-- 				end
		-- 			else
		-- 				break
		-- 			end
		-- 		end
		-- 	end
		-- end
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

		if(not element.smoothing) then
			element.smoothing = Enum.StatusBarInterpolation.Immediate
		end

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
		element.Pips = element.Pips or {}

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
			PetCastingBarFrame:OnLoad()
		end
	end
end

oUF:AddElement('Castbar', Update, Enable, Disable)
