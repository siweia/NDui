local _, ns = ...
local B, C, L, DB = unpack(ns)
local A = B:GetModule("Auras")

if DB.MyClass ~= "SHAMAN" then return end

local function GetUnitAura(unit, spell, filter)
	return A:GetUnitAura(unit, spell, filter)
end

local function UpdateCooldown(button, spellID, texture)
	return A:UpdateCooldown(button, spellID, texture)
end

local function UpdateBuff(button, spellID, auraID, cooldown)
	return A:UpdateAura(button, "player", auraID, "HELPFUL", spellID, cooldown)
end

local function UpdateDebuff(button, spellID, auraID, cooldown, glow)
	return A:UpdateAura(button, "target", auraID, "HARMFUL", spellID, cooldown, glow)
end

local function UpdateTotemAura(button, texture, spellID)
	return A:UpdateTotemAura(button, texture, spellID)
end

function A:ChantLumos(self)
	local spec = GetSpecialization()
	if spec == 1 then
		UpdateDebuff(self.lumos[1], 188389, 188389, true, "END")
		UpdateBuff(self.lumos[2], 51505, 77762, true)

		do
			local button = self.lumos[3]
			if IsPlayerSpell(320125) then
				UpdateBuff(button, 320125, 320125, true)
			elseif IsPlayerSpell(117014) then
				UpdateCooldown(button, 117014, true)
			else
				if IsUsableSpell(8042) then
					button.Icon:SetDesaturated(false)
					B.ShowOverlayGlow(button.glowFrame)
				else
					button.Icon:SetDesaturated(true)
					B.HideOverlayGlow(button.glowFrame)
				end
				button.Icon:SetTexture(GetSpellTexture(8042))
			end
		end

		do
			local button = self.lumos[4]
			if IsPlayerSpell(260895) then
				UpdateBuff(button, 260895, 272737)
			elseif IsPlayerSpell(191634) then
				UpdateBuff(button, 191634, 191634, true)
			else
				UpdateBuff(button, 114050, 114050, true)
			end
		end

		do
			local button = self.lumos[5]
			if IsPlayerSpell(192249) then
				UpdateTotemAura(button, 1020304, 192249)
			else
				UpdateTotemAura(button, 135790, 198067)
			end
		end
	elseif spec == 2 then
		UpdateCooldown(self.lumos[1], 17364, true)

		do
			local button = self.lumos[2]
			if IsPlayerSpell(117014) then
				UpdateCooldown(button, 117014, true)
			elseif IsPlayerSpell(262647) then
				UpdateBuff(button, 262647, 262652)
			else
				UpdateDebuff(button, 60103, 334168, true)
			end
		end

		UpdateBuff(self.lumos[3], 344179, 344179)

		do
			local button = self.lumos[4]
			if IsPlayerSpell(320137) then
				UpdateCooldown(button, 320137, true)
			elseif IsPlayerSpell(197214) then
				UpdateCooldown(button, 197214, true)
			else
				UpdateCooldown(button, 187874, true)
			end
		end

		do
			local button = self.lumos[5]
			if IsPlayerSpell(188089) then
				UpdateDebuff(button, 188089, 188089, true)
			elseif IsPlayerSpell(114051) then
				UpdateBuff(button, 114051, 114051, true)
			else
				UpdateTotemAura(button, 237577, 51533)
			end
		end
	elseif spec == 3 then
		UpdateCooldown(self.lumos[1], 61295, true)

		do
			local button = self.lumos[2]
			if IsPlayerSpell(157153) then
				button.Icon:SetTexture(GetSpellTexture(157504))
				local name, _, _, _, _, _, value = GetUnitAura("player", 157504, "HELPFUL")
				if name then
					UpdateTotemAura(button, 971076)
					button.Count:SetText(B.Numb(value))
					button.Count:SetTextColor(1, 1, 1)
				else
					UpdateCooldown(button, 157153)
				end
			else
				UpdateCooldown(button, 5394, true)
			end
		end

		UpdateCooldown(self.lumos[3], 73920, true)

		do
			local button = self.lumos[4]
			if IsPlayerSpell(114052) then
				UpdateBuff(button, 114052, 114052, true)
			elseif IsPlayerSpell(197995) then
				UpdateCooldown(button, 197995, true)
			else
				UpdateBuff(button, 288675, 288675)
			end
		end

		UpdateBuff(self.lumos[5], 79206, 79206, true)
	end
end