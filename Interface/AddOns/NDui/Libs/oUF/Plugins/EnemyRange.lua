--[[
# Element: EnemyRange Fader, modify from oUF_Range

Changes the opacity of a unit frame based on whether the frame's unit is in the player's range.

## Widget

EnemyRange - A table containing opacity values.

## Notes

Offline units are handled as if they are in range.

## Options

.outsideAlpha - Opacity when the unit is out of range. Defaults to 0.55 (number)[0-1].
.insideAlpha  - Opacity when the unit is within range. Defaults to 1 (number)[0-1].

## Examples

	-- Register with oUF
	self.EnemyRange = {
		insideAlpha = 1,
		outsideAlpha = 1/2,
	}
--]]

local _, ns = ...
local oUF = ns.oUF

local _FRAMES = {}
local OnRangeFrame

local next = next
local UnitInRange, UnitIsConnected = UnitInRange, UnitIsConnected
local InCombatLockdown, CheckInteractDistance, UnitCanAttack = InCombatLockdown, CheckInteractDistance, UnitCanAttack
local IsSpellInRange = C_Spell.IsSpellInRange
local myClass = select(2, UnitClass('player'))

local CHECK_SPELLS = {
	DEATHKNIGHT = {
		[49576] = 'Death Grip',
	},
	DEMONHUNTER = {
		[278326] = 'Consume Magic'
	},
	DRUID = {
		[8921] = 'Moonfire'
	},
	EVOKER = {
		[362969] = 'Azure Strike'
	},
	HUNTER = {
		[75] = 'Auto Shot'
	},
	MAGE = {
		[2139] = 'Counterspell'
	},
	MONK = {
		[115546] = 'Provoke'
	},
	PALADIN = {
		[20473] = 'Holy Shock',
		[20271] = 'Judgement'
	},
	PRIEST = {
		[589] = 'Shadow Word: Pain'
	},
	ROGUE = {
		[36554] = 'Shadowstep'
	},
	SHAMAN = {
		[8042] = 'Earth Shock',
		[188196] = 'Lightning Bolt',
	},
	WARLOCK = {
		[234153] = 'Drain Life',
	},
	WARRIOR = {
		[355] = 'Taunt'
	}
}

local function UnitSpellRangeCheck(unit, spells)
	local failed
	for spell in next, spells do
		local range = IsSpellInRange(spell, unit)
		if range then
			return true
		elseif range ~= nil then
			failed = true -- keep looking for other spells
		end
	end
	if failed then
		return false
	end
end

local function CheckUnitRange(unit)
	local spells = CHECK_SPELLS[myClass]
	local range = (not next(spells) and 1) or UnitSpellRangeCheck(unit, spells)

	if (not range or range == 1) and not InCombatLockdown() then
		return CheckInteractDistance(unit, 4) -- check follow interact when not in combat
	else
		return (range == nil and 1) or range -- nil: various reason it cant be checked; ie: cant be cast on the unit
	end
end

local function Update(self, event)
	local element = self.EnemyRange
	local unit = self.unit

	if unit and UnitCanAttack("player", unit) then
		local inRange = CheckUnitRange(unit)
		if inRange then
			self:SetAlpha(element.insideAlpha)
		else
			self:SetAlpha(element.outsideAlpha)
		end
	else
		self:SetAlpha(element.insideAlpha)
	end

	--[[ Callback: EnemyRange:PostUpdate(object, inRange, checkedRange, isConnected)
	Called after the element has been updated.

	* self         - the EnemyRange element
	* object       - the parent object
	* inRange      - indicates if the unit was within 40 yards of the player (boolean)
	* checkedRange - indicates if the range check was actually performed (boolean)
	* isConnected  - indicates if the unit is online (boolean)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(self, inRange)
	end
end

local function Path(self, ...)
	--[[ Override: EnemyRange.Override(self, event)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	--]]
	return (self.EnemyRange.Override or Update) (self, ...)
end

-- Internal updating method
local timer = 0
local function OnRangeUpdate(_, elapsed)
	timer = timer + elapsed

	if(timer >= .20) then
		for _, object in next, _FRAMES do
			if(object:IsShown()) then
				Path(object, 'OnUpdate')
			end
		end

		timer = 0
	end
end

local function Enable(self)
	local element = self.EnemyRange
	if(element) then
		element.__owner = self
		element.insideAlpha = element.insideAlpha or 1
		element.outsideAlpha = element.outsideAlpha or .55

		if(not OnRangeFrame) then
			OnRangeFrame = CreateFrame('Frame')
			OnRangeFrame:SetScript('OnUpdate', OnRangeUpdate)
		end

		table.insert(_FRAMES, self)
		OnRangeFrame:Show()

		return true
	end
end

local function Disable(self)
	local element = self.EnemyRange
	if(element) then
		for index, frame in next, _FRAMES do
			if(frame == self) then
				table.remove(_FRAMES, index)
				break
			end
		end
		self:SetAlpha(element.insideAlpha)

		if(#_FRAMES == 0) then
			OnRangeFrame:Hide()
		end
	end
end

oUF:AddElement('EnemyRange', nil, Enable, Disable)