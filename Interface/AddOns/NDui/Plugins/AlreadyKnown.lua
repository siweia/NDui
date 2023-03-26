local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:GetModule("Tooltip")

local mod, strmatch, strfind, format = mod, strmatch, strfind, format
local GetItemInfo, SetItemButtonTextureVertexColor = GetItemInfo, SetItemButtonTextureVertexColor
local GetCurrentGuildBankTab, GetGuildBankItemInfo, GetGuildBankItemLink = GetCurrentGuildBankTab, GetGuildBankItemInfo, GetGuildBankItemLink
local GetMerchantNumItems, GetMerchantItemInfo, GetMerchantItemLink = GetMerchantNumItems, GetMerchantItemInfo, GetMerchantItemLink
local GetNumBuybackItems, GetBuybackItemInfo, GetBuybackItemLink = GetNumBuybackItems, GetBuybackItemInfo, GetBuybackItemLink
local C_PetJournal_GetNumCollectedInfo = C_PetJournal.GetNumCollectedInfo

local COLOR = {r = .1, g = 1, b = .1}
local knowables = {
	[Enum.ItemClass.Consumable] = true,
	[Enum.ItemClass.Recipe] = true,
	[Enum.ItemClass.Miscellaneous] = true,
	[Enum.ItemClass.ItemEnhancement] = true,
}
local knowns = {}

local function isPetCollected(speciesID)
	if not speciesID or speciesID == 0 then return end
	local numOwned = C_PetJournal_GetNumCollectedInfo(speciesID)
	if numOwned > 0 then
		return true
	end
end

local function IsAlreadyKnown(link, index)
	if not link then return end

	local linkType, linkID = strmatch(link, "|H(%a+):(%d+)")
	linkID = tonumber(linkID)

	if linkType == "battlepet" then
		return isPetCollected(linkID)
	elseif linkType == "item" then
		local name, _, _, level, _, _, _, _, _, _, _, itemClassID = GetItemInfo(link)
		if not name then return end

		if itemClassID == Enum.ItemClass.Battlepet and index then
			local data = C_TooltipInfo.GetGuildBankItem(GetCurrentGuildBankTab(), index)
			if data then
				if DB.isPatch10_1 then
					return data.battlePetSpeciesID and isPetCollected(data.battlePetSpeciesID)
				else
					local argVal = data.args and data.args[2]
					if argVal.field == "battlePetSpeciesID" then
						return isPetCollected(argVal.intVal)
					end
				end
			end
		else
			if knowns[link] then return true end
			if not knowables[itemClassID] then return end

			local data = C_TooltipInfo.GetHyperlink(link, nil, nil, true)
			if data then
				for i = 1, #data.lines do
					local lineData = data.lines[i]
					if DB.isPatch10_1 then
						local text = lineData.leftText
						if text then
							if strfind(text, COLLECTED) or text == ITEM_SPELL_KNOWN then
								knowns[link] = true
								return true
							end
						end
					else
						local argVal = lineData and lineData.args
						if argVal then
							local text = argVal[2] and argVal[2].stringVal
							if text then
								if strfind(text, COLLECTED) or text == ITEM_SPELL_KNOWN then
									knowns[link] = true
									return true
								end
							end
						end
					end
				end
			end
		end
	end
end

