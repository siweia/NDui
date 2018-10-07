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
	Provides multiple easy ways to specify a range of bags to use within different contexts

	:ParseBags(bags) accepts the following:
		- a bag string, e.g. "backpack+bags"
		- an indexed table of bagIDs, e.g. { 0, 1, 2, 3, 4 }
		- a string defining a range, e.g. "0-4"
		- a single number, e.g. 0
	and returns an indexed table of all bagIDs
]]
local _, ns = ...
local cargBags = ns.cargBags

local bagStrings = {
	["backpack"]		= { 0 },
	["bags"]			= { 1, 2, 3, 4 },
	["backpack+bags"]	= { 0, 1, 2, 3, 4, },
	["bankframe"]		= { -1 },
	["bankframe+bank"]	= { -1, 5, 6, 7, 8, 9, 10, 11 },
	["bankreagent"]		= { -3 },
	["bank"]			= { 5, 6, 7, 8, 9, 10, 11 },
	["keyring"]			= { -2 },
}
cargBags.BagStrings = bagStrings

--[[!
	Parses a range of bags and outputs a table of indexed bagIDs
	@param bags <BagType>
	@return bags <table>
]]
function cargBags:ParseBags(bags)
	if not bags then return end
	if(type(bags) == "table") then return bags end
	if(bagStrings[bags]) then return bagStrings[bags] end
	local min, max = bags:match("(%d+)-(%d+)")
	if(min) then
		local t = {}
		for i=min, max do
			t[#t+1] = i
		end
		bagStrings[bags] = t
		return t
	elseif(tonumber(bags)) then
		local t = {tonumber(bags)}
		bagStrings[bags] = t
		return t
	end
end