local _, ns = ...
local B, C, L, DB = unpack(ns)
local A = B:GetModule("Auras")

if DB.MyClass ~= "PRIEST" then return end

local function UpdateCooldown(button, spellID, texture)
	return A:UpdateCooldown(button, spellID, texture)
end

local function UpdateBuff(button, spellID, auraID, cooldown, glow)
	return A:UpdateAura(button, "player", auraID, "HELPFUL", spellID, cooldown, glow)
end

local function UpdateDebuff(button, spellID, auraID)
	return A:UpdateAura(button, "target", auraID, "HARMFUL", spellID, false, "END")
end

function A:ChantLumos(self)
	if GetSpecialization() == 1 then
		UpdateCooldown(self.bu[1], 47540, true)
		UpdateCooldown(self.bu[2], 194509, true)
		UpdateBuff(self.bu[3], 47536, 47536, true, true)
		UpdateBuff(self.bu[4], 33206, 33206, true, true)
		UpdateCooldown(self.bu[5], 32375, true)
	elseif GetSpecialization() == 2 then
		UpdateCooldown(self.bu[1], 2050, true)
		UpdateCooldown(self.bu[2], 47788, true)
		UpdateBuff(self.bu[3], 64843, 64843, true, true)
		UpdateBuff(self.bu[4], 64901, 64901, true, true)
		UpdateCooldown(self.bu[5], 32375, true)
	elseif GetSpecialization() == 3 then
		UpdateDebuff(self.bu[1], 589, 589)
		UpdateDebuff(self.bu[2], 34914, 34914)

		do
			local button = self.bu[3]
			if IsPlayerSpell(205351) then
				UpdateCooldown(button, 205351, true)
			else
				UpdateCooldown(button, 8092, true)
			end
		end

		do
			local button = self.bu[4]
			UpdateCooldown(button, 228260, true)
			if IsUsableSpell(228260) then
				button.Icon:SetDesaturated(false)
				B.ShowOverlayGlow(button.glowFrame)
			else
				button.Icon:SetDesaturated(true)
				B.HideOverlayGlow(button.glowFrame)
			end
		end

		UpdateBuff(self.bu[5], 47585, 47585, true, true)
	end
end