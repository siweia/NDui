local _, ns = ...
local B, C, L, DB = unpack(ns)
local A = B:GetModule("Auras")

if DB.MyClass ~= "DRUID" then return end

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
	local spec = GetSpecialization()
	if spec == 1 then
		local currentPower = UnitPower("player", 8)
		do
			local button = self.lumos[1]
			local count = GetSpellCount(190984)
			UpdateBuff(button, 190984, 48517)
			button.Count:SetText(count > 0 and count or "")
		end

		do
			local button = self.lumos[2]
			local count = GetSpellCount(194153)
			UpdateBuff(button, 194153, 48518)
			button.Count:SetText(count > 0 and count or "")
		end

		do
			local button = self.lumos[3]
			UpdateSpellStatus(button, 78674)
			button.Count:SetText(floor(currentPower/30))
		end

		do
			local button = self.lumos[4]
			if IsPlayerSpell(274281) then
				UpdateCooldown(button, 274281, true)
			elseif IsPlayerSpell(202770) then
				UpdateCooldown(button, 202770, true)
			else
				UpdateBuff(button, 343648, 343648)
			end
		end

		do
			local button = self.lumos[5]
			if IsPlayerSpell(102560) then
				UpdateBuff(button, 102560, 102560, true, true)
			else
				UpdateBuff(button, 194223, 194223, true, true)
			end
		end
	elseif spec == 2 then
		UpdateDebuff(self.lumos[1], 1822, 155722, false, "END")
		UpdateDebuff(self.lumos[2], 1079, 1079, false, "END")

		do
			local button = self.lumos[3]
			if IsPlayerSpell(274837) then
				UpdateCooldown(button, 274837, true)
			elseif IsPlayerSpell(319439) then
				UpdateBuff(button, 145152, 145152)
			else
				UpdateBuff(button, 135700, 135700)
			end
		end

		UpdateBuff(self.lumos[4], 5217, 5217, true, true)

		do
			local button = self.lumos[5]
			if IsPlayerSpell(102543) then
				UpdateBuff(button, 102543, 102543, true, true)
			else
				UpdateBuff(button, 106951, 106951, true, true)
			end
		end
	elseif spec == 3 then
		UpdateBuff(self.lumos[1], 192081, 192081, false, "END")
		UpdateBuff(self.lumos[2], 22842, 22842, true)
		UpdateBuff(self.lumos[3], 22812, 22812, true)

		do
			local button = self.lumos[4]
			if IsPlayerSpell(102558) then
				UpdateBuff(button, 102558, 102558, true)
			elseif IsPlayerSpell(203964) then
				UpdateBuff(button, 213708, 213708)
			else
				UpdateDebuff(button, 192090, 192090)
			end
		end

		UpdateBuff(self.lumos[5], 61336, 61336, true, true)
	elseif spec == 4 then
		UpdateCooldown(self.lumos[1], 18562, true)
		UpdateCooldown(self.lumos[2], 132158, true)
		UpdateCooldown(self.lumos[3], 102342, true)
		UpdateBuff(self.lumos[4], 29166, 29166, true, true)
		UpdateBuff(self.lumos[5], 740, 157982, true)
	end
end