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
	This file provides some API and database for additions to cargBags.
	They are only used in the layout and more experienced user
	may replace the functions with their own in their implementation.
]]

local addon, ns = ...
local cargBags = ns.cargBags
local Implementation = cargBags.classes.Implementation
local Container = cargBags.classes.Container
local ItemButton = cargBags.classes.ItemButton

--[[################################
	Layouts
		Methods for positioning the buttons in a container
##################################]]

Container.layouts = {}

function Container:LayoutButtons(layout, ...)
	return self.layouts[layout](self, ...)
end


--[[################################
	Plugins
		Additional widgets for a bag
##################################]]

cargBags.plugins = {}

function Implementation:SpawnPlugin(name, ...)
	if(cargBags.plugins[name]) then
		local plugin = cargBags.plugins[name](self, ...)
		if(plugin) then
			plugin.parent = self
		end
		return plugin
	end
end
Container.SpawnPlugin = Implementation.SpawnPlugin

function cargBags:RegisterPlugin(name, func)
	cargBags.plugins[name] = func
end


--[[################################
	Sorts
		Sort-functions for your containers
##################################]]

Container.sorts = {}

function Container:SortButtons(arg1)
	table.sort(self.buttons, self.sorts[arg1] or arg1)
end

--[[################################
	Scaffolds
		Templates for ItemButtons
##################################]]

ItemButton.scaffolds = {}

function ItemButton:Scaffold(name, ...)
	return self.scaffolds[name](self, ...)
end

function cargBags:RegisterScaffold(name, func)
	ItemButton.scaffolds[name] = func
end
