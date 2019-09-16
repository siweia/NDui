local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local pairs, select, next = pairs, select, next
local UnitGUID, GetItemInfo = UnitGUID, GetItemInfo
local GetContainerItemLink, GetInventoryItemLink = GetContainerItemLink, GetInventoryItemLink
local EquipmentManager_UnpackLocation, EquipmentManager_GetItemInfoByLocation = EquipmentManager_UnpackLocation, EquipmentManager_GetItemInfoByLocation
local BAG_ITEM_QUALITY_COLORS = BAG_ITEM_QUALITY_COLORS

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
	local icon = slot:CreateTexture(nil, "ARTWORK")
	icon:SetPoint(relF, x, y)
	icon:SetSize(14, 14)
	icon:SetTexCoord(unpack(DB.TexCoord))
	icon.bg = B.CreateBG(icon)
	B.CreateBD(icon.bg)
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
			for i = 1, 5 do
				local offset = (i-1)*18 + 5
				local iconX = x > 0 and x+offset or x-offset
				local iconY = index > 15 and 20 or 2
				slotFrame["textureIcon"..i] = M:CreateItemTexture(slotFrame, relF, iconX, iconY)
			end
		end
	end

	frame.fontCreated = true
end

function M:ItemLevel_SetupLevel(frame, strType, unit)
	if not UnitExists(unit) then return end

	M:CreateItemString(frame, strType)

	for index, slot in pairs(inspectSlots) do
		if index ~= 4 then
			local slotFrame = _G[strType..slot.."Slot"]
			slotFrame.iLvlText:SetText("")
			slotFrame.enchantText:SetText("")
			for i = 1, 5 do
				local texture = slotFrame["textureIcon"..i]
				texture:SetTexture(nil)
				texture.bg:Hide()
			end

			local link = GetInventoryItemLink(unit, index)
			if link then
				local quality = select(3, GetItemInfo(link))
				local level, enchant, gems, essences = B.GetItemLevel(link, unit, index, NDuiDB["Misc"]["GemNEnchant"])

				if level and level > 1 and quality then
					local color = BAG_ITEM_QUALITY_COLORS[quality]
					slotFrame.iLvlText:SetText(level)
					slotFrame.iLvlText:SetTextColor(color.r, color.g, color.b)
				end

				if enchant then
					slotFrame.enchantText:SetText(enchant)
				end

				for i = 1, 5 do
					local texture = slotFrame["textureIcon"..i]
					if gems and next(gems) then
						local index, gem = next(gems)
						texture:SetTexture(gem)
						texture.bg:Show()

						gems[index] = nil
					elseif essences and next(essences) then
						local index, essence = next(essences)
						local selected = essence[1]
						texture:SetTexture(selected)
						texture.bg:Show()

						essences[index] = nil
					end
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

	local link, level
	if bag then
		link = GetContainerItemLink(bag, slot)
		level = B.GetItemLevel(link, bag, slot)
	else
		link = GetInventoryItemLink("player", slot)
		level = B.GetItemLevel(link, "player", slot)
	end

	local color = BAG_ITEM_QUALITY_COLORS[quality or 1]
	self.iLvl:SetText(level)
	self.iLvl:SetTextColor(color.r, color.g, color.b)
end

function M:ItemLevel_FlyoutSetup()
	local location = self.location
	if not location or location >= EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION then
		if self.iLvl then self.iLvl:SetText("") end
		return
	end

	local _, _, bags, voidStorage, slot, bag = EquipmentManager_UnpackLocation(location)
	if voidStorage then return end
	local quality = select(13, EquipmentManager_GetItemInfoByLocation(location))
	if bags then
		M.ItemLevel_FlyoutUpdate(self, bag, slot, quality)
	else
		M.ItemLevel_FlyoutUpdate(self, nil, slot, quality)
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
	local color = BAG_ITEM_QUALITY_COLORS[quality]
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

function M:ShowItemLevel()
	if not NDuiDB["Misc"]["ItemLevel"] then return end

	-- iLvl on CharacterFrame
	CharacterFrame:HookScript("OnShow", M.ItemLevel_UpdatePlayer)
	B:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", M.ItemLevel_UpdatePlayer)

	-- iLvl on InspectFrame
	B:RegisterEvent("INSPECT_READY", self.ItemLevel_UpdateInspect)

	-- iLvl on FlyoutButtons
	hooksecurefunc("EquipmentFlyout_DisplayButton", self.ItemLevel_FlyoutSetup)

	-- iLvl on ScrappingMachineFrame
	B:RegisterEvent("ADDON_LOADED", self.ItemLevel_ScrappingShow)
end