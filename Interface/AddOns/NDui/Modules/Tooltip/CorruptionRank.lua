local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:GetModule("Tooltip")

local ITEM_MOD_CORRUPTION = ITEM_MOD_CORRUPTION
local IsCorruptedItem, GetSpellInfo = IsCorruptedItem, GetSpellInfo
local select, strmatch, gmatch, format = select, strmatch, gmatch, format

local corruptionData = {
	-- Credit: CorruptionNameTooltips
	["6483"] = {spellID = 315607, level = 1},
	["6484"] = {spellID = 315608, level = 2},
	["6485"] = {spellID = 315609, level = 3},
	["6474"] = {spellID = 315544, level = 1},
	["6475"] = {spellID = 315545, level = 2},
	["6476"] = {spellID = 315546, level = 3},
	["6471"] = {spellID = 315529, level = 1},
	["6472"] = {spellID = 315530, level = 2},
	["6473"] = {spellID = 315531, level = 3},
	["6480"] = {spellID = 315554, level = 1},
	["6481"] = {spellID = 315557, level = 2},
	["6482"] = {spellID = 315558, level = 3},
	["6477"] = {spellID = 315549, level = 1},
	["6478"] = {spellID = 315552, level = 2},
	["6479"] = {spellID = 315553, level = 3},
	["6493"] = {spellID = 315590, level = 1},
	["6494"] = {spellID = 315591, level = 2},
	["6495"] = {spellID = 315592, level = 3},
	["6437"] = {spellID = 315277, level = 1},
	["6438"] = {spellID = 315281, level = 2},
	["6439"] = {spellID = 315282, level = 3},
	["6555"] = {spellID = 318266, level = 1},
	["6559"] = {spellID = 318492, level = 2},
	["6560"] = {spellID = 318496, level = 3},
	["6556"] = {spellID = 318268, level = 1},
	["6561"] = {spellID = 318493, level = 2},
	["6562"] = {spellID = 318497, level = 3},
	["6558"] = {spellID = 318270, level = 1},
	["6565"] = {spellID = 318495, level = 2},
	["6566"] = {spellID = 318499, level = 3},
	["6557"] = {spellID = 318269, level = 1},
	["6563"] = {spellID = 318494, level = 2},
	["6564"] = {spellID = 318498, level = 3},
	["6549"] = {spellID = 318280, level = 1},
	["6550"] = {spellID = 318485, level = 2},
	["6551"] = {spellID = 318486, level = 3},
	["6552"] = {spellID = 318274, level = 1},
	["6553"] = {spellID = 318487, level = 2},
	["6554"] = {spellID = 318488, level = 3},
	["6547"] = {spellID = 318303, level = 1},
	["6548"] = {spellID = 318484, level = 2},
	["6537"] = {spellID = 318276, level = 1},
	["6538"] = {spellID = 318477, level = 2},
	["6539"] = {spellID = 318478, level = 3},
	["6543"] = {spellID = 318481, level = 1},
	["6544"] = {spellID = 318482, level = 2},
	["6545"] = {spellID = 318483, level = 3},
	["6540"] = {spellID = 318286, level = 1},
	["6541"] = {spellID = 318479, level = 2},
	["6542"] = {spellID = 318480, level = 3},
	["6573"] = {spellID = 318272, level = ""},
	["6546"] = {spellID = 318239, level = ""},
	["6571"] = {spellID = 318293, level = ""},
	["6572"] = {spellID = 316651, level = ""},
	["6567"] = {spellID = 318294, level = ""},
	["6568"] = {spellID = 316780, level = ""},
	["6570"] = {spellID = 318299, level = ""},
	["6569"] = {spellID = 317290, level = ""},
}

local linkCache = {}
function TT:Corruption_Search(link)
	local value = linkCache[link]
	if not value then
		local itemString = strmatch(link, "item:([%-?%d:]+)")
		for index in gmatch(itemString, "%d+") do
			if corruptionData[index] then
				value = corruptionData[index]
				linkCache[link] = value
				break
			end
		end
	end
	return value
end

local function getIconString(icon)
	return format("|T%s:14:14:0:0:64:64:5:59:5:59|t ", icon)
end

function TT:Corruption_Convert(name, icon, level)
	for i = 5, self:NumLines() do
		local line = _G[self:GetName().."TextLeft"..i]
		local text = line:GetText()
		if text and strmatch(text, ITEM_MOD_CORRUPTION) then
			line:SetText(text.." - "..getIconString(icon)..name.." "..level)
			return
		end
	end
end

function TT:Corruption_Update()
	local link = select(2, self:GetItem())
	if link and IsCorruptedItem(link) then
		local value = TT:Corruption_Search(link)
		if value then
			if not value.name or not value.icon then
				value.name, _, value.icon = GetSpellInfo(value.spellID)
			end
			TT.Corruption_Convert(self, value.name, value.icon, value.level)
		end
	end
end

function TT:CorruptionRank()
	if not NDuiDB["Tooltip"]["CorruptionRank"] then return end
	if IsAddOnLoaded("CorruptionTooltips") then return end
	if IsAddOnLoaded("CorruptionNameTooltips") then return end

	GameTooltip:HookScript("OnTooltipSetItem", TT.Corruption_Update)
	ItemRefTooltip:HookScript("OnTooltipSetItem", TT.Corruption_Update)
	ShoppingTooltip1:HookScript("OnTooltipSetItem", TT.Corruption_Update)
	ShoppingTooltip2:HookScript("OnTooltipSetItem", TT.Corruption_Update)
	EmbeddedItemTooltip:HookScript("OnTooltipSetItem", TT.Corruption_Update)
end