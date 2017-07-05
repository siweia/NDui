local B, C, L, DB = unpack(select(2, ...))
local module = NDui:GetModule("Misc")

--[[
	在角色面板显示装备等级
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

		for slot, id in pairs(SLOTIDS) do
			local str = strType[slot]
			if not str then return end
			str:SetText("")

			local link = GetInventoryItemLink(unit, id)
			if link and id ~= 4 then
				local _, _, quality, level = GetItemInfo(link)
				level = NDui:GetItemLevel(link, quality) or level

				if level and level > 1 and quality then
					local color = BAG_ITEM_QUALITY_COLORS[quality]
					str:SetText(level)
					str:SetTextColor(color.r, color.g, color.b)
				end
			end
		end
	end

	hooksecurefunc("PaperDollItemSlotButton_OnShow", function(self)
		SetupItemLevel("player", myString)
	end)

	hooksecurefunc("PaperDollItemSlotButton_OnEvent", function(self, event, id)
		if event == "PLAYER_EQUIPMENT_CHANGED" and self:GetID() == id then
			SetupItemLevel("player", myString)
		end
	end)

	NDui:EventFrame("INSPECT_READY"):SetScript("OnEvent", function(self, event, ...)
		local guid = ...
		if InspectFrame and InspectFrame.unit and UnitGUID(InspectFrame.unit) == guid then
			SetupItemLevel(InspectFrame.unit, tarString)
		end
	end)
end