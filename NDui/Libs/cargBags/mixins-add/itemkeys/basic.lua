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
	A few simple item keys, mostly ones resulting through pattern matching
]]

local _, ns = ...
local cargBags = ns.cargBags

-- Returns the numeric item id (12345)
cargBags.itemKeys["id"] = function(i)
	return i.link and tonumber(i.link:match("item:(%d+)"))
end

--	Returns the type of the parent bag
cargBags.itemKeys["bagType"] = function(i)
	return select(2, GetContainerNumFreeSlots(i.bagId))
end

-- Returns the item string (12345:0:0:0)
cargBags.itemKeys["string"] = function(i)
	return i.link and i.link:match("item:(%d+:%d+:%d+:%d+)")
end

cargBags.itemKeys["stats"] = function(i)
	if(not i.link or not GetItemStats) then return end
	local stats = GetItemStats(i.link)
	i.stats = stats
	return stats
end