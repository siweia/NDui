local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")
local TT = B:GetModule("Tooltip")

local pairs, select, next, type, unpack = pairs, select, next, type, unpack
local UnitGUID, GetItemInfo, GetSpellInfo = UnitGUID, GetItemInfo, GetSpellInfo
local GetContainerItemLink = C_Container.GetContainerItemLink
local GetInventoryItemLink = GetInventoryItemLink
local EquipmentManager_UnpackLocation, EquipmentManager_GetItemInfoByLocation = EquipmentManager_UnpackLocation, EquipmentManager_GetItemInfoByLocation
local C_AzeriteEmpoweredItem_IsPowerSelected = C_AzeriteEmpoweredItem.IsPowerSelected
local GetTradePlayerItemLink, GetTradeTargetItemLink = GetTradePlayerItemLink, GetTradeTargetItemLink

local inspectSlots = {
	"Head",
	"Neck",
	"Shoulder",
	"Shirt",
	"Chest",
	"Waist",
	"Legs",
	"Feet",
	"Wrist",
	"Hands",
	"Finger0",
	"Finger1",
	"Trinket0",
	"Trinket1",
	"Back",
	"MainHand",
	"SecondaryHand",
}

function M:GetSlotAnchor(index)
	if not index then return end

	if index <= 5 or index == 9 or index == 15 then
		return "BOTTOMLEFT", 40, 20
	elseif index == 16 then
		return "BOTTOMRIGHT", -40, 2
	elseif index == 17 then
		return "BOTTOMLEFT", 40, 2
	else
		return "BOTTOMRIGHT", -40, 20
	end
end

function M:CreateItemTexture(slot, relF, x, y)
	local icon = slot:CreateTexture()
	icon:SetPoint(relF, x, y)
	icon:SetSize(14, 14)
	icon:SetTexCoord(unpack(DB.TexCoord))
	icon.bg = B.ReskinIcon(icon)
	icon.bg:SetFrameLevel(3)
	icon.bg:Hide()

	return icon
end

function M:CreateItemString(frame, strType)
	if frame.fontCreated then return end

	for index, slot in pairs(inspectSlots) do
		if index ~= 4 then
			local slotFrame = _G[strType..slot.."Slot"]
			slotFrame.iLvlText = B.CreateFS(slotFrame, DB.Font[2]+1)
			slotFrame.iLvlText:ClearAllPoints()
			slotFrame.iLvlText:SetPoint("BOTTOMLEFT", slotFrame, 1, 1)
			local relF, x, y = M:GetSlotAnchor(index)
			slotFrame.enchantText = B.CreateFS(slotFrame, DB.Font[2]+1)
			slotFrame.enchantText:ClearAllPoints()
			slotFrame.enchantText:SetPoint(relF, slotFrame, x, y)
			slotFrame.enchantText:SetTextColor(0, 1, 0)
			for i = 1, 10 do
				local offset = (i-1)*18 + 5
				local iconX = x > 0 and x+offset or x-offset
				local iconY = index > 15 and 20 or 2
				slotFrame["textureIcon"..i] = M:CreateItemTexture(slotFrame, relF, iconX, iconY)
			end
		end
	end

	frame.fontCreated = true
end

local azeriteSlots = {
	[1] = true,
	[3] = true,
	[5] = true,
}

local locationCache = {}
local function GetSlotItemLocation(id)
	if not azeriteSlots[id] then return end

	local itemLocation = locationCache[id]
	if not itemLocation then
		itemLocation = ItemLocation:CreateFromEquipmentSlot(id)
		locationCache[id] = itemLocation
	end
	return itemLocation
end

function M:ItemLevel_UpdateTraits(button, id, link)
	if not C.db["Misc"]["AzeriteTraits"] then return end

	local empoweredItemLocation = GetSlotItemLocation(id)
	if not empoweredItemLocation then return end

	local allTierInfo = TT:Azerite_UpdateTier(link)
	if not allTierInfo then return end

	for i = 1, 2 do
		local powerIDs = allTierInfo[i] and allTierInfo[i].azeritePowerIDs
		if not powerIDs or powerIDs[1] == 13 then break end

		for _, powerID in pairs(powerIDs) do
			local selected = C_AzeriteEmpoweredItem_IsPowerSelected(empoweredItemLocation, powerID)
			if selected then
				local spellID = TT:Azerite_PowerToSpell(powerID)
				local name, _, icon = GetSpellInfo(spellID)
				local texture = button["textureIcon"..i]
				if name and texture then
					texture:SetTexture(icon)
					texture.bg:Show()
				end
			end
		end
	end
