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
.Delay    - A `FontString` to represent spell pushback delay for player casts.

## Sub-Widget options

.Time.binding   - A [`DurationTextBinding`](https://warcraft.wiki.gg/wiki/ScriptObject_DurationTextBinding) object to override the default
.Time.formatter - A [`NumericFormatter`](https://warcraft.wiki.gg/wiki/ScriptObject_NumericFormatter) to override the default

## Notes

A default texture will be applied to the StatusBar and Texture widgets if they don't have a texture or a color set.

## Options

.timeToHold         - Indicates for how many seconds the castbar should be visible after a _FAILED or _INTERRUPTED
                      event. Defaults to 0 (number)
.hideTradeSkills    - Makes the element ignore casts related to crafting professions (boolean)
.smoothing          - Which status bar smoothing method to use, defaults to `Enum.StatusBarInterpolation.Immediate` (number)
.showGlobalCooldown - Whether to show a castbar for the global cooldown for the player (boolean)

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

local STATE = {}
local issecretvalue = issecretvalue

local FAILED = _G.FAILED or 'Failed'
local INTERRUPTED = _G.INTERRUPTED or 'Interrupted'
local GLOBAL_SPELL_ID = 61304 -- Global Cooldown

local function HasInterruptedBy(interruptedBy)
	-- Opaque GUIDs still identify an interrupted cast; only their contents are unavailable.
	return issecretvalue(interruptedBy) or interruptedBy ~= nil
end

local defaultFormatter = C_StringUtil.CreateSecondsFormatter()
defaultFormatter:SetDefaultAbbreviation(Enum.SecondsFormatterAbbreviation.OneLetter)
defaultFormatter:SetMinInterval(Enum.SecondsFormatterInterval.Seconds)
defaultFormatter:SetMillisecondsThreshold(60)

local function resetState(element)
	if(not (element.timeToHold ~= nil and STATE[element].holdTime and STATE[element].holdTime > 0)) then
		table.wipe(STATE[element])
	end

	for _, pip in next, element.Pips do
		pip:Hide()
	end
end

local function CreatePip(element)
	return CreateFrame('Frame', nil, element, 'CastingBarFrameStagePipTemplate')
end

local function UpdatePips(element, stages)
	local horizontal = element:GetOrientation() == 'HORIZONTAL'
	local elementSize = horizontal and element:GetWidth() or element:GetHeight()

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

		if(horizontal) then
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
local function GetDisplayUnit(element, eventUnit)
	-- Secret unit payloads have already been filtered by RegisterUnitEvent. For public
	-- payloads, keep the active/real unit distinction used during vehicle transitions.
	local unit = element.__owner.__unit
	if(not issecretvalue(eventUnit) and eventUnit ~= unit) then
		return
	end

	if(element.ShouldShow and not element:ShouldShow(unit)) then
		return
	end

	return unit
end

local function CastStart(self, event, eventUnit, _castGUID, _spellID, eventCastID)
	local element = self.Castbar
	local unit = GetDisplayUnit(element, eventUnit)
	if(not unit) then return end

	local direction, duration = Enum.StatusBarTimerDirection.ElapsedTime
	local displayName, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID, castID, _
	_, displayName, texture, startTime, endTime, isTradeSkill, _, notInterruptible, spellID, castID = UnitCastingInfo(unit)
	local isCasting = isTradeSkill ~= nil
	local isEmpowered
	if(not isCasting) then
		_, displayName, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID, isEmpowered, _, castID = UnitChannelInfo(unit)
	end

	-- The frame can be registered for both its active and real unit while in a vehicle.
	-- Match only on public cast state and NeverSecret castBarID, never on the event unit.
	if((eventCastID ~= nil and eventCastID ~= castID)
	or (event == 'UNIT_SPELLCAST_START' and not isCasting)
	or (event == 'UNIT_SPELLCAST_CHANNEL_START' and (isTradeSkill == nil or isCasting or isEmpowered))
	or (event == 'UNIT_SPELLCAST_EMPOWER_START' and not isEmpowered)
	) then
		return
	end

	if(isTradeSkill == nil or (isTradeSkill and element.hideTradeSkills)) then
		resetState(element)

		-- don't cancel hold time when we swap targets
		if(not (event == 'PLAYER_TARGET_CHANGED' and STATE[element].holdTime and STATE[element].holdTime > 0)) then
			element:Hide()
		end

		return
	end

	-- reset first to avoid any attributes that might be stuck
	resetState(element)

	if(isCasting) then
		STATE[element].casting = true
		duration = UnitCastingDuration(unit)
	elseif(isEmpowered) then
		STATE[element].empowering = true
		duration = UnitEmpoweredChannelDuration(unit)
	else
		STATE[element].channeling = true
		duration = UnitChannelDuration(unit)
		direction = Enum.StatusBarTimerDirection.RemainingTime
	end

	STATE[element].delay = 0
	STATE[element].holdTime = 0
	STATE[element].notInterruptible = notInterruptible
	STATE[element].spellID = spellID
	STATE[element].castID = castID

	if(unit == 'player') then
		-- we can only read these variables for players
		STATE[element].startTime = startTime / 1000
		if(STATE[element].empowering) then
			STATE[element].endTime = (endTime + GetUnitEmpowerHoldAtMaxTime(unit)) / 1000
		else
			STATE[element].endTime = endTime / 1000
		end
	end

	element:SetTimerDuration(duration, element.smoothing, direction)

	if(element.Time) then
		element.Time.binding:SetDuration(duration)
	end

	if(element.Icon) then element.Icon:SetTexture(texture) end
	if(element.Shield) then element.Shield:SetAlphaFromBoolean(notInterruptible, 1, 0) end
	if(element.Spark) then element.Spark:Show() end
	if(element.Text) then element.Text:SetText(displayName) end
	if(element.Time) then element.Time:SetText() end

	local safeZone = element.SafeZone
	if(safeZone and unit == 'player') then
		local horizontal = element:GetOrientation() == 'HORIZONTAL'

		safeZone:ClearAllPoints()
		safeZone:SetPoint(horizontal and 'TOP' or 'LEFT')
		safeZone:SetPoint(horizontal and 'BOTTOM' or 'RIGHT')

		if(STATE[element].channeling) then
			local directionNormal = horizontal and 'LEFT' or 'BOTTOM'
			local directionReverse = horizontal and 'RIGHT' or 'TOP'
			safeZone:SetPoint(element:GetReverseFill() and directionReverse or directionNormal)
		else
			local directionNormal = horizontal and 'RIGHT' or 'TOP'
			local directionReverse = horizontal and 'LEFT' or 'BOTTOM'
			safeZone:SetPoint(element:GetReverseFill() and directionReverse or directionNormal)
		end

		if(STATE[element].empowering) then
			endTime = endTime + GetUnitEmpowerHoldAtMaxTime(unit)
		end

		local ratio = (select(4, GetNetStats())) / (endTime - startTime)
		if(ratio > 1) then
			ratio = 1
		end

		local axis = horizontal and 'Width' or 'Height'
		safeZone['Set' .. axis](safeZone, element['Get' .. axis](element) * ratio)
	end

	if(STATE[element].empowering) then
		--[[ Override: Castbar:UpdatePips(stages)
		Handles updates for stage separators (pips) in an empowered cast.

		* self   - the Castbar widget
		* stages - stages with percentage of each stage (table)
		--]]
		(element.UpdatePips or UpdatePips) (element, UnitEmpoweredStagePercentages(unit))
	end

	--[[ Callback: Castbar:PostCastStart(unit, spellID, notInterruptible, name, texture, isTradeSkill)
	Called after the element has been updated upon a spell cast or channel start.

	* self             - the Castbar widget
	* unit             - the unit for which the update has been triggered (string)
	* spellID          - the ID of the spell (number)
	* notInterruptible - whether the spell is interruptible (boolean)
	* name             - the name of the spell (string)
	* texture          - the texture path associated with the spell (string/number)
	* isTradeSkill     - whether the spell is associated with a profession (boolean)
	--]]
	if(element.PostCastStart) then
		element:PostCastStart(unit, spellID, notInterruptible, displayName, texture, isTradeSkill)
	end

	element:Show()
end

local function CastUpdate(self, event, eventUnit, _castGUID, spellID, castID)
	local element = self.Castbar
	local unit = GetDisplayUnit(element, eventUnit)
	if(not unit) then return end

	if(not element:IsShown() or not castID or STATE[element].castID ~= castID) then
		return
	end

	local direction = Enum.StatusBarTimerDirection.ElapsedTime
	local duration, startTime, delayTime, isTradeSkill, _
	if(event == 'UNIT_SPELLCAST_DELAYED') then
		_, _, _, _, _, isTradeSkill, _, _, _, _, delayTime = UnitCastingInfo(unit)
		duration = UnitCastingDuration(unit)
	else
		_, _, _, startTime, _, isTradeSkill = UnitChannelInfo(unit)
		if(event == 'UNIT_SPELLCAST_EMPOWER_UPDATE') then
			duration = UnitEmpoweredChannelDuration(unit)
		else
			duration = UnitChannelDuration(unit)
			direction = Enum.StatusBarTimerDirection.RemainingTime
		end
	end

	if(isTradeSkill == nil) then return end

	if(unit == 'player' and startTime) then
		-- we can only calculate delay for players
		startTime = startTime / 1000

		local delta
		if(STATE[element].channeling) then
			delta = STATE[element].startTime - startTime
		else
			delta = startTime - STATE[element].startTime
		end

		if(delta < 0) then
			delta = 0
		end

		STATE[element].delay = STATE[element].delay + delta
	elseif(delayTime) then
		STATE[element].delay = STATE[element].delay + (delayTime / 1000)
	end

	element:SetTimerDuration(duration, element.smoothing, direction)

	if(element.Time) then
		element.Time.binding:SetDuration(duration)
	end

	--[[ Callback: Castbar:PostCastUpdate(unit, spellID, duration, direction)
	Called after the element has been updated when a spell cast or channel has been updated.

	* self      - the Castbar widget
	* unit      - the unit that the update has been triggered (string)
	* spellID   - the ID of the spell (number)
	* duration  - the duration object associated with the cast ([DurationObject](https://warcraft.wiki.gg/wiki/ScriptObject_DurationObject))
	* direction - the direction of the duration object (number)
	--]]
	if(element.PostCastUpdate) then
		return element:PostCastUpdate(unit, spellID, duration, direction)
	end
end

local function CastStop(self, event, eventUnit, _castGUID, spellID, ...)
	local element = self.Castbar
	local unit = GetDisplayUnit(element, eventUnit)
	if(not unit) then return end

	local castID, interruptedBy, empowerComplete
	if(event == 'UNIT_SPELLCAST_STOP') then
		castID = ...
	elseif(event == 'UNIT_SPELLCAST_EMPOWER_STOP') then
		empowerComplete, interruptedBy, castID = ...
	elseif(event == 'UNIT_SPELLCAST_CHANNEL_STOP') then
		interruptedBy, castID = ...
	end

	if(not element:IsShown() or not castID or STATE[element].castID ~= castID) then
		return
	end

	if(element.Spark) then element.Spark:Hide() end

	local wasInterrupted = HasInterruptedBy(interruptedBy)
	if(wasInterrupted) then
		if(element.Text) then element.Text:SetText(INTERRUPTED) end

		STATE[element].holdTime = element.timeToHold or 0

		-- force filled castbar
		element:SetMinMaxValues(0, 1)
		element:SetValue(1)
	end

	if(wasInterrupted) then
		--[[ Callback: Castbar:PostCastInterrupted(unit, spellID, interruptedBy)
		Called after the element has been updated when a spell cast or channel has stopped.

		* self          - the Castbar widget
		* unit          - the unit for which the update has been triggered (string)
		* spellID       - the ID of the spell (number)
		* interruptedBy - GUID of whomever interrupted the cast (string)
		--]]
		if(element.PostCastInterrupted) then
			element:PostCastInterrupted(unit, spellID, interruptedBy)
		end
	else
		--[[ Callback: Castbar:PostCastStop(unit, spellID[, empowerComplete])
		Called after the element has been updated when a spell cast or channel has stopped.

		* self            - the Castbar widget
		* unit            - the unit for which the update has been triggered (string)
		* spellID         - the ID of the spell (number)
		* empowerComplete - if the empowered cast was complete (boolean?)
		--]]
		if(element.PostCastStop) then
			element:PostCastStop(unit, spellID, empowerComplete)
		end
	end

	resetState(element)
end

local function CastFail(self, event, eventUnit, _castGUID, spellID, ...)
	local element = self.Castbar
	local unit = GetDisplayUnit(element, eventUnit)
	if(not unit) then return end

	local castID, interruptedBy
	if(event == 'UNIT_SPELLCAST_INTERRUPTED') then
		interruptedBy, castID = ...
	elseif(event == 'UNIT_SPELLCAST_FAILED') then
		castID = ...
	end

	if(not element:IsShown() or not castID or STATE[element].castID ~= castID) then
		return
	end

	if(element.Text) then
		element.Text:SetText(event == 'UNIT_SPELLCAST_FAILED' and FAILED or INTERRUPTED)
	end

	if(element.Spark) then element.Spark:Hide() end

	STATE[element].holdTime = element.timeToHold or 0

	-- force filled castbar
	element:SetMinMaxValues(0, 1)
	element:SetValue(1)

	if(event == 'UNIT_SPELLCAST_INTERRUPTED') then
		if(element.PostCastInterrupted) then
			element:PostCastInterrupted(unit, spellID, interruptedBy)
		end
	else
		--[[ Callback: Castbar:PostCastFail(unit, spellID)
		Called after the element has been updated upon a failed or interrupted spell cast.

		* self    - the Castbar widget
		* unit    - the unit for which the update has been triggered (string)
		* spellID - the ID of the spell (number)
		--]]
		if(element.PostCastFail) then
			element:PostCastFail(unit, spellID)
		end
	end

	resetState(element)
end

local function CastInterruptible(self, _event, eventUnit)
	local element = self.Castbar
	local unit = GetDisplayUnit(element, eventUnit)
	if(not unit) then return end

	if(not element:IsShown()) then return end

	-- The event has no castBarID, so re-query the active unit instead of trusting its unit payload.
	local isTradeSkill, notInterruptible, _
	_, _, _, _, _, isTradeSkill, _, notInterruptible = UnitCastingInfo(unit)
	if(isTradeSkill == nil) then
		_, _, _, _, _, isTradeSkill, notInterruptible = UnitChannelInfo(unit)
	end
	if(isTradeSkill == nil) then return end

	STATE[element].notInterruptible = notInterruptible

	if(element.Shield) then element.Shield:SetAlphaFromBoolean(notInterruptible, 1, 0) end

	--[[ Callback: Castbar:PostCastInterruptible(unit, spellID, notInterruptible)
	Called after the element has been updated when a spell cast has become interruptible or uninterruptible.

	* self             - the Castbar widget
	* unit             - the unit for which the update has been triggered (string)
	* spellID          - the ID of the spell (number)
	* notInterruptible - whether the spell is interruptible (boolean)
	--]]
	if(element.PostCastInterruptible) then
		return element:PostCastInterruptible(unit, STATE[element].spellID, notInterruptible)
	end
end

local globalTimer
local function globalTimerCallback(element)
	-- ensure a real cast hasn't started
	if(not STATE[element].castID) then
		resetState(element)
	end

	globalTimer = nil
end

local function CastGlobal(self, _event, eventUnit, _castGUID, spellID)
	local element = self.Castbar
	local unit = GetDisplayUnit(element, eventUnit)
	if(not unit) then return end

	-- ensure a real cast is not active
	if(STATE[element].castID) then
		return
	end

	local cooldownInfo = C_Spell.GetSpellCooldown(GLOBAL_SPELL_ID)
	if(not (cooldownInfo and cooldownInfo.isOnGCD and cooldownInfo.duration > 0)) then
		return
	end

	if(globalTimer) then
		globalTimer:Cancel()
	end

	-- reset first
	resetState(element)

	-- we need to fake some data
	STATE[element].channeling = true

	local duration = C_DurationUtil.CreateDuration()
	duration:SetTimeFromStart(cooldownInfo.startTime, cooldownInfo.duration, cooldownInfo.modRate)

	element:SetTimerDuration(duration, element.smoothing, Enum.StatusBarTimerDirection.RemainingTime)

	if(element.Time) then
		element.Time.binding:SetDuration(duration)
	end

	-- we need to reset manually
	local resetTime = cooldownInfo.duration - (GetTime() - cooldownInfo.startTime)
	globalTimer = C_Timer.NewTimer(resetTime, GenerateClosure(globalTimerCallback, element))

	--[[ Callback: Castbar:PostCastGlobal(unit, spellID, cooldownInfo, duration)
	Called after the element has been updated upon a spell global cooldown.

	* self         - the Castbar widget
	* unit         - the unit for which the update has been triggered (string)
	* spellID      - the ID of the spell (number)
	* cooldownInfo - cooldown information related to the cast (table)
	* duration     - the duration object associated with the cast ([DurationObject](https://warcraft.wiki.gg/wiki/ScriptObject_DurationObject))
	--]]
	if(element.PostCastGlobal) then
		element:PostCastGlobal(unit, spellID, cooldownInfo, duration)
	end

	element:Show()
end

local function onUpdate(self, elapsed)
	if(STATE[self].holdTime and STATE[self].holdTime > 0) then
		STATE[self].holdTime = STATE[self].holdTime - elapsed
	elseif((not STATE[self].holdTime or STATE[self].holdTime == 0) and (STATE[self].casting or STATE[self].channeling or STATE[self].empowering)) then
		if(self.Delay) then
			if(STATE[self].delay and STATE[self].delay ~= 0) then
				local isChanneling = STATE[self].channeling
				--[[ Override: Castbar:CustomDelayText(delay, isChanneling)
				Used to completely override the updating of the .Delay sub-widget when there is a delay in the cast.

				* self         - the Castbar widget
				* delay        - the amount of time the cast is delayed for
				* isChanneling - whether the cast is considered a channel or not
				--]]
				if(self.CustomDelayText) then
					self:CustomDelayText(STATE[self].delay, isChanneling)
				else
					self.Delay:SetFormattedText('%s%.2f', isChanneling and '-' or '+', STATE[self].delay)
				end
			else
				self.Delay:SetText('')
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
	else
		resetState(self)
		self:Hide()
	end
end

local function Update(...)
	CastStart(...)
end

local function ForceUpdate(element)
	return Update(element.__owner, 'ForceUpdate', element.__owner.__unit)
end

local eventMethods = {
	UNIT_SPELLCAST_START = CastStart,
	UNIT_SPELLCAST_CHANNEL_START = CastStart,
	UNIT_SPELLCAST_EMPOWER_START = CastStart,
	UNIT_SPELLCAST_STOP = CastStop,
	UNIT_SPELLCAST_CHANNEL_STOP = CastStop,
	UNIT_SPELLCAST_EMPOWER_STOP = CastStop,
	UNIT_SPELLCAST_DELAYED = CastUpdate,
	UNIT_SPELLCAST_CHANNEL_UPDATE = CastUpdate,
	UNIT_SPELLCAST_EMPOWER_UPDATE = CastUpdate,
	UNIT_SPELLCAST_FAILED = CastFail,
	UNIT_SPELLCAST_INTERRUPTED = CastFail,
	UNIT_SPELLCAST_INTERRUPTIBLE = CastInterruptible,
	UNIT_SPELLCAST_NOT_INTERRUPTIBLE = CastInterruptible,
}

local function Enable(self, unit)
	local element = self.Castbar
	if(element and unit and not unit:match('%wtarget$')) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		STATE[element] = {}

		if(not element.smoothing) then
			element.smoothing = Enum.StatusBarInterpolation.Immediate
		end

		for event, method in next, eventMethods do
			self:RegisterEvent(event, method)
		end

		if(unit == 'player' and element.showGlobalCooldown) then
			self:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED', CastGlobal)
		end

		element.Pips = element.Pips or {}

		element:SetScript('OnUpdate', element.OnUpdate or onUpdate)

		if(unit == 'player' and not (self.hasChildren or self.isChild or self.isNamePlate)) then
			PlayerCastingBarFrame:UnregisterAllEvents()
			PlayerCastingBarFrame:Hide()
			PetCastingBarFrame:UnregisterAllEvents()
			PetCastingBarFrame:Hide()
		end

		local Time = element.Time
		if(Time) then
			if(not Time.binding) then
				Time.binding = C_DurationUtil.CreateDurationTextBinding()
				Time.binding:SetFormatter(Time.formatter or defaultFormatter)
			end

			Time.binding:SetFontString(Time)
			Time.binding:SetEnabled(true)
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

local function Disable(self, unit)
	local element = self.Castbar
	if(element) then
		element:Hide()

		for event, method in next, eventMethods do
			self:UnregisterEvent(event, method)
		end

		if(unit == 'player' and element.showGlobalCooldown) then
			self:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED', CastGlobal)
		end

		element:SetScript('OnUpdate', nil)

		if(element.Time) then
			element.Time.binding:SetEnabled(false)
		end

		if(unit == 'player' and not (self.hasChildren or self.isChild or self.isNamePlate)) then
			for event in next, eventMethods do
				PlayerCastingBarFrame:RegisterUnitEvent(event, 'player')
				PetCastingBarFrame:RegisterUnitEvent(event, 'pet')
			end

			PlayerCastingBarFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
			PetCastingBarFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
			PetCastingBarFrame:RegisterEvent('UNIT_PET')
		end
	end
end

oUF:AddElement('Castbar', Update, Enable, Disable)
