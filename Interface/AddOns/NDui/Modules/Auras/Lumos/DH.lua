local _, ns = ...
local B, C, L, DB = unpack(ns)
local A = B:GetModule("Auras")

if DB.MyClass ~= "DEMONHUNTER" then return end
local GetSpellTexture = C_Spell.GetSpellTexture

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
	if C_Spell.IsSpellUsable(spellID) then
		button.Icon:SetDesaturated(false)
	else
		button.Icon:SetDesaturated(true)
	end
end

function A:ChantLumos(self)
	local spec = GetSpecialization()
	if spec == 1 then
		UpdateBuff(self.lumos[1], 258920, 258920, true)
		UpdateBuff(self.lumos[2], 188499, 188499, true, true)
		UpdateCooldown(self.lumos[3], 198013, true)
		UpdateCooldown(self.lumos[4], 179057, true)
		UpdateBuff(self.lumos[5], 191427, 162264, true, true)
	elseif spec == 2 then
		do
			local button, spellID = self.lumos[1], 228477
			UpdateSpellStatus(button, spellID)
			button.Count:SetText(C_Spell.GetSpellCastCount(spellID))
		end

		UpdateBuff(self.lumos[2], 258920, 258920, true)
		UpdateBuff(self.lumos[3], 203720, 203819, true, "END")
		UpdateDebuff(self.lumos[4], 204021, 207771, true, true)
		UpdateBuff(self.lumos[5], 187827, 187827, true, true)
	end
end