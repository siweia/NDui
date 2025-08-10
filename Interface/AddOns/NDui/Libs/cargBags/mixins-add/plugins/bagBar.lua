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
	A collection of buttons for the bags.

	The buttons are not positioned automatically, use the standard-
	function :LayoutButtons() for this

DEPENDENCIES
	mixins/api-common
	mixins/parseBags (optional)
	base-add/filters.sieve.lua (optional)

CALLBACKS
	BagButton:OnCreate(bagID)
]]

local addon, ns = ...
local B, C, L, DB = unpack(ns)
local cargBags = ns.cargBags
local Implementation = cargBags.classes.Implementation

local ContainerIDToInventoryID = C_Container.ContainerIDToInventoryID
local maxBagSlots = 5

function Implementation:GetBagButtonClass()
	return self:GetClass("BagButton", true, "BagButton")
end

local BagButton = cargBags:NewClass("BagButton", nil, "ItemButton")

-- Default attributes
BagButton.bgTex = [[Interface\Paperdoll\UI-PaperDoll-Slot-Bag]]
BagButton.itemFadeAlpha = 0.1

local function UpdateTooltip(self, id)
	GameTooltip:SetOwner(self.bar, "ANCHOR_RIGHT")
	GameTooltip:SetInventoryItem("player", id)
	GameTooltip:Show()
end

local buttonNum = 0
function BagButton:Create(bagID)
	buttonNum = buttonNum+1
	local name = addon.."BagButton"..buttonNum
	local isBankBag = bagID > 5 and bagID < 13
	local button = setmetatable(CreateFrame("ItemButton", name, nil, "BackdropTemplate"), self.__index)

	local invID = (isBankBag and bagID - maxBagSlots) or ContainerIDToInventoryID(bagID)
	button.invID = invID
	button:SetID(invID)
	button.bagId = bagID
	button.isBankBag = isBankBag
	if isBankBag then
		button.isBag = 1
		button.GetInventorySlot = ButtonInventorySlot
	end

	button:RegisterForDrag("LeftButton", "RightButton")
	button:RegisterForClicks("AnyUp")
	button:SetSize(37, 37)
	button.Icon = _G[name.."IconTexture"]

	cargBags.SetScriptHandlers(button, "OnClick", "OnReceiveDrag", "OnEnter", "OnLeave", "OnDragStart")

	if(button.OnCreate) then button:OnCreate(bagID) end

	return button
end

function BagButton:UpdateButton()
	local icon = GetInventoryItemTexture("player", self.GetInventorySlot and self:GetInventorySlot() or self.invID)
	self.Icon:SetTexture(icon or self.bgTex)
	self.Icon:SetDesaturated(IsInventoryItemLocked(self.invID))

	if(self.bagId > maxBagSlots) then
		if(self.bagId - maxBagSlots <= GetNumBankSlots()) then
			self.Icon:SetVertexColor(1, 1, 1)
			self.notBought = nil
		else
			self.notBought = true
			self.Icon:SetVertexColor(1, 0, 0)
		end
	end

	if(self.OnUpdateButton) then self:OnUpdateButton() end
end

local function highlight(button, func, bagID)
	func(button, not bagID or button.bagId == bagID)
end

function BagButton:OnEnter()
	local hlFunction = self.bar.highlightFunction

	if(hlFunction) then
		if(self.bar.isGlobal) then
			for _, container in pairs(self.implementation.contByID) do
				container:ApplyToButtons(highlight, hlFunction, self.bagId)
			end
		else
			self.bar.container:ApplyToButtons(highlight, hlFunction, self.bagId)
		end
	end

	if self.isBankBag then
		UpdateTooltip(self, self:GetInventorySlot())
	else
		UpdateTooltip(self, self:GetID())
	end
end

function BagButton:OnLeave()
	local hlFunction = self.bar.highlightFunction

	if(hlFunction) then
		if(self.bar.isGlobal) then
			for _, container in pairs(self.implementation.contByID) do
				container:ApplyToButtons(highlight, hlFunction)
			end
		else
			self.bar.container:ApplyToButtons(highlight, hlFunction)
		end
	end

	GameTooltip:Hide()
end

function BagButton:OnClick(btn)
	if InCombatLockdown() then UIErrorsFrame:AddMessage("|cff99ccff"..ERR_NOT_IN_COMBAT) return end -- PutItemInBag is secure in combat

	if(self.notBought) then
		BankFrame.nextSlotCost = GetBankSlotCost(GetNumBankSlots())
		return StaticPopup_Show("CONFIRM_BUY_BANK_SLOT")
	end

	if(PutItemInBag((self.GetInventorySlot and self:GetInventorySlot()) or self.invID)) then return end

	if btn ~= "RightButton" then return end
	-- Somehow we need to disconnect this from the filter-sieve
	local container = self.bar.container
	if(container and container.SetFilter) then
		if(not self.filter) then
			local bagID = self.bagId
			self.filter = function(i) return i.bagId ~= bagID end
		end
		self.hidden = not self.hidden

		if(self.bar.isGlobal) then
			for _, container in pairs(container.implementation.contByID) do
				container:SetFilter(self.filter, self.hidden)
				container.implementation:OnEvent("BAG_UPDATE", self.bagId)
			end
		else
			container:SetFilter(self.filter, self.hidden)
			container.implementation:OnEvent("BAG_UPDATE", self.bagId)
		end
	end
end
BagButton.OnReceiveDrag = BagButton.OnClick

function BagButton:OnDragStart()
	PickupBagFromSlot((self.GetInventorySlot and self:GetInventorySlot()) or self.invID)
end

-- Updating the icons
local function updater(self)
	for _, button in pairs(self.buttons) do
		button:UpdateButton()
	end
end

local function onLock(self, _, bagID, slotID)
	if(bagID == -1 and slotID > NUM_BANKGENERIC_SLOTS) then
		bagID, slotID = ContainerIDToInventoryID(slotID - NUM_BANKGENERIC_SLOTS + maxBagSlots)
	end

	if(slotID) then return end

	for _, button in pairs(self.buttons) do
		if(button.invID == bagID) then
			return button:UpdateButton()
		end
	end
end

local disabled = {
	[-2] = true,
	[-1] = true,
	[0] = true,
}

-- Register the plugin
cargBags:RegisterPlugin("BagBar", function(self, bags)
	if(cargBags.ParseBags) then
		bags = cargBags:ParseBags(bags)
	end

	local bar = CreateFrame("Frame", nil, self)
	bar.container = self

	bar.layouts = cargBags.classes.Container.layouts
	bar.LayoutButtons = cargBags.classes.Container.LayoutButtons

	local buttonClass = self.implementation:GetBagButtonClass()
	bar.buttons = {}
	for i=1, #bags do
		if(not disabled[bags[i]]) then -- Temporary until I include fake buttons for backpack, bankframe and keyring
			local button = buttonClass:Create(bags[i])
			button:SetParent(bar)
			button.bar = bar
			table.insert(bar.buttons, button)
		end
	end

	self.implementation:RegisterEvent("BAG_UPDATE", bar, updater)
	self.implementation:RegisterEvent("ITEM_LOCK_CHANGED", bar, onLock)

	return bar
end)