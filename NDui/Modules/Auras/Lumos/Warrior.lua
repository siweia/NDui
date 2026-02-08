local _, ns = ...
local B, C, L, DB = unpack(ns)
local A = B:GetModule("Auras")

if DB.MyClass ~= "WARRIOR" then return end

local function GetUnitAura(unit, spell, filter)
	return A:GetUnitAura(unit, spell, filter)
end

local function UpdateCooldown(button, spellID, texture)
	return A:UpdateCooldown(button, spellID, texture)
end

local function UpdateBuff(button, spellID, auraID, cooldown, glow)
	return A:UpdateAura(button, "player", auraID, "HELPFUL", spellID, cooldown, glow)
end

local function UpdateDebuff(button, spellID, auraID, cooldown, glow)
	return A:UpdateAura(button, "target", auraID, "HARMFUL", spellID, cooldown, glow)
end

local function UpdateSpellStatus(button, spellID)
	button.Icon:SetTexture(GetSpellTexture(spellID))
	if IsUsableSpell(spellID) then
		button.Icon:SetDesaturated(false)
	else
		button.Icon:SetDesaturated(true)
	end
end

function A:ChantLumos(self)
	if GetSpecialization() == 1 then
		do
			local button = self.bu[1]
			local name, count, duration, expire = GetUnitAura("player", 7384, "HELPFUL")
			if name then
				if count == 0 then count = "" end
				button.Count:SetText(count)
				button.CD:SetCooldown(expire-duration, duration)
				button.CD:Show()
				button.Icon:SetDesaturated(false)
				button.Icon:SetTexture(GetSpellTexture(12294))
			else
				UpdateCooldown(button, 7384, true)
			end
		end

		UpdateSpellStatus(self.bu[2], 163201)
		UpdateDebuff(self.bu[3], 167105, 208086, true, true)
		UpdateBuff(self.bu[4], 260708, 260708, true, "END")

		do
			local button = self.bu[5]
			if IsPlayerSpell(152277) then
				UpdateCooldown(button, 152277, true)
			else
				UpdateBuff(button, 227847, 227847, true, true)
			end
		end
	elseif GetSpecialization() == 2 then
		UpdateCooldown(self.bu[1], 85288, true)

		do
			local button = self.bu[2]
			UpdateCooldown(button, 5308)
			if IsPlayerSpell(206315) then
				UpdateSpellStatus(button, 280735)
			else
				UpdateSpellStatus(button, 5308)
			end
		end

		do
			local button = self.bu[3]
			if IsPlayerSpell(215571) then
				local name, _, duration, expire = GetUnitAura("player", 215572, "HELPFUL")
				if name then
					button.CD:SetCooldown(expire-duration, duration)
					button.CD:Show()
					button.Icon:SetDesaturated(false)
					button.Icon:SetTexture(GetSpellTexture(215572))
				else
					button.CD:Hide()
					UpdateSpellStatus(button, 184367)
				end
			else
				UpdateSpellStatus(button, 184367)
			end
		end

		UpdateBuff(self.bu[4], 184362, 184362, true, true)
		UpdateBuff(self.bu[5], 1719, 1719, true, true)
	elseif GetSpecialization() == 3 then
		UpdateDebuff(self.bu[1], 1160, 1160, true)

		do
			local button = self.bu[2]
			local name, _, duration, expire = GetUnitAura("player", 132404, "HELPFUL")
			if name then
				button.Count:SetText("")
				button.CD:SetCooldown(expire-duration, duration)
				button.CD:Show()
				button.Icon:SetDesaturated(false)
			else
				UpdateCooldown(button, 2565)
				UpdateSpellStatus(button, 2565)
			end
		end

		UpdateBuff(self.bu[3], 12975, 12975, true, true)
		UpdateBuff(self.bu[4], 23920, 23920, true)
		UpdateBuff(self.bu[5], 871, 871, true, true)
	end
end