local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local pairs, unpack, tinsert, select = pairs, unpack, tinsert, select
local GetSpellCooldown, GetSpellInfo, GetItemCooldown, GetItemCount, GetItemInfo = GetSpellCooldown, GetSpellInfo, GetItemCooldown, GetItemCount, GetItemInfo
local IsPassiveSpell, IsCurrentSpell, IsPlayerSpell, UseItemByName = IsPassiveSpell, IsCurrentSpell, IsPlayerSpell, UseItemByName
local GetProfessions, GetProfessionInfo, GetSpellBookItemInfo = GetProfessions, GetProfessionInfo, GetSpellBookItemInfo
local PlayerHasToy, C_ToyBox_IsToyUsable, C_ToyBox_GetToyInfo = PlayerHasToy, C_ToyBox.IsToyUsable, C_ToyBox.GetToyInfo
local C_TradeSkillUI_GetRecipeInfo, C_TradeSkillUI_GetTradeSkillLine = C_TradeSkillUI.GetRecipeInfo, C_TradeSkillUI.GetTradeSkillLine
local C_TradeSkillUI_GetOnlyShowSkillUpRecipes, C_TradeSkillUI_SetOnlyShowSkillUpRecipes = C_TradeSkillUI.GetOnlyShowSkillUpRecipes, C_TradeSkillUI.SetOnlyShowSkillUpRecipes
local C_TradeSkillUI_GetOnlyShowMakeableRecipes, C_TradeSkillUI_SetOnlyShowMakeableRecipes = C_TradeSkillUI.GetOnlyShowMakeableRecipes, C_TradeSkillUI.SetOnlyShowMakeableRecipes

local BOOKTYPE_PROFESSION = BOOKTYPE_PROFESSION
local RUNEFORGING_ID = 53428
local PICK_LOCK = 1804
local CHEF_HAT = 134020
local THERMAL_ANVIL = 87216
local ENCHANTING_VELLUM = 38682
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
		M:TradeTabs_Create(RUNEFORGING_ID)
	elseif DB.MyClass == "ROGUE" and IsPlayerSpell(PICK_LOCK) then
		M:TradeTabs_Create(PICK_LOCK)
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
						M:TradeTabs_Create(spellID)
					else
						M:TradeTabs_Create(spellID)
					end
				end
			end
		end
	end

	if isCook and PlayerHasToy(CHEF_HAT) and C_ToyBox_IsToyUsable(CHEF_HAT) then
		M:TradeTabs_Create(nil, CHEF_HAT)
	end
	if GetItemCount(THERMAL_ANVIL) > 0 then
		M:TradeTabs_Create(nil, nil, THERMAL_ANVIL)
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
	if not C.db["Skins"]["BlizzardSkins"] then return end

	for _, tab in pairs(tabList) do
		tab:SetCheckedTexture(DB.textures.pushed)
		tab:GetRegions():Hide()
		B.CreateBDFrame(tab)
		local texture = tab:GetNormalTexture()
		if texture then texture:SetTexCoord(unpack(DB.TexCoord)) end
	end
end

local index = 1
function M:TradeTabs_Create(spellID, toyID, itemID)
	local name, _, texture
	if toyID then
		_, name, texture = C_ToyBox_GetToyInfo(toyID)
	elseif itemID then
		name, _, _, _, _, _, _, _, _, texture = GetItemInfo(itemID)
	else
		name, _, texture = GetSpellInfo(spellID)
	end

	local parent = DB.isNewPatch and ProfessionsFrame or TradeSkillFrame

	local tab = CreateFrame("CheckButton", nil, parent, "SpellBookSkillLineTabTemplate, SecureActionButtonTemplate")
	tab.tooltip = name
	tab.spellID = spellID
	tab.itemID = toyID or itemID
	tab.type = (toyID and "toy") or (itemID and "item") or "spell"
	if DB.isNewPatch then
		tab:RegisterForClicks("AnyDown")
	end
	if spellID == 818 then -- cooking fire
		tab:SetAttribute("type", "macro")
		tab:SetAttribute("macrotext", "/cast [@player]"..name)
	else
		tab:SetAttribute("type", tab.type)
		tab:SetAttribute(tab.type, spellID or name)
	end
	tab:SetNormalTexture(texture)
	tab:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	tab:Show()

	tab.CD = CreateFrame("Cooldown", nil, tab, "CooldownFrameTemplate")
	tab.CD:SetAllPoints()

	tab.cover = CreateFrame("Frame", nil, tab)
	tab.cover:SetAllPoints()
	tab.cover:EnableMouse(true)

	tab:SetPoint("TOPLEFT", parent, "TOPRIGHT", 3, -index*42)
	tinsert(tabList, tab)
	index = index + 1
end

