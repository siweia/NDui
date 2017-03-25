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
	This file provides default sort-functions for your Containers.

DEPENDENCIES
	mixins/api-common.lua
]]

local addon, ns = ...
local sorts = ns.cargBags.classes.Container.sorts

--[[!
	Sorts the buttons depending on their bagSlot
]]
function sorts.bagSlot(a, b)
	if(a.bagID == b.bagID) then
		return a.slotID < b.slotID
	else
		return a.bagID < b.bagID
	end
end
