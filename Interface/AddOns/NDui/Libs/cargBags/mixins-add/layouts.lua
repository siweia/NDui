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
	This file holds a list of default layouts

DEPENDENCIES
	mixins/api-common.lua
]]
local addon, ns = ...
local layouts = ns.cargBags.classes.Container.layouts

function layouts.grid(self, columns, spacing, xOffset, yOffset)
	columns, spacing = columns or 8, spacing or 5
	xOffset, yOffset = xOffset or 0, yOffset or 0


	local width, height = 0, 0
	local col, row = 0, 0
	for i, button in ipairs(self.buttons) do

		if(i == 1) then -- Hackish, I know
			width, height = button:GetSize()
		end

		col = i % columns
		if(col == 0) then col = columns end
		row = math.ceil(i/columns)

		local xPos = (col-1) * (width + spacing)
		local yPos = -1 * (row-1) * (height + spacing)

		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", self, "TOPLEFT", xPos+xOffset, yPos+yOffset)
	end

	return columns * (width+spacing)-spacing, row * (height+spacing)-spacing
end

--[[!
	Places the buttons in a circle [experimental]
	@param radius <number> radius of the circle [optional]
	@param xOffset <number> x-offset of the whole layout [default: 0]
	@param yOffset <number> y-offset of the whole layout [default: 0]
]]
function layouts.circle(self, radius, xOffset, yOffset)
	radius = radius or (#self.buttons*50)/math.pi/2
	xOffset, yOffset = xOffset or 0, yOffset or 0

	local a = 360/#self.buttons

	for i, button in ipairs(self.buttons) do
		local x = radius*cos(a*i)
		local y = -radius*sin(a*i)

		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", self, "TOPLEFT", radius+x+xOffset, y-radius+yOffset)
	end
	return radius*2, radius*2
end
