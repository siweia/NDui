local _, ns = ...
local B, C, L, DB, F = unpack(ns)
local M = B:GetModule("Misc")

local pairs, unpack, tinsert, select = pairs, unpack, tinsert, select
local GetSpellCooldown, GetSpellInfo, GetItemCooldown = GetSpellCooldown, GetSpellInfo, GetItemCooldown
local IsPassiveSpell, IsCurrentSpell, CastSpell = IsPassiveSpell, IsCurrentSpell, CastSpell
local GetProfessions, GetProfessionInfo, GetSpellBookItemInfo = GetProfessions, GetProfessionInfo, GetSpellBookItemInfo
local PlayerHasToy, C_ToyBox_IsToyUsable, C_ToyBox_GetToyInfo = PlayerHasToy, C_ToyBox.IsToyUsable, C_ToyBox.GetToyInfo

local BOOKTYPE_PROFESSION = BOOKTYPE_PROFESSION
local RUNEFORGING_ID = 53428
local CHEF_HAT = 134020
local tabList = {}

local onlyPrimary = {
	[171] = true, -- Alchemy
	[202] = true, -- Engineering
	[182] = true, -- Herbalism
	[393] = true, -- Skinning
	[356] = true, -- Fishing
}

function M:UpdateProfessions()
	local prof1, prof2, _, fish, cook = GetProfessions()
	local profs = {prof1, prof2, fish, cook}

	if DB.MyClass == "DEATHKNIGHT" then
		M:TradeTabs_Create(nil, RUNEFORGING_ID)
	end

	local isCook
	for _, prof in pairs(profs) do
		local _, _, _, _, numSpells, spelloffset, skillLine = GetProfessionInfo(prof)
		if skillLine == 185 then isCook = true end

		numSpells = onlyPrimary[skillLine] and 1 or numSpells
		if numSpells > 0 then
			for i = 1, numSpells do
				local slotID = i + spelloffset
				if not IsPassiveSpell(slotID, BOOKTYPE_PROFESSION) then
					local spellID = select(2, GetSpellBookItemInfo(slotID, BOOKTYPE_PROFESSION))
					if i == 1 then
						M:TradeTabs_Create(slotID, spellID)
					else
						M:TradeTabs_Create(nil, spellID)
					end
				end
			end
		end
	end

	if isCook and PlayerHasToy(CHEF_HAT) and C_ToyBox_IsToyUsable(CHEF_HAT) then
		M:TradeTabs_Create(nil, nil, CHEF_HAT)
	end
end

function M:TradeTabs_Update()
	for _, tab in pairs(tabList) do
		local spellID = tab.spellID
		local itemID = tab.itemID

		if IsCurrentSpell(spellID) then
			tab:SetChecked(true)
			tab.cover:Show()
		else
			tab:SetChecked(false)
			tab.cover:Hide()
		end

		local start, duration
		if itemID then
			start, duration = GetItemCooldown(itemID)
		else
			start, duration = GetSpellCooldown(spellID)
		end
		if start and duration and duration > 1.5 then
			tab.CD:SetCooldown(start, duration)
		end
	end
end

function M:TradeTabs_Reskin()
	if not F then return end

	for _, tab in pairs(tabList) do
		tab:SetCheckedTexture(DB.textures.pushed)
		tab:GetRegions():Hide()
		F.CreateBG(tab)
		tab:GetNormalTexture():SetTexCoord(unpack(DB.TexCoord))
	end
end

function M:TradeTabs_OnClick()
	CastSpell(self.slotID, BOOKTYPE_PROFESSION)
end

local index = 1
function M:TradeTabs_Create(slotID, spellID, itemID)
	local name, _, texture
	if itemID then
		_, name, texture = C_ToyBox_GetToyInfo(itemID)
	else
		name, _, texture = GetSpellInfo(spellID)
	end

	local tab = CreateFrame("CheckButton", nil, TradeSkillFrame, "SpellBookSkillLineTabTemplate, SecureActionButtonTemplate")
	tab.tooltip = name
	tab.slotID = slotID
	tab.spellID = spellID
	tab.itemID = itemID
	tab.type = itemID and "toy" or "spell"
	if slotID then
		tab:SetScript("OnClick", M.TradeTabs_OnClick)
	else
		tab:SetAttribute("type", tab.type)
		tab:SetAttribute(tab.type, name)
	end
	tab:SetNormalTexture(texture)
	tab:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	tab:Show()

	tab.CD = CreateFrame("Cooldown", nil, tab, "CooldownFrameTemplate")
	tab.CD:SetAllPoints()

	tab.cover = CreateFrame("Frame", nil, tab)
	tab.cover:SetAllPoints()
	tab.cover:EnableMouse(true)

	tab:SetPoint("TOPLEFT", TradeSkillFrame, "TOPRIGHT", 3, -index*42)
	tinsert(tabList, tab)
	index = index + 1
end

function M:TradeTabs_OnLoad()
	M:UpdateProfessions()

	M:TradeTabs_Reskin()
	M:TradeTabs_Update()
	B:RegisterEvent("TRADE_SKILL_SHOW", M.TradeTabs_Update)
	B:RegisterEvent("TRADE_SKILL_CLOSE", M.TradeTabs_Update)
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
	if not NDuiDB["Misc"]["TradeTabs"] then return end

	B:RegisterEvent("ADDON_LOADED", M.TradeTabs_OnEvent)
end