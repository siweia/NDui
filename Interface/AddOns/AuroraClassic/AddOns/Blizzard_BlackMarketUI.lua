local F, C = unpack(select(2, ...))

C.themes["Blizzard_BlackMarketUI"] = function()
	local r, g, b = C.r, C.g, C.b

	F.StripTextures(BlackMarketFrame)
	BlackMarketFrame.MoneyFrameBorder:SetAlpha(0)
	F.StripTextures(BlackMarketFrame.HotDeal)
	F.CreateBG(BlackMarketFrame.HotDeal.Item)
	BlackMarketFrame.HotDeal.Item.IconTexture:SetTexCoord(.08, .92, .08, .92)

	local headers = {"ColumnName", "ColumnLevel", "ColumnType", "ColumnDuration", "ColumnHighBidder", "ColumnCurrentBid"}
	for _, header in pairs(headers) do
		local header = BlackMarketFrame[header]
		F.StripTextures(header)
		local bg = F.CreateBDFrame(header, .25)
		bg:SetPoint("TOPLEFT", 2, 0)
		bg:SetPoint("BOTTOMRIGHT", -1, 0)
	end

	F.SetBD(BlackMarketFrame)
	F.CreateBD(BlackMarketFrame.HotDeal, .25)
	F.Reskin(BlackMarketFrame.BidButton)
	F.ReskinClose(BlackMarketFrame.CloseButton)
	F.ReskinInput(BlackMarketBidPriceGold)
	F.ReskinScroll(BlackMarketScrollFrameScrollBar)

	hooksecurefunc("BlackMarketScrollFrame_Update", function()
		local buttons = BlackMarketScrollFrame.buttons
		for i = 1, #buttons do
			local bu = buttons[i]

			bu.Item.IconTexture:SetTexCoord(.08, .92, .08, .92)
			if not bu.reskinned then
				F.StripTextures(bu)

				bu.Item:SetNormalTexture("")
				bu.Item:SetPushedTexture("")
				bu.Item:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				F.CreateBG(bu.Item)
				bu.Item.IconBorder:SetAlpha(0)

				local bg = F.CreateBDFrame(bu, .25)
				bg:SetPoint("TOPLEFT", bu.Item, "TOPRIGHT", 3, C.mult)
				bg:SetPoint("BOTTOMRIGHT", 0, 4)

				bu:SetHighlightTexture(C.media.backdrop)
				local hl = bu:GetHighlightTexture()
				hl:SetVertexColor(r, g, b, .2)
				hl.SetAlpha = F.dummy
				hl:ClearAllPoints()
				hl:SetAllPoints(bg)

				bu.Selection:ClearAllPoints()
				bu.Selection:SetAllPoints(bg)
				bu.Selection:SetTexture(C.media.backdrop)
				bu.Selection:SetVertexColor(r, g, b, .1)

				bu.reskinned = true
			end

			if bu:IsShown() and bu.itemLink then
				local _, _, quality = GetItemInfo(bu.itemLink)
				bu.Name:SetTextColor(GetItemQualityColor(quality))
			end
		end
	end)

	hooksecurefunc("BlackMarketFrame_UpdateHotItem", function(self)
		local hotDeal = self.HotDeal
		if hotDeal:IsShown() and hotDeal.itemLink then
			local _, _, quality = GetItemInfo(hotDeal.itemLink)
			hotDeal.Name:SetTextColor(GetItemQualityColor(quality))
		end
		hotDeal.Item.IconBorder:Hide()
	end)
end