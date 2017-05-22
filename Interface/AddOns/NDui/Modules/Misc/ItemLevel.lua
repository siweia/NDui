local B, C, L, DB = unpack(select(2, ...))
local module = NDui:GetModule("Misc")

--[[
	在角色面板显示装备等级
]]
local lvlPattern = _G["ITEM_LEVEL"]:gsub("%%d", "(%%d+)")
local ItemDB = {}
function NDui:GetUnitItemInfo(unit, slot)
    if not UnitExists(unit) then return end

	local tip = _G["NDuiUnitTip"] or CreateFrame("GameTooltip", "NDuiUnitTip", nil, "GameTooltipTemplate")
    tip:SetOwner(UIParent, "ANCHOR_NONE")
    tip:SetInventoryItem(unit, slot)

    local link = GetInventoryItemLink(unit, slot) or select(2, tip:GetItem())
    if not link then return end
	if ItemDB[link] then return ItemDB[link] end

	for i = 2, 5 do
		local textLine = _G["NDuiUnitTipTextLeft"..i]
		if textLine and textLine:GetText() then
			local level = strmatch(textLine:GetText(), lvlPattern)
			if level then
				ItemDB[link] = tonumber(level)
				break
			end
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

	local function RefreshData(self, event)
		local unit, getString = "player", myString
		if event == "INSPECT_READY" then
			unit, getString = InspectFrame and InspectFrame.unit, tarString
		end
		if not unit then return end

		for slot, id in pairs(SLOTIDS) do
			local str = getString[slot]
			if not str then return end
			str:SetText("")

			local link = GetInventoryItemLink(unit, id)
			if link and id ~= 4 then
				local _, _, quality, level = GetItemInfo(link)
				level = NDui:GetUnitItemInfo(unit, id) or level

				if level and level > 1 and quality then
					local color = BAG_ITEM_QUALITY_COLORS[quality]
					str:SetText(level)
					str:SetTextColor(color.r, color.g, color.b)
				end
			end
		end
	end

	hooksecurefunc("PaperDollItemSlotButton_OnShow", function(self)
		if not self.init then
			RefreshData()
			self.init = true
		end
	end)

	local f = NDui:EventFrame({"PLAYER_EQUIPMENT_CHANGED", "INSPECT_READY"})
	f:SetScript("OnEvent", RefreshData)
end