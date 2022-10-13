local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:GetModule("Tooltip")

local strmatch, format, tonumber, select = string.match, string.format, tonumber, select
local UnitAura, GetItemCount, GetItemInfo, GetUnitName = UnitAura, GetItemCount, GetItemInfo, GetUnitName
local GetItemInfoFromHyperlink, IsPlayerSpell = GetItemInfoFromHyperlink, IsPlayerSpell
local C_TradeSkillUI_GetRecipeReagentItemLink = DB.isNewPatch and C_TradeSkillUI.GetRecipeFixedReagentItemLink or C_TradeSkillUI.GetRecipeReagentItemLink
local C_CurrencyInfo_GetCurrencyListLink = C_CurrencyInfo.GetCurrencyListLink
local C_MountJournal_GetMountFromSpell = C_MountJournal.GetMountFromSpell
local BAGSLOT, BANK = BAGSLOT, BANK
local LEARNT_STRING = "|cffff0000"..ALREADY_LEARNED.."|r"

local types = {
	spell = SPELLS.."ID:",
	item = ITEMS.."ID:",
	quest = QUESTS_LABEL.."ID:",
	talent = TALENT.."ID:",
	achievement = ACHIEVEMENTS.."ID:",
	currency = CURRENCY.."ID:",
	azerite = L["Trait"].."ID:",
}

function TT:AddLineForID(id, linkType, noadd)
	for i = 1, self:NumLines() do
		local line = _G[self:GetName().."TextLeft"..i]
		if not line then break end
		local text = line:GetText()
		if text and text == linkType then return end
	end

	if self.__isHoverTip and linkType == types.spell and IsPlayerSpell(id) and C_MountJournal_GetMountFromSpell(id) then
		self:AddLine(LEARNT_STRING)
	end

	if not noadd then self:AddLine(" ") end

	if linkType == types.item then
		local bagCount = GetItemCount(id)
		local bankCount = GetItemCount(id, true) - bagCount
		local itemStackCount = select(8, GetItemInfo(id))
		if bankCount > 0 then
			self:AddDoubleLine(BAGSLOT.."/"..BANK..":", DB.InfoColor..bagCount.."/"..bankCount)
		elseif bagCount > 0 then
			self:AddDoubleLine(BAGSLOT..":", DB.InfoColor..bagCount)
		end
		if itemStackCount and itemStackCount > 1 then
			self:AddDoubleLine(L["Stack Cap"]..":", DB.InfoColor..itemStackCount)
		end
	end

	self:AddDoubleLine(linkType, format(DB.InfoColor.."%s|r", id))
	self:Show()
end

function TT:SetHyperLinkID(link)
	local linkType, id = strmatch(link, "^(%a+):(%d+)")
	if not linkType or not id then return end

	if linkType == "spell" or linkType == "enchant" or linkType == "trade" then
		TT.AddLineForID(self, id, types.spell)
	elseif linkType == "talent" then
		TT.AddLineForID(self, id, types.talent, true)
	elseif linkType == "quest" then
		TT.AddLineForID(self, id, types.quest)
	elseif linkType == "achievement" then
		TT.AddLineForID(self, id, types.achievement)
	elseif linkType == "item" then
		TT.AddLineForID(self, id, types.item)
	elseif linkType == "currency" then
		TT.AddLineForID(self, id, types.currency)
	end
end

function TT:SetItemID()
	local link = select(2, self:GetItem())
	if link then
		local id = GetItemInfoFromHyperlink(link)
		local keystone = strmatch(link, "|Hkeystone:([0-9]+):")
		if keystone then id = tonumber(keystone) end
		if id then TT.AddLineForID(self, id, types.item) end
	end
end

function TT:SetSpellID()
	local spellID = select(2, self:GetSpell())
	if spellID then
		if spellID then TT.AddLineForID(self, spellID, types.spell) end
	end
end

