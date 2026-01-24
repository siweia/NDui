local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:GetModule("Tooltip")

local strmatch, format, tonumber, select = string.match, string.format, tonumber, select
local GetUnitName = GetUnitName
local IsPlayerSpell = IsPlayerSpell
local C_TradeSkillUI_GetRecipeReagentItemLink = C_TradeSkillUI.GetRecipeFixedReagentItemLink
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
	if self:IsForbidden() then return end

	for i = 1, self:NumLines() do
		local line = _G[self:GetName().."TextLeft"..i]
		if not line then break end
		local text = line:GetText()
		if text and B:NotSecretValue(text) and text == linkType then return end
	end

	if self.__isHoverTip and linkType == types.spell and IsPlayerSpell(id) and C_MountJournal_GetMountFromSpell(id) then
		self:AddLine(LEARNT_STRING)
	end

	if not noadd then self:AddLine(" ") end

	if linkType == types.item then
		local bagCount = C_Item.GetItemCount(id)
		-- bank, ?, reagentbank, accountbank
		local bankCount = C_Item.GetItemCount(id, true, nil, true, true) - bagCount
		local itemStackCount = select(8, C_Item.GetItemInfo(id))
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
	if self:IsForbidden() then return end
	if not link then return end

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

function TT:SetupTooltipID()
	if C.db["Tooltip"]["HideAllID"] then return end

	-- Update all
	hooksecurefunc(GameTooltip, "SetHyperlink", TT.SetHyperLinkID)
	hooksecurefunc(ItemRefTooltip, "SetHyperlink", TT.SetHyperLinkID)

	-- Spells
	hooksecurefunc(GameTooltip, "SetUnitAura", function(self, ...)
		if self:IsForbidden() then return end
		local data = C_UnitAuras.GetAuraDataByIndex(...)
		if not data then return end

		local id, caster = data.spellId, data.sourceUnit
		if id then
			TT.AddLineForID(self, id, types.spell)
		end
		if caster and B:NotSecretValue(caster) then
			local name = GetUnitName(caster, true)
			local hexColor = B.HexRGB(B.UnitColor(caster))
			self:AddDoubleLine(L["From"]..":", hexColor..name)
			self:Show()
		end
	end)

	local function UpdateAuraTip(self, unit, auraInstanceID)
		local data = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID)
		if not data then return end

		local id, caster = data.spellId, data.sourceUnit
		if id then
			TT.AddLineForID(self, id, types.spell)
		end
		if caster and B:NotSecretValue(caster) then
			local name = GetUnitName(caster, true)
			local hexColor = B.HexRGB(B.UnitColor(caster))
			self:AddDoubleLine(L["From"]..":", hexColor..name)
			self:Show()
		end
	end
	hooksecurefunc(GameTooltip, "SetUnitBuffByAuraInstanceID", UpdateAuraTip)
	hooksecurefunc(GameTooltip, "SetUnitDebuffByAuraInstanceID", UpdateAuraTip)
	hooksecurefunc(GameTooltip, "SetUnitAuraByAuraInstanceID", UpdateAuraTip)

	hooksecurefunc("SetItemRef", function(link)
		local id = tonumber(strmatch(link, "spell:(%d+)"))
		if id then TT.AddLineForID(ItemRefTooltip, id, types.spell) end
	end)

	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, function(self, data)
		if self:IsForbidden() then return end
		if data.id then
			TT.AddLineForID(self, data.id, types.spell)
		end
	end)

	local function UpdateActionTooltip(self, data)
		if self:IsForbidden() then return end

		local lineData = data.lines and data.lines[1]
		local tooltipType = lineData and lineData.tooltipType
		if not tooltipType then return end

		if tooltipType == 0 then --item
			TT.AddLineForID(self, lineData.tooltipID, types.item)
		elseif tooltipType == 1 then --spell
			TT.AddLineForID(self, lineData.tooltipID, types.spell)
		end
	end
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Macro, UpdateActionTooltip)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.PetAction, UpdateActionTooltip)

	-- Items
	local function addItemID(self, data)
		if self:IsForbidden() then return end
		if data.id then
			TT.AddLineForID(self, data.id, types.item)
		end
	end
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, addItemID)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Toy, addItemID)

	-- Currencies
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Currency, function(self, data)
		if self:IsForbidden() then return end
		if data.id then
			TT.AddLineForID(self, data.id, types.currency)
		end
	end)

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
end