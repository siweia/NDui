-------------------------------
-- oUF_RaidDebuffs, by yleaf
-- NDui MOD
-------------------------------
local B, C, L, DB = unpack(select(2, ...))
local _, ns = ...
local oUF = ns.oUF

local CleanseName = GetSpellInfo(4987)

local bossDebuffPrio = 9999999
local invalidPrio = -1

local RaidDebuffsReverse = {}
local RaidDebuffsIgnore = {}

local auraFilters = {
	["HARMFUL"] = true,
	["HELPFUL"] = true,
}

local DispellColor = {
	["Magic"]	= {.2, .6, 1},
	["Curse"]	= {.6, 0, 1},
	["Disease"]	= {.6, .4, 0},
	["Poison"]	= {0, .6, 0},
	["none"]	= {1, 0, 0},
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
			["Magic"] = false,
			["Curse"] = true,
			["Poison"] = true,
		},
		["MAGE"] = {
			["Curse"] = true,
		},
		["MONK"] = {
			["Magic"] = true,
			["Poison"] = true,
			["Disease"] = true,
		},
		["PALADIN"] = {
			["Magic"] = false,
			["Poison"] = true,
			["Disease"] = true,
		},
		["PRIEST"] = {
			["Magic"] = false,
			["Disease"] = false,
		},
		["SHAMAN"] = {
			["Magic"] = false,
			["Curse"] = true,
		},
	}

	DispellFilter = dispellClasses[class] or {}
end

local function CheckSpec(tree)
	local activeGroup = GetActiveSpecGroup()
	if activeGroup and GetSpecialization(false, false, activeGroup) then
		return tree == GetSpecialization(false, false, activeGroup)
	end
end

local function CheckSpecs()
	if class == "DRUID" then
		if CheckSpec(4) then
			DispellFilter.Magic = true
		else
			DispellFilter.Magic = false
		end
	elseif class == "MONK" then
		if CheckSpec(2) then
			DispellFilter.Magic = true
		else
			DispellFilter.Magic = false
		end
	elseif class == "PALADIN" then
		if CheckSpec(1)then
			DispellFilter.Magic = true
		else
			DispellFilter.Magic = false
		end
	elseif class == "PRIEST" then
		if CheckSpec(3) then
			DispellFilter.Magic = false
			DispellFilter.Disease = false
		else
			DispellFilter.Magic = true
			DispellFilter.Disease = true
		end
	elseif class == "SHAMAN" then
		if CheckSpec(3) then
			DispellFilter.Magic = true
		else
			DispellFilter.Magic = false
		end
	end
end

local abs = math.abs
local function OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= 0.1 then
		local timeLeft = self.expirationTime - GetTime()
		if self.reverse then timeLeft = abs((self.expirationTime - GetTime()) - self.duration) end
		if timeLeft > 0 then
			local text = B.FormatTime(timeLeft)
			self.time:SetText(text)
		else
			self:SetScript("OnUpdate", nil)
			self.time:Hide()
		end
		self.elapsed = 0
	end
end

local UpdateDebuffFrame = function(rd)
	if rd.index and rd.type and rd.filter then
		local name, rank, icon, count, debuffType, duration, expirationTime, _, _, _, spellId, _, isBossDebuff = UnitAura(rd.__owner.unit, rd.index, rd.filter)

		if rd.icon then
			rd.icon:SetTexture(icon)
			rd.icon:Show()
		end

		if rd.count then
			if count and (count > 1) then
				rd.count:SetText(count)
				rd.count:Show()
			else
				rd.count:Hide()
			end
		end

		if spellId and RaidDebuffsReverse[spellId] then
			rd.reverse = true
		else
			rd.reverse = nil
		end

		if rd.time then
			rd.duration = duration
			if duration and (duration > 0) then
				rd.expirationTime = expirationTime
				rd.nextUpdate = 0
				rd:SetScript("OnUpdate", OnUpdate)
				rd.time:Show()
			else
				rd:SetScript("OnUpdate", nil)
				rd.time:Hide()
			end
		end

		if rd.cd then
			if duration and (duration > 0) then
				rd.cd:SetCooldown(expirationTime - duration, duration)
				rd.cd:Show()
			else
				rd.cd:Hide()
			end
		end

		local c = DispellColor[debuffType] or DispellColor.none
		if rd.ShowDebuffBorder and rd.Shadow then
			rd.Shadow:SetBackdropBorderColor(c[1], c[2], c[3])
		end

		if not rd:IsShown() then
			rd:Show()
		end

		if rd.EnableTooltip then
			rd:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
				GameTooltip:ClearLines()
				GameTooltip:SetUnitAura(self.__owner.unit, self.index, self.filter)
				GameTooltip:Show()
			end)
			rd:SetScript("OnLeave", GameTooltip_Hide)
		end
	else
		if rd:IsShown() then
			rd:Hide()
		end
	end
end

local Update = function(self, event, unit)
	if unit ~= self.unit then return end
	local rd = self.RaidDebuffs
	rd.priority = invalidPrio

	for filter in next, (rd.Filters or auraFilters) do
		local i = 0
		while(true) do
			i = i + 1
			local name, rank, icon, count, debuffType, duration, expirationTime, _, _, _, spellId, _, isBossDebuff = UnitAura(unit, i, filter)
			if not name then break end

			if rd.ShowBossDebuff and isBossDebuff then
				local prio = rd.BossDebuffPriority or bossDebuffPrio
				if prio and prio > rd.priority then
					rd.priority = prio
					rd.index = i
					rd.type = "Boss"
					rd.filter = filter
				end
			end

			if rd.ShowDispellableDebuff and debuffType and filter == "HARMFUL" then
				local disPrio = rd.DispellPriority or DispellPriority
				local disFilter = rd.DispellFilter or DispellFilter
				local prio

				if rd.FilterDispellableDebuff and disFilter then
					prio = disFilter[debuffType] and disPrio[debuffType]
				else
					prio = disPrio[debuffType]
				end

				if prio and (prio > rd.priority) then
					rd.priority = prio
					rd.index = i
					rd.type = "Dispel"
					rd.filter = filter
				end
			end

			local prio
			local debuffs = rd.Debuffs or {}
			if IsInInstance() then
				local instName = GetInstanceInfo()
				if debuffs[instName] then
					prio = debuffs[instName][spellId]
				end
			end
			-- Test
			--local debuffs = {[11196]=1}
			--local prio = debuffs[spellId]

			if not RaidDebuffsIgnore[spellId] and prio and (prio > rd.priority) then
				rd.priority = prio
				rd.index = i
				rd.type = "Custom"
				rd.filter = filter
			end
		end
	end

	if rd.priority == invalidPrio then
		rd.index = nil
		rd.filter = nil
		rd.type = nil
	end

	return UpdateDebuffFrame(rd)
end

local Path = function(self, ...)
	return (self.RaidDebuffs.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local Enable = function(self)
	local rd = self.RaidDebuffs
	if rd then
		self:RegisterEvent("UNIT_AURA", Path)
		rd.ForceUpdate = ForceUpdate
		rd.__owner = self
		return true
	end
	self:RegisterEvent("PLAYER_TALENT_UPDATE", CheckSpecs)
	CheckSpecs()
end

local Disable = function(self)
	if self.RaidDebuffs then
		self:UnregisterEvent("UNIT_AURA", Path)
		self.RaidDebuffs:Hide()
		self.RaidDebuffs.__owner = nil
	end
	self:UnregisterEvent("PLAYER_TALENT_UPDATE", CheckSpecs)
	CheckSpecs()
end

oUF:AddElement("RaidDebuffs", Update, Enable, Disable)