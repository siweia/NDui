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
	This file implements the filtering system for categories into cargBags.
	It is not compatible with other container sieves, especially not
	with the ones using Implementation:GetContainerForItem()
]]
local _, ns = ...
local cargBags = ns.cargBags
local Implementation = cargBags.classes.Implementation
local Container = cargBags.classes.Container

local FilterSet = cargBags:NewClass("FilterSet")

--[[!
	Returns a new FilterSet
	@return set <FilterSet>
]]
function FilterSet:New()
	return setmetatable({
		funcs = {},
		params = {},
		chained = {},
	}, self.__index)
end

--[[!
	Empties the filter table
]]
function FilterSet:Empty()
	for k in pairs(self.funcs) do self.funcs[k] = nil end
	for k in pairs(self.params) do self.params[k] = nil end
	for k in pairs(self.chained) do self.chained[k] = nil end
end

--[[!
	Sets a filter function and its flag
	@param filter <function>
	@param flag <bool> whether the filter is enabled (-1: inverted)
]]
function FilterSet:Set(filter, flag)
	self.funcs[filter] = flag
end

--[[!
	Sets a filter and its parameter
	@param filter <function>
	@param param <any>
	@param flag <bool> whether the filter is enabled (-1: inverted) [optional]
]]
function FilterSet:SetExtended(filter, param, flag)
	if(not flag and param) then
		flag = true
	end

	self:Set(filter, flag)
	self.params[filter] = param
end

--[[!
	Sets multiple filters
	@param flag <bool> whether the filters are enabled (-1: inverted)
	@param ... <function> a list of filters
]]
function FilterSet:SetMultiple(flag, ...)
	for i=1, select("#", ...) do
		local filter = select(i, ...)
		self:Set(filter, flag)
	end
end

--[[!
	chains / unchains an additional filter set
	@param set <FilterSet>
	@param flag <bool> enabled or not
]]
function FilterSet:Chain(set, flag)
	self.chained[set] = flag
end

--[[!
	Checks if an item passes this filter table
	@param item <ItemTable>
	@return passed <bool>
]]
function FilterSet:Check(item)
	local funcs, params = self.funcs, self.params

	-- check own filters
	for filter, flag in pairs(funcs) do
		local result = filter(item, params[filter])
		if((flag == true and not result) or (flag == -1 and result)) then
			return nil
		end
	end

	-- check filters of chained sets
	for table in pairs(self.chained) do
		if(not table:Check(item)) then
			return nil
		end
	end

	return true
end

--[[!
	Returns the right container for a specific item
	@param item <ItemTable>
	@return container <Container>
]]
function Implementation:GetContainerForItem(item)
	for i, container in ipairs(self.contByID) do
		if(not container.filters or container.filters:Check(item)) then
			return container
		end
	end
end

--[[
	Simple function shortcuts for Containers
]]
for name, func in pairs{
	["SetFilter"] = "Set",
	["SetExtendedFilter"] = "SetExtended",
	["SetMultipleFilters"] = "SetMultiple",
	["ChainFilters"] = "Chain",
	["CheckFilters"]= "Check",
} do
	Container[name] = function(self, ...)
		self.filters = self.filters or FilterSet:New()
		self.filters[func](self.filters, ...)
	end
end

--[[!
	Calls a function(button, result) with the result of the filters on all child-itembuttons
	@param func <function>
	@param filters <FilterTable> check against other filters [optional]
]]
function Container:FilterForFunction(func, filters)
	filters = filters or self.filters

	for i, button in pairs(self.buttons) do
		local result = filters:Check(button:GetItemInfo())
		func(button, result)
	end
end

