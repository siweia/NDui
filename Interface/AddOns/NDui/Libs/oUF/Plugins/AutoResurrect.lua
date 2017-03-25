--------------------------------
-- FreebAutoRez, by Freebaser
-- NDui MOD
--------------------------------
local B, C, L, DB = unpack(select(2, ...))
local _, ns = ...
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
	["HUNTER"] = {},
	["WARLOCK"] = {},
}

local body = ""
local function macroBody(class)
	body = "/stopmacro [@mouseover,nodead]\n"

	if class == "HUNTER" then
		local name1 = GetSpellInfo(126393)	--魁麟
		body = body.."/cast [@mouseover,help,dead] "..name1.."\n"
		local name2 = GetSpellInfo(159931)	--鹤
		body = body.."/cast [@mouseover,help,dead] "..name2.."; "
	elseif class == "WARLOCK" then
		local name = GetSpellInfo(20707)	--灵魂石
		body = body.."/cast [@mouseover,help,dead] "..name.."; "
	else
		local combatspell = classList[class].combat
		local oocspell = classList[class].ooc
		if combatspell then
			body = body.."/cast [combat,@mouseover,help,dead] "..combatspell.."; "

			if oocspell then
				body = body.."[@mouseover,help,dead] "..oocspell.."; "
			end
		elseif oocspell then
			body = body.."/cast [@mouseover,help,dead] "..oocspell.."; "
		end
	end

	return body
end

local Enable = function(self)
	local _, class = UnitClass("player")
	if not class or not NDuiDB["UFs"]["AutoRes"] then return end

	if classList[class] and not IsAddOnLoaded("Clique") then
		self:SetAttribute("*type3", "macro")
		self:SetAttribute("macrotext3", macroBody(class))
		return true
	end
end

local Disable = function(self)
	if NDuiDB["UFs"]["AutoRes"] then return end

	self:SetAttribute("*type3", nil)
end

oUF:AddElement("AutoResurrect", nil, Enable, Disable)