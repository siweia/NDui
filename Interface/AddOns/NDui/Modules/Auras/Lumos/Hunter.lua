local _, ns = ...
local B, C, L, DB = unpack(ns)
local A = B:GetModule("Auras")

if DB.MyClass ~= "HUNTER" then return end

local pairs, GetSpellPowerCost = pairs, GetSpellPowerCost
local POWER_TYPE_FOCUS = 2

local function GetSpellCost(spellID)
	local costTable = GetSpellPowerCost(spellID)
	if costTable then
		for _, costInfo in pairs(costTable) do
			if costInfo.type == POWER_TYPE_FOCUS then
				return costInfo.cost
			end
		end
	end
end

function A:UpdateFocusCost(unit, _, spellID)
	if unit ~= "player" then return end

	local focusCal = A.MMFocus
	local cost = GetSpellCost(spellID)
	if cost then
		focusCal.cost = focusCal.cost + cost
	end
	focusCal:SetFormattedText("%d/40", focusCal.cost%40)
end

local oldSpec
function A:ToggleFocusCalculation()
	if not A.MMFocus then return end

	local spec = GetSpecialization()
	if C.db["Auras"]["MMT29X4"] and spec == 2 then
		if self ~= "PLAYER_SPECIALIZATION_CHANGED" or spec ~= oldSpec then -- don't reset when talent changed only
			A.MMFocus.cost = 0 -- reset calculation when switch on
		end
		A.MMFocus:Show()
		B:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", A.UpdateFocusCost)
	else
		A.MMFocus:Hide()
		B:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", A.UpdateFocusCost)
	end
	oldSpec = spec
end

function A:PostCreateLumos(self)
	local iconSize = self.lumos[1]:GetWidth()
	local boom = CreateFrame("Frame", nil, self.Health)
	boom:SetSize(iconSize, iconSize)
	boom:SetPoint("BOTTOM", self.Health, "TOP", 0, 5)
	B.AuraIcon(boom)
	boom:Hide()

	self.boom = boom

	-- MM hunter T29 4sets
	A.MMFocus = B.CreateFS(self.Health, 16)
	A.MMFocus:ClearAllPoints()
	A.MMFocus:SetPoint("BOTTOM", self.Health, "TOP", 0, 5)
	A:ToggleFocusCalculation()
	B:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", A.ToggleFocusCalculation)
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

local function UpdateSpellStatus(button, spellID)
	button.Icon:SetTexture(GetSpellTexture(spellID))
	if IsUsableSpell(spellID) then
		button.Icon:SetDesaturated(false)
	else
		button.Icon:SetDesaturated(true)
	end
end

local boomGroups = {
	[270339] = 186270,
	[270332] = 259489,
	[271049] = 259491,
}

function A:ChantLumos(self)
	local spec = GetSpecialization()
	if spec == 1 then
		UpdateCooldown(self.lumos[1], 34026, true)
		UpdateCooldown(self.lumos[2], 217200, true)
		UpdateBuff(self.lumos[3], 106785, 272790, false, true, "END")
		UpdateBuff(self.lumos[4], 19574, 19574, true, false, true)
		UpdateBuff(self.lumos[5], 193530, 193530, true, false, true)

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
			if IsPlayerSpell(260248) then
				UpdateBuff(button, 260248, 260249)
			elseif IsPlayerSpell(162488) then
				UpdateDebuff(button, 162488, 162487, true)
			else
				UpdateDebuff(button, 131894, 131894, true)
			end
		end

		do
			local button = self.lumos[3]
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
			local button = self.lumos[4]
			if IsPlayerSpell(260285) then
				UpdateBuff(button, 260285, 260286)
			elseif IsPlayerSpell(269751) then
				UpdateCooldown(button, 269751, true)
			else
				UpdateBuff(button, 259387, 259388, false, false, "END")
			end
		end

		UpdateBuff(self.lumos[5], 266779, 266779, true, false, true)
	end
end