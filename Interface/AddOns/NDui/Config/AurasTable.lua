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

function module:OnLogin()
	module:CheckCornerSpells()
	cleanupNameplateUnits("CustomUnits")
end