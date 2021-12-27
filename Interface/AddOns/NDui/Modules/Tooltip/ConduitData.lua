local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:GetModule("Tooltip")

local pairs, select = pairs, select
local GetItemInfo, GetItemInfoFromHyperlink = GetItemInfo, GetItemInfoFromHyperlink
local C_Soulbinds_GetConduitCollection = C_Soulbinds.GetConduitCollection
local C_Soulbinds_IsItemConduitByItemInfo = C_Soulbinds.IsItemConduitByItemInfo
local COLLECTED_STRING = " |cffff0000("..COLLECTED..")|r"

TT.ConduitData = {}

function TT:Conduit_UpdateCollection()
	for i = 0, 2 do
		local collectionData = C_Soulbinds_GetConduitCollection(i)
		for _, value in pairs(collectionData) do
			TT.ConduitData[value.conduitItemID] = value.conduitItemLevel
		end
	end
end

function TT:Conduit_CheckStatus()
	local _, link = self:GetItem()
	if not link then return end
	if not C_Soulbinds_IsItemConduitByItemInfo(link) then return end

	local itemID = GetItemInfoFromHyperlink(link)
	local level = select(4, GetItemInfo(link))
	local knownLevel = itemID and TT.ConduitData[itemID]

	if knownLevel and level and knownLevel >= level then
		local textLine = _G[self:GetName().."TextLeft1"]
		local text = textLine and textLine:GetText()
		if text then
			textLine:SetText(text..COLLECTED_STRING)
		end
	end
end

function TT:ConduitCollectionData()
	TT.Conduit_UpdateCollection()
	if not next(TT.ConduitData) then
		C_Timer.After(10, TT.Conduit_UpdateCollection) -- might be empty on fist load
	end
	B:RegisterEvent("SOULBIND_CONDUIT_COLLECTION_UPDATED", TT.Conduit_UpdateCollection)

	if not C.db["Tooltip"]["ConduitInfo"] then return end

	GameTooltip:HookScript("OnTooltipSetItem", TT.Conduit_CheckStatus)
	ItemRefTooltip:HookScript("OnTooltipSetItem", TT.Conduit_CheckStatus)
	ShoppingTooltip1:HookScript("OnTooltipSetItem", TT.Conduit_CheckStatus)
	GameTooltipTooltip:HookScript("OnTooltipSetItem", TT.Conduit_CheckStatus)
	EmbeddedItemTooltip:HookScript("OnTooltipSetItem", TT.Conduit_CheckStatus)
end