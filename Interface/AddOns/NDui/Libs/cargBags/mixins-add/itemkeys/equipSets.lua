--[[
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
	Item keys for the Blizz equipment sets

DEPENDENCIES
	mixins-add/itemkeys/basic.lua
]]
local _, ns = ...
local cargBags = ns.cargBags

local ItemKeys = cargBags.itemKeys

local setItems

local function initUpdater()
	local function updateSets()
		setItems = setItems or {}
		wipe(setItems)

		for setID = 0, C_EquipmentSet.GetNumEquipmentSets() do
			local locations = C_EquipmentSet.GetItemLocations(setID)
			if locations then
				for _, location in pairs(locations) do
					local _, _, bags, _, slot, bag = EquipmentManager_UnpackLocation(location)
					if bags then
						setItems[bag..":"..slot] = true
					end
				end
			end
		end
	end

	local updater = CreateFrame("Frame")
	updater:RegisterEvent("BAG_UPDATE")
	updater:RegisterEvent("EQUIPMENT_SETS_CHANGED")
	updater:SetScript("OnEvent", function()
		updateSets()
	end)

	updateSets()
end

ItemKeys["isItemSet"] = function(item)
	if not setItems then initUpdater() end
	return setItems[item.bagId..":"..item.slotId]
end