local _, ns = ...
local B, C, L, DB = unpack(ns)
local A = B:GetModule("Auras")

if DB.MyClass ~= "HUNTER" then return end

local pairs, IsEquippedItem = pairs, IsEquippedItem
local playerGUID = UnitGUID("player")

local GetSpellCost = {
	[53351]  = 10, -- 杀戮射击
	[19434]  = 35, -- 瞄准射击
	[185358] = 20, -- 奥术射击
	[257620] = 20, -- 多重射击
	[271788] = 10, -- 毒蛇钉刺
	[212431] = 20, -- 爆炸射击
	[186387] = 10, -- 爆裂射击
	[157863] = 35, -- 复活宠物
	[131894] = 20, -- 夺命黑鸦
	[120360] = 30, -- 弹幕射击
	[342049] = 20, -- 奇美拉射击
	[355589] = 15, -- 哀痛箭
}

function A:UpdateFocusColor(focusCal)
	if A.MMFocus.trickActive > 0 then
		A.MMFocus:SetTextColor(0, 1, 0) -- 有技巧绿色
	elseif A.MMFocus.cost > 0 then
		A.MMFocus:SetTextColor(1, 1, 0) -- 无技巧，但集中值不为0，则黄色
	else
		A.MMFocus:SetTextColor(1, 0, 0) -- 无技巧，且集中值为0，红色
	end
end

function A:UpdateFocusText(value)
	A.MMFocus.cost = value
	A.MMFocus:SetFormattedText("%d/40", value)
end

function A:UpdateFocusCost(unit, _, spellID)
	if unit ~= "player" then return end

	local focusCal = A.MMFocus
	local cost = GetSpellCost[spellID]
	if cost then
		focusCal.cost = focusCal.cost + cost
	end
	if spellID == 19434 then
		--print("带着技巧读条："..tostring(focusCal.isTrickCast), "消耗技巧层数："..focusCal.trickActive)
		if (focusCal.isTrickCast and focusCal.trickActive == 1) or (not focusCal.isTrickCast and focusCal.trickActive == 0) then
			focusCal.cost = 35
			--print("此时重置集中值为35")
		end
	end
	A:UpdateFocusText(focusCal.cost % 40)
	A:UpdateFocusColor()
end

function A:ResetFocusCost()
	A:UpdateFocusText(0)
	A:UpdateFocusColor()
end

function A:ResetOnRaidEncounter(_, _, _, groupSize)
	if groupSize and groupSize > 5 then
		A:ResetFocusCost()
	end
end

local eventSpentIndex = {
	["SPELL_AURA_APPLIED"] = 1,
	["SPELL_AURA_REFRESH"] = 2,
	["SPELL_AURA_REMOVED"] = 0,
}

function A:CheckTrickState(...)
	local _, eventType, _, sourceGUID, _, _, _, _, _, _, _, spellID = ...
	if eventSpentIndex[eventType] and spellID == 257622 and sourceGUID == playerGUID then
		A.MMFocus.trickActive = eventSpentIndex[eventType]
		A:UpdateFocusColor()
	end
end

function A:StartAimedShot(unit, _, spellID)
	if unit ~= "player" then return end
	if spellID == 19434 then
		A.MMFocus.isTrickCast = A.MMFocus.trickActive ~= 0
	end
end

local hunterSets = {188856, 188858, 188859, 188860, 188861}

function A:CheckSetsCount()
	local count = 0
	for _, itemID in pairs(hunterSets) do
		if IsEquippedItem(itemID) then
			count = count + 1
		end
	end

	if count < 4 then
		A.MMFocus:Hide()
		B:UnregisterEvent("UNIT_SPELLCAST_START", A.StartAimedShot)
		B:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", A.UpdateFocusCost)
		B:UnregisterEvent("PLAYER_DEAD", A.ResetFocusCost)
		B:UnregisterEvent("PLAYER_ENTERING_WORLD", A.ResetFocusCost)
		B:UnregisterEvent("ENCOUNTER_START", A.ResetOnRaidEncounter)
		B:UnregisterEvent("CLEU", A.CheckTrickState)
	else
		A.MMFocus:Show()
		B:RegisterEvent("UNIT_SPELLCAST_START", A.StartAimedShot, "player")
		B:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", A.UpdateFocusCost, "player")
		B:RegisterEvent("PLAYER_DEAD", A.ResetFocusCost)
		B:RegisterEvent("PLAYER_ENTERING_WORLD", A.ResetFocusCost)
		B:RegisterEvent("ENCOUNTER_START", A.ResetOnRaidEncounter)
		B:RegisterEvent("CLEU", A.CheckTrickState)
	end
end

local oldSpec
function A:ToggleFocusCalculation()
	if not A.MMFocus then return end

	local spec = GetSpecialization()
	if C.db["Auras"]["MMT29X4"] and spec == 2 then
		if self ~= "PLAYER_SPECIALIZATION_CHANGED" or spec ~= oldSpec then -- don't reset when talent changed only
			A:ResetFocusCost() -- reset calculation when switch on
		end
		A.MMFocus:Show()
		A:CheckSetsCount()
		B:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", A.CheckSetsCount)
	else
		B:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED", A.CheckSetsCount)
		-- if enabled already
		A.MMFocus:Hide()
		B:UnregisterEvent("UNIT_SPELLCAST_START", A.StartAimedShot)
		B:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", A.UpdateFocusCost)
		B:UnregisterEvent("PLAYER_DEAD", A.ResetFocusCost)
		B:UnregisterEvent("PLAYER_ENTERING_WORLD", A.ResetFocusCost)
		B:UnregisterEvent("ENCOUNTER_START", A.ResetOnRaidEncounter)
		B:UnregisterEvent("CLEU", A.CheckTrickState)
	end
	oldSpec = spec
end

function A:PostCreateLumos(self)
	-- MM hunter T29 4sets
	A.MMFocus = B.CreateFS(self.Health, 18)
	A.MMFocus:ClearAllPoints()
	A.MMFocus:SetPoint("BOTTOM", self.Health, "TOP", 0, 5)
	A.MMFocus.trickActive = 0
	A:ToggleFocusCalculation()
	B:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", A.ToggleFocusCalculation)
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