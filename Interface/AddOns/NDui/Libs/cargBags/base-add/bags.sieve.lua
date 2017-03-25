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
	The bag sieve just places items in the right containers based on their bagID

DEPENDENCIES
	mixins\parseBags.lua (optional)
]]
local _, ns = ...
local cargBags = ns.cargBags

local Implementation = cargBags.classes.Implementation

--[[!
	Returns a container for a specific item [replaces virtual function]
	@param item <ItemTable>
	@returns container <Container>
]]
function Implementation:GetContainerForItem(item)
	return item.bagID and self.bagToContainer and self.bagToContainer[item.bagID]
end

local Container = cargBags.classes.Container

--[[!
	Sets the handled bags for a container
	@param bags <BagType>
]]
function Container:SetBags(bags)
	if(cargBags.ParseBags) then
		bags = cargBags:ParseBags(bags)
	end

	if(not bags) then return end

	self.implementation.bagToContainer = self.implementation.bagToContainer or {}
	local b2c = self.implementation.bagToContainer

	for i, bagID in pairs(bags) do
		b2c[bagID] = self
	end
end
