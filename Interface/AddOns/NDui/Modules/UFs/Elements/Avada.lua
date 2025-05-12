local _, ns = ...
local B, C, L, DB = unpack(ns)
local UF = B:GetModule("UnitFrames")

local wipe, gmatch, strmatch = table.wipe, string.gmatch, string.match
local GetSpecialization, GetSpecializationInfo = GetSpecialization, GetSpecializationInfo
local GetSpellTexture = C_Spell.GetSpellTexture
local EMPTY_TEXTURE = "Interface\\Icons\\INV_Misc_QuestionMark"
local myFullName = DB.MyFullName

UF.defaultStrings = {
	[0] = "", -- None
	-- HUNTER
	[253] = "1ZplayerZcdZ34026N2ZplayerZcdZ217200N3ZpetZbuffZ272790N4ZplayerZbuffZ268877N5ZplayerZcdZ19574N6ZplayerZcdZ359844", -- Beast Mastery
	[254] = "1ZplayerZcdZ19434N2ZplayerZcdZ257044N3ZplayerZbuffZ257622N4ZplayerZbuffZ474293N5ZplayerZbuffZ389020N6ZplayerZcdZ288613", -- Marksmanship
	[255] = "1ZplayerZcdZ259489N2ZplayerZcdZ259495N3ZplayerZcdZ212431N4ZplayerZcdZ212436N5ZplayerZcdZ203415N6ZplayerZcdZ360952", -- Survival
	-- DK
	[250] = "", -- Blood
	[251] = "", -- Frost
	[252] = "", -- Unholy
	-- MAGE
	[62] = "", -- Arcane
	[63] = "", -- Fire
	[64] = "", -- Frost
	-- PALADIN
	[65] = "", -- Holy
	[66] = "", -- Protection
	[70] = "", -- Retribution
	-- PRIEST
	[256] = "", -- Discipline
	[257] = "", -- Holy
	[258] = "", -- Shadow
	-- ROGUE
	[259] = "", -- Assassination
	[260] = "", -- Outlaw
	[261] = "", -- Subtlety
	-- SHAMAN
	[262] = "", -- Elemental
	[263] = "", -- Enhancement
	[264] = "", -- Restoration
	-- DH
	[577] = "", -- Havoc
	[581] = "", -- Vengeance
	-- DRUID
	[102] = "", -- Balance
	[103] = "", -- Feral
	[104] = "", -- Guardian
	[105] = "", -- Restoration
	-- WARLOCK
	[265] = "", -- Affliction
	[266] = "", -- Demonology
	[267] = "", -- Destruction
	-- WARRIOR
	[71] = "", -- Arms
	[72] = "", -- Fury
	[73] = "", -- Protection
	-- EVOKER
	[1467] = "", -- Devastation
	[1468] = "", -- Preservation
	[1473] = "", -- Augmentation
	-- MONK
	[268] = "", -- Brewmaster
	[269] = "", -- Windwalker
	[270] = "", -- Mistweaver
}

local replacedTexture = {
	[272790] = 106785, -- 倒刺buff转换
}

local avadaButtons, auraData = {}, {}
local maxButtons = 6
for i = 1, maxButtons do
	auraData[i] = {}
end

local watchUnits, watchTypes = {}, {}
function UF:Avada_UpdateWatchData()
	wipe(watchUnits)
	wipe(watchTypes)

	for i = 1, maxButtons do
		if auraData[i] then
			local unit = auraData[i].unit
			local iconType = auraData[i].type
			if unit and unit ~= "" then
				watchUnits[unit] = true
			end
			if iconType and iconType ~= "" then
				watchTypes[iconType] = true
			end
		end
	end
end

local function stringParser(str)
	for result in gmatch(str, "[^N]+") do
		local iconIndex, unit, iconType, spellID = strmatch(result, "(%d+)Z(%w+)Z(%w+)Z(%d+)")
		iconIndex = tonumber(iconIndex)
		auraData[iconIndex] = {index = iconIndex, unit = unit, type = iconType, spellID = tonumber(spellID)}
	end
end

