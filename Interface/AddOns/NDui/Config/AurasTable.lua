local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:RegisterModule("AurasTable")

local pairs, next = pairs, next
local GetSpellName = C_Spell.GetSpellName

function module:CheckCornerSpells()
	if not NDuiADB["CornerSpells"][DB.MyClass] then NDuiADB["CornerSpells"][DB.MyClass] = {} end
	local data = C.CornerBuffs[DB.MyClass]
	if not data then return end

	for spellID in pairs(data) do
		local name = GetSpellName(spellID)
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
		local name = GetSpellName(spellID)
		if name then
			if NDuiADB["MajorSpells"][spellID] then
				NDuiADB["MajorSpells"][spellID] = nil
			end
		else
			if DB.isDeveloper then print("Invalid majorspells ID: "..spellID) end
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
		local name = GetSpellName(spellID)
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
--	CheckNameplateFilter(C.WhiteList, "NameplateWhite")
--	CheckNameplateFilter(C.BlackList, "NameplateBlack")
	cleanupNameplateUnits("CustomUnits")
end

function module:OnLogin()
	module:CheckCornerSpells()
	--module:CheckMajorSpells()
	module:CheckNameplateFilters()
end