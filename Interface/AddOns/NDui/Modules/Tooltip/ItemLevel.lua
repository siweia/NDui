local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:GetModule("Tooltip")

-- Credit: Cloudy Unit Info, by Cloudyfa
local select, max, strfind, format, strsplit = select, math.max, string.find, string.format, string.split
local GetTime, CanInspect, NotifyInspect, ClearInspectPlayer, IsShiftKeyDown = GetTime, CanInspect, NotifyInspect, ClearInspectPlayer, IsShiftKeyDown
local UnitGUID, UnitClass, UnitIsUnit, UnitIsPlayer, UnitIsVisible, UnitIsDeadOrGhost, UnitOnTaxi = UnitGUID, UnitClass, UnitIsUnit, UnitIsPlayer, UnitIsVisible, UnitIsDeadOrGhost, UnitOnTaxi
local GetInventoryItemTexture, GetInventoryItemLink, GetAverageItemLevel = GetInventoryItemTexture, GetInventoryItemLink, GetAverageItemLevel
local HEIRLOOMS = _G.HEIRLOOMS

local levelPrefix = STAT_AVERAGE_ITEM_LEVEL..": "..DB.InfoColor
local isPending = LFG_LIST_LOADING
local resetTime, frequency = 900, .5
local inspectFrameLockTime, inspectNotifyLockTime = 10, 3
local cache, weapon, currentUNIT, currentGUID, inspectGUID = {}, {}
local updater
local inspectFrameTime, inspectNotifyTime = 0, 0
local tooltipInspecting

