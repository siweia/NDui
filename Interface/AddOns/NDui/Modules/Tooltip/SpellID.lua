local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Tooltip")

function module:ExtraTipInfo()
	local types = {
		spell = SPELLS.."ID:",
		item = ITEMS.."ID:",
		quest = QUESTS_LABEL.."ID:",
		talent = TALENT.."ID:",
		achievement = ACHIEVEMENTS.."ID:",
		currency = CURRENCY.."ID:",
	}

	local function addLine(self, id, type, noadd)
		for i = 1, self:NumLines() do
			local line = _G[self:GetName().."TextLeft"..i]
			if not line then break end
			local text = line:GetText()
			if text and text == type then return end
		end
		if not noadd then self:AddLine(" ") end

		if type == types.item then
			local bagCount = GetItemCount(id)
			local bankCount = GetItemCount(id, true) - GetItemCount(id)
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
		self:AddDoubleLine(type, format(DB.InfoColor.."%s|r", id))
		self:Show()
	end

	-- All types, primarily for linked tooltips
	local function onSetHyperlink(self, link)
		local type, id = string.match(link, "^(%a+):(%d+)")
		if not type or not id then return end
		if type == "spell" or type == "enchant" or type == "trade" then
			addLine(self, id, types.spell)
		elseif type == "talent" then
			addLine(self, id, types.talent, true)
		elseif type == "quest" then
			addLine(self, id, types.quest)
		elseif type == "achievement" then
			addLine(self, id, types.achievement)
		elseif type == "item" then
			addLine(self, id, types.item)
		elseif type == "currency" then
			addLine(self, id, types.currency)
		end
	end
	hooksecurefunc(ItemRefTooltip, "SetHyperlink", onSetHyperlink)
	hooksecurefunc(GameTooltip, "SetHyperlink", onSetHyperlink)

	-- Spells
	hooksecurefunc(GameTooltip, "SetUnitAura", function(self, ...)
		local id = select(10, UnitAura(...))
		if id then addLine(self, id, types.spell) end
	end)
	GameTooltip:HookScript("OnTooltipSetSpell", function(self)
		local id = select(2, self:GetSpell())
		if id then addLine(self, id, types.spell) end
	end)
	hooksecurefunc("SetItemRef", function(link)
		local id = tonumber(link:match("spell:(%d+)"))
		if id then addLine(ItemRefTooltip, id, types.spell) end
	end)

	-- Items
	local function attachItemTooltip(self)
		local link = select(2, self:GetItem())
		if link then
			local id = link:match("item:(%d+):")
			if link:find("keystone") then id = 138019 end
			if id then addLine(self, id, types.item) end
		end
	end
	GameTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
	ItemRefTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
	ItemRefShoppingTooltip1:HookScript("OnTooltipSetItem", attachItemTooltip)
	ItemRefShoppingTooltip2:HookScript("OnTooltipSetItem", attachItemTooltip)
	ShoppingTooltip1:HookScript("OnTooltipSetItem", attachItemTooltip)
	ShoppingTooltip2:HookScript("OnTooltipSetItem", attachItemTooltip)
	hooksecurefunc(GameTooltip, "SetToyByItemID", function(self, id)
		if id then addLine(self, id, types.item) end
	end)
	hooksecurefunc(GameTooltip, "SetRecipeReagentItem", function(self, recipeID, reagentIndex)
		local link = C_TradeSkillUI.GetRecipeReagentItemLink(recipeID, reagentIndex)
		if link then
			local id = link:match("item:(%d+):")
			if id then addLine(self, id, types.item) end
		end
	end)

	-- Currencies
	hooksecurefunc(GameTooltip, "SetCurrencyToken", function(self, index)
		local id = tonumber(string.match(GetCurrencyListLink(index), "currency:(%d+)"))
		if id then addLine(self, id, types.currency) end
	end)
	hooksecurefunc(GameTooltip, "SetCurrencyByID", function(self, id)
		if id then addLine(self, id, types.currency) end
	end)
	hooksecurefunc(GameTooltip, "SetCurrencyTokenByID", function(self, id)
		if id then addLine(self, id, types.currency) end
	end)

	-- Castby
	local function SetCaster(self, unit, index, filter)
		local unitCaster = select(7, UnitAura(unit, index, filter))
		if unitCaster then
			local name = GetUnitName(unitCaster, true)
			local hexColor = B.HexRGB(B.UnitColor(unitCaster))
			self:AddDoubleLine(L["From"]..":", hexColor..name)
			self:Show()
		end
	end
	hooksecurefunc(GameTooltip, "SetUnitAura", SetCaster)
end