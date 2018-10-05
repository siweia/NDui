local F, C = unpack(select(2, ...))

C.themes["Blizzard_BlackMarketUI"] = function()
	local r, g, b = C.r, C.g, C.b

	BlackMarketFrame:DisableDrawLayer("BACKGROUND")
	BlackMarketFrame:DisableDrawLayer("BORDER")
	BlackMarketFrame:DisableDrawLayer("OVERLAY")
	BlackMarketFrame.Inset:DisableDrawLayer("BORDER")
	select(9, BlackMarketFrame.Inset:GetRegions()):Hide()
	BlackMarketFrame.MoneyFrameBorder:Hide()
	BlackMarketFrame.HotDeal.Left:Hide()
	BlackMarketFrame.HotDeal.Right:Hide()
	select(4, BlackMarketFrame.HotDeal:GetRegions()):Hide()
	BlackMarketFrameLeft:Hide()
	BlackMarketFrameMiddle:Hide()
	BlackMarketFrameRight:Hide()

	F.CreateBG(BlackMarketFrame.HotDeal.Item)
	BlackMarketFrame.HotDeal.Item.IconTexture:SetTexCoord(.08, .92, .08, .92)

	local headers = {"ColumnName", "ColumnLevel", "ColumnType", "ColumnDuration", "ColumnHighBidder", "ColumnCurrentBid"}
	for _, header in pairs(headers) do
		local header = BlackMarketFrame[header]
		header.Left:Hide()
		header.Middle:Hide()
		header.Right:Hide()

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
				bu.Left:Hide()
				bu.Right:Hide()
				select(3, bu:GetRegions()):Hide()

				bu.Item:SetNormalTexture("")
				bu.Item:SetPushedTexture("")
				bu.Item:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				F.CreateBG(bu.Item)
				bu.Item.IconBorder:SetAlpha(0)

				local bg = F.CreateBDFrame(bu, 0)
				bg:SetPoint("TOPLEFT")
				bg:SetPoint("BOTTOMRIGHT", 0, 5)

				local tex = bu:CreateTexture(nil, "BACKGROUND")
				tex:SetPoint("TOPLEFT")
				tex:SetPoint("BOTTOMRIGHT", 0, 5)
				tex:SetColorTexture(0, 0, 0, .25)

				bu:SetHighlightTexture(C.media.backdrop)
				local hl = bu:GetHighlightTexture()
				hl:SetVertexColor(r, g, b, .2)
				hl.SetAlpha = F.dummy
				hl:ClearAllPoints()
				hl:SetPoint("TOPLEFT", 0, -1)
				hl:SetPoint("BOTTOMRIGHT", -1, 6)

				bu.Selection:ClearAllPoints()
				bu.Selection:SetPoint("TOPLEFT", 0, -1)
				bu.Selection:SetPoint("BOTTOMRIGHT", -1, 6)
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