local F, C = unpack(select(2, ...))

C.themes["Blizzard_AuctionHouseUI"] = function()
	local function reskinAuctionButton(button)
		F.Reskin(button)
		button:SetSize(22,22)
	end

	local function reskinSellPanel(frame)
		F.StripTextures(frame)

		local itemDisplay = frame.ItemDisplay
		F.StripTextures(itemDisplay)
		F.CreateBDFrame(itemDisplay, .25)

		local itemButton = itemDisplay.ItemButton
		if itemButton.IconMask then itemButton.IconMask:Hide() end
		if itemButton.IconBorder then itemButton.IconBorder:SetAlpha(0) end
		itemButton.EmptyBackground:Hide()
		itemButton:SetPushedTexture("")
		itemButton.Highlight:SetColorTexture(1, 1, 1, .25)
		itemButton.Highlight:SetAllPoints(itemButton.Icon)
		itemButton.Icon:SetTexCoord(.08, .92, .08, .92)
		local bg = F.CreateBDFrame(itemButton.Icon)
		hooksecurefunc(itemButton.IconBorder, "SetVertexColor", function(_, r, g, b) bg:SetBackdropBorderColor(r, g, b) end)
		hooksecurefunc(itemButton.IconBorder, "Hide", function() bg:SetBackdropBorderColor(0, 0, 0) end)

		F.ReskinInput(frame.QuantityInput.InputBox)
		F.Reskin(frame.QuantityInput.MaxButton)
		F.ReskinInput(frame.PriceInput.MoneyInputFrame.GoldBox)
		F.ReskinInput(frame.PriceInput.MoneyInputFrame.SilverBox)
		if frame.SecondaryPriceInput then
			F.ReskinInput(frame.SecondaryPriceInput.MoneyInputFrame.GoldBox)
			F.ReskinInput(frame.SecondaryPriceInput.MoneyInputFrame.SilverBox)
		end
		F.ReskinDropDown(frame.DurationDropDown.DropDown)
		F.Reskin(frame.PostButton)
		if frame.BuyoutModeCheckButton then F.ReskinCheck(frame.BuyoutModeCheckButton) end
	end

	local function reskinListIcon(frame)
		if not frame.tableBuilder then return end

		for i = 1, 22 do
			local row = frame.tableBuilder.rows[i]
			if row then
				for j = 1, 4 do
					local cell = row.cells and row.cells[j]
					if cell and cell.Icon then
						if not cell.styled then
							cell.Icon.bg = F.ReskinIcon(cell.Icon)
							if cell.IconBorder then cell.IconBorder:Hide() end
							cell.styled = true
						end
						cell.Icon.bg:SetShown(cell.Icon:IsShown())
					end
				end
			end
		end
	end

	local function reskinSummaryIcon(frame)
		for i = 1, 23 do
			local child = select(i, frame.ScrollFrame.scrollChild:GetChildren())
			if child and child.Icon then
				if not child.styled then
					child.Icon.bg = F.ReskinIcon(child.Icon)
					child.styled = true
				end
				child.Icon.bg:SetShown(child.Icon:IsShown())
			end
		end
	end

	local function reskinListHeader(frame)
		local maxHeaders = frame.HeaderContainer:GetNumChildren()
		for i = 1, maxHeaders do
			local header = select(i, frame.HeaderContainer:GetChildren())
			if header and not header.styled then
				header:DisableDrawLayer("BACKGROUND")
				header.bg = F.CreateBDFrame(header)
				local hl = header:GetHighlightTexture()
				hl:SetColorTexture(1, 1, 1, .1)
				hl:SetAllPoints(header.bg)

				header.styled = true
			end

			if header.bg then
				header.bg:SetPoint("BOTTOMRIGHT", i < maxHeaders and -5 or 0, -2)
			end
		end

		reskinListIcon(frame)
	end

	local function reskinSellList(frame, hasHeader)
		F.StripTextures(frame)
		if frame.RefreshFrame then
			reskinAuctionButton(frame.RefreshFrame.RefreshButton)
		end
		F.ReskinScroll(frame.ScrollFrame.scrollBar)
		if hasHeader then
			F.CreateBDFrame(frame.ScrollFrame, .25)
			hooksecurefunc(frame, "RefreshScrollFrame", reskinListHeader)
		else
			hooksecurefunc(frame, "RefreshScrollFrame", reskinSummaryIcon)
		end
	end

	local function reskinItemDisplay(frame)
		local itemDisplay = frame.ItemDisplay
		F.StripTextures(itemDisplay)
		local bg = F.CreateBDFrame(itemDisplay, .25)
		bg:SetPoint("TOPLEFT", 3, -3)
		bg:SetPoint("BOTTOMRIGHT", -3, 0)
		local itemButton = itemDisplay.ItemButton
		itemButton.CircleMask:Hide()
		itemButton.IconBorder:SetAlpha(0)
		F.ReskinIcon(itemButton.Icon)
	end

	F.ReskinPortraitFrame(AuctionHouseFrame)
	F.StripTextures(AuctionHouseFrame.MoneyFrameBorder)
	F.CreateBDFrame(AuctionHouseFrame.MoneyFrameBorder, .25)
	F.StripTextures(AuctionHouseFrame.MoneyFrameInset)
	F.ReskinTab(AuctionHouseFrameBuyTab)
	F.ReskinTab(AuctionHouseFrameSellTab)
	F.ReskinTab(AuctionHouseFrameAuctionsTab)

	local searchBar = AuctionHouseFrame.SearchBar
	reskinAuctionButton(searchBar.FavoritesSearchButton)
	F.ReskinInput(searchBar.SearchBox)
	F.ReskinFilterButton(searchBar.FilterButton)
	F.Reskin(searchBar.SearchButton)

	F.StripTextures(AuctionHouseFrame.CategoriesList)
	F.ReskinScroll(AuctionHouseFrame.CategoriesList.ScrollFrame.ScrollBar)

	hooksecurefunc("FilterButton_SetUp", function(button)
		button.NormalTexture:SetAlpha(0)
		button.SelectedTexture:SetColorTexture(0, .6, 1, .3)
		button.HighlightTexture:SetColorTexture(1, 1, 1, .1)
	end)
	
	local itemList = AuctionHouseFrame.BrowseResultsFrame.ItemList
	F.StripTextures(itemList, 3)
	F.CreateBDFrame(itemList.ScrollFrame, .25)
	F.ReskinScroll(itemList.ScrollFrame.scrollBar)
	hooksecurefunc(itemList, "RefreshScrollFrame", reskinListHeader)

	local itemBuyFrame = AuctionHouseFrame.ItemBuyFrame
	F.Reskin(itemBuyFrame.BackButton)
	F.Reskin(itemBuyFrame.BidFrame.BidButton)
	F.Reskin(itemBuyFrame.BuyoutFrame.BuyoutButton)
	F.ReskinInput(AuctionHouseFrameGold)
	F.ReskinInput(AuctionHouseFrameSilver)
	reskinItemDisplay(itemBuyFrame)
	local itemList = itemBuyFrame.ItemList
	F.StripTextures(itemList)
	reskinAuctionButton(itemList.RefreshFrame.RefreshButton)
	F.CreateBDFrame(itemList.ScrollFrame, .25)
	F.ReskinScroll(itemList.ScrollFrame.scrollBar)
	hooksecurefunc(itemList, "RefreshScrollFrame", reskinListHeader)

	local commBuyFrame = AuctionHouseFrame.CommoditiesBuyFrame
	F.Reskin(commBuyFrame.BackButton)
	local buyDisplay = commBuyFrame.BuyDisplay
	F.StripTextures(buyDisplay)
	F.ReskinInput(buyDisplay.QuantityInput.InputBox)
	F.Reskin(buyDisplay.BuyButton)
	reskinItemDisplay(buyDisplay)
	local itemList = commBuyFrame.ItemList
	F.StripTextures(itemList)
	F.CreateBDFrame(itemList, .25)
	reskinAuctionButton(itemList.RefreshFrame.RefreshButton)
	F.ReskinScroll(itemList.ScrollFrame.scrollBar)

	local wowTokenResults = AuctionHouseFrame.WoWTokenResults
	F.StripTextures(wowTokenResults)
	F.StripTextures(wowTokenResults.TokenDisplay)
	F.CreateBDFrame(wowTokenResults.TokenDisplay, .25)
	F.Reskin(wowTokenResults.Buyout)
	F.ReskinScroll(wowTokenResults.DummyScrollBar)

	reskinSellPanel(AuctionHouseFrame.ItemSellFrame)
	reskinSellPanel(AuctionHouseFrame.CommoditiesSellFrame)
	reskinSellList(AuctionHouseFrame.CommoditiesSellList, true)
	reskinSellList(AuctionHouseFrame.ItemSellList, true)
	reskinSellList(AuctionHouseFrameAuctionsFrame.SummaryList)
	reskinSellList(AuctionHouseFrameAuctionsFrame.AllAuctionsList, true)
	reskinSellList(AuctionHouseFrameAuctionsFrame.BidsList, true)
	reskinSellList(AuctionHouseFrameAuctionsFrame.CommoditiesList, true)
	reskinItemDisplay(AuctionHouseFrameAuctionsFrame)

	F.ReskinTab(AuctionHouseFrameAuctionsFrameAuctionsTab)
	F.ReskinTab(AuctionHouseFrameAuctionsFrameBidsTab)
	F.ReskinInput(AuctionHouseFrameAuctionsFrameGold)
	F.ReskinInput(AuctionHouseFrameAuctionsFrameSilver)
	F.Reskin(AuctionHouseFrameAuctionsFrame.CancelAuctionButton)
	F.Reskin(AuctionHouseFrameAuctionsFrame.BidFrame.BidButton)
	F.Reskin(AuctionHouseFrameAuctionsFrame.BuyoutFrame.BuyoutButton)

	local buyDialog = AuctionHouseFrame.BuyDialog
	F.StripTextures(buyDialog)
	F.SetBD(buyDialog)
	F.Reskin(buyDialog.BuyNowButton)
	F.Reskin(buyDialog.CancelButton)
