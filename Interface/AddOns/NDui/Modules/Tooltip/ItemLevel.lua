local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:GetModule("Tooltip")

local format, strfind = string.format, string.find
local GetTime, CanInspect, NotifyInspect, ClearInspectPlayer = GetTime, CanInspect, NotifyInspect, ClearInspectPlayer
local UnitGUID, UnitIsPlayer, UnitIsVisible, UnitIsDeadOrGhost, UnitOnTaxi = UnitGUID, UnitIsPlayer, UnitIsVisible, UnitIsDeadOrGhost, UnitOnTaxi
local GetInventoryItemID, GetInventoryItemQuality = GetInventoryItemID, GetInventoryItemQuality
local GetAverageItemLevel = GetAverageItemLevel
local HEIRLOOMS = _G.HEIRLOOMS

local levelPrefix = STAT_AVERAGE_ITEM_LEVEL..": "..DB.InfoColor
local pendingText = LFG_LIST_LOADING
local cacheDuration, requestDelay = 120, .5
local inspectFrameLockTime, inspectNotifyLockTime = 10, 3
local heirloomQuality = Enum.ItemQuality.Heirloom
local cache = {}
local currentUnit, currentGUID, pendingGUID
local inspectFrameTime, inspectNotifyTime = 0, 0
local lastTooltipInspectTime = 0
local internalInspect
local requester, OnInspectReady

local tierSets = {
	-- WARRIOR
	[271454] = true, [271455] = true, [271456] = true, [271457] = true, [271459] = true,
	-- PALADIN
	[271463] = true, [271464] = true, [271465] = true, [271466] = true, [271468] = true,
	-- HUNTER
	[271490] = true, [271491] = true, [271492] = true, [271493] = true, [271495] = true,
	-- ROGUE
	[271508] = true, [271509] = true, [271510] = true, [271511] = true, [271513] = true,
	-- PRIEST
	[271553] = true, [271554] = true, [271555] = true, [271556] = true, [271558] = true,
	-- DEATHKNIGHT
	[271472] = true, [271473] = true, [271474] = true, [271475] = true, [271477] = true,
	-- SHAMAN
	[271481] = true, [271482] = true, [271483] = true, [271484] = true, [271486] = true,
	-- MAGE
	[271562] = true, [271563] = true, [271564] = true, [271565] = true, [271567] = true,
	-- WARLOCK
	[271544] = true, [271545] = true, [271546] = true, [271547] = true, [271549] = true,
	-- MONK
	[271517] = true, [271518] = true, [271519] = true, [271520] = true, [271522] = true,
	-- DRUID
	[271526] = true, [271527] = true, [271528] = true, [271529] = true, [271531] = true,
	-- DEMONHUNTER
	[271535] = true, [271536] = true, [271537] = true, [271538] = true, [271540] = true,
	-- EVOKER
	[271499] = true, [271500] = true, [271501] = true, [271502] = true, [271504] = true,
}

local setText = {
	[1] = " |cff14b200(1/4)",
	[2] = " |cff0091f2(2/4)",
	[3] = " |cff0091f2(3/4)",
	[4] = " |cffc745f9(4/4)",
	[5] = " |cffc745f9(5/5)",
}

local function GetUnitGUID(unit)
	local guid = unit and UnitGUID(unit)
	return B:NotSecretValue(guid) and guid
end

local function UnitMatchesGUID(unit, guid)
	return unit and B:NotSecretValue(unit) and guid and GetUnitGUID(unit) == guid
end

local function GetInspectUnit(guid, preferred)
	if UnitMatchesGUID(preferred, guid) then return preferred end
	if UnitMatchesGUID("player", guid) then return "player" end

	local count, prefix
	if IsInRaid() then
		count, prefix = GetNumGroupMembers(), "raid"
	else
	count, prefix = GetNumSubgroupMembers(), "party"
	end
	for index = 1, count do
		local unit = prefix..index
		if UnitMatchesGUID(unit, guid) then return unit end
	end

	local unit = UnitTokenFromGUID and UnitTokenFromGUID(guid)
	return UnitMatchesGUID(unit, guid) and unit
