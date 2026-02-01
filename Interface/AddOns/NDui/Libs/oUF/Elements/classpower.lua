--[[
# Element: ClassPower

Handles the visibility and updating of the player's class resources (like Chi Orbs or Holy Power) and combo points.

## Widget

ClassPower - An `table` consisting of as many StatusBars as the theoretical maximum return of [UnitPowerMax](https://warcraft.wiki.gg/wiki/API_UnitPowerMax).

## Notes

A default texture will be applied if the sub-widgets are StatusBars and don't have a texture set.
If the sub-widgets are StatusBars, their minimum and maximum values will be set to 0 and 1 respectively.

Supported class powers:
  - All          - Combo Points
  - Demon Hunter - Soul Fragments
  - Evoker       - Essence
  - Mage         - Arcane Charges
  - Monk         - Chi Orbs
  - Paladin      - Holy Power
  - Shaman       - Maelstrom Weapon
  - Warlock      - Soul Shards

## Examples

    local ClassPower = {}
    for index = 1, 10 do
        local Bar = CreateFrame('StatusBar', nil, self)

        -- Position and size.
        Bar:SetSize(16, 16)
        Bar:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', (index - 1) * Bar:GetWidth(), 0)

        ClassPower[index] = Bar
    end

    -- Register with oUF
    self.ClassPower = ClassPower
--]]

local _, ns = ...
local oUF = ns.oUF

local playerClass = UnitClassBase('player')

-- sourced from Blizzard_FrameXMLBase/Constants.lua
local SPEC_DEMONHUNTER_DEVOURER = _G.SPEC_DEMONHUNTER_DEVOURER or 3
local SPEC_MAGE_ARCANE = _G.SPEC_MAGE_ARCANE or 1
local SPEC_MONK_WINDWALKER = _G.SPEC_MONK_WINDWALKER or 3
local SPEC_SHAMAN_ENCHANCEMENT = 2
local SPEC_WARLOCK_DESTRUCTION = _G.SPEC_WARLOCK_DESTRUCTION or 3

local POWER_ID_ARCANE_CHARGES = Enum.PowerType.ArcaneCharges or 16
local POWER_ID_CHI = Enum.PowerType.Chi or 12
local POWER_ID_COMBO_POINTS = Enum.PowerType.ComboPoints or 4
local POWER_ID_ENERGY = Enum.PowerType.Energy or 3
local POWER_ID_ESSENCE = Enum.PowerType.Essence or 19
local POWER_ID_HOLY_POWER = Enum.PowerType.HolyPower or 9
local POWER_ID_SOUL_SHARDS = Enum.PowerType.SoulShards or 7

local POWER_TYPE_ARCANE_CHARGES = 'ARCANE_CHARGES'
local POWER_TYPE_CHI = 'CHI'
local POWER_TYPE_COMBO_POINTS = 'COMBO_POINTS'
local POWER_TYPE_ESSENCE = 'ESSENCE'
local POWER_TYPE_HOLY_POWER = 'HOLY_POWER'
local POWER_TYPE_MAELSTROM = 'MAELSTROM'
local POWER_TYPE_SOUL_FRAGMENTS = 'SOUL_FRAGMENTS' -- fake, but it's present in PowerBarColor
local POWER_TYPE_SOUL_SHARDS = 'SOUL_SHARDS'

local SPELL_DARK_HEART = Constants.UnitPowerSpellIDs.DARK_HEART_SPELL_ID or 1225789
local SPELL_MAELSTROM_WEAPON = 344179
local SPELL_MAELSTROM_WEAPON_TALENT = 187880
local SPELL_SHRED = 5221
local SPELL_SILENCE_THE_WHISPERS = Constants.UnitPowerSpellIDs.SILENCE_THE_WHISPERS_SPELL_ID or 1227702
local SPELL_VOID_METAMORPHOSIS = Constants.UnitPowerSpellIDs.VOID_METAMORPHOSIS_SPELL_ID or 1217607

local SOUL_FRAGMENTS_NO_META_INDEX = 1
local SOUL_FRAGMENTS_META_INDEX = 2

local ClassPowerEnable, ClassPowerDisable
local GetPower, GetPowerMax, GetPowerColor, GetPowerUpdaters

-- holds class-specific information for enablement toggles
local classPowerID, classPowerType, classAuraID
local requireSpec, requirePower, requireSpell

local function GetGenericPower(unit)
	return UnitPower(unit, classPowerID)
	end

local function GetGenericPowerMax(unit)
	return UnitPowerMax(unit, classPowerID)
end

local function GetGenericPowerColor(element, powerType)
	return element.__owner.colors.power[powerType]
end

local function GetComboPoints(unit)
	return UnitPower(unit, POWER_ID_COMBO_POINTS), GetUnitChargedPowerPoints(unit)
end

local function GetComboPointsMax(unit)
	return UnitPowerMax(unit, POWER_ID_COMBO_POINTS)
end

if(playerClass == 'DEMONHUNTER') then
	requireSpec = SPEC_DEMONHUNTER_DEVOURER
	classAuraID = SPELL_VOID_METAMORPHOSIS
	classPowerType = POWER_TYPE_SOUL_FRAGMENTS

	local function GetSoulFragments()
		if(C_UnitAuras.GetPlayerAuraBySpellID(SPELL_VOID_METAMORPHOSIS)) then
			local auraInfo = C_UnitAuras.GetPlayerAuraBySpellID(SPELL_SILENCE_THE_WHISPERS)
			if(auraInfo) then
				return auraInfo.applications / GetCollapsingStarCost()
			end
		else
			local auraInfo = C_UnitAuras.GetPlayerAuraBySpellID(SPELL_DARK_HEART)
			if(auraInfo) then
				return auraInfo.applications / C_Spell.GetSpellMaxCumulativeAuraApplications(SPELL_DARK_HEART)
			end
		end

		return 0
	end

	local function GetSoulFragmentsMax()
		-- we use normalised cur so that there's only 1 bar instead of 30-50
		return 1
	end

	local function GetSoulFragmentsColor(element)
		local color = element.__owner.colors.power[POWER_TYPE_SOUL_FRAGMENTS]
		if(color) then
			if(C_UnitAuras.GetPlayerAuraBySpellID(SPELL_VOID_METAMORPHOSIS)) then
				return color[SOUL_FRAGMENTS_META_INDEX]
			end

			return color[SOUL_FRAGMENTS_NO_META_INDEX]
		end
	end

	GetPowerUpdaters = function()
		return GetSoulFragments, GetSoulFragmentsMax, GetSoulFragmentsColor
	end
elseif(playerClass == 'DRUID') then
	classPowerID = POWER_ID_COMBO_POINTS
	classPowerType = POWER_TYPE_COMBO_POINTS
	requirePower = POWER_ID_ENERGY
	requireSpell = SPELL_SHRED

	GetPowerUpdaters = function()
		return GetComboPoints, GetComboPointsMax, GetGenericPowerColor
	end
elseif(playerClass == 'EVOKER') then
	classPowerID = POWER_ID_ESSENCE
	classPowerType = POWER_TYPE_ESSENCE

	GetPowerUpdaters = function()
		return GetGenericPower, GetGenericPowerMax, GetGenericPowerColor
	end
elseif(playerClass == 'MAGE') then
	classPowerID = POWER_ID_ARCANE_CHARGES
	classPowerType = POWER_TYPE_ARCANE_CHARGES
	requireSpec = SPEC_MAGE_ARCANE

	GetPowerUpdaters = function()
		return GetGenericPower, GetGenericPowerMax, GetGenericPowerColor
	end
elseif(playerClass == 'MONK') then
	classPowerID = POWER_ID_CHI
	classPowerType = POWER_TYPE_CHI
	requireSpec = SPEC_MONK_WINDWALKER

	GetPowerUpdaters = function()
		return GetGenericPower, GetGenericPowerMax, GetGenericPowerColor
	end
elseif(playerClass == 'PALADIN') then
	classPowerID = POWER_ID_HOLY_POWER
	classPowerType = POWER_TYPE_HOLY_POWER

	GetPowerUpdaters = function()
		return GetGenericPower, GetGenericPowerMax, GetGenericPowerColor
	end
elseif(playerClass == 'ROGUE') then
	classPowerID = POWER_ID_COMBO_POINTS
	classPowerType = POWER_TYPE_COMBO_POINTS

	GetPowerUpdaters = function()
		return GetComboPoints, GetComboPointsMax, GetGenericPowerColor
	end
elseif(playerClass == 'SHAMAN') then
	classAuraID = SPELL_MAELSTROM_WEAPON
	classPowerType = POWER_TYPE_MAELSTROM -- we re-use this from elemental for the colors
	requireSpec = SPEC_SHAMAN_ENCHANCEMENT
	requireSpell = SPELL_MAELSTROM_WEAPON_TALENT

	local function GetMaelstromWeapon()
		local auraInfo = C_UnitAuras.GetPlayerAuraBySpellID(SPELL_MAELSTROM_WEAPON)
		if(auraInfo) then
			return auraInfo.applications
		end

		return 0
	end

	local function GetMaelstromWeaponMax()
		return C_Spell.GetSpellMaxCumulativeAuraApplications(SPELL_MAELSTROM_WEAPON)
	end

	GetPowerUpdaters = function()
		return GetMaelstromWeapon, GetMaelstromWeaponMax, GetGenericPowerColor
	end
elseif(playerClass == 'WARLOCK') then
	classPowerID = POWER_ID_SOUL_SHARDS
	classPowerType = POWER_TYPE_SOUL_SHARDS

	local function GetSoulShardsDestruction(unit)
		return UnitPower(unit, POWER_ID_SOUL_SHARDS, true) / UnitPowerDisplayMod(POWER_ID_SOUL_SHARDS)
	end

	GetPowerUpdaters = function()
		if(C_SpecializationInfo.GetSpecialization() == SPEC_WARLOCK_DESTRUCTION) then
			return GetSoulShardsDestruction, GetGenericPowerMax, GetGenericPowerColor
		end

		return GetGenericPower, GetGenericPowerMax, GetGenericPowerColor
	end
end

local function UpdateColor(element, powerType)
	local color = GetPowerColor(element, powerType)
	if(color) then
		for i = 1, #element do
			local bar = element[i]
			bar:GetStatusBarTexture():SetVertexColor(color:GetRGB())
		end
	end

	--[[ Callback: ClassPower:PostUpdateColor(color)
	Called after the element color has been updated.

	* self  - the ClassPower element
	* color - the used ColorMixin-based object (table?)
	--]]
	if(element.PostUpdateColor) then
		element:PostUpdateColor(color)
	end
end

local function ColorPath(self)
	local element = self.ClassPower

	local powerType = classPowerType
	if(UnitHasVehicleUI('player')) then
		powerType = POWER_TYPE_COMBO_POINTS
	end

	--[[ Override: ClassPower:UpdateColor(powerType)
	Used to completely override the internal function for updating the widgets' colors.

	* self      - the ClassPower element
	* powerType - the active power type (string)
	--]]
	do
		(element.UpdateColor or UpdateColor) (element, powerType)
	end
end

local function Update(self, event, unit, powerType)
	if(not unit) then
		return
	elseif(unit == 'vehicle' and powerType ~= POWER_TYPE_COMBO_POINTS) then
		return
	elseif(not UnitIsUnit(unit, 'player')) then -- is this redundant?
		return
	elseif(event == 'UNIT_AURA' or event == 'UNIT_POWER_POINT_CHARGE') then
		-- fake the power type for events that don't provide any
		powerType = classPowerType
	elseif(not powerType or powerType ~= classPowerType) then
		return
	end

	local element = self.ClassPower

	--[[ Callback: ClassPower:PreUpdate(unit)
	Called before the element has been updated.

	* self - the ClassPower element
	* unit - the unit for which the update has been triggered (string)
	]]
	if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local cur, max, chargedPoints, hasMaxChanged
	if(event ~= 'ClassPowerDisable') then
		cur, chargedPoints = GetPower(unit)
		max = GetPowerMax(unit)

		hasMaxChanged = max ~= element.__max
		if(hasMaxChanged) then
			for i = 1, #element do
				element[i]:SetShown(i <= max)

				if(i > max) then
					element[i]:SetValue(0)
				end
			end

			element.__max = max
		end

		local hasCurChanged = cur ~= element.__cur
		if(hasCurChanged) then
			local numActive = cur + 0.9
			for i = 1, max do
				if(i > numActive) then
					element[i]:SetValue(0)
				else
					element[i]:SetValue(cur - i + 1)
				end
			end

			element.__cur = cur
		end
	end
	--[[ Callback: ClassPower:PostUpdate(cur, max, hasMaxChanged, powerType)
	Called after the element has been updated.

	* self          - the ClassPower element
	* cur           - the current amount of power (number)
	* max           - the maximum amount of power (number)
	* hasMaxChanged - indicates whether the maximum amount has changed since the last update (boolean)
	* powerType     - the active power type (string)
	* ...           - the indices of currently charged power points, if any
	--]]
	if(element.PostUpdate) then
		--return element:PostUpdate(cur, max, hasMaxChanged, powerType, unpack(chargedPoints or {}))
		return element:PostUpdate(cur, max, hasMaxChanged, powerType, chargedPoints) -- NDui mod
	end
end

local function Path(self, ...)
	--[[ Override: ClassPower.Override(self, event, unit, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.ClassPower.Override or Update) (self, ...)
end

local function Visibility(self, event, unit)
	local element = self.ClassPower
	local powerType, isAuraPower

	if(UnitHasVehicleUI('player')) then
		unit = 'vehicle'

		if(PlayerVehicleHasComboPoints()) then
			powerType = POWER_TYPE_COMBO_POINTS
		end
	elseif(classAuraID) then
		if(not requireSpec or requireSpec == C_SpecializationInfo.GetSpecialization()) then
			if(not requireSpell or C_SpellBook.IsSpellKnown(requireSpell)) then
				isAuraPower = true
				powerType = classPowerType
				unit = 'player'
			end
		end
	elseif(classPowerID) then
		if(not requireSpec or requireSpec == C_SpecializationInfo.GetSpecialization()) then
			if(not requirePower or requirePower == UnitPowerType('player')) then
				if(not requireSpell or C_SpellBook.IsSpellKnown(requireSpell)) then
					powerType = classPowerType
					unit = 'player'
				end
			end
		end
	end

	local wasEnabled = element.__isEnabled
	local shouldEnable = powerType ~= nil

	if(shouldEnable) then
		if(unit == 'vehicle') then
			GetPower, GetPowerMax, GetPowerColor = GetComboPoints, GetComboPointsMax, GetGenericPowerColor
		else
			GetPower, GetPowerMax, GetPowerColor = GetPowerUpdaters()
		end

		ColorPath(self)
	end

	if(shouldEnable ~= wasEnabled) then
		ClassPowerDisable(self, shouldEnable)

		if(shouldEnable) then
			ClassPowerEnable(self, isAuraPower)
		end

		--[[ Callback: ClassPower:PostVisibility(isVisible)
		Called after the element's visibility has been changed.

		* self      - the ClassPower element
		* isVisible - the current visibility state of the element (boolean)
		--]]
		if(element.PostVisibility) then
			element:PostVisibility(shouldEnable)
		end
	elseif(shouldEnable) then
		Path(self, event, unit, powerType)
	end
end

local function VisibilityPath(self, event, ...)
	if(event == 'TRAIT_CONFIG_UPDATED') then
		if(C_ClassTalents.GetActiveConfigID() ~= ...) then return end
	end

	--[[ Override: ClassPower.OverrideVisibility(self, event, unit)
	Used to completely override the internal visibility function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.ClassPower.OverrideVisibility or Visibility) (self, event, ...)
end

local function ForceUpdate(element)
	return VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit)
end

do
	function ClassPowerEnable(self, registerAuraEvents)
		if(registerAuraEvents) then
			self:RegisterEvent('UNIT_AURA', Path)
		else
			self:RegisterEvent('UNIT_MAXPOWER', Path)
			self:RegisterEvent('UNIT_POWER_UPDATE', Path)

			-- according to Blizz any class may receive this event due to specific spell auras
			self:RegisterEvent('UNIT_POWER_POINT_CHARGE', Path)
		end

		self:RegisterEvent('SPELLS_CHANGED', ColorPath, true)

		self.ClassPower.__isEnabled = true

		if(UnitHasVehicleUI('player')) then
			Path(self, 'ClassPowerEnable', 'vehicle', POWER_TYPE_COMBO_POINTS)
		else
			Path(self, 'ClassPowerEnable', 'player', classPowerType)
		end
	end

	function ClassPowerDisable(self, unregisterOnly)
		self:UnregisterEvent('UNIT_AURA', Path)
		self:UnregisterEvent('UNIT_POWER_UPDATE', Path)
		self:UnregisterEvent('UNIT_MAXPOWER', Path)
		self:UnregisterEvent('UNIT_POWER_POINT_CHARGE', Path)
		self:UnregisterEvent('SPELLS_CHANGED', ColorPath)

		if(not unregisterOnly) then
			local element = self.ClassPower
			for i = 1, #element do
				element[i]:Hide()
			end

			element.__max = 0
			element.__isEnabled = false
			Path(self, 'ClassPowerDisable', 'player', classPowerType)
		end
	end
end

local function Enable(self, unit)
	local element = self.ClassPower
	if(element and UnitIsUnit(unit, 'player')) then
		element.__owner = self
		element.__max = 0
		element.ForceUpdate = ForceUpdate

		if(requireSpec or requireSpell) then
			self:RegisterEvent('PLAYER_LEVEL_UP', VisibilityPath, true)
			self:RegisterEvent('TRAIT_CONFIG_UPDATED', VisibilityPath, true)
		end

		if(requirePower) then
			self:RegisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)
		end

		element.ClassPowerEnable = ClassPowerEnable
		element.ClassPowerDisable = ClassPowerDisable

		for i = 1, #element do
			local bar = element[i]
			if(bar:IsObjectType('StatusBar')) then
				if(not bar:GetStatusBarTexture()) then
					bar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
				end

				bar:SetMinMaxValues(0, 1)
			end
		end

		return true
	end
end

local function Disable(self)
	if(self.ClassPower) then
		ClassPowerDisable(self)

		self:UnregisterEvent('PLAYER_LEVEL_UP', VisibilityPath)
		self:UnregisterEvent('TRAIT_CONFIG_UPDATED', VisibilityPath)
		self:UnregisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)
	end
end

oUF:AddElement('ClassPower', VisibilityPath, Enable, Disable)