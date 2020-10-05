local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:GetModule("Tooltip")

local pairs, tonumber, strmatch = pairs, tonumber, strmatch
local C_Soulbinds_GetConduitCollection = C_Soulbinds.GetConduitCollection
local COLLECTED_STRING = " |cffff0000("..COLLECTED..")|r"

TT.ConduitData = {}

function TT:Conduit_UpdateCollection()
	for i = 0, 2 do
		local collectionData = C_Soulbinds_GetConduitCollection(i)
		for _, value in pairs(collectionData) do
			TT.ConduitData[value.conduitItemID] = true
		end
	end
end

function TT:Conduit_CheckStatus()
	local _, link = self:GetItem()
	if not link then return end

	local itemID = strmatch(link, "item:(%d*)")
	if itemID and TT.ConduitData[tonumber(itemID)] then
		local textLine = _G[self:GetName().."TextLeft1"]
		local text = textLine and textLine:GetText()
		if text and text ~= "" then
			textLine:SetText(text..COLLECTED_STRING)
		end
	end
end

function TT:ConduitCollectionData()
	C_Timer.After(3, TT.Conduit_UpdateCollection) -- might be empty on fist load
	B:RegisterEvent("SOULBIND_CONDUIT_COLLECTION_UPDATED", TT.Conduit_UpdateCollection)

	GameTooltip:HookScript("OnTooltipSetItem", TT.Conduit_CheckStatus)
	ItemRefTooltip:HookScript("OnTooltipSetItem", TT.Conduit_CheckStatus)
	ShoppingTooltip1:HookScript("OnTooltipSetItem", TT.Conduit_CheckStatus)
	GameTooltipTooltip:HookScript("OnTooltipSetItem", TT.Conduit_CheckStatus)
	EmbeddedItemTooltip:HookScript("OnTooltipSetItem", TT.Conduit_CheckStatus)
end