function TT:SetupTooltipID()
	if C.db["Tooltip"]["HideAllID"] then return end

	-- Update all
	hooksecurefunc(GameTooltip, "SetHyperlink", TT.SetHyperLinkID)
	hooksecurefunc(ItemRefTooltip, "SetHyperlink", TT.SetHyperLinkID)

	-- Spells
	hooksecurefunc(GameTooltip, "SetUnitAura", function(self, ...)
		local _, _, _, _, _, _, caster, _, _, id = UnitAura(...)
		if id then
			TT.AddLineForID(self, id, types.spell)
		end
		if caster then
			local name = GetUnitName(caster, true)
			local hexColor = B.HexRGB(B.UnitColor(caster))
			self:AddDoubleLine(L["From"]..":", hexColor..name)
			self:Show()
		end
	end)
	hooksecurefunc("SetItemRef", function(link)
		local id = tonumber(strmatch(link, "spell:(%d+)"))
		if id then TT.AddLineForID(ItemRefTooltip, id, types.spell) end
	end)
	if not DB.isNewPatch then
		GameTooltip:HookScript("OnTooltipSetSpell", function(self)
			local id = select(2, self:GetSpell())
			if id then TT.AddLineForID(self, id, types.spell) end
		end)
	end

	-- Items
	if not DB.isNewPatch then
		GameTooltip:HookScript("OnTooltipSetItem", TT.SetItemID)
		GameTooltipTooltip:HookScript("OnTooltipSetItem", TT.SetItemID)
		ItemRefTooltip:HookScript("OnTooltipSetItem", TT.SetItemID)
		ShoppingTooltip1:HookScript("OnTooltipSetItem", TT.SetItemID)
		ShoppingTooltip2:HookScript("OnTooltipSetItem", TT.SetItemID)
		ItemRefShoppingTooltip1:HookScript("OnTooltipSetItem", TT.SetItemID)
		ItemRefShoppingTooltip2:HookScript("OnTooltipSetItem", TT.SetItemID)
		hooksecurefunc(GameTooltip, "SetRecipeReagentItem", function(self, recipeID, reagentIndex)
			local link = C_TradeSkillUI_GetRecipeReagentItemLink(recipeID, reagentIndex)
			local id = link and strmatch(link, "item:(%d+):")
			if id then TT.AddLineForID(self, id, types.item) end
		end)
		hooksecurefunc(GameTooltip, "SetToyByItemID", function(self, id)
			if id then TT.AddLineForID(self, id, types.item) end
		end)
	end

	-- Currencies
	hooksecurefunc(GameTooltip, "SetCurrencyToken", function(self, index)
		local id = tonumber(strmatch(C_CurrencyInfo_GetCurrencyListLink(index), "currency:(%d+)"))
		if id then TT.AddLineForID(self, id, types.currency) end
	end)
	hooksecurefunc(GameTooltip, "SetCurrencyByID", function(self, id)
		if id then TT.AddLineForID(self, id, types.currency) end
	end)
	if not DB.isNewPatch then
		hooksecurefunc(GameTooltip, "SetCurrencyTokenByID", function(self, id)
			if id then TT.AddLineForID(self, id, types.currency) end
		end)
	end

	-- Azerite traits
	hooksecurefunc(GameTooltip, "SetAzeritePower", function(self, _, _, id)
		if id then TT.AddLineForID(self, id, types.azerite, true) end
	end)

	-- Quests
	hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(self)
		if self.questID then
			TT.AddLineForID(GameTooltip, self.questID, types.quest)
		end
	end)

	if not DB.isNewPatch then return end

	local isItems = {
		["GetBagItem"] = true,
		["GetInventoryItem"] = true,
		["GetMerchantItem"] = true,
		["GetBuybackItem"] = true,
		["GetItemByID"] = true,
		["GetRecipeResultItem"] = true,
		["GetRecipeReagentItem"] = true,
		["GetToyByItemID"] = true,
		["GetHeirloomByItemID"] = true,
		["GetHyperlink"] = true,
		["GetItemKey"] = true,
	}

	local isSpells = {
		["GetSpellByID"] = true,
		["GetSpellBookItem"] = true,
		["GetSpellByID"] = true,
		["GetTraitEntry"] = true,
		["GetMountBySpellID"] = true,
	}

	hooksecurefunc(GameTooltip, "ProcessLines", function(self)
		local getterName = self.info and self.info.getterName
		if isSpells[getterName] then
			TT.HookTooltipSetSpell(self)
			TT.SetSpellID(self)
		elseif isItems[getterName] then
			TT.HookTooltipSetItem(self)
			TT.SetItemID(self)
		else
			--print(getterName)
		end
	end)

	hooksecurefunc(GameTooltip, "SetAction", function(self, action)
		local actionType, actionID = GetActionInfo(action)
		if actionType == "spell" or actionType == "companion" then
			TT.HookTooltipSetSpell(self)
			TT.AddLineForID(self, actionID, types.spell)
		elseif actionType == "item" then
			TT.HookTooltipSetItem(self)
			TT.AddLineForID(self, actionID, types.item)
		end
	end)
end