-- merchant frame
local function Hook_UpdateMerchantInfo()
	local numItems = GetMerchantNumItems()
	for i = 1, MERCHANT_ITEMS_PER_PAGE do
		local index = (MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE + i
		if index > numItems then return end

		local button = _G["MerchantItem"..i.."ItemButton"]
		if button and button:IsShown() then
			local _, _, _, _, numAvailable, isUsable = GetMerchantItemInfo(index)
			if isUsable and IsAlreadyKnown(GetMerchantItemLink(index)) then
				local r, g, b = COLOR.r, COLOR.g, COLOR.b
				if numAvailable == 0 then
					r, g, b = r*.5, g*.5, b*.5
				end
				SetItemButtonTextureVertexColor(button, r, g, b)
			end
		end
	end
end
hooksecurefunc("MerchantFrame_UpdateMerchantInfo", Hook_UpdateMerchantInfo)

local function Hook_UpdateBuybackInfo()
	local numItems = GetNumBuybackItems()
	for index = 1, BUYBACK_ITEMS_PER_PAGE do
		if index > numItems then return end

		local button = _G["MerchantItem"..index.."ItemButton"]
		if button and button:IsShown() then
			local _, _, _, _, _, isUsable = GetBuybackItemInfo(index)
			if isUsable and IsAlreadyKnown(GetBuybackItemLink(index)) then
				SetItemButtonTextureVertexColor(button, COLOR.r, COLOR.g, COLOR.b)
			end
		end
	end
end
hooksecurefunc("MerchantFrame_UpdateBuybackInfo", Hook_UpdateBuybackInfo)

local function Hook_UpdateAuctionItems(self)
	for i = 1, self.ScrollTarget:GetNumChildren() do
		local child = select(i, self.ScrollTarget:GetChildren())
		if child.cells then
			local button = child.cells[2]
			local itemKey = button and button.rowData and button.rowData.itemKey
			if itemKey and itemKey.itemID then
				local itemLink
				if itemKey.itemID == 82800 then
					itemLink = format("|Hbattlepet:%d::::::|h[Dummy]|h", itemKey.battlePetSpeciesID)
				else
					itemLink = format("|Hitem:%d", itemKey.itemID)
				end

				if itemLink and IsAlreadyKnown(itemLink) then
					-- Highlight
					child.SelectedHighlight:Show()
					child.SelectedHighlight:SetVertexColor(COLOR.r, COLOR.g, COLOR.b)
					child.SelectedHighlight:SetAlpha(.25)
					-- Icon
					button.Icon:SetVertexColor(COLOR.r, COLOR.g, COLOR.b)
					button.IconBorder:SetVertexColor(COLOR.r, COLOR.g, COLOR.b)
				else
					-- Highlight
					child.SelectedHighlight:SetVertexColor(1, 1, 1)
					-- Icon
					button.Icon:SetVertexColor(1, 1, 1)
					button.IconBorder:SetVertexColor(1, 1, 1)
				end
			end
		end
	end
end

-- guild bank frame
local MAX_GUILDBANK_SLOTS_PER_TAB = MAX_GUILDBANK_SLOTS_PER_TAB or 98
local NUM_SLOTS_PER_GUILDBANK_GROUP = NUM_SLOTS_PER_GUILDBANK_GROUP or 14

local function GuildBankFrame_Update(self)
	if self.mode ~= "bank" then return end

	local button, index, column, texture, locked
	local tab = GetCurrentGuildBankTab()
	for i = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		index = mod(i, NUM_SLOTS_PER_GUILDBANK_GROUP)
		if index == 0 then index = NUM_SLOTS_PER_GUILDBANK_GROUP end

		column = ceil((i-.5)/NUM_SLOTS_PER_GUILDBANK_GROUP)
		button = self.Columns[column].Buttons[index]
		if button and button:IsShown() then
			texture, _, locked = GetGuildBankItemInfo(tab, i)
			if texture and not locked then
				if IsAlreadyKnown(GetGuildBankItemLink(tab, i), i) then
					SetItemButtonTextureVertexColor(button, COLOR.r, COLOR.g, COLOR.b)
				else
					SetItemButtonTextureVertexColor(button, 1, 1, 1)
				end
			end
		end
	end
end

local hookCount = 0
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, event, addon)
	if addon == "Blizzard_AuctionHouseUI" then
		hooksecurefunc(AuctionHouseFrame.BrowseResultsFrame.ItemList.ScrollBox, "Update", Hook_UpdateAuctionItems)
		hookCount = hookCount + 1
	elseif addon == "Blizzard_GuildBankUI" then
		hooksecurefunc(GuildBankFrame, "Update", GuildBankFrame_Update)
		hookCount = hookCount + 1
	end

	if hookCount >= 2 then
		f:UnregisterEvent(event)
	end
end)