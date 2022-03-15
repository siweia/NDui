local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:GetModule("Tooltip")

-- Credit: Cloudy Unit Info, by Cloudyfa
local select, max, strfind, format, strsplit = select, math.max, string.find, string.format, string.split
local GetTime, CanInspect, NotifyInspect, ClearInspectPlayer, IsShiftKeyDown = GetTime, CanInspect, NotifyInspect, ClearInspectPlayer, IsShiftKeyDown
local UnitGUID, UnitClass, UnitIsUnit, UnitIsPlayer, UnitIsVisible, UnitIsDeadOrGhost, UnitOnTaxi = UnitGUID, UnitClass, UnitIsUnit, UnitIsPlayer, UnitIsVisible, UnitIsDeadOrGhost, UnitOnTaxi
local GetInventoryItemTexture, GetInventoryItemLink, GetItemInfo, GetItemGem, GetAverageItemLevel = GetInventoryItemTexture, GetInventoryItemLink, GetItemInfo, GetItemGem, GetAverageItemLevel
local GetSpecialization, GetSpecializationInfo, GetInspectSpecialization, GetSpecializationInfoByID = GetSpecialization, GetSpecializationInfo, GetInspectSpecialization, GetSpecializationInfoByID
local HEIRLOOMS, LE_ITEM_QUALITY_ARTIFACT, LE_ITEM_QUALITY_HEIRLOOM = HEIRLOOMS, LE_ITEM_QUALITY_ARTIFACT, LE_ITEM_QUALITY_HEIRLOOM

local specPrefix = SPECIALIZATION..": "..DB.InfoColor
local levelPrefix = STAT_AVERAGE_ITEM_LEVEL..": "..DB.InfoColor
local isPending = LFG_LIST_LOADING
local resetTime, frequency = 900, .5
local cache, weapon, currentUNIT, currentGUID = {}, {}

local T29Sets = {
	-- HUNTER
	[188856] = true, [188858] = true, [188859] = true, [188860] = true, [188861] = true,
	-- WARRIOR
	[188937] = true, [188938] = true, [188940] = true, [188941] = true, [188942] = true,
	-- PALADIN
	[188928] = true, [188929] = true, [188931] = true, [188932] = true, [188933] = true,
	-- ROGUE
	[188901] = true, [188902] = true, [188903] = true, [188905] = true, [188907] = true,
	-- PRIEST
	[188875] = true, [188878] = true, [188879] = true, [188880] = true, [188881] = true,
	-- DK
	[188863] = true, [188864] = true, [188866] = true, [188867] = true, [188868] = true,
	-- SHAMAN
	[188920] = true, [188922] = true, [188923] = true, [188924] = true, [188925] = true,
	-- MAGE
	[188839] = true, [188842] = true, [188843] = true, [188844] = true, [188845] = true,
	-- WARLOCK
	[188884] = true, [188887] = true, [188888] = true, [188889] = true, [188890] = true,
	-- MONK
	[188910] = true, [188911] = true, [188912] = true, [188914] = true, [188916] = true,
	-- DRUID
	[188847] = true, [188848] = true, [188849] = true, [188851] = true, [188853] = true,
	-- DH
	[188892] = true, [188893] = true, [188894] = true, [188896] = true, [188898] = true,
}

function TT:InspectOnUpdate(elapsed)
	self.elapsed = (self.elapsed or frequency) + elapsed
	if self.elapsed > frequency then
		self.elapsed = 0
		self:Hide()
		ClearInspectPlayer()

		if currentUNIT and UnitGUID(currentUNIT) == currentGUID then
			B:RegisterEvent("INSPECT_READY", TT.GetInspectInfo)
			NotifyInspect(currentUNIT)
		end
	end
end

local updater = CreateFrame("Frame")
updater:SetScript("OnUpdate", TT.InspectOnUpdate)
updater:Hide()