end

function M:ItemLevel_UpdateInfo(slotFrame, info, quality)
	local infoType = type(info)
	local level
	if infoType == "table" then
		level = info.iLvl
	else
		level = info
	end

	if level and level > 1 and quality and quality > 1 then
		local color = DB.QualityColors[quality]
		slotFrame.iLvlText:SetText(level)
		slotFrame.iLvlText:SetTextColor(color.r, color.g, color.b)
	end

	if infoType == "table" then
		local enchant = info.enchantText
		if enchant then
			slotFrame.enchantText:SetText(enchant)
		end

		local gemStep, essenceStep = 1, 1
		for i = 1, 10 do
			local texture = slotFrame["textureIcon"..i]
			local bg = texture.bg
			local gem = info.gems and info.gems[gemStep]
			local color = info.gemsColor and info.gemsColor[gemStep]
			local essence = not gem and (info.essences and info.essences[essenceStep])
			if gem then
				texture:SetTexture(gem)
				if color then
					bg:SetBackdropBorderColor(color.r, color.g, color.b)
				else
					bg:SetBackdropBorderColor(0, 0, 0)
				end
				bg:Show()

				gemStep = gemStep + 1
			elseif essence and next(essence) then
				local r = essence[4]
				local g = essence[5]
				local b = essence[6]
				if r and g and b then
					bg:SetBackdropBorderColor(r, g, b)
				else
					bg:SetBackdropBorderColor(0, 0, 0)
				end

				local selected = essence[1]
				texture:SetTexture(selected)
				bg:Show()

				essenceStep = essenceStep + 1
			end
		end
	end
end

function M:ItemLevel_RefreshInfo(link, unit, index, slotFrame)
	C_Timer.After(.1, function()
		local quality = select(3, GetItemInfo(link))
		local info = B.GetItemLevel(link, unit, index, C.db["Misc"]["GemNEnchant"])
		if info == "tooSoon" then return end
		M:ItemLevel_UpdateInfo(slotFrame, info, quality)
	end)
end

function M:ItemLevel_SetupLevel(frame, strType, unit)
	if not UnitExists(unit) then return end

	M:CreateItemString(frame, strType)

	for index, slot in pairs(inspectSlots) do
		if index ~= 4 then
			local slotFrame = _G[strType..slot.."Slot"]
			slotFrame.iLvlText:SetText("")
			slotFrame.enchantText:SetText("")
			for i = 1, 10 do
				local texture = slotFrame["textureIcon"..i]
				texture:SetTexture(nil)
				texture.bg:Hide()
			end

			local link = GetInventoryItemLink(unit, index)
			if link then
				local quality = select(3, GetItemInfo(link))
				local info = B.GetItemLevel(link, unit, index, C.db["Misc"]["GemNEnchant"])
				if info == "tooSoon" then
					M:ItemLevel_RefreshInfo(link, unit, index, slotFrame)
				else
					M:ItemLevel_UpdateInfo(slotFrame, info, quality)
				end

				if strType == "Character" then
					M:ItemLevel_UpdateTraits(slotFrame, index, link)
				end
			end
		end
	end
end

function M:ItemLevel_UpdatePlayer()
	M:ItemLevel_SetupLevel(CharacterFrame, "Character", "player")
end

function M:ItemLevel_UpdateInspect(...)
	local guid = ...
	if InspectFrame and InspectFrame.unit and UnitGUID(InspectFrame.unit) == guid then
		M:ItemLevel_SetupLevel(InspectFrame, "Inspect", InspectFrame.unit)
	end
end

