local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_AuctionUI"] = function()
	local r, g, b = DB.r, DB.g, DB.b

	B.SetBD(AuctionFrame, nil, 2, -10, 0, 10)
	B.StripTextures(AuctionProgressFrame)
	B.SetBD(AuctionProgressFrame)

	AuctionProgressBar:SetStatusBarTexture(DB.bdTex)
	B.CreateBDFrame(AuctionProgressBar, .25)
	B.ReskinIcon(AuctionProgressBar.Icon)

	AuctionProgressBar.Text:ClearAllPoints()
	AuctionProgressBar.Text:SetPoint("CENTER", 0, 1)
	B.ReskinClose(AuctionProgressFrameCancelButton)

	AuctionFrame:DisableDrawLayer("ARTWORK")
	AuctionPortraitTexture:Hide()

	local auctionSorts = {
		BrowseQualitySort,
		BrowseLevelSort,
		BrowseDurationSort,
		BrowseHighBidderSort,
		BrowseCurrentBidSort,
		BidQualitySort,
		BidLevelSort,
		BidDurationSort,
		BidBuyoutSort,
		BidStatusSort,
		BidBidSort,
		AuctionsQualitySort,
		AuctionsDurationSort,
		AuctionsHighBidderSort,
		AuctionsBidSort,
	}
	for _, tab in pairs(auctionSorts) do
		tab:DisableDrawLayer("BACKGROUND")
		tab:GetHighlightTexture():SetColorTexture(r, g, b, .25)
	end

	B.StripTextures(BrowseCloseButton)
	B.StripTextures(BrowseBuyoutButton)
	B.StripTextures(BrowseBidButton)
	B.StripTextures(BidCloseButton)
	B.StripTextures(BidBuyoutButton)
	B.StripTextures(BidBidButton)

	hooksecurefunc("FilterButton_SetUp", function(button)
		button:SetNormalTexture("")
	end)

	local lastSkinnedTab = 1
	AuctionFrame:HookScript("OnShow", function()
		local tab = _G["AuctionFrameTab"..lastSkinnedTab]

		while tab do
			B.ReskinTab(tab)
			lastSkinnedTab = lastSkinnedTab + 1
			tab = _G["AuctionFrameTab"..lastSkinnedTab]
		end
	end)

	local abuttons = {
		"BrowseBidButton",
		"BrowseBuyoutButton",
		"BrowseCloseButton",
		"BrowseSearchButton",
		"BrowseResetButton",
		"BidBidButton",
		"BidBuyoutButton",
		"BidCloseButton",
		"AuctionsCloseButton",
		"AuctionsCancelAuctionButton",
		"AuctionsCreateAuctionButton",
		"AuctionsNumStacksMaxButton",
		"AuctionsStackSizeMaxButton",
	}
	for _, name in pairs(abuttons) do
		local button = _G[name]
		if not button then
			if DB.isDeveloper then print(name, "not found.") end
		else
			B.Reskin(button)
		end
	end

	BrowseCloseButton:ClearAllPoints()
	BrowseCloseButton:SetPoint("BOTTOMRIGHT", AuctionFrameBrowse, "BOTTOMRIGHT", 66, 13)
	BrowseBuyoutButton:ClearAllPoints()
	BrowseBuyoutButton:SetPoint("RIGHT", BrowseCloseButton, "LEFT", -1, 0)
	BrowseBidButton:ClearAllPoints()
	BrowseBidButton:SetPoint("RIGHT", BrowseBuyoutButton, "LEFT", -1, 0)
	BidBuyoutButton:ClearAllPoints()
	BidBuyoutButton:SetPoint("RIGHT", BidCloseButton, "LEFT", -1, 0)
	BidBidButton:ClearAllPoints()
	BidBidButton:SetPoint("RIGHT", BidBuyoutButton, "LEFT", -1, 0)
	AuctionsCancelAuctionButton:ClearAllPoints()
	AuctionsCancelAuctionButton:SetPoint("RIGHT", AuctionsCloseButton, "LEFT", -1, 0)

	local function reskinAuctionButtons(button, i)
		local bu = _G[button..i]
		local it = _G[button..i.."Item"]
		local ic = _G[button..i.."ItemIconTexture"]

		if bu and it then
			it:SetNormalTexture("")
			it:SetPushedTexture("")
			local itemHL = it:GetHighlightTexture()
			if itemHL then
				itemHL:SetColorTexture(1, 1, 1, .25)
			end
			B.ReskinIcon(ic)
			it.IconBorder:SetAlpha(0)
			B.StripTextures(bu)

			local bg = B.CreateBDFrame(bu, .25)
			bg:SetPoint("TOPLEFT", ic, "TOPRIGHT", 0, C.mult)
			bg:SetPoint("BOTTOMRIGHT", 0, 4)

			bu:SetHighlightTexture(DB.bdTex)
			local hl = bu:GetHighlightTexture()
			hl:SetVertexColor(r, g, b, .2)
			hl:SetInside(bg)
		end
	end

	for i = 1, NUM_BROWSE_TO_DISPLAY do
		reskinAuctionButtons("BrowseButton", i)
	end

	for i = 1, NUM_BIDS_TO_DISPLAY do
		reskinAuctionButtons("BidButton", i)
	end

	for i = 1, NUM_AUCTIONS_TO_DISPLAY do
		reskinAuctionButtons("AuctionsButton", i)
	end

	B:RegisterEvent("NEW_AUCTION_UPDATE", function()
		local iconTexture = AuctionsItemButton:GetNormalTexture()
		if iconTexture then
			iconTexture:SetTexCoord(.08, .92, .08, .92)
			iconTexture:SetInside()
		end
		AuctionsItemButton.IconBorder:SetTexture("")
	end)

	B.CreateBDFrame(AuctionsItemButton, .25)
	local _, AuctionsItemButtonNameFrame = AuctionsItemButton:GetRegions()
	AuctionsItemButtonNameFrame:Hide()
	local hl = AuctionsItemButton:GetHighlightTexture()
	hl:SetColorTexture(1, 1, 1, .25)
	hl:SetInside()

	B.ReskinClose(AuctionFrameCloseButton, AuctionFrame, -4, -14)
	B.ReskinScroll(BrowseScrollFrameScrollBar)
	B.ReskinScroll(AuctionsScrollFrameScrollBar)
	B.ReskinScroll(BrowseFilterScrollFrameScrollBar)
	B.ReskinScroll(BidScrollFrameScrollBar)
	B.ReskinDropDown(PriceDropDown)
	B.ReskinInput(BrowseName)
	B.ReskinArrow(BrowsePrevPageButton, "left")
	B.ReskinArrow(BrowseNextPageButton, "right")
	B.ReskinCheck(IsUsableCheckButton)
	B.ReskinCheck(ShowOnPlayerCheckButton)
	B.ReskinRadio(AuctionsShortAuctionButton)
	B.ReskinRadio(AuctionsMediumAuctionButton)
	B.ReskinRadio(AuctionsLongAuctionButton)

	BrowseDropDownLeft:SetAlpha(0)
	BrowseDropDownMiddle:SetAlpha(0)
	BrowseDropDownRight:SetAlpha(0)

	local a1, p, a2, x, y = BrowseDropDownButton:GetPoint()
	BrowseDropDownButton:SetPoint(a1, p, a2, x, y-4)
	BrowseDropDownButton:SetSize(16, 16)
	B.Reskin(BrowseDropDownButton, true)

	local tex = BrowseDropDownButton:CreateTexture(nil, "OVERLAY")
	B.SetupArrow(tex, "down")
	tex:SetSize(14, 14)
	tex:SetPoint("CENTER")
	tex:SetVertexColor(1, 1, 1)
	BrowseDropDownButton.__texture = tex

	local bg = B.CreateBDFrame(BrowseDropDown, 0, true)
	bg:SetPoint("TOPLEFT", 16, -5)
	bg:SetPoint("BOTTOMRIGHT", 109, 11)

	BrowseDropDownButton:HookScript("OnEnter", B.Texture_OnEnter)
	BrowseDropDownButton:HookScript("OnLeave", B.Texture_OnLeave)

	local inputs = {"BrowseMinLevel", "BrowseMaxLevel", "BrowseBidPriceGold", "BrowseBidPriceSilver", "BrowseBidPriceCopper", "BidBidPriceGold", "BidBidPriceSilver", "BidBidPriceCopper", "StartPriceGold", "StartPriceSilver", "StartPriceCopper", "BuyoutPriceGold", "BuyoutPriceSilver", "BuyoutPriceCopper", "AuctionsStackSizeEntry", "AuctionsNumStacksEntry"}
	for i = 1, #inputs do
		B.ReskinInput(_G[inputs[i]])
	end

	-- [[ WoW token ]]

	local BrowseWowTokenResults = BrowseWowTokenResults

	B.Reskin(BrowseWowTokenResults.Buyout)
	B.ReskinPortraitFrame(WowTokenGameTimeTutorial)
	B.Reskin(StoreButton)
	WowTokenGameTimeTutorial.LeftDisplay.Label:SetTextColor(1, 1, 1)
	WowTokenGameTimeTutorial.LeftDisplay.Tutorial1:SetTextColor(1, .8, 0)
	WowTokenGameTimeTutorial.RightDisplay.Label:SetTextColor(1, 1, 1)
	WowTokenGameTimeTutorial.RightDisplay.Tutorial1:SetTextColor(1, .8, 0)

	-- Token

	do
		local Token = BrowseWowTokenResults.Token
		local icon = Token.Icon
		local iconBorder = Token.IconBorder

		Token.ItemBorder:Hide()
		iconBorder:SetTexture(DB.bdTex)
		iconBorder:SetDrawLayer("BACKGROUND")
		iconBorder:SetOutside(icon)
		icon:SetTexCoord(.08, .92, .08, .92)
	end
end