local _, ns = ...
local B, C, L, DB = unpack(ns)
local A = B:GetModule("Auras")

if DB.MyClass ~= "DEMONHUNTER" then return end

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
			if IsPlayerSpell(258920) then
				UpdateBuff(button, 258920, 258920, true)
			else
				UpdateSpellStatus(button, 162794)
			end
		end

		UpdateBuff(self.bu[2], 188499, 188499, true, true)
		UpdateCooldown(self.bu[3], 198013, true)
		UpdateCooldown(self.bu[4], 179057, true)
		UpdateBuff(self.bu[5], 191427, 162264, true, true)
	elseif GetSpecialization() == 2 then
		do
			local button, spellID = self.bu[1], 228477
			UpdateSpellStatus(button, spellID)
			button.Count:SetText(GetSpellCount(spellID))
		end

		UpdateBuff(self.bu[2], 178740, 178740, true)
		UpdateDebuff(self.bu[3], 204021, 207744, true, true)
		UpdateBuff(self.bu[4], 203720, 203819, true, "END")
		UpdateBuff(self.bu[5], 187827, 187827, true, true)
	end
end