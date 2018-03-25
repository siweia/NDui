--------------------------------
-- FreebAutoRez, by Freebaser
-- NDui MOD
--------------------------------
local B, C, L, DB = unpack(select(2, ...))
local oUF = NDui.oUF or oUF

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
		local res1 = GetSpellInfo(126393)	--魁麟
		local res2 = GetSpellInfo(159931)	--鹤
		local res3 = GetSpellInfo(159956)	--蛾
		body = body.."/cast [@mouseover,help,dead]"..res1.."\n/cast [@mouseover,help,dead]"..res2.."\n/cast [@mouseover,help,dead]"..res3.."; "
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

local function setupAttribute(self)
	if InCombatLockdown() then return end

	if classList[DB.MyClass] and not IsAddOnLoaded("Clique") then
		self:SetAttribute("*type3", "macro")
		self:SetAttribute("macrotext3", macroBody(DB.MyClass))
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end
end

local Enable = function(self)
	if not NDuiDB["UFs"]["AutoRes"] then return end

	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED", setupAttribute)
	else
		setupAttribute(self)
	end
end

local Disable = function(self)
	if NDuiDB["UFs"]["AutoRes"] then return end

	self:SetAttribute("*type3", nil)
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end

oUF:AddElement("AutoResurrect", nil, Enable, Disable)