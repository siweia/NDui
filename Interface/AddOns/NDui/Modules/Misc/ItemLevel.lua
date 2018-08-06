local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Misc")
local bagModule = B:GetModule("Bags")

--[[
	在角色面板显示装备等级
]]
local itemLevelString = _G["ITEM_LEVEL"]:gsub("%%d", "")
local ItemDB = {}
function module:GetUnitItemLevel(link, unit, index, quality)
	if ItemDB[link] and quality ~= 6 then return ItemDB[link] end

	local tip = _G["NDuiItemLevelTooltip"] or CreateFrame("GameTooltip", "NDuiItemLevelTooltip", nil, "GameTooltipTemplate")
	tip:SetOwner(UIParent, "ANCHOR_NONE")
 	tip:SetInventoryItem(unit, index)

	for i = 2, 5 do
		local text = _G[tip:GetName().."TextLeft"..i]:GetText() or ""
		local hasLevel = string.find(text, itemLevelString)
		if hasLevel then
			local level = string.match(text, "(%d+)%)?$")
			ItemDB[link] = tonumber(level)
			break
		end
	end
	return ItemDB[link]
end

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
				level = self:GetUnitItemLevel(link, unit, index, quality) or level

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

	local function SetupFlyoutLevel(button, bag, slot, quality)
		if not button.iLvl then
			button.iLvl = B.CreateFS(button, DB.Font[2]+1, "", false, "BOTTOMLEFT", 1, 1)
		end
		local link, level
		if bag then
			link = GetContainerItemLink(bag, slot)
			level = bagModule:GetBagItemLevel(link, bag, slot)
		else
			link = GetInventoryItemLink("player", slot)
			level = self:GetUnitItemLevel(link, "player", slot, quality)
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
end