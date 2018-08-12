local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Auras")

if DB.MyClass ~= "DEMONHUNTER" then return end

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
		UpdateSpellStatus(self.bu[1], 162794)
		UpdateBuff(self.bu[2], 188499, 188499, true)
		UpdateCooldown(self.bu[3], 198013, true)
		UpdateCooldown(self.bu[4], 179057, true)
		UpdateBuff(self.bu[5], 191427, 162264, true)
	elseif GetSpecialization() == 2 then
		do
			local button, spellID = self.bu[1], 228477
			UpdateSpellStatus(button, spellID)
			button.Count:SetText(GetSpellCount(spellID))
		end

		UpdateBuff(self.bu[2], 178740, 178740, true)
		UpdateDebuff(self.bu[3], 204021, 207744, true)
		UpdateBuff(self.bu[4], 203720, 203819, true)
		UpdateBuff(self.bu[5], 187827, 187827, true)
	end
end