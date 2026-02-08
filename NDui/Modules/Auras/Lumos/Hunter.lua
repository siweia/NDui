local _, ns = ...
local B, C, L, DB = unpack(ns)
local A = B:GetModule("Auras")

if DB.MyClass ~= "HUNTER" then return end

function A:PostCreateLumos(self)
	local iconSize = self.bu[1]:GetWidth()
	local boom = CreateFrame("Frame", nil, self.Health)
	boom:SetSize(iconSize, iconSize)
	boom:SetPoint("BOTTOM", self.Health, "TOP", 0, 5)
	B.AuraIcon(boom)

	self.boom = boom
end

function A:PostUpdateVisibility(self)
	if self.boom then self.boom:Hide() end
end

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

local boomGroups = {
	[270339] = 186270,
	[270332] = 259489,
	[271049] = 259491,
}

function A:ChantLumos(self)
	if GetSpecialization() == 1 then
		UpdateCooldown(self.bu[1], 34026, true)
		UpdateCooldown(self.bu[2], 217200, true)
		UpdateBuff(self.bu[3], 106785, 272790, false, true, "END")
		UpdateBuff(self.bu[4], 19574, 19574, true, false, true)
		UpdateBuff(self.bu[5], 193530, 193530, true, false, true)

	elseif GetSpecialization() == 2 then
		UpdateCooldown(self.bu[1], 19434, true)

		do
			local button = self.bu[2]
			if IsPlayerSpell(271788) then
				UpdateDebuff(button, 271788, 271788)
			elseif IsPlayerSpell(131894) then
				UpdateDebuff(button, 131894, 131894, true)
			else
				if IsPlayerSpell(260367) then
					UpdateBuff(button, 260242, 260242)
				else
					UpdateCooldown(button, 257044, true)
				end
			end
		end

		do
			local button = self.bu[3]
			if IsPlayerSpell(193533) then
				local name, count, duration, expire, caster, spellID = GetUnitAura("target", 277959, "HARMFUL")
				if not name then name, count, duration, expire, caster, spellID = GetUnitAura("player", 193534, "HELPFUL") end
				if name and caster == "player" then
					button.Count:SetText(count)
					button.CD:SetCooldown(expire-duration, duration)
					button.CD:Show()
					button.Icon:SetDesaturated(false)
					button.Icon:SetTexture(GetSpellTexture(spellID))
				else
					button.Count:SetText("")
					button.CD:Hide()
					button.Icon:SetDesaturated(true)
					button.Icon:SetTexture(GetSpellTexture(193534))
				end
			elseif IsPlayerSpell(257284) then
				UpdateDebuff(button, 257284, 257284)
			else
				UpdateCooldown(button, 257044, true)
			end
		end

		do
			local button = self.bu[4]
			if IsPlayerSpell(260402) then
				UpdateBuff(button, 260402, 260402, true, false, true)
			elseif IsPlayerSpell(120360) then
				UpdateCooldown(button, 120360, true)
			else
				UpdateBuff(button, 260395, 260395)
			end
		end

		UpdateBuff(self.bu[5], 288613, 288613, true, false, true)

	elseif GetSpecialization() == 3 then
		UpdateDebuff(self.bu[1], 259491, 259491, false, "END")

		do
			local button = self.bu[2]
			if IsPlayerSpell(260248) then
				UpdateBuff(button, 260248, 260249)
			elseif IsPlayerSpell(162488) then
				UpdateDebuff(button, 162488, 162487, true)
			else
				UpdateDebuff(button, 131894, 131894, true)
			end
		end

		do
			local button = self.bu[3]
			local boom = self.boom
			if IsPlayerSpell(271014) then
				boom:Show()

				local name, _, duration, expire, caster, spellID = GetUnitAura("target", 270339, "HARMFUL")
				if not name then name, _, duration, expire, caster, spellID = GetUnitAura("target", 270332, "HARMFUL") end
				if not name then name, _, duration, expire, caster, spellID = GetUnitAura("target", 271049, "HARMFUL") end
				if name and caster == "player" then
					boom.Icon:SetTexture(GetSpellTexture(boomGroups[spellID]))
					boom.CD:SetCooldown(expire-duration, duration)
					boom.CD:Show()
					boom.Icon:SetDesaturated(false)
				else
					local texture = GetSpellTexture(259495)
					if texture == GetSpellTexture(270323) then
						boom.Icon:SetTexture(GetSpellTexture(259489))
					elseif texture == GetSpellTexture(271045) then
						boom.Icon:SetTexture(GetSpellTexture(259491))
					else
						boom.Icon:SetTexture(GetSpellTexture(186270))	-- 270335
					end
					boom.Icon:SetDesaturated(true)
				end

				UpdateCooldown(button, 259495, true)
			else
				boom:Hide()
				UpdateDebuff(button, 259495, 269747, true)
			end
		end

		do
			local button = self.bu[4]
			if IsPlayerSpell(260285) then
				UpdateBuff(button, 260285, 260286)
			elseif IsPlayerSpell(269751) then
				UpdateCooldown(button, 269751, true)
			else
				UpdateBuff(button, 259387, 259388, false, false, "END")
			end
		end

		UpdateBuff(self.bu[5], 266779, 266779, true, false, true)
	end
end