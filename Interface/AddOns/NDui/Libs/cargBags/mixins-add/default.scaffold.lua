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
	Provides a Scaffold that generates a default Blizz' ContainerButton

DEPENDENCIES
	mixins/api-common.lua
]]

local _, ns = ...
local cargBags = ns.cargBags

local function ItemButton_Scaffold(self)
	self:SetSize(37, 37)

	local name = self:GetName()
	if not self.Icon then
		self.Icon = _G[name.."IconTexture"]
	end
	if not self.Count then
		self.Count = _G[name.."Count"]
	end
	if not self.Cooldown then
		self.Cooldown = _G[name.."Cooldown"]
	end
	if not self.Quest then
		self.Quest = _G[name.."IconQuestTexture"]
	end
	if not self.Border then
		self.Border = _G[name.."NormalTexture"]
	end
end

--[[!
	Update the button with new item-information
	@param item <table> The itemTable holding information, see Implementation:GetItemInfo()
	@callback OnUpdate(item)
]]
local function ItemButton_Update(self, item)
	self.Icon:SetTexture(item.texture or self.bgTex)

	if(item.count and item.count > 1) then
		self.Count:SetText(item.count > 1e4 and "*" or item.count)
		self.Count:Show()
	else
		self.Count:Hide()
	end
	self.count = item.count -- Thank you Blizz for not using local variables >.> (BankFrame.lua @ 234 )

	self:ButtonUpdateCooldown(item)
	self:ButtonUpdateLock(item)
	self:ButtonUpdateQuest(item)

	if(self.OnUpdateButton) then self:OnUpdateButton(item) end
end

--[[!
	Updates the buttons cooldown with new item-information
	@param item <table> The itemTable holding information, see Implementation:GetItemInfo()
	@callback OnUpdateCooldown(item)
]]
local function ItemButton_UpdateCooldown(self, item)
	if(item.cdEnable == 1 and item.cdStart and item.cdStart > 0) then
		self.Cooldown:SetCooldown(item.cdStart, item.cdFinish)
		self.Cooldown:Show()
	else
		self.Cooldown:Hide()
	end

	if(self.OnUpdateCooldown) then self:OnUpdateCooldown(item) end
end

--[[!
	Updates the buttons lock with new item-information
	@param item <table> The itemTable holding information, see Implementation:GetItemInfo()
	@callback OnUpdateLock(item)
]]
local function ItemButton_UpdateLock(self, item)
	self.Icon:SetDesaturated(item.locked)

	if(self.OnUpdateLock) then self:OnUpdateLock(item) end
end

--[[!
	Updates the buttons quest texture with new item information
	@param item <table> The itemTable holding information, see Implementation:GetItemInfo()
	@callback OnUpdateQuest(item)
]]
local function ItemButton_UpdateQuest(self, item)
	if(self.OnUpdateQuest) then self:OnUpdateQuest(item) end
end

local function ItemButton_OnEnter(self)
	if(self.ItemOnEnter) then self:ItemOnEnter() end
end

local function ItemButton_OnLeave(self)
	if(self.ItemOnLeave) then self:ItemOnLeave() end
end

cargBags:RegisterScaffold("Default", function(self)
	self.glowTex = "Interface\\Buttons\\UI-ActionButton-Border" --! @property glowTex <string> The textures used for the glow
	self.glowAlpha = 0.8 --! @property glowAlpha <number> The alpha of the glow texture
	self.glowBlend = "ADD" --! @property glowBlend <string> The blendMode of the glow texture
	self.glowCoords = { 14/64, 50/64, 14/64, 50/64 } --! @property glowCoords <table> Indexed table of texCoords for the glow texture
	self.bgTex = nil --! @property bgTex <string> Texture used as a background if no item is in the slot

	self.CreateFrame = ItemButton_CreateFrame
	self.Scaffold = ItemButton_Scaffold

	self.ButtonUpdate = ItemButton_Update
	self.ButtonUpdateCooldown = ItemButton_UpdateCooldown
	self.ButtonUpdateLock = ItemButton_UpdateLock
	self.ButtonUpdateQuest = ItemButton_UpdateQuest

	self.ButtonOnEnter = ItemButton_OnEnter
	self.ButtonOnLeave = ItemButton_OnLeave
end)