function M:ItemLevel_FlyoutUpdate(bag, slot, quality)
	if not self.iLvl then
		self.iLvl = B.CreateFS(self, DB.Font[2]+1, "", false, "BOTTOMLEFT", 1, 1)
	end

	if quality and quality <= 1 then return end

	local link, level
	if bag then
		link = GetContainerItemLink(bag, slot)
		level = B.GetItemLevel(link, bag, slot)
	else
		link = GetInventoryItemLink("player", slot)
		level = B.GetItemLevel(link, "player", slot)
	end

	local color = DB.QualityColors[quality or 0]
	self.iLvl:SetText(level)
	self.iLvl:SetTextColor(color.r, color.g, color.b)
end

function M:ItemLevel_FlyoutSetup()
	if self.iLvl then self.iLvl:SetText("") end

	local location = self.location
	if not location then return end

	if tonumber(location) then
		if location >= EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION then return end

		local _, _, bags, voidStorage, slot, bag = EquipmentManager_UnpackLocation(location)
		if voidStorage then return end
		local quality = select(13, EquipmentManager_GetItemInfoByLocation(location))
		if bags then
			M.ItemLevel_FlyoutUpdate(self, bag, slot, quality)
		else
			M.ItemLevel_FlyoutUpdate(self, nil, slot, quality)
		end
	else
		local itemLocation = self:GetItemLocation()
		local quality = itemLocation and C_Item.GetItemQuality(itemLocation)
		if itemLocation:IsBagAndSlot() then
			local bag, slot = itemLocation:GetBagAndSlot()
			M.ItemLevel_FlyoutUpdate(self, bag, slot, quality)
		elseif itemLocation:IsEquipmentSlot() then
			local slot = itemLocation:GetEquipmentSlot()
			M.ItemLevel_FlyoutUpdate(self, nil, slot, quality)
		end
	end
end

function M:ItemLevel_ScrappingUpdate()
	if not self.iLvl then
		self.iLvl = B.CreateFS(self, DB.Font[2]+1, "", false, "BOTTOMLEFT", 1, 1)
	end
	if not self.itemLink then self.iLvl:SetText("") return end

	local quality = 1
	if self.itemLocation and not self.item:IsItemEmpty() and self.item:GetItemName() then
		quality = self.item:GetItemQuality()
	end
	local level = B.GetItemLevel(self.itemLink)
	local color = DB.QualityColors[quality]
	self.iLvl:SetText(level)
	self.iLvl:SetTextColor(color.r, color.g, color.b)
end

function M.ItemLevel_ScrappingShow(event, addon)
	if addon == "Blizzard_ScrappingMachineUI" then
		for button in pairs(ScrappingMachineFrame.ItemSlots.scrapButtons.activeObjects) do
			hooksecurefunc(button, "RefreshIcon", M.ItemLevel_ScrappingUpdate)
		end

		B:UnregisterEvent(event, M.ItemLevel_ScrappingShow)
	end
end

function M:ItemLevel_UpdateMerchant(link)
	if not self.iLvl then
		self.iLvl = B.CreateFS(_G[self:GetName().."ItemButton"], DB.Font[2]+1, "", false, "BOTTOMLEFT", 1, 1)
	end
	local quality = link and select(3, GetItemInfo(link)) or nil
	if quality and quality > 1 then
		local level = B.GetItemLevel(link)
		local color = DB.QualityColors[quality]
		self.iLvl:SetText(level)
		self.iLvl:SetTextColor(color.r, color.g, color.b)
	else
		self.iLvl:SetText("")
	end
end

function M.ItemLevel_UpdateTradePlayer(index)
	local button = _G["TradePlayerItem"..index]
	local link = GetTradePlayerItemLink(index)
	M.ItemLevel_UpdateMerchant(button, link)
end

function M.ItemLevel_UpdateTradeTarget(index)
	local button = _G["TradeRecipientItem"..index]
	local link = GetTradeTargetItemLink(index)
	M.ItemLevel_UpdateMerchant(button, link)
end

local itemCache = {}
local CHAT = B:GetModule("Chat")

function M.ItemLevel_ReplaceItemLink(link, name)
	if not link then return end

	local modLink = itemCache[link]
	if not modLink then
		local itemLevel = B.GetItemLevel(link)
		if itemLevel then
			modLink = gsub(link, "|h%[(.-)%]|h", "|h("..itemLevel..CHAT.IsItemHasGem(link)..")"..name.."|h")
			itemCache[link] = modLink
		end
	end
	return modLink
end