function UF:Avada_RefreshIcons()
	local specIndex = GetSpecialization()
	if specIndex > 4 then specIndex = 1 end -- use 1st spec for lower level
	local specID = GetSpecializationInfo(specIndex)
	if not specID then return end

	wipe(auraData)
	local profileIndex = NDuiADB["AvadaIndex"][myFullName] and NDuiADB["AvadaIndex"][myFullName][specID]
	local classString = NDuiADB["AvadaProfile"][specID] and NDuiADB["AvadaProfile"][specID][profileIndex] or UF.defaultStrings[specID]
	if classString then
		stringParser(classString)
	end

	for i = 1, maxButtons do
		local button = avadaButtons[i]
		if button then
			local spellID = auraData[i] and auraData[i].spellID
			local texture = spellID and GetSpellTexture(replacedTexture[spellID] or spellID) or EMPTY_TEXTURE
			if auraData[i] and auraData[i].type == "item" then
				texture = spellID and GetItemIcon(spellID) or EMPTY_TEXTURE
			end
			button.Icon:SetTexture(texture)
			button.Icon:SetDesaturated(true)
			button.Count:SetText("")
		end
	end
end

function UF:Avada_RefreshAll()
	UF.Avada_RefreshIcons(self)
	UF:Avada_UpdateWatchData()
end

function UF:Avada_GetUnitAura(unit, spellID, filter)
	for index = 1, 40 do
		local data = C_UnitAuras.GetAuraDataByIndex(unit, index, filter)
		if not data then break end
		if data.spellId == spellID then
			return data.name, data.applications, data.duration, data.expirationTime, data.sourceUnit, data.spellId, data.points[1]
		end
	end
end

function UF:Avada_UpdateAura(button, unit, spellID, filter)
	local name, count, duration, expire, caster, spellID, value = UF:Avada_GetUnitAura(unit, spellID, filter)
	if name and caster == "player" then
		button.Count:SetText(count > 0 and count or "")
		button.CD:SetCooldown(expire-duration, duration)
		button.CD:Show()
		button.Icon:SetDesaturated(false)
	else
		button.CD:Hide()
		button.Count:SetText("")
		button.Icon:SetDesaturated(true)
	end
	button.CD:SetReverse(true)
end

function UF:Avada_UpdateCD(button, spellID)
	local chargeInfo = C_Spell.GetSpellCharges(spellID)
	local charges = chargeInfo and chargeInfo.currentCharges
	local maxCharges = chargeInfo and chargeInfo.maxCharges
	local chargeStart = chargeInfo and chargeInfo.cooldownStartTime
	local chargeDuration = chargeInfo and chargeInfo.cooldownDuration

	local cooldownInfo = C_Spell.GetSpellCooldown(spellID)
	local start = cooldownInfo and cooldownInfo.startTime
	local duration = cooldownInfo and cooldownInfo.duration

	if charges and maxCharges > 1 then
		button.Count:SetText(charges)
	else
		button.Count:SetText("")
	end
	if charges and charges > 0 and charges < maxCharges then
		button.CD:SetCooldown(chargeStart, chargeDuration)
		button.CD:Show()
		button.Icon:SetDesaturated(false)
		button.Count:SetTextColor(0, 1, 0)
	elseif start and duration > 1.5 then
		button.CD:SetCooldown(start, duration)
		button.CD:Show()
		button.Icon:SetDesaturated(true)
		button.Count:SetTextColor(1, 1, 1)
	else
		button.CD:Hide()
		button.Icon:SetDesaturated(false)
		if charges == maxCharges then button.Count:SetTextColor(1, 0, 0) end
	end
	button.CD:SetReverse(false)
end

function UF:Avada_UpdateItem(button, itemID)
	local count = C_Item.GetItemCount(itemID)
	if count and count > 1 then
		button.Count:SetText(count)
	else
		button.Count:SetText("")
	end

	local start, duration = C_Item.GetItemCooldown(itemID)
	if start and duration > 3 then
		button.CD:SetCooldown(start, duration)
		button.CD:Show()
		button.Icon:SetDesaturated(true)
	else
		button.CD:Hide()
		button.Icon:SetDesaturated(false)
	end
	button.CD:SetReverse(false)
end

