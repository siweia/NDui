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

DESCRIPTION:
	Item keys which require tooltip parsing to work
]]
local _, ns = ...
local B, C, L, DB = unpack(ns)
local cargBags = ns.cargBags

local bindTypeToString = {
	[ITEM_BIND_ON_USE] = "equip",
	[ITEM_BIND_ON_EQUIP] = "equip",
	[ITEM_BIND_ON_PICKUP] = "pickup",
	[ITEM_SOULBOUND] = "soul",
	[ITEM_BIND_QUEST] = "quest",
	[ITEM_ACCOUNTBOUND] = "account",
	[ITEM_BIND_TO_ACCOUNT] = "account",
	[ITEM_BNETACCOUNTBOUND] = "account",
}

cargBags.itemKeys["bindOn"] = function(i)
	if not i.link then return end

	local tip = B.ScanTip
	if not tip then return end

	tip:SetOwner(UIParent, "ANCHOR_NONE")
	tip:SetBagItem(i.bagId, i.slotId)

	for j = 2, 5 do
		local line = _G["NDui_ScanTooltipTextLeft"..j]
		local lineText = line and line:GetText()
		if not lineText then break end

		local bindOn = bindTypeToString[lineText]
		if bindOn then
			i.bindOn = bindOn
			return bindOn
		end
	end
end