end

local function IsCurrentUnit(unit, guid)
	return currentGUID == guid and UnitMatchesGUID(unit, guid)
end

local function GetInspectItemLevel(unit)
	if not C_PaperDollInfo or not C_PaperDollInfo.GetInspectItemLevel then return end
	local level = C_PaperDollInfo.GetInspectItemLevel(unit)
	if not B:NotSecretValue(level) or type(level) ~= "number" or level <= 0 then return end
	return level
end

local function GetPlayerItemLevel()
	local _, level = GetAverageItemLevel()
	if B:NotSecretValue(level) and type(level) == "number" and level > 0 then
		return level
	end
	return GetInspectItemLevel("player")
end

local function GetEquipmentCounts(unit)
	local heirlooms, tierPieces = 0, 0
	for slot = 1, 17 do
		if slot ~= 4 then
			local itemID = GetInventoryItemID(unit, slot)
			if itemID and B:NotSecretValue(itemID) then
				if tierSets[itemID] then tierPieces = tierPieces + 1 end
				if GetInventoryItemQuality(unit, slot) == heirloomQuality then
					heirlooms = heirlooms + 1
				end
			end
		end
	end
	return heirlooms, tierPieces
end

local function FormatItemLevel(level, heirlooms, tierPieces)
	if not level then return end
	local text = format("%.1f", level)
	if heirlooms > 0 then text = text.." |cff00ccff("..heirlooms..HEIRLOOMS..")" end
	if setText[tierPieces] then text = text..setText[tierPieces] end
	return text
end

local function UpdateTooltip(guid, text, unit, refresh)
	-- Post-calls run before Show(); only delayed inspect results require a visible unit tooltip.
	if refresh and (not GameTooltip:IsShown() or not GameTooltip:IsTooltipType(Enum.TooltipDataType.Unit)) then return end
	if not TT:UnitExists(unit) or GetUnitGUID(unit) ~= guid then return end
	local line
	for index = 2, GameTooltip:NumLines() do
		local candidate = _G["GameTooltipTextLeft"..index]
		local value = candidate and candidate:GetText()
		if value and B:NotSecretValue(value) and strfind(value, levelPrefix, 1, true) then
			line = candidate
			break
		end
	end

	local value = levelPrefix..(text or pendingText)
	if line then
		line:SetText(value)
	else
		GameTooltip:AddLine(value)
	end
	if refresh then GameTooltip:Show() end
end

local function CancelRequest()
	if requester then requester:Hide() end
	pendingGUID = nil
	B:UnregisterEvent("INSPECT_READY", OnInspectReady)
end

local function IsInspectBusy()
	local now = GetTime()
	if (inspectFrameTime > 0 and now - inspectFrameTime < inspectFrameLockTime)
		or (inspectNotifyTime > 0 and now - inspectNotifyTime < inspectNotifyLockTime) then return true end
	return InspectFrame and InspectFrame:IsShown()
end

OnInspectReady = function(_, guid)
	if not B:NotSecretValue(guid) or guid ~= pendingGUID then return end

	local unit = GetInspectUnit(guid, currentUnit)
	local current = UnitMatchesGUID(unit, guid)
	local level, heirlooms, tierPieces
	if current then
		level = GetInspectItemLevel(unit)
		if level then heirlooms, tierPieces = GetEquipmentCounts(unit) end
	end

	if current and level then
		local entry = {text = FormatItemLevel(level, heirlooms, tierPieces), time = GetTime()}
		cache[guid] = entry
		local tooltipUnit, tooltipGUID = TT.GetUnit(GameTooltip)
		if tooltipGUID == guid or UnitMatchesGUID(tooltipUnit, guid) then
			tooltipUnit = GetInspectUnit(guid, tooltipUnit)
			UpdateTooltip(guid, entry.text, tooltipUnit, true)
		end
	end

	pendingGUID = nil
	B:UnregisterEvent("INSPECT_READY", OnInspectReady)
	if not IsInspectBusy() then ClearInspectPlayer() end
	if requester and currentGUID ~= guid and UnitMatchesGUID(currentUnit, currentGUID) then
		requester.elapsed = 0
		requester:Show()
	end
