--[[
	## Element: oUF_RaidAuras, by Siweia

	One time UnitAura for all needs.
]]
local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF

local UnitIsUnit = UnitIsUnit
local UnitIsOwnerOrControllerOfUnit = UnitIsOwnerOrControllerOfUnit
local C_UnitAuras_GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex

local maxBuffs = 40
local maxDebufs = 20

local function UpdateAuras(element, list, maxButtons, unit, filter)
	list.num = 0

	for index = 1, maxButtons do
		local auraData = C_UnitAuras_GetAuraDataByIndex(unit, index, filter)
		if not auraData then break end

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
		aura.priority = -1

		-- UnitAura returns
		aura.name = auraData.name
		aura.texture = auraData.icon
		aura.count = auraData.applications
		aura.debuffType = auraData.dispelName
		aura.duration = auraData.duration
		aura.expiration = auraData.expirationTime
		aura.caster = auraData.sourceUnit
		aura.isStealable = auraData.isStealable
		aura.nameplateShowSelf = auraData.nameplateShowPersonal
		aura.spellID = auraData.spellId
		aura.canApply = auraData.canApplyAura
		aura.isBossAura = auraData.isBossAura
		-- aura.casterIsPlayer = casterIsPlayer -- use .isPlayerAura instead
		aura.isPlayerAura = aura.caster and (UnitIsUnit("player", aura.caster) or UnitIsOwnerOrControllerOfUnit("player", aura.caster))
		aura.nameplateShowAll = auraData.nameplateShowAll
		aura.timeMod = auraData.timeMod
		aura.effect1 = auraData.points[1]
		aura.effect2 = auraData.points[2]
		aura.effect3 = auraData.points[3]
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