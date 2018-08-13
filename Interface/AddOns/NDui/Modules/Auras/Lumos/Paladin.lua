local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Auras")

if DB.MyClass ~= "PALADIN" then return end

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

function module:ChantLumos(self)
	if GetSpecialization() == 1 then
		UpdateCooldown(self.bu[1], 20473, true)
		UpdateCooldown(self.bu[2], 85222, true)

		do
			local button = self.bu[3]
			if IsPlayerSpell(114165) then
				UpdateCooldown(button, 114165, true)
			elseif IsPlayerSpell(105809) then
				UpdateBuff(button, 105809, 105809, true)
			else
				UpdateCooldown(button, 275773, true)
			end
		end

		do
			local button = self.bu[4]
			if IsPlayerSpell(216331) then
				UpdateBuff(button, 216331, 216331, true)
			else
				UpdateBuff(button, 31884, 31884, true)
			end
		end

		UpdateBuff(self.bu[5], 31821, 31821, true)
	elseif GetSpecialization() == 2 then
		do
			local button = self.bu[1]
			if IsPlayerSpell(213652) then
				UpdateCooldown(button, 213652, true)
			else
				UpdateCooldown(button, 184092, true)
			end
		end

		UpdateBuff(self.bu[2], 53600, 132403, true)
		UpdateBuff(self.bu[3], 31884, 31884, true)
		UpdateBuff(self.bu[4], 31850, 31850, true)
		UpdateBuff(self.bu[5], 86659, 86659, true)
	elseif GetSpecialization() == 3 then
		do
			local button = self.bu[1]
			if IsPlayerSpell(267610) then
				UpdateBuff(button, 267610, 267611)
			elseif IsPlayerSpell(267798) then
				UpdateDebuff(button, 267798, 267799, true)
			else
				UpdateBuff(button, 20271, 269571, true)
			end
		end

		do
			local button = self.bu[2]
			if IsPlayerSpell(24275) then
				UpdateCooldown(button, 24275)
				UpdateSpellStatus(button, 24275)
			elseif IsPlayerSpell(231832) then
				UpdateBuff(button, 231832, 281178, true)
			else
				UpdateBuff(button, 35395, 209785, true)
			end
		end

		do
			local button = self.bu[3]
			if IsPlayerSpell(271580) then
				UpdateBuff(button, 271580, 271581)
			elseif IsPlayerSpell(205228) then
				UpdateCooldown(button, 205228, true)
			else
				UpdateCooldown(button, 255937, true)
			end
		end

		do
			local button = self.bu[4]
			if IsPlayerSpell(223817) then
				UpdateBuff(button, 223817, 223819)
			elseif IsPlayerSpell(84963) then
				UpdateBuff(button, 84963, 84963)
			else
				button.Icon:SetTexture(GetSpellTexture(184662))
				local name, _, duration, expire, _, _, value = GetUnitAura("player", 184662, "HELPFUL")
				if name then
					button.Count:SetText(B.Numb(value))
					button.CD:SetCooldown(expire-duration, duration)
					button.CD:Show()
					button:SetAlpha(1)
				else
					button.Count:SetText("")
					UpdateCooldown(button, 184662)
				end
				button.Count:SetTextColor(1, 1, 1)
			end
		end

		do
			local button = self.bu[5]
			if IsPlayerSpell(231895) then
				UpdateBuff(button, 231895, 231895, true)
				button.Count:SetTextColor(1, 1, 1)
			else
				UpdateBuff(button, 31884, 31884, true)
			end
		end
	end
end