end

C.themes["Blizzard_AuctionUI"] = function()
	local r, g, b = C.r, C.g, C.b

	F.SetBD(AuctionFrame, 2, -10, 0, 10)
	F.CreateBD(AuctionProgressFrame)
	F.CreateSD(AuctionProgressFrame)

	AuctionProgressBar:SetStatusBarTexture(C.media.backdrop)
	F.CreateBDFrame(AuctionProgressBar, .25)
	F.ReskinIcon(AuctionProgressBar.Icon)

	AuctionProgressBar.Text:ClearAllPoints()
	AuctionProgressBar.Text:SetPoint("CENTER", 0, 1)
	F.ReskinClose(AuctionProgressFrameCancelButton, "LEFT", AuctionProgressBar, "RIGHT", 4, 0)
	select(14, AuctionProgressFrameCancelButton:GetRegions()):SetPoint("CENTER", 0, 2)

	AuctionFrame:DisableDrawLayer("ARTWORK")
	AuctionPortraitTexture:Hide()
	for i = 1, 4 do
		select(i, AuctionProgressFrame:GetRegions()):Hide()
	end
	AuctionProgressBar.Border:Hide()
	BrowseFilterScrollFrame:GetRegions():Hide()
	select(2, BrowseFilterScrollFrame:GetRegions()):Hide()
	BrowseScrollFrame:GetRegions():Hide()
	select(2, BrowseScrollFrame:GetRegions()):Hide()
	BidScrollFrame:GetRegions():Hide()
	select(2, BidScrollFrame:GetRegions()):Hide()
	AuctionsScrollFrame:GetRegions():Hide()
	select(2, AuctionsScrollFrame:GetRegions()):Hide()
	BrowseQualitySort:DisableDrawLayer("BACKGROUND")
	BrowseLevelSort:DisableDrawLayer("BACKGROUND")
	BrowseDurationSort:DisableDrawLayer("BACKGROUND")
	BrowseHighBidderSort:DisableDrawLayer("BACKGROUND")
	BrowseCurrentBidSort:DisableDrawLayer("BACKGROUND")
	BidQualitySort:DisableDrawLayer("BACKGROUND")
	BidLevelSort:DisableDrawLayer("BACKGROUND")
	BidDurationSort:DisableDrawLayer("BACKGROUND")
	BidBuyoutSort:DisableDrawLayer("BACKGROUND")
	BidStatusSort:DisableDrawLayer("BACKGROUND")
	BidBidSort:DisableDrawLayer("BACKGROUND")
	AuctionsQualitySort:DisableDrawLayer("BACKGROUND")
	AuctionsDurationSort:DisableDrawLayer("BACKGROUND")
	AuctionsHighBidderSort:DisableDrawLayer("BACKGROUND")
	AuctionsBidSort:DisableDrawLayer("BACKGROUND")
	select(6, BrowseCloseButton:GetRegions()):Hide()
	select(6, BrowseBuyoutButton:GetRegions()):Hide()
	select(6, BrowseBidButton:GetRegions()):Hide()
	select(6, BidCloseButton:GetRegions()):Hide()
	select(6, BidBuyoutButton:GetRegions()):Hide()
	select(6, BidBidButton:GetRegions()):Hide()

	hooksecurefunc("FilterButton_SetUp", function(button)
		button:SetNormalTexture("")
	end)

	local lastSkinnedTab = 1
	AuctionFrame:HookScript("OnShow", function()
		local tab = _G["AuctionFrameTab"..lastSkinnedTab]

		while tab do
			F.ReskinTab(tab)
			lastSkinnedTab = lastSkinnedTab + 1
			tab = _G["AuctionFrameTab"..lastSkinnedTab]
		end
	end)

	local abuttons = {"BrowseBidButton", "BrowseBuyoutButton", "BrowseCloseButton", "BrowseSearchButton", "BrowseResetButton", "BidBidButton", "BidBuyoutButton", "BidCloseButton", "AuctionsCloseButton", "AuctionsCancelAuctionButton", "AuctionsCreateAuctionButton", "AuctionsNumStacksMaxButton", "AuctionsStackSizeMaxButton"}
	for i = 1, #abuttons do
		F.Reskin(_G[abuttons[i]])
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

	-- Blizz needs to be more consistent

	BrowseBidPriceSilver:SetPoint("LEFT", BrowseBidPriceGold, "RIGHT", 1, 0)
	BrowseBidPriceCopper:SetPoint("LEFT", BrowseBidPriceSilver, "RIGHT", 1, 0)
	BidBidPriceSilver:SetPoint("LEFT", BidBidPriceGold, "RIGHT", 1, 0)
	BidBidPriceCopper:SetPoint("LEFT", BidBidPriceSilver, "RIGHT", 1, 0)
	StartPriceSilver:SetPoint("LEFT", StartPriceGold, "RIGHT", 1, 0)
	StartPriceCopper:SetPoint("LEFT", StartPriceSilver, "RIGHT", 1, 0)
	BuyoutPriceSilver:SetPoint("LEFT", BuyoutPriceGold, "RIGHT", 1, 0)
	BuyoutPriceCopper:SetPoint("LEFT", BuyoutPriceSilver, "RIGHT", 1, 0)

	local function reskinAuctionButtons(button, i)
		local bu = _G[button..i]
		local it = _G[button..i.."Item"]
		local ic = _G[button..i.."ItemIconTexture"]

		if bu and it then
			it:SetNormalTexture("")
			it:SetPushedTexture("")
			it:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			F.ReskinIcon(ic)
			it.IconBorder:SetAlpha(0)
			F.StripTextures(bu)

			local bg = F.CreateBDFrame(bu, .25)
			bg:SetPoint("TOPLEFT")
			bg:SetPoint("BOTTOMRIGHT", 0, 5)

			bu:SetHighlightTexture(C.media.backdrop)
			local hl = bu:GetHighlightTexture()
			hl:SetVertexColor(r, g, b, .2)
			hl:ClearAllPoints()
			hl:SetPoint("TOPLEFT", 0, -1)
			hl:SetPoint("BOTTOMRIGHT", -1, 6)
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

	local auctionhandler = CreateFrame("Frame")
	auctionhandler:RegisterEvent("NEW_AUCTION_UPDATE")
	auctionhandler:SetScript("OnEvent", function()
		local AuctionsItemButtonIconTexture = AuctionsItemButton:GetNormalTexture()
		if AuctionsItemButtonIconTexture then
			AuctionsItemButtonIconTexture:SetTexCoord(.08, .92, .08, .92)
			AuctionsItemButtonIconTexture:SetPoint("TOPLEFT", C.mult, -C.mult)
			AuctionsItemButtonIconTexture:SetPoint("BOTTOMRIGHT", -C.mult, C.mult)
		end
		AuctionsItemButton.IconBorder:SetTexture("")
	end)

	F.CreateBD(AuctionsItemButton, .25)
	local _, AuctionsItemButtonNameFrame = AuctionsItemButton:GetRegions()
	AuctionsItemButtonNameFrame:Hide()
	local hl = AuctionsItemButton:GetHighlightTexture()
	hl:SetColorTexture(1, 1, 1, .25)
	hl:SetPoint("TOPLEFT", C.mult, -C.mult)
	hl:SetPoint("BOTTOMRIGHT", -C.mult, C.mult)

	F.ReskinClose(AuctionFrameCloseButton, "TOPRIGHT", AuctionFrame, "TOPRIGHT", -4, -14)
	F.ReskinScroll(BrowseScrollFrameScrollBar)
	F.ReskinScroll(AuctionsScrollFrameScrollBar)
	F.ReskinScroll(BrowseFilterScrollFrameScrollBar)
	F.ReskinDropDown(PriceDropDown)
	F.ReskinDropDown(DurationDropDown)
	F.ReskinInput(BrowseName)
	F.ReskinArrow(BrowsePrevPageButton, "left")
	F.ReskinArrow(BrowseNextPageButton, "right")
	F.ReskinCheck(ExactMatchCheckButton)
	F.ReskinCheck(IsUsableCheckButton)
	F.ReskinCheck(ShowOnPlayerCheckButton)

	BrowsePrevPageButton:SetPoint("TOPLEFT", 660, -60)
	BrowseNextPageButton:SetPoint("TOPRIGHT", 67, -60)
	BrowsePrevPageButton:GetRegions():SetPoint("LEFT", BrowsePrevPageButton, "RIGHT", 2, 0)

	BrowseDropDownLeft:SetAlpha(0)
	BrowseDropDownMiddle:SetAlpha(0)
	BrowseDropDownRight:SetAlpha(0)

	local a1, p, a2, x, y = BrowseDropDownButton:GetPoint()
	BrowseDropDownButton:SetPoint(a1, p, a2, x, y-4)
	BrowseDropDownButton:SetSize(16, 16)
	F.Reskin(BrowseDropDownButton, true)

	local tex = BrowseDropDownButton:CreateTexture(nil, "OVERLAY")
	tex:SetTexture(C.media.arrowDown)
	tex:SetSize(8, 8)
	tex:SetPoint("CENTER")
	tex:SetVertexColor(1, 1, 1)
	BrowseDropDownButton.bgTex = tex

	local bg = F.CreateBDFrame(BrowseDropDown, 0)
	bg:SetPoint("TOPLEFT", 16, -5)
	bg:SetPoint("BOTTOMRIGHT", 109, 11)
	F.CreateGradient(bg)

	local colourArrow = F.colourArrow
	local clearArrow = F.clearArrow

	BrowseDropDownButton:HookScript("OnEnter", colourArrow)
	BrowseDropDownButton:HookScript("OnLeave", clearArrow)

	local inputs = {"BrowseMinLevel", "BrowseMaxLevel", "BrowseBidPriceGold", "BrowseBidPriceSilver", "BrowseBidPriceCopper", "BidBidPriceGold", "BidBidPriceSilver", "BidBidPriceCopper", "StartPriceGold", "StartPriceSilver", "StartPriceCopper", "BuyoutPriceGold", "BuyoutPriceSilver", "BuyoutPriceCopper", "AuctionsStackSizeEntry", "AuctionsNumStacksEntry"}
	for i = 1, #inputs do
		F.ReskinInput(_G[inputs[i]])
	end

	-- [[ WoW token ]]

	local BrowseWowTokenResults = BrowseWowTokenResults

	F.Reskin(BrowseWowTokenResults.Buyout)
	F.ReskinPortraitFrame(WowTokenGameTimeTutorial)
	F.Reskin(StoreButton)
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
		iconBorder:SetTexture(C.media.backdrop)
		iconBorder:SetDrawLayer("BACKGROUND")
		iconBorder:SetPoint("TOPLEFT", icon, -C.mult, C.mult)
		iconBorder:SetPoint("BOTTOMRIGHT", icon, C.mult, -C.mult)
		icon:SetTexCoord(.08, .92, .08, .92)
	end
end