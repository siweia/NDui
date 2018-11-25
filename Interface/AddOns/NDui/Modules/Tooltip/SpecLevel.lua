local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Tooltip")

-- Credit: Cloudy Unit Info, by Cloudyfa
local cache, weapon, currentUNIT, currentGUID = {}, {}
local specPrefix = SPECIALIZATION..": "..DB.InfoColor
local levelPrefix = STAT_AVERAGE_ITEM_LEVEL..": "..DB.InfoColor
local isPending = LFG_LIST_LOADING
local resetTime, frequency = 900, .5
local tinsert, max = table.insert, math.max
local strfind, format, strsplit = string.find, string.format, string.split

local function updateInspect(self, elapsed)
	self.elapsed = (self.elapsed or frequency) + elapsed
	if self.elapsed > frequency then
		self.elapsed = 0
		self:Hide()
		ClearInspectPlayer()

		if currentUNIT and UnitGUID(currentUNIT) == currentGUID then
			B:RegisterEvent("INSPECT_READY", module.GetInspectInfo)
			NotifyInspect(currentUNIT)
		end
	end
end
local updater = CreateFrame("Frame")
updater:SetScript("OnUpdate", updateInspect)
updater:Hide()

local function inspectRequest(self)
	if NDuiDB["Tooltip"]["SpecLevelByShift"] and not IsShiftKeyDown() then return end

	local _, unit = self:GetUnit()
	if not unit or not CanInspect(unit) then return end

	currentUNIT, currentGUID = unit, UnitGUID(unit)
	if not cache[currentGUID] then cache[currentGUID] = {} end

	module:InspectUnit(unit)
end
GameTooltip:HookScript("OnTooltipSetUnit", inspectRequest)

local function resetUnit(_, btn)
	if btn == "LSHIFT" and UnitExists("mouseover") then
		GameTooltip:SetUnit("mouseover")
	end
end
B:RegisterEvent("MODIFIER_STATE_CHANGED", resetUnit)

function module:GetInspectInfo(...)
	if self == "UNIT_INVENTORY_CHANGED" then
		local unit = ...
		if UnitGUID(unit) == currentGUID then
			module:InspectUnit(unit, true)
		end
	elseif self == "INSPECT_READY" then
		local guid = ...
		if guid == currentGUID then
			local spec = module:GetUnitSpec(currentUNIT)
			local level = module:GetUnitItemLevel(currentUNIT)
			cache[guid].spec = spec
			cache[guid].level = level
			cache[guid].getTime = GetTime()

			if spec and level then
				module:SetupTooltip(spec, level)
			else
				module:InspectUnit(currentUNIT, true)
			end
		end
		B:UnregisterEvent(self, module.GetInspectInfo)
	end
end
B:RegisterEvent("UNIT_INVENTORY_CHANGED", module.GetInspectInfo)

function module:SetupTooltip(spec, level)
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

function module:GetUnitItemLevel(unit)
	if not unit or UnitGUID(unit) ~= currentGUID then return end

	local class = select(2, UnitClass(unit))
	local ilvl, boa, total, haveWeapon, twohand = 0, 0, 0, 0, 0
	local delay, mainhand, offhand, hasArtifact
	wipe(weapon)
	tinsert(weapon, 0)
	tinsert(weapon, 0)

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

		if ilvl > 0 then ilvl = format("%d", ilvl) end
		if boa > 0 then ilvl = ilvl.." |cff00ccff("..boa..HEIRLOOMS..")" end
	else
		ilvl = nil
	end

	return ilvl
end

function module:GetUnitSpec(unit)
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

function module:InspectUnit(unit, forced)
	local spec, level

	if UnitIsUnit(unit, "player") then
		spec = self:GetUnitSpec("player")
		level = self:GetUnitItemLevel("player")
		self:SetupTooltip(spec, level)
	else
		if not unit or UnitGUID(unit) ~= currentGUID then return end
		if not UnitIsPlayer(unit) then return end

		local currentDB = cache[currentGUID]
		spec = currentDB.spec
		level = currentDB.level
		self:SetupTooltip(spec, level)

		if not NDuiDB["Tooltip"]["SpecLevelByShift"] and IsShiftKeyDown() then forced = true end
		if spec and level and not forced and (GetTime() - currentDB.getTime < resetTime) then updater.elapsed = frequency return end
		if not UnitIsVisible(unit) or UnitIsDeadOrGhost("player") or UnitOnTaxi("player") then return end
		if InspectFrame and InspectFrame:IsShown() then return end

		self:SetupTooltip()
		updater:Show()
	end
end