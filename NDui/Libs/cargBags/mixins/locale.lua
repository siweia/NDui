 --[[
LICENSE
	cargBags: An inventory framework addon for World of Warcraft

	Copyright (C) 2010  Constantin "Cargor" Schomburg <xconstruct@gmail.com>

	cargBags is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	cargBags is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with cargBags; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

DESCRIPTION
	Provides translation-tables for the auction house categories

USAGE:
	local L = cargBags:GetLocalizedNames()
	OR local L = Implementation:GetLocalizedNames()

	L[englishName] returns localized name
]]
local _, ns = ...
local cargBags = ns.cargBags

local L

function cargBags:GetLocalizedTypes()
	if(L) then return L end

	L = {}

	L["Consumable"] = AUCTION_CATEGORY_CONSUMABLES -- 0
	L["Container"] = AUCTION_CATEGORY_CONTAINERS -- 1
	L["Weapon"] = AUCTION_CATEGORY_WEAPONS -- 2
	L["Gem"] = AUCTION_CATEGORY_GEMS -- 3
	L["Armor"] = AUCTION_CATEGORY_ARMOR -- 4
	L["Trade Goods"] = AUCTION_CATEGORY_TRADE_GOODS -- 7
	L["Item Enchantment"] = AUCTION_CATEGORY_ITEM_ENHANCEMENT -- 8
	L["Recipe"] = AUCTION_CATEGORY_RECIPES -- 9
	L["Quest"] = AUCTION_CATEGORY_QUEST_ITEMS -- 12
	L["Miscellaneous"] = AUCTION_CATEGORY_MISCELLANEOUS -- 15
	L["Glyph"] = AUCTION_CATEGORY_GLYPHS -- 16
	L["Battle Pets"] = AUCTION_CATEGORY_BATTLE_PETS -- 17
	L["WoWToken"] = TOKEN_FILTER_LABEL

	return L
end

cargBags.classes.Implementation.GetLocalizedNames = cargBags.GetLocalizedNames
