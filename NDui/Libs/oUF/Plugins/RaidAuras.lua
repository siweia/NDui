--[[
	## Element: oUF_RaidAuras, by Siweia

	One time UnitAura for all needs.
]]
local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF

local UnitAura = UnitAura
local UnitIsUnit = UnitIsUnit
local UnitIsOwnerOrControllerOfUnit = UnitIsOwnerOrControllerOfUnit

local maxBuffs = 40
local maxDebufs = 20

local function UpdateAuras(element, list, maxButtons, unit, filter)
	list.num = 0

	for index = 1, maxButtons do
		local name, texture, count, debuffType, duration, expiration, caster, isStealable,
		nameplateShowSelf, spellID, canApply, isBossAura, casterIsPlayer, nameplateShowAll,
		timeMod, effect1, effect2, effect3 = UnitAura(unit, index, filter)
		if not name then break end

		list.num = list.num + 1
		local aura = list[list.num]
		if not aura then
			list[list.num] = {}
			aura = list[list.num]
		end

		aura.unit = unit
		aura.index = index
		aura.filter = filter
		aura.isDebuff = filter == "HARMFUL"
		aura.isPlayerAura = caster and (UnitIsUnit("player", caster) or UnitIsOwnerOrControllerOfUnit("player", caster))
		aura.priority = -1

		-- UnitAura returns
		aura.name = name
		aura.texture = texture
		aura.count = count
		aura.debuffType = debuffType
		aura.duration = duration
		aura.expiration = expiration
		aura.caster = caster
		aura.isStealable = isStealable
		aura.nameplateShowSelf = nameplateShowSelf
		aura.spellID = spellID
		aura.canApply = canApply
		aura.isBossAura = isBossAura
		-- aura.casterIsPlayer = casterIsPlayer -- use .isPlayerAura instead
		aura.nameplateShowAll = nameplateShowAll
		aura.timeMod = timeMod
		aura.effect1 = effect1
		aura.effect2 = effect2
		aura.effect3 = effect3
	end
end

local function Update(self, event, unit, isFullUpdate, updatedAuras)
	if self.unit ~= unit then return end

	local element = self.RaidAuras
	if element then
		if element.PreUpdate then
			element:PreUpdate(unit, isFullUpdate, updatedAuras)
		end

		UpdateAuras(element, element.buffList, maxBuffs, unit, "HELPFUL")
		UpdateAuras(element, element.debuffList, maxDebufs, unit, "HARMFUL")

		if element.PostUpdate then
			element:PostUpdate(unit, isFullUpdate, updatedAuras)
		end
	end
end

local function Path(self, ...)
	return (self.RaidAuras.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
	local element = self.RaidAuras
	if element then
		element.buffList = {}
		element.debuffList = {}
		element.ForceUpdate = ForceUpdate
		element.__owner = self

		self:RegisterEvent("UNIT_AURA", Path)
		return true
	end
end

local function Disable(self)
	local element = self.RaidAuras
	if element then
		wipe(element.list)
		wipe(element.debuffList)
		self:UnregisterEvent("UNIT_AURA", Path)
	end
end

oUF:AddElement("RaidAuras", Update, Enable, Disable)