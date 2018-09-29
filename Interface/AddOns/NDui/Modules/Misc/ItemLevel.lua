local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Misc")

--[[
	在角色面板等显示装备等级
]]
function module:ShowItemLevel()
	if not NDuiDB["Misc"]["ItemLevel"] then return end

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

	local function SetupItemLevel(unit, strType)
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

	hooksecurefunc("PaperDollItemSlotButton_OnShow", function()
		SetupItemLevel("player", myString)
	end)

	hooksecurefunc("PaperDollItemSlotButton_OnEvent", function(self, event, id)
		if event == "PLAYER_EQUIPMENT_CHANGED" and self:GetID() == id then
			SetupItemLevel("player", myString)
		end
	end)

	B:RegisterEvent("INSPECT_READY", function(_, ...)
		local guid = ...
		if InspectFrame and InspectFrame.unit and UnitGUID(InspectFrame.unit) == guid then
			SetupItemLevel(InspectFrame.unit, tarString)
		end
	end)

	-- ilvl on flyout buttons
	local function SetupFlyoutLevel(button, bag, slot, quality)
		if not button.iLvl then
			button.iLvl = B.CreateFS(button, DB.Font[2]+1, "", false, "BOTTOMLEFT", 1, 1)
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
		button.iLvl:SetText(level)
		button.iLvl:SetTextColor(color.r, color.g, color.b)
	end

	hooksecurefunc("EquipmentFlyout_DisplayButton", function(button)
		local location = button.location
		if not location or location < 0 then return end
		if location == EQUIPMENTFLYOUT_PLACEINBAGS_LOCATION then
			if button.iLvl then button.iLvl:SetText("") end
			return
		end

		local _, _, bags, voidStorage, slot, bag = EquipmentManager_UnpackLocation(location)
		if voidStorage then return end
		local quality = select(13, EquipmentManager_GetItemInfoByLocation(location))
		if bags then
			SetupFlyoutLevel(button, bag, slot, quality)
		else
			SetupFlyoutLevel(button, nil, slot, quality)
		end
	end)

	-- ilvl on scrapping machine
	local function updateMachineLevel(self)
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

	local function itemLevelOnScrapping(event, addon)
		if addon == "Blizzard_ScrappingMachineUI" then
			for button in pairs(ScrappingMachineFrame.ItemSlots.scrapButtons.activeObjects) do
				hooksecurefunc(button, "RefreshIcon", updateMachineLevel)
			end

			B:UnregisterEvent(event, itemLevelOnScrapping)
		end
	end
	B:RegisterEvent("ADDON_LOADED", itemLevelOnScrapping)
end