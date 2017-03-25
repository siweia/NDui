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
	Provides a text-based filtering approach, e.g. for searchbars or GUIs
	Only one text filter per container can be active at any time!

DEPENDENCIES:
	base-add/filters.sieve.lua
]]

local addon, ns = ...
local cargBags = ns.cargBags
local Container = cargBags.classes.Container
local Implementation = cargBags.classes.Implementation

local defaultFilters = {
	n = function(i, arg) return i.name and i.name:lower():match(arg) end,
	t = function(i, arg) return (i.type and i.type:lower():match(arg)) or (i.subType and i.subType:lower():match(arg)) or (i.equipLoc and i.equipLoc:lower():match(arg)) end,
	b = function(i, arg) return i.bindOn and i.bindOn:match(arg) end,
	q = function(i, arg) return i.rarity == tonumber(arg) end,
	bag = function(i, arg) return i.bagID == tonumber(arg) end,
	quest = function(i, arg) return i.isQuestItem end,

	_default = "n",
}

--[[
	Parses a text for filters and stores them in a filterTable
	@param text <string> the text filter
	@param filters <FilterSet> table to store resulting filters in [optional]
	@param textFilters <table> table of text filters to parse from [optional]

	@note Basically works like this: text ----textFilters----> filters,filterInfo	
]]
function Implementation:ParseTextFilter(text, filters, textFilters)
	filters = filters or cargBags.classes.FilterSet:New()
	textFilters = textFilters or defaultFilters

	for match in text:gmatch("[^,;&]+") do
		local mod, type, value = match:trim():match("^(!?)(.-)[:=]?([^:=]*)$")
		mod = (mod == "!" and -1) or true
		if(value and type ~= "" and textFilters[type]) then
			filters:SetExtended(textFilters[type], value:lower(), mod)
		elseif(value and type == "" and textFilters._default) then
			local name = textFilters._default
			filters:SetExtended(textFilters[name], value:lower(), mod)
		end
	end

	return filters
end

Container.ParseTextFilter = Implementation.ParseTextFilter

--[[!
	Applies a text filter to the container, for convenience
	@param text <string> the text filter
	@param textFilters <table> a table of textFilters to parse from [optional]
]]
function Container:SetTextFilter(text, textFilters)
	self.filters = self:ParseTextFilter(text, self.filters, textFilters)
end

cargBags.textFilters = defaultFilters
