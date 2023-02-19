local _, ns = ...
local B, C, L, DB = unpack(ns)
local A = B:GetModule("Auras")

if DB.MyClass ~= "HUNTER" then return end

local function GetUnitAura(unit, spell, filter)
	return A:GetUnitAura(unit, spell, filter)
end

local function UpdateCooldown(button, spellID, texture)
	return A:UpdateCooldown(button, spellID, texture)
end

local function UpdateBuff(button, spellID, auraID, cooldown, isPet, glow)
	return A:UpdateAura(button, isPet and "pet" or "player", auraID, "HELPFUL", spellID, cooldown, glow)
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
		UpdateCooldown(self.lumos[1], 34026, true)
		UpdateCooldown(self.lumos[2], 217200, true)
		UpdateBuff(self.lumos[3], 106785, 272790, false, true, "END")
		UpdateBuff(self.lumos[4], 19574, 19574, true, false, true)
		UpdateBuff(self.lumos[5], 268877, 268877)

	elseif spec == 2 then
		UpdateCooldown(self.lumos[1], 19434, true)
		UpdateCooldown(self.lumos[2], 257044, true)
		UpdateBuff(self.lumos[3], 257622, 257622)

		do
			local button = self.lumos[4]
			if IsPlayerSpell(260402) then
				UpdateBuff(button, 260402, 260402, true, false, true)
			elseif IsPlayerSpell(321460) then
				UpdateCooldown(button, 53351)
				UpdateSpellStatus(button, 53351)
			else
				UpdateBuff(button, 260242, 260242)
			end
		end

		UpdateBuff(self.lumos[5], 288613, 288613, true, false, true)

	elseif spec == 3 then
		UpdateDebuff(self.lumos[1], 259491, 259491, false, "END")

		do
			local button = self.lumos[2]
			UpdateCooldown(button, 259489, true)
			local name = GetUnitAura("target", 270332, "HARMFUL") -- 目标红炸弹高亮
			if name then
				B.ShowOverlayGlow(button)
			else
				B.HideOverlayGlow(button)
			end
		end

		do
			local button = self.lumos[3]
			if IsPlayerSpell(260285) then
				UpdateBuff(button, 260285, 260286)
			elseif IsPlayerSpell(269751) then
				UpdateCooldown(button, 269751, true)
			else
				UpdateBuff(button, 259387, 259388, false, false, "END")
			end
		end

		do
			local button = self.lumos[4]
			if IsPlayerSpell(271014) then
				UpdateCooldown(button, 259495, true)
				local name = GetUnitAura("player", 363805, "HELPFUL") -- 有疯狂投弹兵时高亮
				if name then
					B.ShowOverlayGlow(button)
				else
					B.HideOverlayGlow(button)
				end
			else
				UpdateDebuff(button, 259495, 269747, true)
			end
		end

		UpdateBuff(self.lumos[5], 266779, 266779, true, false, true)
	end
end