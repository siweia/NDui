local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF
local UF = B:GetModule("UnitFrames")

local invalidPrio = -1

function UF:CreateRaidAuras(self)
	-- Indicators
	UF:CreateAurasIndicator(self)
	UF:CreateSpellsIndicator(self)
	UF:CreateBuffsIndicator(self)
	UF:CreateDebuffsIndicator(self)

	-- RaidAuras Util
	local frame = CreateFrame("Frame", nil, self)
	frame:SetSize(1, 1)
	frame:SetPoint("CENTER")

	self.RaidAuras = frame
	self.RaidAuras.PostUpdate = UF.RaidAurasPostUpdate
end

function UF.RaidAurasPostUpdate(element, unit)
	local self = element.__owner
	local auras = self.AurasIndicator
	local spells = self.SpellsIndicator
	local debuffs = self.DebuffsIndicator
	local buffs = self.BuffsIndicator

	local enableSpells = C.db["UFs"]["RaidBuffIndicator"]
	local auraIndex, debuffIndex, buffIndex = 0, 0, 0
	local numBuffs = element.buffList.num
	local numDebuffs = element.debuffList.num

	element.isInCombat = UnitAffectingCombat("player")

	if C.db["UFs"]["DispellType"] ~= 3 or C.db["UFs"]["InstanceAuras"] then
		UF.AurasIndicator_UpdatePriority(self, numDebuffs, unit)
		UF.AurasIndicator_HideButtons(self)

		for i = 1, numDebuffs do
			local button = auras.buttons[i]
			if not button then break end

			local aura = element.debuffList[i]
			if aura.priority > invalidPrio then
				auraIndex = auraIndex + 1
				UF:AurasIndicator_UpdateButton(button, aura)
			end
		end
	end

	UF.SpellsIndicator_HideButtons(self)

	for i = auraIndex+1, numDebuffs do
		local aura = element.debuffList[i]
		local value = enableSpells and not C.CornerBlackList[aura.spellID] and (UF.CornerSpells[aura.spellID] or UF.CornerSpellsByName[aura.name])
		if value and (value[3] or aura.isPlayerAura) then
			local button = spells[value[1]]
			if button then
				UF:SpellsIndicator_UpdateButton(button, aura, value[2][1], value[2][2], value[2][3])
			end
		elseif debuffs.enable and debuffIndex < 4 and UF.DebuffsIndicator_Filter(element, aura) then
			debuffIndex = debuffIndex + 1
			UF.DebuffsIndicator_UpdateButton(self, debuffIndex, aura)
		end
	end

	UF.DebuffsIndicator_HideButtons(self, debuffIndex+1, 3)

	for i = 1, numBuffs do
		local aura = element.buffList[i]
		local value = enableSpells and not C.CornerBlackList[aura.spellID] and (UF.CornerSpells[aura.spellID] or UF.CornerSpellsByName[aura.name])
		if value and (value[3] or aura.isPlayerAura) then
			local button = spells[value[1]]
			if button then
				UF:SpellsIndicator_UpdateButton(button, aura, value[2][1], value[2][2], value[2][3])
			end
		elseif buffs.enable and buffIndex < 4 and UF.BuffsIndicator_Filter(element, aura) then
			buffIndex = buffIndex + 1
			UF.BuffsIndicator_UpdateButton(self, buffIndex, aura)
		end
	end

	UF.BuffsIndicator_HideButtons(self, buffIndex+1, 3)
end

function UF:RaidAuras_UpdateOptions()
	for _, frame in pairs(oUF.objects) do
		if frame.mystyle == "raid" then
			UF.AurasIndicator_UpdateOptions(frame)
			UF.SpellsIndicator_UpdateOptions(frame)
			UF.DebuffsIndicator_UpdateOptions(frame)
			UF.BuffsIndicator_UpdateOptions(frame)
		end
	end
end