local lastTime = 0
function TT:GetInspectInfo(...)
	if self == "UNIT_INVENTORY_CHANGED" then
		local thisTime = GetTime()
		if thisTime - lastTime > .1 then
			lastTime = thisTime

			local unit = ...
			if UnitGUID(unit) == currentGUID then
				TT:InspectUnit(unit, true)
			end
		end
	elseif self == "INSPECT_READY" then
		local guid = ...
		if guid == currentGUID then
			local spec = TT:GetUnitSpec(currentUNIT)
			local level = TT:GetUnitItemLevel(currentUNIT)
			cache[guid].spec = spec
			cache[guid].level = level
			cache[guid].getTime = GetTime()

			if spec and level then
				TT:SetupSpecLevel(spec, level)
			else
				TT:InspectUnit(currentUNIT, true)
			end
		end
		B:UnregisterEvent(self, TT.GetInspectInfo)
	end
end
B:RegisterEvent("UNIT_INVENTORY_CHANGED", TT.GetInspectInfo)

function TT:SetupSpecLevel(spec, level)
	local _, unit = GameTooltip:GetUnit()
	if not unit or UnitGUID(unit) ~= currentGUID then return end

	local specLine, levelLine
	for i = 2, GameTooltip:NumLines() do
		local line = _G["GameTooltipTextLeft"..i]
		local text = line:GetText()
		if text and strfind(text, specPrefix) then
			specLine = line
		elseif text and strfind(text, levelPrefix) then
			levelLine = line
		end
	end

	spec = specPrefix..(spec or isPending)
	if specLine then
		specLine:SetText(spec)
	else
		GameTooltip:AddLine(spec)
	end

	level = levelPrefix..(level or isPending)
	if levelLine then
		levelLine:SetText(level)
	else
		GameTooltip:AddLine(level)
	end
end

function TT:GetUnitItemLevel(unit)
	if not unit or UnitGUID(unit) ~= currentGUID then return end

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
					local _, _, quality, level, _, _, _, _, slot = GetItemInfo(itemLink)
					if (not quality) or (not level) then
						delay = true
					else
						if quality == LE_ITEM_QUALITY_HEIRLOOM then
							boa = boa + 1
						end

						local itemID = GetItemInfoFromHyperlink(itemLink)
						if T29Sets[itemID] then
							sets = sets + 1
						end

						if unit ~= "player" then
							level = B.GetItemLevel(itemLink) or level
							if i < 16 then
								total = total + level
							elseif i > 15 and quality == LE_ITEM_QUALITY_ARTIFACT then
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
								if quality == LE_ITEM_QUALITY_ARTIFACT then hasArtifact = true end

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
		if sets > 0 then ilvl = ilvl.." |cffffcc00("..sets.."/4)" end
	else
		ilvl = nil
	end

	return ilvl
end

function TT:GetUnitSpec(unit)
	if not unit or UnitGUID(unit) ~= currentGUID then return end

	local specName
	if unit == "player" then
		local specIndex = GetSpecialization()
		if specIndex then
			specName = select(2, GetSpecializationInfo(specIndex))
		end
	else
		local specID = GetInspectSpecialization(unit)
		if specID and specID > 0 then
			specName = select(2, GetSpecializationInfoByID(specID))
		end
	end

	return specName
end

function TT:InspectUnit(unit, forced)
	local spec, level

	if UnitIsUnit(unit, "player") then
		spec = self:GetUnitSpec("player")
		level = self:GetUnitItemLevel("player")
		self:SetupSpecLevel(spec, level)
	else
		if not unit or UnitGUID(unit) ~= currentGUID then return end
		if not UnitIsPlayer(unit) then return end

		local currentDB = cache[currentGUID]
		spec = currentDB.spec
		level = currentDB.level
		self:SetupSpecLevel(spec, level)

		if not C.db["Tooltip"]["SpecLevelByShift"] and IsShiftKeyDown() then forced = true end
		if spec and level and not forced and (GetTime() - currentDB.getTime < resetTime) then updater.elapsed = frequency return end
		if not UnitIsVisible(unit) or UnitIsDeadOrGhost("player") or UnitOnTaxi("player") then return end
		if InspectFrame and InspectFrame:IsShown() then return end

		self:SetupSpecLevel()
		updater:Show()
	end
end

function TT:InspectUnitSpecAndLevel(unit)
	if C.db["Tooltip"]["SpecLevelByShift"] and not IsShiftKeyDown() then return end

	if not unit or not CanInspect(unit) then return end
	currentUNIT, currentGUID = unit, UnitGUID(unit)
	if not cache[currentGUID] then cache[currentGUID] = {} end

	TT:InspectUnit(unit)
end