local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF

local debugMode = false
local class = DB.MyClass
local RaidDebuffsIgnore, invalidPrio = {}, -1

local DispellColor = {
	["Magic"]	= {.2, .6, 1},
	["Curse"]	= {.6, 0, 1},
	["Disease"]	= {.6, .4, 0},
	["Poison"]	= {0, .6, 0},
	["none"]	= {0, 0, 0},
}

local DispellPriority = {
	["Magic"]	= 4,
	["Curse"]	= 3,
	["Disease"]	= 2,
	["Poison"]	= 1,
}

local DispellFilter
do
	local dispellClasses = {
		["DRUID"] = {
			["Curse"] = true,
			["Poison"] = true,
		},
		["PALADIN"] = {
			["Magic"] = true,
			["Poison"] = true,
			["Disease"] = true,
		},
		["PRIEST"] = {
			["Magic"] = true,
			["Disease"] = true,
		},
		["SHAMAN"] = {
			["Poison"] = true,
			["Disease"] = true,
		},
		["MAGE"] = {
			["Curse"] = true,
		},
		["WARLOCK"] = {
			["Magic"] = true,
		},
	}

	DispellFilter = dispellClasses[class] or {}
end

local function UpdateDebuffFrame(self, name, icon, count, debuffType, duration, expiration)
	local rd = self.RaidDebuffs
	if name then
		if rd.icon then
			rd.icon:SetTexture(icon)
			rd.icon:Show()
		end

		if rd.count then
			if count and count > 1 then
				rd.count:SetText(count)
				rd.count:Show()
			else
				rd.count:Hide()
			end
		end

		if rd.timer then
			rd.duration = duration
			if duration and duration > 0 then
				rd.expiration = expiration
				rd:SetScript("OnUpdate", B.CooldownOnUpdate)
				rd.timer:Show()
			else
				rd:SetScript("OnUpdate", nil)
				rd.timer:Hide()
			end
		end

		if rd.cd then
			if duration and duration > 0 then
				rd.cd:SetCooldown(expiration - duration, duration)
				rd.cd:Show()
			else
				rd.cd:Hide()
			end
		end

		local c = DispellColor[debuffType] or DispellColor.none
		if rd.ShowDebuffBorder and rd.__shadow then
			rd.__shadow:SetBackdropBorderColor(c[1], c[2], c[3])
		end

		if rd.glowFrame then
			if rd.priority == 6 then
				B.ShowOverlayGlow(rd.glowFrame)
			else
				B.HideOverlayGlow(rd.glowFrame)
			end
		end

		rd:Show()
	else
		rd:Hide()
	end
end

local instID
local function checkInstance()
	instID = select(8, GetInstanceInfo())
end

local emptyDebuffs = {}

local function Update(self, _, unit)
	if unit ~= self.unit then return end

	local rd = self.RaidDebuffs
	rd.priority = invalidPrio
	rd.filter = "HARMFUL"

	local _name, _icon, _count, _debuffType, _duration, _expiration
	local debuffs = rd.Debuffs or emptyDebuffs
	local isCharmed = UnitIsCharmed(unit)
	local canAttack = UnitCanAttack("player", unit)
	local prio

	for i = 1, 32 do
		local name, icon, count, debuffType, duration, expiration, _, _, _, spellId = UnitAura(unit, i, rd.filter)
		if not name then break end

		if rd.ShowDispellableDebuff and debuffType and (not isCharmed) and (not canAttack) then
			if C.db["UFs"]["DispellOnly"] then
				prio = DispellFilter[debuffType] and (DispellPriority[debuffType] + 6) or invalidPrio
				if prio == invalidPrio then debuffType = nil end
			else
				prio = DispellPriority[debuffType]
			end

			if prio and prio > rd.priority then
				rd.priority, rd.index, rd.spellID = prio, i, spellId
				_name, _icon, _count, _debuffType, _duration, _expiration = name, icon, count, debuffType, duration, expiration
			end
		end

		local instPrio
		local debuffList = instID and debuffs[instID] or debuffs[0]
		if debuffList then
			instPrio = debuffList[spellId]
		end

		if not RaidDebuffsIgnore[spellId] and instPrio and (instPrio == 6 or instPrio > rd.priority) then
			rd.priority, rd.index, rd.spellID = instPrio, i, spellId
			_name, _icon, _count, _debuffType, _duration, _expiration = name, icon, count, debuffType, duration, expiration
		end
	end

	if debugMode then
		rd.priority = 6
		_name, _, _icon = GetSpellInfo(168)
		_count, _debuffType, _duration, _expiration = 2, "Magic", 10, GetTime()+10, 0
	end

	if rd.priority == invalidPrio then
		rd.index, rd.spellID, _name = nil, nil, nil
	end

	UpdateDebuffFrame(self, _name, _icon, _count, _debuffType, _duration, _expiration)
end

local function Path(self, ...)
	return (self.RaidDebuffs.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
	local rd = self.RaidDebuffs
	if rd then
		self:RegisterEvent("UNIT_AURA", Path)
		rd.ForceUpdate = ForceUpdate
		rd.__owner = self
		return true
	end

	checkInstance()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", checkInstance, true)
end

local function Disable(self)
	if self.RaidDebuffs then
		self:UnregisterEvent("UNIT_AURA", Path)
		self.RaidDebuffs:Hide()
		self.RaidDebuffs.__owner = nil
	end

	self:UnregisterEvent("PLAYER_ENTERING_WORLD", checkInstance)
end

oUF:AddElement("RaidDebuffs", Update, Enable, Disable)