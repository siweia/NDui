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
]]
local _, ns = ...
local cargBags = ns.cargBags

local _G = _G
local BANK_SLOTS = {
	[Enum.BagIndex.CharacterBankTab_1 or 6 ] = true,
	[Enum.BagIndex.CharacterBankTab_2 or 7 ] = true,
	[Enum.BagIndex.CharacterBankTab_3 or 8 ] = true,
	[Enum.BagIndex.CharacterBankTab_4 or 9 ] = true,
	[Enum.BagIndex.CharacterBankTab_5 or 10 ] = true,
	[Enum.BagIndex.CharacterBankTab_6 or 11 ] = true,
	[Enum.BagIndex.AccountBankTab_1 or 12 ] = true,
	[Enum.BagIndex.AccountBankTab_2 or 13 ] = true,
	[Enum.BagIndex.AccountBankTab_3 or 14 ] = true,
	[Enum.BagIndex.AccountBankTab_4 or 15 ] = true,
	[Enum.BagIndex.AccountBankTab_5 or 16 ] = true,
}

--[[!
	@class ItemButton
		This class serves as the basis for all itemSlots in a container
]]
local ItemButton = cargBags:NewClass("ItemButton", nil, "ItemButton")

--[[!
	Gets a template name for the bagID
	@param bagID <number> [optional]
	@return tpl <string>
]]
function ItemButton:GetTemplate(bagID)
	bagID = bagID or self.bagId
	return (bagID and "ContainerFrameItemButtonTemplate") or "",
		(BANK_SLOTS[bagID] and BankFrame.BankPanel) or (bagID and _G["ContainerFrame"..(bagID + 1)]) or ""
end

local mt_gen_key = {__index = function(self,k) self[k] = {}; return self[k]; end}

--[[!
	Fetches a new instance of the ItemButton, creating one if necessary
	@param bagID <number>
	@param slotID <number>
	@return button <ItemButton>
]]
function ItemButton:New(bagID, slotID)
	self.recycled = self.recycled or setmetatable({}, mt_gen_key)

	local tpl, parent = self:GetTemplate(bagID)
	local button = table.remove(self.recycled[tpl]) or self:Create(tpl, parent)

	button.bagId = bagID
	button.slotId = slotID
	button:SetID(slotID)
	button:Show()
	button:HookScript("OnEnter", button.ButtonOnEnter)
	button:HookScript("OnLeave", button.ButtonOnLeave)

	return button
end

--[[!
	Creates a new ItemButton
	@param tpl <string> The template to use [optional]
	@return button <ItemButton>
	@callback button:OnCreate(tpl)
]]

local allButtons = {}
local function GetButton(slot, name, tpl)
	if not allButtons[slot] then
		allButtons[slot] = CreateFrame("ItemButton", name, nil, tpl..", BackdropTemplate")
	end
	return allButtons[slot]
end

function ItemButton:Create(tpl, parent)
	local impl = self.implementation
	impl.numSlots = (impl.numSlots or 0) + 1
	local name = ("%sSlot%d"):format(impl.name, impl.numSlots)

	local button = setmetatable(GetButton(impl.numSlots, name, tpl), self.__index)
	button:SetParent(parent or UIParent)

	if(button.Scaffold) then button:Scaffold(tpl) end
	if(button.OnCreate) then button:OnCreate(tpl) end

	local btnNT = _G[button:GetName().."NormalTexture"]
	local btnNIT = button.NewItemTexture
	local btnBIT = button.BattlepayItemTexture
	local btnICO = button.ItemContextOverlay
	if btnNT then btnNT:SetTexture("") end
	if btnNIT then btnNIT:SetTexture("") end
	if btnBIT then btnBIT:SetTexture("") end
	if btnICO then btnICO:SetTexture("") end

	button:RegisterForDrag("LeftButton") -- fix button drag in 9.0

	return button
end

--[[!
	Frees an ItemButton, storing it for later use
]]
function ItemButton:Free()
	self:Hide()
	table.insert(self.recycled[self:GetTemplate()], self)
end

--[[!
	Fetches the item-info of the button, just a small wrapper for comfort
	@param item <table> [optional]
	@return item <table>
]]
function ItemButton:GetInfo(item)
	return self.implementation:GetItemInfo(self.bagId, self.slotId, item)
end