end
local function OnExternalInspect()
	if internalInspect then return end
	inspectNotifyTime = GetTime()
	CancelRequest()
end

local function OnInspectUnit()
	inspectFrameTime = GetTime()
	CancelRequest()
end

local function HookInspectUnit()
	if InspectUnit and not TT.inspectUnitHooked then
		hooksecurefunc("InspectUnit", OnInspectUnit)
		TT.inspectUnitHooked = true
	end
end
function TT:GetInspectInfo(event, unit)
	if event ~= "UNIT_INVENTORY_CHANGED" or InCombatLockdown() then return end
	if IsCurrentUnit(unit, currentGUID) then
		local entry = cache[currentGUID]
		if entry then entry.time = 0 end
	end
end

function TT:InspectUnitItemLevel(unit)
	if C.db["Tooltip"]["SpecLevelByShift"] and not IsShiftKeyDown() then return end

	local guid = GetUnitGUID(unit)
	if not guid then return end

	if UnitIsUnit(unit, "player") then
		local level = GetPlayerItemLevel()
		local heirlooms, tierPieces = GetEquipmentCounts("player")
		UpdateTooltip(guid, FormatItemLevel(level, heirlooms, tierPieces), unit)
		return
	end
	if not UnitIsPlayer(unit) or not CanInspect(unit) then return end

	if currentGUID ~= guid and requester then requester:Hide() end
	currentUnit, currentGUID = unit, guid

	local entry = cache[guid]
	local force = not C.db["Tooltip"]["SpecLevelByShift"] and IsShiftKeyDown()
	if entry and not force and GetTime() - entry.time < cacheDuration then
		UpdateTooltip(guid, entry.text, unit)
		return
	end

	UpdateTooltip(guid, nil, unit)
	if pendingGUID == guid then return end
	if not UnitIsVisible(unit) or UnitIsDeadOrGhost("player") or UnitOnTaxi("player") or IsInspectBusy() then return end
	if not requester:IsShown() then
		requester.elapsed = 0
		requester:Show()
	end
end

function TT:SetupItemLevel()
	requester = CreateFrame("Frame")
	requester:Hide()
	requester:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed < requestDelay then return end
		self.elapsed = 0

		if pendingGUID then return end
		if not IsCurrentUnit(currentUnit, currentGUID) or IsInspectBusy() then
			self:Hide()
			return
		end
		if lastTooltipInspectTime > 0 then
			local remaining = inspectNotifyLockTime - (GetTime() - lastTooltipInspectTime)
			if remaining > 0 then
				self.elapsed = requestDelay - math.min(requestDelay, remaining)
				return
			end
		end

		pendingGUID = currentGUID
		B:RegisterEvent("INSPECT_READY", OnInspectReady)
		lastTooltipInspectTime = GetTime()
		ClearInspectPlayer()
		internalInspect = true
		NotifyInspect(currentUnit)
		internalInspect = nil
		self:Hide()
	end)

	HookInspectUnit()
	if not TT.inspectUnitHooked then
		local function OnAddonLoaded(event, addon)
			if addon ~= "Blizzard_InspectUI" then return end
			HookInspectUnit()
			B:UnregisterEvent(event, OnAddonLoaded)
		end
		B:RegisterEvent("ADDON_LOADED", OnAddonLoaded)
	end
	hooksecurefunc("NotifyInspect", OnExternalInspect)
	B:RegisterEvent("UNIT_INVENTORY_CHANGED", TT.GetInspectInfo)
end
