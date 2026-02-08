local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:RegisterModule("AurasTable")

local pairs, next, format, wipe, unpack, tinsert = pairs, next, format, wipe, unpack, tinsert
local GetRealZoneText, GetSpellInfo = GetRealZoneText, GetSpellInfo

-- AuraWatch
local AuraWatchList = {}
local groups = {
	-- groups name = direction, interval, mode, iconsize, position, barwidth
	-- Direction "CENTER" for ICONS only, which sort by midpoint.
	["Player Aura"] = {"LEFT", 5, "ICON", 22, C.Auras.PlayerAuraPos},
	["Target Aura"] = {"RIGHT", 5, "ICON", 36, C.Auras.TargetAuraPos},
	["Special Aura"] = {"LEFT", 5, "ICON", 36, C.Auras.SpecialPos},
	["Focus Aura"] = {"RIGHT", 5, "ICON", 35, C.Auras.FocusPos},
	["Spell Cooldown"] = {"UP", 5, "BAR", 18, C.Auras.CDPos, 150},
	["Enchant Aura"] = {"LEFT", 5, "ICON", 36, C.Auras.EnchantPos},
	["Raid Buff"] = {"LEFT", 5, "ICON", 42, C.Auras.RaidBuffPos},
	["Raid Debuff"] = {"RIGHT", 5, "ICON", 42, C.Auras.RaidDebuffPos},
	["Warning"] = {"RIGHT", 5, "ICON", 42, C.Auras.WarningPos},
	["InternalCD"] = {"UP", 5, "BAR", 18, C.Auras.InternalPos, 150},
}

local function newAuraFormat(value)
	local newTable = {}
	for _, v in pairs(value) do
		local id = v.AuraID or v.SpellID or v.ItemID or v.SlotID or v.TotemID or v.IntID
		if id then
			newTable[id] = v
		end
	end
	return newTable
end

function module:AddNewAuraWatch(class, list)
	for _, k in pairs(list) do
		for _, v in pairs(k) do
			local spellID = v.AuraID or v.SpellID
			if spellID then
				local name = GetSpellInfo(spellID)
				if not name then
					wipe(v)
					if DB.isDeveloper then
						print(format("|cffFF0000Invalid spellID:|r '%s' %s", class, spellID))
					end
				end
			end
		end
	end

	if class ~= "ALL" and class ~= DB.MyClass then return end
	if not AuraWatchList[class] then AuraWatchList[class] = {} end

	for name, v in pairs(list) do
		local direction, interval, mode, size, pos, width = unpack(groups[name])
		tinsert(AuraWatchList[class], {
			Name = name,
			Direction = direction,
			Interval = interval,
			Mode = mode,
			IconSize = size,
			Pos = pos,
			BarWidth = width,
			List = newAuraFormat(v)
		})
	end
end

-- RaidFrame debuffs
local RaidDebuffs = {}
function module:AddRaidDebuffs(list)
	if not RaidDebuffs[0] then RaidDebuffs[0] = {} end

	for spellID, prio in pairs(list) do
		if prio > 6 then prio = 6 end
		RaidDebuffs[0][spellID] = prio
	end
end

function module:RegisterDebuff(tierID, instID, _, spellID, level)
	local instName = GetRealZoneText(instID)
	if not instName then
		if DB.isDeveloper then print("Invalid instance ID: "..instID) end
		return
	end

	if not RaidDebuffs[instID] then RaidDebuffs[instID] = {} end
	if not level then level = 2 end
	if level > 6 then level = 6 end

	RaidDebuffs[instID][spellID] = level
end

function module:CheckCornerSpells()
	if not NDuiADB["CornerSpells"][DB.MyClass] then NDuiADB["CornerSpells"][DB.MyClass] = {} end
	local data = C.CornerBuffs[DB.MyClass]
	if not data then return end

	for spellID in pairs(data) do
		local name = GetSpellInfo(spellID)
		if not name then
			if DB.isDeveloper then print("Invalid cornerspell ID: "..spellID) end
		end
	end

	for spellID, value in pairs(NDuiADB["CornerSpells"][DB.MyClass]) do
		if not next(value) and C.CornerBuffs[DB.MyClass][spellID] == nil then
			NDuiADB["CornerSpells"][DB.MyClass][spellID] = nil
		end
	end
end

function module:CheckMajorSpells()
	for spellID in pairs(C.MajorSpells) do
		local name = GetSpellInfo(spellID)
		if name then
			if NDuiADB["MajorSpells"][spellID] then
				NDuiADB["MajorSpells"][spellID] = nil
			end
		else
			if DB.isDeveloper then print("Invalid cornerspell ID: "..spellID) end
		end
	end

	for spellID, value in pairs(NDuiADB["MajorSpells"]) do
		if value == false and C.MajorSpells[spellID] == nil then
			NDuiADB["MajorSpells"][spellID] = nil
		end
	end
end

local function CheckNameplateFilter(list, key)
	for spellID in pairs(list) do
		local name = GetSpellInfo(spellID)
		if name then
			if NDuiADB[key][spellID] then
				NDuiADB[key][spellID] = nil
			end
		else
			if DB.isDeveloper then print("Invalid nameplate filter ID: "..spellID) end
		end
	end

	for spellID, value in pairs(NDuiADB[key]) do
		if value == false and list[spellID] == nil then
			NDuiADB[key][spellID] = nil
		end
	end
end

local function cleanupNameplateUnits(VALUE)
	for npcID in pairs(C[VALUE]) do
		if C.db["Nameplate"][VALUE][npcID] then
			C.db["Nameplate"][VALUE][npcID] = nil
		end
	end
	for npcID, value in pairs(C.db["Nameplate"][VALUE]) do
		if value == false and C[VALUE][npcID] == nil then
			C.db["Nameplate"][VALUE][npcID] = nil
		end
	end
end

function module:CheckNameplateFilters()
	CheckNameplateFilter(C.WhiteList, "NameplateWhite")
	CheckNameplateFilter(C.BlackList, "NameplateBlack")
	cleanupNameplateUnits("CustomUnits")
	cleanupNameplateUnits("PowerUnits")
end

function module:OnLogin()
	for instID, value in pairs(RaidDebuffs) do
		for spell, priority in pairs(value) do
			if NDuiADB["RaidDebuffs"][instID] and NDuiADB["RaidDebuffs"][instID][spell] and NDuiADB["RaidDebuffs"][instID][spell] == priority then
				NDuiADB["RaidDebuffs"][instID][spell] = nil
			end
		end
	end
	for instID, value in pairs(NDuiADB["RaidDebuffs"]) do
		if not next(value) then
			NDuiADB["RaidDebuffs"][instID] = nil
		end
	end

	C.AuraWatchList = AuraWatchList
	C.RaidDebuffs = RaidDebuffs

	module:CheckCornerSpells()
	module:CheckMajorSpells()
	module:CheckNameplateFilters()
end