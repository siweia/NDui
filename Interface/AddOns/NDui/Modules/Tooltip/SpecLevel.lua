local _, ns = ...
local B, C, L, DB = unpack(ns)
---------------------------------
-- CloudyUnitInfo, by Cloudyfa
-- NDui MOD
---------------------------------
local GearDB, SpecDB, currentUNIT, currentGUID, weapon = {}, {}
local gearPrefix = STAT_AVERAGE_ITEM_LEVEL..": "..DB.InfoColor
local specPrefix = SPECIALIZATION..": "..DB.InfoColor
local nextUpdate, lastUpdate = 0, 0
local updater = CreateFrame("Frame")

local function SetUnitInfo(gear, spec)
	if (not gear) and (not spec) then return end
	local _, unit = GameTooltip:GetUnit()
	if (not unit) or (UnitGUID(unit) ~= currentGUID) then return end

	local gearLine, specLine
	for i = 2, GameTooltip:NumLines() do
		local line = _G["GameTooltipTextLeft" .. i]
		local text = line:GetText()
		if text and strfind(text, gearPrefix) then
			gearLine = line
		elseif text and strfind(text, specPrefix) then
			specLine = line
		end
	end

	if spec then
		spec = specPrefix..spec
		if specLine then
			specLine:SetText(spec)
		else
			GameTooltip:AddLine(spec)
		end
	end

	if gear then
		gear = gearPrefix..gear
		if gearLine then
			gearLine:SetText(gear)
		else
			GameTooltip:AddLine(gear)
		end
	end

	GameTooltip:Show()
end

local function UnitGear(unit)
	if (not unit) or (UnitGUID(unit) ~= currentGUID) then return end
	local class = select(2, UnitClass(unit))
	local ilvl, boa, total, haveWeapon, twohand = 0, 0, 0, 0, 0
	local delay, mainhand, offhand, hasArtifact
	weapon = {0, 0}

	for i = 1, 17 do
		if i ~= 4 then
			local itemTexture = GetInventoryItemTexture(unit, i)

			if itemTexture then
				local itemLink = GetInventoryItemLink(unit, i)

				if not itemLink then
					delay = true
				else
					local _, _, quality, level, _, _, _, _, slot = GetItemInfo(itemLink)
					if (not quality) or (not level) then
						delay = true
					else
						if quality == 7 then
							boa = boa + 1
						end

						if unit ~= "player" then
							level = B.GetItemLevel(itemLink) or level
							if i < 16 then
								total = total + level
							elseif i > 15 and quality == 6 then
								local relics = {select(4, strsplit(":", itemLink))}
								for i = 1, 3 do
									local relicID = relics[i] ~= "" and relics[i]
									local relicLink = select(2, GetItemGem(itemLink, i))
									if relicID and not relicLink then
										delay = true
										break
									end
								end
							end

							if i == 16 then
								if quality == 6 then hasArtifact = true end

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
				local higher = math.max(weapon[1], weapon[2])
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

		if ilvl > 0 then ilvl = string.format("%d", ilvl) end
		if boa > 0 then ilvl = ilvl.." |cff00ccff("..boa..HEIRLOOMS..")" end
	else
		ilvl = nil
	end

	return ilvl
end

local function UnitSpec(unit)
	if (not unit) or (UnitGUID(unit) ~= currentGUID) then return end

	local specName
	if unit == "player" then
		local specIndex = GetSpecialization()
		if specIndex then
			specName = select(2, GetSpecializationInfo(specIndex))
		end
	else
		local specID = GetInspectSpecialization(unit)
		if specID and (specID > 0) then
			specName = select(2, GetSpecializationInfoByID(specID))
		end
	end

	return specName
end

local function ScanUnit(unit, forced)
	local cachedGear, cachedSpec

	if UnitIsUnit(unit, "player") then
		cachedGear = UnitGear("player")
		cachedSpec = UnitSpec("player")
		SetUnitInfo(cachedGear or LFG_LIST_LOADING, cachedSpec or LFG_LIST_LOADING)
	else
		if (not unit) or (UnitGUID(unit) ~= currentGUID) or (not UnitIsPlayer(unit)) then return end
		cachedGear = GearDB[currentGUID]
		cachedSpec = UnitSpec(unit) or SpecDB[currentGUID]

		if cachedGear or forced then
			SetUnitInfo(cachedGear or LFG_LIST_LOADING, cachedSpec)
		end

		if not (IsShiftKeyDown() or forced) then
			if cachedGear and cachedSpec then return end
		end

		if not UnitIsVisible(unit) then return end
		if UnitIsDeadOrGhost("player") or UnitOnTaxi("player") then return end
		if InspectFrame and InspectFrame:IsShown() then return end

		SetUnitInfo(LFG_LIST_LOADING, cachedSpec or LFG_LIST_LOADING)

		local lastRequest = GetTime() - lastUpdate
		if lastRequest >= 1.5 then
			nextUpdate = 0
		else
			nextUpdate = 1.5 - lastRequest
		end
		updater:Show()
	end
end

local function getInspectInfo(event, ...)
	if event == "UNIT_INVENTORY_CHANGED" then
		local unit = ...
		if UnitGUID(unit) == currentGUID then
			ScanUnit(unit, true)
		end
	elseif event == "INSPECT_READY" then
		local guid = ...
		if guid == currentGUID then
			local spec = UnitSpec(currentUNIT)
			SpecDB[guid] = spec

			local gear = UnitGear(currentUNIT)
			GearDB[guid] = gear

			if gear and spec then
				SetUnitInfo(gear, spec)
			else
				ScanUnit(currentUNIT, true)
			end
		end
		B:UnregisterEvent(event, getInspectInfo)
	end
end
B:RegisterEvent("UNIT_INVENTORY_CHANGED", getInspectInfo)

updater:SetScript("OnUpdate", function(self, elapsed)
	nextUpdate = nextUpdate - elapsed
	if nextUpdate > 0 then return end
	self:Hide()
	ClearInspectPlayer()

	if currentUNIT and UnitGUID(currentUNIT) == currentGUID then
		lastUpdate = GetTime()
		B:RegisterEvent("INSPECT_READY", getInspectInfo)
		NotifyInspect(currentUNIT)
	end
end)

GameTooltip:HookScript("OnTooltipSetUnit", function(self)
	local _, unit = self:GetUnit()
	if (not unit) or (not CanInspect(unit)) then return end

	currentUNIT, currentGUID = unit, UnitGUID(unit)
	ScanUnit(unit)
end)