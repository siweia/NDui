local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Auras")

if DB.MyClass ~= "MAGE" then return end

local function GetUnitAura(unit, spell, filter)
	return module:GetUnitAura(unit, spell, filter)
end

local function UpdateCooldown(button, spellID, texture)
	return module:UpdateCooldown(button, spellID, texture)
end

local function UpdateBuff(button, spellID, auraID, cooldown, isPet)
	return module:UpdateAura(button, isPet and "pet" or "player", auraID, "HELPFUL", spellID, cooldown)
end

local function UpdateDebuff(button, spellID, auraID, cooldown)
	return module:UpdateAura(button, "target", auraID, "HARMFUL", spellID, cooldown)
end

local function UpdateSpellStatus(button, spellID)
	button.Icon:SetTexture(GetSpellTexture(spellID))
	if IsUsableSpell(spellID) then
		button:SetAlpha(1)
	else
		button:SetAlpha(.5)
	end
end

local function UpdateTotemAura(button, texture, spellID)
	return module:UpdateTotemAura(button, texture, spellID)
end

function module:ChantLumos(self)
	if GetSpecialization() == 1 then
		UpdateBuff(self.bu[1], 263725, 263725)
		UpdateBuff(self.bu[2], 205025, 205025, true)

		do
			local button = self.bu[3]
			if IsPlayerSpell(116011) then
				UpdateTotemAura(button, 609815, 116011)
			elseif IsPlayerSpell(55342) then
				UpdateCooldown(button, 55342, true)
			else
				UpdateBuff(button, 1463, 116267)
			end
		end

		UpdateBuff(self.bu[4], 12051, 12051, true)
		UpdateBuff(self.bu[5], 12042, 12042, true)
	elseif GetSpecialization() == 2 then
		do
			local button = self.bu[1]
			local name, _, duration, expire, _, spellID = GetUnitAura("player", 48108, "HELPFUL")
			if not name then name, _, duration, expire, _, spellID = GetUnitAura("player", 48107, "HELPFUL") end
			if name then
				button.CD:SetCooldown(expire-duration, duration)
				button.CD:Show()
				button:SetAlpha(1)
				button.Icon:SetTexture(GetSpellTexture(spellID))
			else
				button.CD:Hide()
				button:SetAlpha(.5)
				button.Icon:SetTexture(GetSpellTexture(48107))
			end
		end

		do
			local button = self.bu[2]
			if IsPlayerSpell(257541) then
				UpdateCooldown(button, 257541, true)
			elseif IsPlayerSpell(235870) then
				UpdateCooldown(button, 31661, true)
			else
				UpdateCooldown(button, 108853, true)
			end
		end

		do
			local button = self.bu[3]
			if IsPlayerSpell(116011) then
				UpdateTotemAura(button, 609815, 116011)
			elseif IsPlayerSpell(55342) then
				UpdateCooldown(button, 55342, true)
			else
				UpdateBuff(button, 1463, 116267)
			end
		end

		do
			local button = self.bu[4]
			if IsPlayerSpell(153561) then
				UpdateCooldown(button, 153561, true)
			elseif IsPlayerSpell(269650) then
				UpdateBuff(button, 269650, 269651)
			else
				UpdateDebuff(button, 12654, 12654)
			end
		end

		UpdateBuff(self.bu[5], 190319, 190319, true)
	elseif GetSpecialization() == 3 then
		UpdateBuff(self.bu[1], 30455, 44544)
		UpdateBuff(self.bu[2], 44614, 190446)

		do
			local button = self.bu[3]
			if IsPlayerSpell(116011) then
				UpdateTotemAura(button, 609815, 116011)
			elseif IsPlayerSpell(55342) then
				UpdateCooldown(button, 55342, true)
			else
				UpdateBuff(button, 1463, 116267)
			end
		end

		UpdateCooldown(self.bu[4], 84714, true)

		do
			local button = self.bu[5]
			if IsPlayerSpell(199786) then
				UpdateBuff(button, 199786, 199844)
			elseif IsPlayerSpell(205021) then
				UpdateCooldown(button, 205021, true)
			else
				UpdateBuff(button, 12472, 12472, true)
			end
		end
	end
end