TT.TierSets = {
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

local formatSets = {
	[1] = " |cff14b200(1/4)", -- green
	[2] = " |cff0091f2(2/4)", -- blue
	[3] = " |cff0091f2(3/4)", -- blue
	[4] = " |cffc745f9(4/4)", -- purple
	[5] = " |cffc745f9(5/5)", -- purple
}

local function checkUnitGUID(unit)
	local guid = UnitGUID(unit)
	return B:NotSecretValue(guid) and guid
end

local function StopInspectUpdate(clearGUID)
	if updater then updater:Hide() end
	if clearGUID then inspectGUID = nil end
end

local function CancelInspectUpdate()
	StopInspectUpdate(true)
	if TT.GetInspectInfo then
		B:UnregisterEvent("INSPECT_READY", TT.GetInspectInfo)
	end
end

local function InspectFrameIsBusy()
	local now = GetTime()
	if inspectFrameTime > 0 and now - inspectFrameTime < inspectFrameLockTime then return true end
	if inspectNotifyTime > 0 and now - inspectNotifyTime < inspectNotifyLockTime then return true end

	return InspectFrame and InspectFrame:IsShown()
end

local function OnInspectUnit()
	inspectFrameTime = GetTime()
	CancelInspectUpdate()
end

local function HookInspectUnit()
	if not InspectUnit or TT.inspectUnitHooked then return end

	hooksecurefunc("InspectUnit", OnInspectUnit)
	TT.inspectUnitHooked = true
end

local function OnInspectUILoaded(event, addon)
	if addon ~= "Blizzard_InspectUI" then return end

	HookInspectUnit()
	B:UnregisterEvent(event, OnInspectUILoaded)
end

hooksecurefunc("NotifyInspect", function()
	if not tooltipInspecting then
		inspectNotifyTime = GetTime()
		CancelInspectUpdate()
	end
end)

function TT:InspectOnUpdate(elapsed)
	self.elapsed = (self.elapsed or frequency) + elapsed
	if self.elapsed > frequency then
		self.elapsed = 0

		if currentUNIT and checkUnitGUID(currentUNIT) == currentGUID then
			if InspectFrameIsBusy() then
				CancelInspectUpdate()
				return
			end

			B:RegisterEvent("INSPECT_READY", TT.GetInspectInfo)
			inspectGUID = currentGUID
			StopInspectUpdate()
			tooltipInspecting = true
			NotifyInspect(currentUNIT)
			tooltipInspecting = nil
		else
			CancelInspectUpdate()
		end
	end
end

updater = CreateFrame("Frame")
updater:SetScript("OnUpdate", TT.InspectOnUpdate)
updater:Hide()

HookInspectUnit()
if not TT.inspectUnitHooked then
	B:RegisterEvent("ADDON_LOADED", OnInspectUILoaded)
end

local lastTime = 0
function TT:GetInspectInfo(...)
	if self == "UNIT_INVENTORY_CHANGED" then
		if InCombatLockdown() then return end
		local thisTime = GetTime()
		if thisTime - lastTime > .1 then
			lastTime = thisTime

			local unit = ...
			if checkUnitGUID(unit) == currentGUID then
				TT:InspectUnit(unit, true)
			end
		end
	elseif self == "INSPECT_READY" then
		local guid = ...
		if B:NotSecretValue(guid) and guid == currentGUID and guid == inspectGUID then
			inspectGUID = nil

			local level = TT:GetUnitItemLevel(currentUNIT)
			cache[guid].level = level
			cache[guid].getTime = GetTime()

			if level then
				TT:SetupItemLevel(level)
			else
				TT:InspectUnit(currentUNIT, true)
			end

			if not InspectFrameIsBusy() then
				ClearInspectPlayer()
			end
		else
			inspectGUID = nil
		end
		B:UnregisterEvent(self, TT.GetInspectInfo)
	end
end
B:RegisterEvent("UNIT_INVENTORY_CHANGED", TT.GetInspectInfo)

function TT:SetupItemLevel(level)
	if not TT:UnitExists("mouseover") or UnitGUID("mouseover") ~= currentGUID then return end

	local levelLine
	for i = 2, GameTooltip:NumLines() do
		local line = _G["GameTooltipTextLeft"..i]
		local text = line:GetText()
		if text and B:NotSecretValue(text) and strfind(text, levelPrefix) then
			levelLine = line
		end
	end

	level = levelPrefix..(level or isPending)
	if levelLine then
		levelLine:SetText(level)
	else
		GameTooltip:AddLine(level)
	end
end

function TT:GetUnitItemLevel(unit)
	if not unit or checkUnitGUID(unit) ~= currentGUID then return end

	local class = select(2, UnitClass(unit))
	local ilvl, boa, total, haveWeapon, twohand, sets = 0, 0, 0, 0, 0, 0
	local delay, mainhand, offhand, hasArtifact
	weapon[1], weapon[2] = 0, 0

	for i = 1, 17 do
		if i ~= 4 then
			local itemTexture = GetInventoryItemTexture(unit, i)

			if itemTexture then
				local itemLink = GetInventoryItemLink(unit, i)

				if not itemLink then
					delay = true
				else
					local _, _, quality, level, _, _, _, _, slot = C_Item.GetItemInfo(itemLink)
					if (not quality) or (not level) then
						delay = true
					else
						if quality == Enum.ItemQuality.Heirloom then
							boa = boa + 1
						end

						local itemID = GetItemInfoFromHyperlink(itemLink)
						if TT.TierSets[itemID] then
							sets = sets + 1
						end

						if unit ~= "player" then
							level = B.GetItemLevel(itemLink) or level
							if i < 16 then
								total = total + level
							elseif i > 15 and quality == Enum.ItemQuality.Artifact then
								local relics = {select(4, strsplit(":", itemLink))}
								for i = 1, 3 do
									local relicID = relics[i] ~= "" and relics[i]
									local relicLink = select(2, C_Item.GetItemGem(itemLink, i))
									if relicID and not relicLink then
										delay = true
										break
									end
								end
							end

							if i == 16 then
								if quality == Enum.ItemQuality.Artifact then hasArtifact = true end

								weapon[1] = level
								haveWeapon = haveWeapon + 1
								if slot == "INVTYPE_2HWEAPON" or slot == "INVTYPE_RANGED" or (slot == "INVTYPE_RANGEDRIGHT" and class == "HUNTER") then
									mainhand = true
									twohand = twohand + 1
								end
							elseif i == 17 then
								weapon[2] = level
								haveWeapon = haveWeapon + 1
								if slot == "INVTYPE_2HWEAPON" then
									offhand = true
									twohand = twohand + 1
								end
							end
						end
					end
				end
			end
		end
	end

	if not delay then
		if unit == "player" then
			ilvl = select(2, GetAverageItemLevel())
		else
			if hasArtifact or twohand == 2 then
				local higher = max(weapon[1], weapon[2])
				total = total + higher*2
			elseif twohand == 1 and haveWeapon == 1 then
				total = total + weapon[1]*2 + weapon[2]*2
			elseif twohand == 1 and haveWeapon == 2 then
				if mainhand and weapon[1] >= weapon[2] then
					total = total + weapon[1]*2
				elseif offhand and weapon[2] >= weapon[1] then
					total = total + weapon[2]*2
				else
					total = total + weapon[1] + weapon[2]
				end
			else
				total = total + weapon[1] + weapon[2]
			end
			ilvl = total / 16
		end

		if ilvl > 0 then ilvl = format("%.1f", ilvl) end
		if boa > 0 then ilvl = ilvl.." |cff00ccff("..boa..HEIRLOOMS..")" end
		if sets > 0 then ilvl = ilvl..formatSets[sets] end
	else
		ilvl = nil
	end

	return ilvl
end

function TT:InspectUnit(unit, forced)
	local level

	if UnitIsUnit(unit, "player") then
		level = self:GetUnitItemLevel("player")
		self:SetupItemLevel(level)
	else
		if not unit or checkUnitGUID(unit) ~= currentGUID then return end
		if not UnitIsPlayer(unit) then return end

		local currentDB = cache[currentGUID]
		level = currentDB.level
		self:SetupItemLevel(level)

		if not C.db["Tooltip"]["SpecLevelByShift"] and IsShiftKeyDown() then forced = true end
		if level and not forced and (GetTime() - currentDB.getTime < resetTime) then updater.elapsed = frequency return end
		if not UnitIsVisible(unit) or UnitIsDeadOrGhost("player") or UnitOnTaxi("player") then return end
		if InspectFrameIsBusy() then return end

		self:SetupItemLevel()
		updater:Show()
	end
end

function TT:InspectUnitItemLevel(unit)
	if C.db["Tooltip"]["SpecLevelByShift"] and not IsShiftKeyDown() then return end

	if not unit or not CanInspect(unit) then return end
	currentUNIT, currentGUID = unit, checkUnitGUID(unit)
	if not cache[currentGUID] then cache[currentGUID] = {} end

	TT:InspectUnit(unit)
end
