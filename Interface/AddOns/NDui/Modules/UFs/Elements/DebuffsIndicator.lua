local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF
local UF = B:GetModule("UnitFrames")

local SpellIsPriorityAura, SpellGetVisibilityInfo = SpellIsPriorityAura, SpellGetVisibilityInfo
local GetAuraApplicationDisplayCount = C_UnitAuras.GetAuraApplicationDisplayCount
local GetAuraDuration = C_UnitAuras.GetAuraDuration
local MIN_SPELL_COUNT, MAX_SPELL_COUNT = 2, 999

UF.RaidDebuffsBlack = {}
function UF:UpdateRaidDebuffsBlack()
	wipe(UF.RaidDebuffsBlack)

	for spellID in pairs(C.RaidDebuffsBlack) do
		local name = C_Spell.GetSpellName(spellID)
		if name then
			if NDuiADB["RaidDebuffsBlack"][spellID] == nil then
				UF.RaidDebuffsBlack[spellID] = true
			end
		end
	end

	for spellID, value in pairs(NDuiADB["RaidDebuffsBlack"]) do
		if value then
			UF.RaidDebuffsBlack[spellID] = true
		end
	end
end

function UF:CreateDebuffsIndicator(self)
	local debuffFrame = CreateFrame("Frame", nil, self)
	debuffFrame:SetSize(1, 1)
	debuffFrame:SetPoint("BOTTOMLEFT", C.mult, C.mult)

	debuffFrame.buttons = {}
	local prevDebuff
	for i = 1, 3 do
		local button = CreateFrame("Frame", nil, debuffFrame)
		B.PixelIcon(button)
		button:SetScript("OnEnter", UF.AuraButton_OnEnter)
		button:SetScript("OnLeave", B.HideTooltip)
		button:Hide()

		local cd = CreateFrame("Cooldown", "$parentCooldown", button, "CooldownFrameTemplate")
		cd:SetAllPoints()
		cd:SetReverse(true)
		button.cd = cd

		local parentFrame = CreateFrame("Frame", nil, button)
		parentFrame:SetAllPoints()
		parentFrame:SetFrameLevel(button:GetFrameLevel() + 6)
		button.count = B.CreateFS(parentFrame, 12, "", false, "BOTTOMRIGHT", 6, -3)

		button.cd = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
		button.cd:SetAllPoints()
		button.cd:SetReverse(true)
		button.cd:SetHideCountdownNumbers(true)

		if not prevDebuff then
			button:SetPoint("BOTTOMLEFT", self.Health)
		else
			button:SetPoint("LEFT", prevDebuff, "RIGHT")
		end
		prevDebuff = button
		debuffFrame.buttons[i] = button
	end

	self.DebuffsIndicator = debuffFrame

	UF.DebuffsIndicator_UpdateOptions(self)
end

function UF:DebuffsIndicator_UpdateButton(debuffIndex, aura)
	local button = self.DebuffsIndicator.buttons[debuffIndex]
	if not button then return end

	button.unit, button.index, button.filter = aura.unit, aura.index, aura.filter
	if button.cd then
		local auraDuration = button.unit and GetAuraDuration(button.unit, aura.auraInstanceID)
		if auraDuration then
			button.cd:SetCooldownFromDurationObject(auraDuration)
			button.cd:Show()
		else
			button.cd:Hide()
		end
	end

	if button.bg then
		if aura.isDebuff then
			local color = oUF.colors.dispel[aura.debuffType] or oUF.colors.dispel[0]
			button.bg:SetBackdropBorderColor(color:GetRGB())
		else
			button.bg:SetBackdropBorderColor(0, 0, 0)
		end
	end

	if button.Icon then button.Icon:SetTexture(aura.texture) end
	if button.count then
		local count = aura.applications
		if issecretvalue(count) then
			button.count:SetText(GetAuraApplicationDisplayCount(button.unit, aura.auraInstanceID, MIN_SPELL_COUNT, MAX_SPELL_COUNT))
		else
			local hideCount = not count or (count < MIN_SPELL_COUNT or count > MAX_SPELL_COUNT)
			button.count:SetText(hideCount and "" or count)
		end
	end

	button:Show()
end

function UF:DebuffsIndicator_HideButtons(from, to)
	for i = from, to do
		local button = self.DebuffsIndicator.buttons[i]
		if button then
			button:Hide()
		end
	end
end

function UF.DebuffsIndicator_Filter(raidAuras, aura)
	local spellID = aura.spellID
	if not issecretvalue(spellID) and UF.RaidDebuffsBlack[spellID] then
		return false
	elseif aura.isBosAsura or AuraUtil.IsRoleAura(aura) then
		return true
	else
		return AuraUtil.ShouldDisplayDebuff(aura.Caster, spellID)
	end
end

function UF:DebuffsIndicator_UpdateOptions()
	local debuffs = self.DebuffsIndicator
	if not debuffs then return end

	debuffs.enable = C.db["UFs"]["ShowRaidDebuff"]
	local size = C.db["UFs"]["RaidDebuffSize"]
	local disableMouse = C.db["UFs"]["DebuffClickThru"]

	for i = 1, 3 do
		local button = debuffs.buttons[i]
		if button then
			button:SetSize(size, size)
			button:EnableMouse(not disableMouse)
		end
	end
end