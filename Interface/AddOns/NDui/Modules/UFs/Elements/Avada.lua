local _, ns = ...
local B, C, L, DB = unpack(ns)
local UF = B:GetModule("UnitFrames")

local wipe, gmatch, strmatch = table.wipe, string.gmatch, string.match
local GetSpecialization = GetSpecialization
local GetSpellTexture = C_Spell.GetSpellTexture
local EMPTY_TEXTURE = "Interface\\Icons\\INV_Misc_QuestionMark"

local defaultStrings = {
	["HUNTER"] = {
		[1] = "1:player:cd:34026N2:player:cd:217200N3:pet:buff:272790N4:player:buff:268877N5:player:cd:19574N6:player:cd:264735",
		[2] = "1:player:cd:19434N2:player:cd:257044N3:player:buff:257622N4:player:buff:474293N5:player:buff:194594N6:player:cd:288613",
		[3] = "1:player:cd:259489N2:player:cd:259495N3:player:cd:212431N4:player:cd:212436N5:player:cd:203415N6:player:cd:360952",
	},
	["MAGE"] = {
		[1] = "",
		[2] = "",
		[3] = "",
	},
	["PALADIN"] = {
		[1] = "",
		[2] = "",
		[3] = "",
	},		
	["PRIEST"] = {
		[1] = "",
		[2] = "",
		[3] = "",
	},
	["ROGUE"] = {
		[1] = "",
		[2] = "",
		[3] = "",
	},
	["SHAMAN"] = {
		[1] = "",
		[2] = "",
		[3] = "",
	},
	["WARLOCK"] = {
		[1] = "",
		[2] = "",
		[3] = "",
	},
	["WARRIOR"] = {
		[1] = "",
		[2] = "",
		[3] = "",
	},
	["DEATHKNIGHT"] = {
		[1] = "",
		[2] = "",
		[3] = "",
	},
	["DEMONHUNTER"] = {
		[1] = "",
		[2] = "",
	},
	["MONK"] = {
		[1] = "",
		[2] = "",
		[3] = "",
	},
	["EVOKER"] = {
		[1] = "",
		[2] = "",
		[3] = "",
	},
	["DRUID"] = {
		[1] = "",
		[2] = "",
		[3] = "",
		[4] = "",
	},
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
		local iconIndex, unit, iconType, spellID = strmatch(result, "(%d+):(%w+):(%w+):(%d+)")
		iconIndex = tonumber(iconIndex)
		auraData[iconIndex] = {index = iconIndex, unit = unit, type = iconType, spellID = tonumber(spellID)}
	end
end

function UF:Avada_RefreshIcons()
	local specIndex = GetSpecialization()
	if not specIndex then return end
	wipe(auraData)
	local classString = defaultStrings[DB.MyClass][specIndex]
	if classString then
		stringParser(classString)
	end

	for i = 1, maxButtons do
		local button = avadaButtons[i]
		if button then
			local spellID = auraData[i] and auraData[i].spellID
			local texture = spellID and GetSpellTexture(replacedTexture[spellID] or spellID) or EMPTY_TEXTURE
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

function UF:AvadaKedavra(self)
	if not C.db["Avada"]["Enable"] then return end

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

	B:RegisterEvent("UNIT_AURA", UF.Avada_OnAura)
	self:RegisterEvent("PLAYER_TARGET_CHANGED", UF.Avada_OnEvent, true)
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN", UF.Avada_OnEvent, true)
	self:RegisterEvent("SPELL_UPDATE_CHARGES", UF.Avada_OnEvent, true)

	UF.Avada_RefreshAll(self)
	self:RegisterEvent("PLAYER_TALENT_UPDATE", UF.Avada_RefreshAll, true)
end