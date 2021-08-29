--------------------------------
-- FreebAutoRez, by Freebaser
-- NDui MOD
--------------------------------
local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF

local classList = {
	["DEATHKNIGHT"] = {
		combat = GetSpellInfo(61999),	-- Raise Ally
	},
	["DRUID"] = {
		combat = GetSpellInfo(20484),	-- Rebirth
		ooc = GetSpellInfo(50769),		-- Revive
	},
	["MONK"] = {
		ooc = GetSpellInfo(115178),		-- Resuscitate
	},
	["PALADIN"] = {
		ooc = GetSpellInfo(7328),		-- Redemption
	},
	["PRIEST"] = {
		ooc = GetSpellInfo(2006),		-- Resurrection
	},
	["SHAMAN"] = {
		ooc = GetSpellInfo(2008),		-- Ancestral Spirit
	},
	["WARLOCK"] = {
		combat = GetSpellInfo(20707),	-- Soulstone
	},
	--["HUNTER"] = {},	-- blz has removed hunter res
}

local hunterRes = {
	[1] = GetSpellInfo(126393),			-- Eternal Guardian
	[2] = GetSpellInfo(159931),			-- Gift of Chiji
	[3] = GetSpellInfo(159956),			-- Dust of Life
}

local body = ""
local function macroBody(class)
	body = "/stopmacro [@mouseover,nodead]\n"

	if class == "HUNTER" then
		for i = 1, #hunterRes do
			body = body.."/cast [@mouseover,help,dead]"..hunterRes[i].."\n"
		end
	else
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
	end

	return body
end

local function setupAttribute(self)
	if InCombatLockdown() then return end

	if classList[DB.MyClass] and not IsAddOnLoaded("Clique") then
		self:SetAttribute("*type3", "macro")
		self:SetAttribute("macrotext3", macroBody(DB.MyClass))
		self:UnregisterEvent("PLAYER_REGEN_ENABLED", setupAttribute)
	end
end

local Enable = function(self)
	if not C.db["UFs"]["AutoRes"] then return end

	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED", setupAttribute, true)
	else
		setupAttribute(self)
	end
end

local Disable = function(self)
	if C.db["UFs"]["AutoRes"] then return end

	self:SetAttribute("*type3", nil)
	self:UnregisterEvent("PLAYER_REGEN_ENABLED", setupAttribute)
end

oUF:AddElement("AutoResurrect", nil, Enable, Disable)