function M:TradeTabs_FilterIcons()
	local buttonList = {
		[1] = {"Atlas:bags-greenarrow", TRADESKILL_FILTER_HAS_SKILL_UP, C_TradeSkillUI_GetOnlyShowSkillUpRecipes, C_TradeSkillUI_SetOnlyShowSkillUpRecipes},
		[2] = {"Interface\\RAIDFRAME\\ReadyCheck-Ready", CRAFT_IS_MAKEABLE, C_TradeSkillUI_GetOnlyShowMakeableRecipes, C_TradeSkillUI_SetOnlyShowMakeableRecipes},
	}

	local function filterClick(self)
		local value = self.__value
		if value[3]() then
			value[4](false)
			B.SetBorderColor(self.bg)
		else
			value[4](true)
			self.bg:SetBackdropBorderColor(1, .8, 0)
		end
	end

	local parent = DB.isNewPatch and ProfessionsFrame.CraftingPage or TradeSkillFrame

	local buttons = {}
	for index, value in pairs(buttonList) do
		local bu = CreateFrame("Button", nil, parent, "BackdropTemplate")
		bu:SetSize(22, 22)
		if DB.isNewPatch then
			bu:SetPoint("BOTTOMRIGHT", ProfessionsFrame.CraftingPage.RecipeList.FilterButton, "TOPRIGHT", -(index-1)*27, 10)
		else
			bu:SetPoint("RIGHT", TradeSkillFrame.FilterButton, "LEFT", -5 - (index-1)*27, 0)
		end
		B.PixelIcon(bu, value[1], true)
		B.AddTooltip(bu, "ANCHOR_TOP", value[2])
		bu.__value = value
		bu:SetScript("OnClick", filterClick)

		buttons[index] = bu
	end

	local function updateFilterStatus()
		for index, value in pairs(buttonList) do
			if value[3]() then
				buttons[index].bg:SetBackdropBorderColor(1, .8, 0)
			else
				B.SetBorderColor(buttons[index].bg)
			end
		end
	end
	B:RegisterEvent("TRADE_SKILL_LIST_UPDATE", updateFilterStatus)
end

function M:TradeTabs_OnLoad()
	M:UpdateProfessions()

	M:TradeTabs_Reskin()
	M:TradeTabs_Update()
	B:RegisterEvent("TRADE_SKILL_SHOW", M.TradeTabs_Update)
	B:RegisterEvent("TRADE_SKILL_CLOSE", M.TradeTabs_Update)
	B:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", M.TradeTabs_Update)

	M:TradeTabs_FilterIcons()
	M:TradeTabs_QuickEnchanting()
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

local isEnchanting
local tooltipString = "|cffffffff%s(%d)"
local function IsRecipeEnchanting(self)
	isEnchanting = nil

	local recipeID = self.selectedRecipeID
	local recipeInfo = recipeID and C_TradeSkillUI_GetRecipeInfo(recipeID)
	if recipeInfo and recipeInfo.alternateVerb then
		local parentSkillLineID = select(6, C_TradeSkillUI_GetTradeSkillLine())
		if parentSkillLineID == 333 then
			isEnchanting = true
			self.CreateButton.tooltip = format(tooltipString, L["UseVellum"], GetItemCount(ENCHANTING_VELLUM))
		end
	end
end

function M:TradeTabs_QuickEnchanting()
	if DB.isNewPatch then
		if ProfessionsFrame.CraftingPage.ValidateControls then
			hooksecurefunc(ProfessionsFrame.CraftingPage, "ValidateControls", function(self)
				isEnchanting = nil
				local currentRecipeInfo = self.SchematicForm:GetRecipeInfo()
				if currentRecipeInfo and currentRecipeInfo.alternateVerb then
					local professionInfo = ProfessionsFrame:GetProfessionInfo()
					if professionInfo and professionInfo.parentProfessionID == 333 then
						isEnchanting = true
						self.CreateButton.tooltipText = format(tooltipString, L["UseVellum"], GetItemCount(ENCHANTING_VELLUM))
					end
				end
			end)
		end
	
		local createButton = ProfessionsFrame.CraftingPage.CreateButton
		createButton:RegisterForClicks("AnyUp")
		createButton:HookScript("OnClick", function(_, btn)
			if btn == "RightButton" and isEnchanting then
				UseItemByName(ENCHANTING_VELLUM)
			end
		end)
	else
		if not TradeSkillFrame then return end
	
		local detailsFrame = TradeSkillFrame.DetailsFrame
		hooksecurefunc(detailsFrame, "RefreshDisplay", IsRecipeEnchanting)
	
		local createButton = detailsFrame.CreateButton
		createButton:RegisterForClicks("AnyUp")
		createButton:HookScript("OnClick", function(_, btn)
			if btn == "RightButton" and isEnchanting then
				UseItemByName(ENCHANTING_VELLUM)
			end
		end)
	end
end

function M:TradeTabs()
	if not C.db["Misc"]["TradeTabs"] then return end

	if DB.isNewPatch then
		if ProfessionsFrame then
			M:TradeTabs_OnLoad()
		end
	else
		B:RegisterEvent("ADDON_LOADED", M.TradeTabs_OnEvent)
	end
end
M:RegisterMisc("TradeTabs", M.TradeTabs)