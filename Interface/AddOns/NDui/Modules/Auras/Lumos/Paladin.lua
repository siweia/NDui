local _, ns = ...
local B, C, L, DB = unpack(ns)
local A = B:GetModule("Auras")

if DB.MyClass ~= "PALADIN" then return end
local GetSpellTexture = C_Spell.GetSpellTexture

local IsPlayerSpell = IsPlayerSpell
local GetCurrentGlyphNameForSpell = GetCurrentGlyphNameForSpell

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

local function checkQueenGlyph()
	local name, spellID = GetCurrentGlyphNameForSpell(86659)
	A.hasQueenGlyph = name and spellID == 212642
end

function A:PostCreateLumos()
	checkQueenGlyph()
	B:RegisterEvent("SPELLS_CHANGED", checkQueenGlyph)
end

function A:ChantLumos(self)
	local spec = GetSpecialization()
	if spec == 1 then
		UpdateCooldown(self.lumos[1], 35395, true)
		UpdateCooldown(self.lumos[2], 20473, true)

		do
			local button = self.lumos[3]
			if IsPlayerSpell(114165) then
				UpdateCooldown(button, 114165, true)
			elseif IsPlayerSpell(105809) then
				UpdateBuff(button, 105809, 105809, true, true)
			else
				UpdateCooldown(button, 275773, true)
			end
		end

		do
			local button = self.lumos[4]
			if IsPlayerSpell(216331) then
				UpdateBuff(button, 216331, 216331, true, true)
			else
				UpdateBuff(button, 31884, 31884, true, true)
			end
		end

		UpdateBuff(self.lumos[5], 31821, 31821, true, true)
	elseif spec == 2 then
		UpdateCooldown(self.lumos[1], 31935, true)
		UpdateBuff(self.lumos[2], 53600, 132403, true, "END")
		UpdateBuff(self.lumos[3], 31884, 31884, true, true)
		UpdateBuff(self.lumos[4], 31850, 31850, true, true)

		do
			local button = self.lumos[5]
			if A.hasQueenGlyph then
				UpdateBuff(button, 212641, 212641, true, true)
			else
				UpdateBuff(button, 86659, 86659, true, true)
			end
		end
	elseif spec == 3 then
		UpdateCooldown(self.lumos[1], 20271, true)
		UpdateCooldown(self.lumos[2], 35395, true)
		UpdateCooldown(self.lumos[3], 184575, true)
		UpdateCooldown(self.lumos[4], 255937, true)

		do
			local button = self.lumos[5]
			if IsPlayerSpell(231895) then
				UpdateBuff(button, 231895, 231895, true, true)
				button.Count:SetTextColor(1, 1, 1)
			else
				UpdateBuff(button, 31884, 31884, true, true)
			end
		end
	end
end