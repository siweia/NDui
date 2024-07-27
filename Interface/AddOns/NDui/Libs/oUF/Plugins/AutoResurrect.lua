--------------------------------
-- FreebAutoRez, by Freebaser
-- NDui MOD
--------------------------------
local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF
local GetSpellName = C_Spell.GetSpellName

local classList = {
	["DEATHKNIGHT"] = {
		combat = GetSpellName(61999),	-- Raise Ally
	},
	["DRUID"] = {
		combat = GetSpellName(20484),	-- Rebirth
		ooc = GetSpellName(50769),		-- Revive
	},
	["MONK"] = {
		ooc = GetSpellName(115178),		-- Resuscitate
	},
	["PALADIN"] = {
		ooc = GetSpellName(7328),		-- Redemption
		combat = GetSpellName(391054),	-- 代祷Intercession
	},
	["PRIEST"] = {
		ooc = GetSpellName(2006),		-- Resurrection
	},
	["SHAMAN"] = {
		ooc = GetSpellName(2008),		-- Ancestral Spirit
	},
	["WARLOCK"] = {
		combat = GetSpellName(20707),	-- Soulstone
	},
	["EVOKER"] = {
		ooc = GetSpellName(361227),		-- 生还Return
	},
}

local body = ""
local function macroBody(class)
	body = "/stopmacro [@mouseover,nodead]\n"

	local combatSpell = classList[class].combat
	local oocSpell = classList[class].ooc
	if combatSpell then
		if oocSpell then
			body = body.."/cast [combat,@mouseover,help,dead] "..combatSpell.."; "
			body = body.."[@mouseover,help,dead] "..oocSpell
		else
			body = body.."/cast [@mouseover,help,dead] "..combatSpell
		end
	elseif oocSpell then
		body = body.."/cast [@mouseover,help,dead] "..oocSpell
	end

	return body
end

local function setupAttribute(self)
	if InCombatLockdown() then return end

	if classList[DB.MyClass] and not C_AddOns.IsAddOnLoaded("Clique") then
		self:SetAttribute("*type3", "macro")
		self:SetAttribute("macrotext3", macroBody(DB.MyClass))
		self:UnregisterEvent("PLAYER_REGEN_ENABLED", setupAttribute)
	end
end

local function Enable(self)
	if not C.db["UFs"]["AutoRes"] then return end

	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED", setupAttribute, true)
	else
		setupAttribute(self)
	end
end

local function Disable(self)
	if C.db["UFs"]["AutoRes"] then return end

	self:SetAttribute("*type3", nil)
	self:UnregisterEvent("PLAYER_REGEN_ENABLED", setupAttribute)
end

oUF:AddElement("AutoResurrect", nil, Enable, Disable)