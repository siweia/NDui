local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF
local UF = B:GetModule("UnitFrames")

local SpellGetVisibilityInfo, SpellIsSelfBuff = SpellGetVisibilityInfo, SpellIsSelfBuff

UF.RaidBuffsWhite = {}
function UF:UpdateRaidBuffsWhite()
	wipe(UF.RaidBuffsWhite)

	for spellID in pairs(C.RaidBuffsWhite) do
		local name = GetSpellInfo(spellID)
		if name then
			if NDuiADB["RaidBuffsWhite"][spellID] == nil then
				UF.RaidBuffsWhite[spellID] = true
			end
		end
	end

	for spellID, value in pairs(NDuiADB["RaidBuffsWhite"]) do
		if value then
			UF.RaidBuffsWhite[spellID] = true
		end
	end
end

function UF:CreateBuffsIndicator(self)
	local buffFrame = CreateFrame("Frame", nil, self)
	buffFrame:SetSize(1, 1)
	buffFrame:SetPoint("BOTTOMRIGHT", -C.mult, C.mult)
	buffFrame:SetFrameLevel(5)

	buffFrame.buttons = {}
	local prevBuff
	for i = 1, 3 do
		local button = CreateFrame("Frame", nil, buffFrame)
		B.PixelIcon(button)
		button:SetScript("OnEnter", UF.AuraButton_OnEnter)
		button:SetScript("OnLeave", B.HideTooltip)
		button:Hide()

		local parentFrame = CreateFrame("Frame", nil, button)
		parentFrame:SetAllPoints()
		parentFrame:SetFrameLevel(button:GetFrameLevel() + 3)
		button.count = B.CreateFS(parentFrame, 10, "", false, "BOTTOMRIGHT", 6, -3)

		button.cd = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
		button.cd:SetAllPoints()
		button.cd:SetReverse(true)
		button.cd:SetHideCountdownNumbers(true)

		if not prevBuff then
			button:SetPoint("BOTTOMRIGHT", self.Health)
		else
			button:SetPoint("RIGHT", prevBuff, "LEFT")
		end
		prevBuff = button
		buffFrame.buttons[i] = button
	end

	self.BuffsIndicator = buffFrame

	UF.BuffsIndicator_UpdateOptions(self)
end

function UF:BuffsIndicator_UpdateButton(buffIndex, aura)
	local button = self.BuffsIndicator.buttons[buffIndex]
	if not button then return end

	button.unit, button.index, button.filter = aura.unit, aura.index, aura.filter
	if button.cd then
		if aura.duration and aura.duration > 0 then
			button.cd:SetCooldown(aura.expiration - aura.duration, aura.duration)
			button.cd:Show()
		else
			button.cd:Hide()
		end
	end

	if button.Icon then button.Icon:SetTexture(aura.texture) end
	if button.count then button.count:SetText(aura.count > 1 and aura.count or "") end

	button:Show()
end

function UF:BuffsIndicator_HideButtons(from, to)
	for i = from, to do
		local button = self.BuffsIndicator.buttons[i]
		if button then
			button:Hide()
		end
	end
end

function UF.BuffsIndicator_Filter(raidAuras, aura)
	local spellID = aura.spellID
	if aura.isBossAura then
		return true
	elseif C.db["UFs"]["AutoBuffs"] then
		local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellID, raidAuras.isInCombat and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")
		if hasCustom then
			return showForMySpec or (alwaysShowMine and aura.isPlayerAura)
		else
			return aura.isPlayerAura and aura.canApply and not SpellIsSelfBuff(spellID)
		end
	else
		return UF.RaidBuffsWhite[spellID]
	end
end

function UF:BuffsIndicator_UpdateOptions()
	local buffs = self.BuffsIndicator
	if not buffs then return end

	buffs.enable = C.db["UFs"]["ShowRaidBuff"]
	local size = C.db["UFs"]["RaidBuffSize"]
	local disableMouse = C.db["UFs"]["BuffClickThru"]

	for i = 1, 3 do
		local button = buffs.buttons[i]
		if button then
			button:SetSize(size, size)
			button:EnableMouse(not disableMouse)
		end
	end
end