function UF:Avada_OnEvent(event, unit)
	if event == "PLAYER_TARGET_CHANGED" then
		if not watchTypes["buff"] and not watchTypes["debuff"] then return end
		if not watchUnits["target"] then return end

		for i = 1, maxButtons do
			local data = auraData[i]
			if data and data.unit == "target" then
				UF:Avada_UpdateAura(avadaButtons[data.index], data.unit, data.spellID, filter)
			end
		end
	elseif event == "SPELL_UPDATE_COOLDOWN" or event == "SPELL_UPDATE_CHARGES" then
		if not watchTypes["cd"] then return end

		for i = 1, maxButtons do
			local data = auraData[i]
			if data and data.type == "cd" then
				UF:Avada_UpdateCD(avadaButtons[data.index], data.spellID)
			end
		end
	elseif event == "BAG_UPDATE_COOLDOWN" then
		if not watchTypes["item"] then return end

		for i = 1, maxButtons do
			local data = auraData[i]
			if data and data.type == "item" then
				UF:Avada_UpdateItem(avadaButtons[data.index], data.spellID)
			end
		end
	end
end

function UF:Avada_OnAura(unit)
	if not watchTypes["buff"] and not watchTypes["debuff"] then return end
	if not watchUnits[unit] then return end

	for i = 1, maxButtons do
		local data = auraData[i]
		if data then
			local filter = data.type == "buff" and "HELPFUL" or data.type == "debuff" and "HARMFUL"
			if data.unit == unit and filter then
				UF:Avada_UpdateAura(avadaButtons[data.index], unit, data.spellID, filter)
			end
		end
	end
end

function UF:Avada_Toggle(frame)
	frame = frame or oUF_PlayerPlate
	if not frame then return end

	if C.db["Avada"]["Enable"] then
		for i = 1, 6 do frame.Avada[i]:Show() end
		B:RegisterEvent("UNIT_AURA", UF.Avada_OnAura)
		frame:RegisterEvent("PLAYER_TARGET_CHANGED", UF.Avada_OnEvent, true)
		frame:RegisterEvent("SPELL_UPDATE_COOLDOWN", UF.Avada_OnEvent, true)
		frame:RegisterEvent("SPELL_UPDATE_CHARGES", UF.Avada_OnEvent, true)
		frame:RegisterEvent("BAG_UPDATE_COOLDOWN", UF.Avada_OnEvent, true)

		UF.Avada_RefreshAll(frame)
		frame:RegisterEvent("PLAYER_TALENT_UPDATE", UF.Avada_RefreshAll, true)
	else
		for i = 1, 6 do frame.Avada[i]:Hide() end
		B:UnregisterEvent("UNIT_AURA", UF.Avada_OnAura)
		frame:UnregisterEvent("PLAYER_TARGET_CHANGED", UF.Avada_OnEvent)
		frame:UnregisterEvent("SPELL_UPDATE_COOLDOWN", UF.Avada_OnEvent)
		frame:UnregisterEvent("SPELL_UPDATE_CHARGES", UF.Avada_OnEvent)
		frame:UnregisterEvent("BAG_UPDATE_COOLDOWN", UF.Avada_OnEvent)
		frame:UnregisterEvent("PLAYER_TALENT_UPDATE", UF.Avada_RefreshAll, true)
	end
end

function UF:AvadaKedavra(self)
	local iconSize = (C.db["Nameplate"]["PPWidth"]+2*C.mult - C.margin*(maxButtons-1))/maxButtons

	self.Avada = {}
	for i = 1, maxButtons do
		local bu = CreateFrame("Frame", "NDui_AvadaIcon" .. i, self.Health)
		bu:SetSize(iconSize, iconSize)
		B.AuraIcon(bu)
		--bu.glowFrame = B.CreateGlowFrame(bu, iconSize)

		local fontParent = CreateFrame("Frame", nil, bu)
		fontParent:SetAllPoints()
		fontParent:SetFrameLevel(bu:GetFrameLevel() + 6)
		bu.Count = B.CreateFS(fontParent, 16, "", false, "BOTTOM", 0, -10)
		if i == 1 then
			bu:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", -C.mult, -C.margin)
		else
			bu:SetPoint("LEFT", self.Avada[i-1], "RIGHT", C.margin, 0)
		end

		self.Avada[i] = bu
	end
	avadaButtons = self.Avada
	UF.avadaData = auraData

	UF:Avada_Toggle(self)
end