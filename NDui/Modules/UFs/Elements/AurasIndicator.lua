local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF
local UF = B:GetModule("UnitFrames")

local invalidPrio = -1

local class, instID = DB.MyClass
local function checkInstance()
	instID = select(8, GetInstanceInfo())
end

local DispellColor = {
	["Magic"]	= {.2, .6, 1},
	["Curse"]	= {.6, 0, 1},
	["Disease"]	= {.6, .4, 0},
	["Poison"]	= {0, .6, 0},
	["none"]	= {0, 0, 0},
}

local DispellPriority = {
	["Magic"]	= 4,
	["Curse"]	= 3,
	["Disease"]	= 2,
	["Poison"]	= 1,
}

local DispellFilter
local cleanse = IsSpellKnown(51886)
do
	local dispellClasses = {
		["DRUID"] = {
			["Curse"] = true,
			["Poison"] = true,
		},
		["PALADIN"] = {
			["Magic"] = true,
			["Poison"] = true,
			["Disease"] = true,
		},
		["PRIEST"] = {
			["Magic"] = true,
			["Disease"] = true,
		},
		["SHAMAN"] = {
			["Poison"] = cleanse,
			["Disease"] = cleanse,
			["Curse"] = cleanse,
		},
		["MAGE"] = {
			["Curse"] = true,
		},
		["WARLOCK"] = {
			["Magic"] = true,
		},
	}

	DispellFilter = dispellClasses[class] or {}
end

local function checkSpecs()
	if class == "DRUID" then
		if GetSpecialization() == 4 then
			DispellFilter.Magic = true
		else
			DispellFilter.Magic = false
		end
	elseif class == "MONK" then
		if GetSpecialization() == 2 then
			DispellFilter.Magic = true
		else
			DispellFilter.Magic = false
		end
	elseif class == "PALADIN" then
		if GetSpecialization() == 1 then
			DispellFilter.Magic = true
		else
			DispellFilter.Magic = false
		end
	elseif class == "SHAMAN" then
		if GetSpecialization() == 3 then
			DispellFilter.Magic = true
		else
			DispellFilter.Magic = false
		end
	end
end

UF.DebuffList = {}

function UF:UpdateRaidDebuffs()
	wipe(UF.DebuffList)
	for instID, value in pairs(C.RaidDebuffs) do
		for spell, priority in pairs(value) do
			if not (NDuiADB["RaidDebuffs"][instID] and NDuiADB["RaidDebuffs"][instID][spell]) then
				if not UF.DebuffList[instID] then UF.DebuffList[instID] = {} end
				UF.DebuffList[instID][spell] = priority
			end
		end
	end
	for instID, value in pairs(NDuiADB["RaidDebuffs"]) do
		for spell, priority in pairs(value) do
			if priority > 0 then
				if not UF.DebuffList[instID] then UF.DebuffList[instID] = {} end
				UF.DebuffList[instID][spell] = priority
			end
		end
	end
end

function UF:UpdateRaidInfo()
	checkInstance()
	B:RegisterEvent("PLAYER_ENTERING_WORLD", checkInstance)
	--checkSpecs()
	--B:RegisterEvent("PLAYER_TALENT_UPDATE", checkSpecs)
	UF:UpdateRaidDebuffs()
end

function UF:AuraButton_OnEnter()
	if not self.index then return end
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
	GameTooltip:ClearLines()
	GameTooltip:SetUnitAura(self.unit, self.index, self.filter)
	GameTooltip:Show()
end

