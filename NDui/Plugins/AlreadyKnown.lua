local _, ns = ...
local B, C, L, DB = unpack(ns)
-----------------------------
-- AlreadyKnown, by villiv
-- NDui MOD
-----------------------------
local strmatch, strfind, strsplit, mod = string.match, string.find, string.split, mod

local COLOR = {r = .1, g = 1, b = .1}
local knowables, knowns = {
	[LE_ITEM_CLASS_CONSUMABLE] = true,
	[LE_ITEM_CLASS_RECIPE] = true,
	[LE_ITEM_CLASS_MISCELLANEOUS] = true,
}, {}

local function isPetCollected(speciesID)
	if not speciesID or speciesID == 0 then return end
	local numOwned = C_PetJournal.GetNumCollectedInfo(speciesID)
	if numOwned > 0 then
		return true
	end
end

local function IsAlreadyKnown(link, index)
	if not link then return end

	if strmatch(link, "battlepet:") then
		local speciesID = select(2, strsplit(":", link))
		return isPetCollected(speciesID)
	elseif strmatch(link, "item:") then
		local name, _, _, _, _, _, _, _, _, _, _, itemClassID = GetItemInfo(link)
		if not name then return end

		if itemClassID == LE_ITEM_CLASS_BATTLEPET and index then
			local speciesID = B.ScanTip:SetGuildBankItem(GetCurrentGuildBankTab(), index)
			return isPetCollected(speciesID)
		else
			if knowns[link] then return true end
			if not knowables[itemClassID] then return end

			B.ScanTip:SetOwner(UIParent, "ANCHOR_NONE")
			B.ScanTip:SetHyperlink(link)
			for i = 1, B.ScanTip:NumLines() do
				local text = _G["NDui_ScanTooltipTextLeft"..i]:GetText() or ""
				if strfind(text, COLLECTED) or text == ITEM_SPELL_KNOWN then
					knowns[link] = true
					return true
				end
			end
		end
	end
end

-- merchant frame
local function MerchantFrame_UpdateMerchantInfo()
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
hooksecurefunc("MerchantFrame_UpdateMerchantInfo", MerchantFrame_UpdateMerchantInfo)

local function MerchantFrame_UpdateBuybackInfo()
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
hooksecurefunc("MerchantFrame_UpdateBuybackInfo", MerchantFrame_UpdateBuybackInfo)

-- auction frame
local function AuctionFrameBrowse_Update()
	local numItems = GetNumAuctionItems("list")
	local offset = FauxScrollFrame_GetOffset(BrowseScrollFrame)
	for i = 1, NUM_BROWSE_TO_DISPLAY do
		local index = offset + i
		if index > numItems then return end

		local texture = _G["BrowseButton"..i.."ItemIconTexture"]
		if texture and texture:IsShown() then
			local _, _, _, _, canUse = GetAuctionItemInfo("list", index)
			if canUse and IsAlreadyKnown(GetAuctionItemLink("list", index)) then
				texture:SetVertexColor(COLOR.r, COLOR.g, COLOR.b)
			end
		end
	end
end

local function AuctionFrameBid_Update()
	local numItems = GetNumAuctionItems("bidder")
	local offset = FauxScrollFrame_GetOffset(BidScrollFrame)
	for i = 1, NUM_BIDS_TO_DISPLAY do
		local index = offset + i
		if index > numItems then return end

		local texture = _G["BidButton"..i.."ItemIconTexture"]
		if texture and texture:IsShown() then
			local _, _, _, _, canUse = GetAuctionItemInfo("bidder", index)
			if canUse and IsAlreadyKnown(GetAuctionItemLink("bidder", index)) then
				texture:SetVertexColor(COLOR.r, COLOR.g, COLOR.b)
			end
		end
	end
end

local function AuctionFrameAuctions_Update()
	local numItems = GetNumAuctionItems("owner")
	local offset = FauxScrollFrame_GetOffset(AuctionsScrollFrame)
	for i = 1, NUM_AUCTIONS_TO_DISPLAY do
		local index = offset + i
		if index > numItems then return end

		local texture = _G["AuctionsButton"..i.."ItemIconTexture"]
		if texture and texture:IsShown() then
			local _, _, _, _, canUse, _, _, _, _, _, _, _, saleStatus = GetAuctionItemInfo("owner", index)
			if canUse and IsAlreadyKnown(GetAuctionItemLink("owner", index)) then
				local r, g, b = COLOR.r, COLOR.g, COLOR.b
				if saleStatus == 1 then
					r, g, b = r*.5, g*.5, b*.5
				end
				texture:SetVertexColor(r, g, b)
			end
		end
	end
end

-- guild bank frame
local MAX_GUILDBANK_SLOTS_PER_TAB = 98
local NUM_SLOTS_PER_GUILDBANK_GROUP = 14

local function GuildBankFrame_Update(self)
	if self.mode ~= "bank" then return end

	local button, index, column, texture, locked, quality
	local tab = GetCurrentGuildBankTab()
	for i = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		index = mod(i, NUM_SLOTS_PER_GUILDBANK_GROUP)
		if index == 0 then index = NUM_SLOTS_PER_GUILDBANK_GROUP end

		column = ceil((i-.5)/NUM_SLOTS_PER_GUILDBANK_GROUP)
		button = self.Columns[column].Buttons[index]
		if button and button:IsShown() then
			texture, _, locked, _, quality = GetGuildBankItemInfo(tab, i)
			if texture and not locked then
				if IsAlreadyKnown(GetGuildBankItemLink(tab, i), i) then
					SetItemButtonTextureVertexColor(button, COLOR.r, COLOR.g, COLOR.b)
				else
					SetItemButtonTextureVertexColor(button, 1, 1, 1)
				end
			end

			if button.bg then
				local color = DB.QualityColors[quality or 1]
				button.bg:SetBackdropBorderColor(color.r, color.g, color.b)
			end
		end
	end
end

local hookCount = 0
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, event, addon)
	if addon == "Blizzard_AuctionUI" then
		hooksecurefunc("AuctionFrameBrowse_Update", AuctionFrameBrowse_Update)
		hooksecurefunc("AuctionFrameBid_Update", AuctionFrameBid_Update)
		hooksecurefunc("AuctionFrameAuctions_Update", AuctionFrameAuctions_Update)
		hookCount = hookCount + 1
	elseif addon == "Blizzard_GuildBankUI" then
		hooksecurefunc(GuildBankFrame, "Update", GuildBankFrame_Update)
		hookCount = hookCount + 1
	end

	if hookCount >= 2 then
		f:UnregisterEvent(event)
	end
end)