function M:ItemLevel_ReplaceGuildNews()
	local newText = gsub(self.text:GetText(), "(|Hitem:%d+:.-|h%[(.-)%]|h)", M.ItemLevel_ReplaceItemLink)
	if newText then
		self.text:SetText(newText)
	end
end

function M:ItemLevel_UpdateLoot()
	for i = 1, self.ScrollTarget:GetNumChildren() do
		local button = select(i, self.ScrollTarget:GetChildren())
		if button and button.Item and button.GetElementData then
			if not button.iLvl then
				button.iLvl = B.CreateFS(button.Item, DB.Font[2]+1, "", false, "BOTTOMLEFT", 1, 1)
			end
			local slotIndex = button:GetSlotIndex()
			local quality = select(5, GetLootSlotInfo(slotIndex))
			if quality and quality > 1 then
				local level = B.GetItemLevel(GetLootSlotLink(slotIndex))
				local color = DB.QualityColors[quality]
				button.iLvl:SetText(level)
				button.iLvl:SetTextColor(color.r, color.g, color.b)
			else
				button.iLvl:SetText("")
			end
		end
	end
end

function M:ItemLevel_UpdateBags()
	local button = self.__owner
	if not button.iLvl then
		button.iLvl = B.CreateFS(button, DB.Font[2]+1, "", false, "BOTTOMLEFT", 1, 1)
	end

	local bagID = button:GetBagID()
	local slotID = button:GetID()
	local info = C_Container.GetContainerItemInfo(bagID, slotID)
	local link = info and info.hyperlink
	local quality = info and info.quality
	if quality and quality > 1 then
		local level = B.GetItemLevel(link, bagID, slotID)
		local color = DB.QualityColors[quality]
		button.iLvl:SetText(level)
		button.iLvl:SetTextColor(color.r, color.g, color.b)
	else
		button.iLvl:SetText("")
	end
end

function M:ItemLevel_Containers()
	if C.db["Bags"]["Enable"] then return end

	for i = 1, 13 do
		for _, button in _G["ContainerFrame"..i]:EnumerateItems() do
			button.IconBorder.__owner = button
			hooksecurefunc(button.IconBorder, "SetShown", M.ItemLevel_UpdateBags)
		end
	end

	for i = 1, 28 do
		local button = _G["BankFrameItem"..i]
		button.IconBorder.__owner = button
		hooksecurefunc(button.IconBorder, "SetShown", M.ItemLevel_UpdateBags)
	end
end

function M:ShowItemLevel()
	if not C.db["Misc"]["ItemLevel"] then return end

	-- iLvl on CharacterFrame
	CharacterFrame:HookScript("OnShow", M.ItemLevel_UpdatePlayer)
	B:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", M.ItemLevel_UpdatePlayer)

	-- iLvl on InspectFrame
	B:RegisterEvent("INSPECT_READY", M.ItemLevel_UpdateInspect)

	-- iLvl on FlyoutButtons
	hooksecurefunc("EquipmentFlyout_UpdateItems", function()
		for _, button in pairs(EquipmentFlyoutFrame.buttons) do
			if button:IsShown() then
				M.ItemLevel_FlyoutSetup(button)
			end
		end
	end)

	-- iLvl on ScrappingMachineFrame
	B:RegisterEvent("ADDON_LOADED", M.ItemLevel_ScrappingShow)

	-- iLvl on MerchantFrame
	hooksecurefunc("MerchantFrameItem_UpdateQuality", M.ItemLevel_UpdateMerchant)

	-- iLvl on TradeFrame
	hooksecurefunc("TradeFrame_UpdatePlayerItem", M.ItemLevel_UpdateTradePlayer)
	hooksecurefunc("TradeFrame_UpdateTargetItem", M.ItemLevel_UpdateTradeTarget)

	-- iLvl on GuildNews
	hooksecurefunc("GuildNewsButton_SetText", M.ItemLevel_ReplaceGuildNews)

	-- iLvl on LootFrame
	hooksecurefunc(LootFrame.ScrollBox, "Update", M.ItemLevel_UpdateLoot)

	-- iLvl on default Container
	M:ItemLevel_Containers()
end
M:RegisterMisc("GearInfo", M.ShowItemLevel)
