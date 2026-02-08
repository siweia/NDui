local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local pairs, unpack, tinsert = pairs, unpack, tinsert
local GetSpellCooldown, GetSpellInfo = GetSpellCooldown, GetSpellInfo
local InCombatLockdown, IsPlayerSpell, IsCurrentSpell = InCombatLockdown, IsPlayerSpell, IsCurrentSpell

local CAMPFIRE_ID = 818
local SMELTING_ID = 2656
local RUNEFORGING_ID = 53428

local tradeList = {
	["Alchemy"] = {
		[2259] = true,
		[3101] = true,
		[3464] = true,
		[11611] = true,
		[28596] = true,
		[51304] = true,
	},
	["Blacksmithing"] = {
		[2018] = true,
		[3100] = true,
		[3538] = true,
		[9785] = true,
		[29844] = true,
		[51300] = true,
	},
	["Cooking"] = {
		[2550] = true,
		[3102] = true,
		[3413] = true,
		[18260] = true,
		[33359] = true,
		[51296] = true,
	},
	["Enchanting"] = {
		[7411] = true,
		[7412] = true,
		[7413] = true,
		[13920] = true,
		[28029] = true,
		[51313] = true,
	},
	["Engineering"] = {
		[4036] = true,
		[4037] = true,
		[4038] = true,
		[12656] = true,
		[30350] = true,
		[51306] = true,
	},
	["FistAid"] = {
		[3273] = true,
		[3274] = true,
		[7924] = true,
		[10846] = true,
		[27028] = true,
		[45542] = true,
	},
	["Inscription"] = {
		[45357] = true,
		[45358] = true,
		[45359] = true,
		[45360] = true,
		[45361] = true,
		[45363] = true,
	},
	["Jewelcrafting"] = {
		[25229] = true,
		[25230] = true,
		[28894] = true,
		[28895] = true,
		[28897] = true,
		[51311] = true,
	},
	["Leatherworking"] = {
		[2108] = true,
		[3104] = true,
		[3811] = true,
		[10662] = true,
		[32549] = true,
		[51302] = true,
	},
	["Mining"] = {
		[2575] = true,
		[2576] = true,
		[3564] = true,
		[10248] = true,
		[29354] = true,
		[50310] = true,
	},
	["Poisons"] = {
		[2842] = true,
	},
	["Tailoring"] = {
		[3908] = true,
		[3909] = true,
		[3910] = true,
		[12180] = true,
		[26790] = true,
		[51309] = true,
	},
}

local myProfessions = {}
local tabList = {}

function M:UpdateProfessions()
	for tradeName, list in pairs(tradeList) do
		for spellID in pairs(list) do
			if IsPlayerSpell(spellID) then
				myProfessions[tradeName] = spellID
				break
			end
		end
	end
end

function M:TradeTabs_Update()
	for _, tab in pairs(tabList) do
		local spellID = tab.spellID
		if IsCurrentSpell(spellID) then
			tab:SetChecked(true)
			tab.cover:Show()
		else
			tab:SetChecked(false)
			tab.cover:Hide()
		end

		local start, duration = GetSpellCooldown(spellID)
		if start and duration and duration > 1.5 then
			tab.CD:SetCooldown(start, duration)
		end
	end
end

function M:TradeTabs_Reskin()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	for _, tab in pairs(tabList) do
		tab:SetCheckedTexture(DB.pushedTex)
		tab:GetRegions():Hide()
		B.CreateBDFrame(tab)
		local texture = tab:GetNormalTexture()
		if texture then texture:SetTexCoord(unpack(DB.TexCoord)) end
	end
end

local index = 1
function M:TradeTabs_Create(spellID, tradeName)
	local name, _, texture = GetSpellInfo(spellID)

	local tab = CreateFrame("CheckButton", nil, TradeSkillFrame, "SpellBookSkillLineTabTemplate, SecureActionButtonTemplate")
	tab.tooltip = name
	tab.spellID = spellID
	tab:SetAttribute("type", "spell")
	tab:SetAttribute("spell", name)
	tab:SetNormalTexture(texture)
	tab:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	tab:Show()

	tab.CD = CreateFrame("Cooldown", nil, tab, "CooldownFrameTemplate")
	tab.CD:SetAllPoints()

	local cover = CreateFrame("Frame", nil, tab)
	cover:SetAllPoints()
	if tradeName ~= "Enchanting" then cover:EnableMouse(true) end -- clickthru on enchant
	tab.cover = cover

	tab:SetPoint("TOPLEFT", TradeSkillFrame, "TOPRIGHT", C.db["Skins"]["BlizzardSkins"] and -30 or -33, -70 - (index-1)*45)
	tinsert(tabList, tab)
	index = index + 1

	return tab
end

function M:TradeTabs_OnLoad()
	M:UpdateProfessions()

	if DB.MyClass == "DEATHKNIGHT" then
		M:TradeTabs_Create(RUNEFORGING_ID)
	end

	local hasCooking

	for tradeName, spellID in pairs(myProfessions) do
		if tradeName == "Mining" then
			spellID = SMELTING_ID
		elseif tradeName == "Cooking" then
			hasCooking = true
		end

		self:TradeTabs_Create(spellID, tradeName)
	end

	if hasCooking then
		self:TradeTabs_Create(CAMPFIRE_ID)
	end

	M:TradeTabs_Reskin()
	M:TradeTabs_Update()
	B:RegisterEvent("TRADE_SKILL_SHOW", M.TradeTabs_Update)
	B:RegisterEvent("TRADE_SKILL_CLOSE", M.TradeTabs_Update)
	B:RegisterEvent("CRAFT_SHOW", M.TradeTabs_Update)
	B:RegisterEvent("CRAFT_CLOSE", M.TradeTabs_Update)
	B:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", M.TradeTabs_Update)
end

function M.TradeTabs_OnEvent(event, addon)
	if event == "ADDON_LOADED" and addon == "Blizzard_TradeSkillUI" then
		B:UnregisterEvent(event, M.TradeTabs_OnEvent)
		if InCombatLockdown() then
			B:RegisterEvent("PLAYER_REGEN_ENABLED", M.TradeTabs_OnEvent)
		else
			M:TradeTabs_OnLoad()
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		B:UnregisterEvent(event, M.TradeTabs_OnEvent)
		M:TradeTabs_OnLoad()
	end
end

function M:TradeTabs()
	if not C.db["Misc"]["TradeTabs"] then return end

	B:RegisterEvent("ADDON_LOADED", M.TradeTabs_OnEvent)
end
M:RegisterMisc("TradeTabs", M.TradeTabs)