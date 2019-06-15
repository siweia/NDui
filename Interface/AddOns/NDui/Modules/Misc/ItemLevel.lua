local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

--[[
	在角色面板等显示装备等级
]]
local pairs = pairs
local SLOTIDS = {}
for _, slot in pairs({"Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist", "Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand", "SecondaryHand"}) do
	SLOTIDS[slot] = GetInventorySlotInfo(slot.."Slot")
end

local myString = setmetatable({}, {
	__index = function(t, i)
		local gslot = _G["Character"..i.."Slot"]
		if not gslot then return end
		local fstr = B.CreateFS(gslot, DB.Font[2]+1, "", false, "BOTTOMLEFT", 1, 1)
		t[i] = fstr
		return fstr
	end
})

local tarString = setmetatable({}, {
	__index = function(t, i)
		local gslot = _G["Inspect"..i.."Slot"]
		if not gslot then return end
		local fstr = B.CreateFS(gslot, DB.Font[2]+1, "", false, "BOTTOMLEFT", 1, 1)
		t[i] = fstr
		return fstr
	end
})

function M:ItemLevel_SetupLevel(unit, strType)
	if not UnitExists(unit) then return end

	for slot, index in pairs(SLOTIDS) do
		local str = strType[slot]
		if not str then return end
		str:SetText("")

		local link = GetInventoryItemLink(unit, index)
		if link and index ~= 4 then
			local _, _, quality, level = GetItemInfo(link)
			level = B.GetItemLevel(link, unit, index) or level

			if level and level > 1 and quality then
				local color = BAG_ITEM_QUALITY_COLORS[quality]
				str:SetText(level)
				str:SetTextColor(color.r, color.g, color.b)
			end
		end
	end
end

function M:ItemLevel_UpdateInspect(...)
	local guid = ...
	if InspectFrame and InspectFrame.unit and UnitGUID(InspectFrame.unit) == guid then
		M:ItemLevel_SetupLevel(InspectFrame.unit, tarString)
	end
end

-- iLvl on flyout buttons
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

-- iLvl on scrapping machine
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

	hooksecurefunc("PaperDollItemSlotButton_OnShow", function()
		M:ItemLevel_SetupLevel("player", myString)
	end)

	hooksecurefunc("PaperDollItemSlotButton_OnEvent", function(self, event, id)
		if event == "PLAYER_EQUIPMENT_CHANGED" and self:GetID() == id then
			M:ItemLevel_SetupLevel("player", myString)
		end
	end)

	B:RegisterEvent("INSPECT_READY", self.ItemLevel_UpdateInspect)
	hooksecurefunc("EquipmentFlyout_DisplayButton", self.ItemLevel_FlyoutSetup)
	B:RegisterEvent("ADDON_LOADED", self.ItemLevel_ScrappingShow)
end