function UF:CreateAurasIndicator(self)
	local auraSize = 18

	local auraFrame = CreateFrame("Frame", nil, self)
	auraFrame:SetSize(1, 1)
	auraFrame:SetPoint("RIGHT", -15, 0)
	auraFrame.instAura = C.db["UFs"]["InstanceAuras"]
	auraFrame.dispellType = C.db["UFs"]["DispellType"]

	auraFrame.buttons = {}
	local prevAura
	for i = 1, 2 do
		local button = CreateFrame("Frame", nil, auraFrame)
		button:SetSize(auraSize, auraSize)
		button:SetFrameLevel(self:GetFrameLevel() + 3)
		B.PixelIcon(button)
		B.CreateSD(button, 3, true)
		button.__shadow:SetFrameLevel(self:GetFrameLevel() + 2)
		button:Hide()

		button:SetScript("OnEnter", UF.AuraButton_OnEnter)
		button:SetScript("OnLeave", B.HideTooltip)

		local parentFrame = CreateFrame("Frame", nil, button)
		parentFrame:SetAllPoints()
		parentFrame:SetFrameLevel(button:GetFrameLevel() + 6)
		button.count = B.CreateFS(parentFrame, 12, "", false, "BOTTOMRIGHT", 6, -3)
		button.timer = B.CreateFS(button, 12, "", false, "CENTER", 1, 0)
		button.glowFrame = B.CreateGlowFrame(button, auraSize)

		if not prevAura then
			button:SetPoint("RIGHT")
		else
			button:SetPoint("RIGHT", prevAura, "LEFT", -5, 0)
		end
		prevAura = button
		auraFrame.buttons[i] = button
	end

	self.AurasIndicator = auraFrame
	self.AurasIndicator.Debuffs = UF.DebuffList

	UF.AurasIndicator_UpdateOptions(self)
end

function UF.SortAuraTable(a, b)
	if a and b then
		return a.priority == b.priority and a.expiration > b.expiration or a.priority > b.priority
	end
end

function UF:AurasIndicator_UpdatePriority(numDebuffs, unit)
	local auras = self.AurasIndicator
	local dispellType = auras.dispellType
	local raidAuras = self.RaidAuras
	local isCharmed = UnitIsCharmed(unit) or UnitCanAttack("player", unit)

	for i = 1, numDebuffs do
		local aura = raidAuras.debuffList[i]
		if dispellType ~= 3 and aura.debuffType and not isCharmed then
			if dispellType == 2 then -- dispellable first
				aura.priority = DispellFilter[aura.debuffType] and (DispellPriority[aura.debuffType] + 6)
			elseif dispellType == 1 then -- by dispell type
				aura.priority = DispellPriority[aura.debuffType]
			end
			aura.priority = aura.priority or invalidPrio
		end

		if auras.instAura then
			local instPrio
			local debuffList = instID and auras.Debuffs[instID] or auras.Debuffs[0]
			if debuffList then
				instPrio = debuffList[aura.spellID]
			end

			if instPrio and (instPrio == 6 or instPrio > aura.priority) then
				aura.priority = instPrio
			end
		end
	end

	sort(raidAuras.debuffList, UF.SortAuraTable)
end

function UF:AurasIndicator_UpdateButton(button, aura)
	local icon, count, debuffType, duration, expiration = aura.texture, aura.count, aura.debuffType, aura.duration, aura.expiration
	button.unit, button.index, button.filter = aura.unit, aura.index, aura.filter

	if button.Icon then
		button.Icon:SetTexture(icon)
	end
	if button.count then
		button.count:SetText(count > 1 and count or "")
	end
	if button.timer then
		button.duration = duration
		if duration and duration > 0 then
			button.expiration = expiration
			button:SetScript("OnUpdate", B.CooldownOnUpdate)
			button.timer:Show()
		else
			button:SetScript("OnUpdate", nil)
			button.timer:Hide()
		end
	end
	if button.cd then
		if duration and duration > 0 then
			button.cd:SetCooldown(expiration - duration, duration)
			button.cd:Show()
		else
			button.cd:Hide()
		end
	end
	local color = DispellColor[debuffType] or DispellColor.none
	if button.__shadow then
		button.__shadow:SetBackdropBorderColor(color[1], color[2], color[3])
	end
	if button.glowFrame then
		if aura.priority == 6 then
			B.ShowOverlayGlow(button.glowFrame)
		else
			B.HideOverlayGlow(button.glowFrame)
		end
	end
	button:Show()
end

function UF:AurasIndicator_HideButtons()
	local auras = self.AurasIndicator
	if auras then
		auras.buttons[1]:Hide()
		auras.buttons[2]:Hide()
	end
end

function UF:AurasIndicator_UpdateOptions()
	local auras = self.AurasIndicator
	if not auras then return end

	auras.instAura = C.db["UFs"]["InstanceAuras"]
	auras.dispellType = C.db["UFs"]["DispellType"]
	local scale = C.db["UFs"]["RaidDebuffScale"]
	local disableMouse = C.db["UFs"]["AuraClickThru"]

	for i = 1, 2 do
		local button = auras.buttons[i]
		if button then
			button:SetScale(scale)
			button:EnableMouse(not disableMouse)
		end
	end
end