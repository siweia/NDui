local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	TradePlayerEnchantInset:Hide()
	TradePlayerItemsInset:Hide()
	TradeRecipientEnchantInset:Hide()
	TradeRecipientItemsInset:Hide()
	TradePlayerInputMoneyInset:Hide()
	TradeRecipientMoneyInset:Hide()
	TradeRecipientBG:Hide()
	TradeRecipientMoneyBg:Hide()
	TradeRecipientBotLeftCorner:Hide()
	TradeRecipientLeftBorder:Hide()
	select(4, TradePlayerItem7:GetRegions()):Hide()
	select(4, TradeRecipientItem7:GetRegions()):Hide()

	B.ReskinPortraitFrame(TradeFrame)
	TradeFrame.RecipientOverlay:Hide()
	B.Reskin(TradeFrameTradeButton)
	B.Reskin(TradeFrameCancelButton)

	if not TradePlayerInputMoneyFrame:IsForbidden() then
		B.ReskinInput(TradePlayerInputMoneyFrameGold)
		B.ReskinInput(TradePlayerInputMoneyFrameSilver)
		B.ReskinInput(TradePlayerInputMoneyFrameCopper)
	
		TradePlayerInputMoneyFrameSilver:SetPoint("LEFT", TradePlayerInputMoneyFrameGold, "RIGHT", 1, 0)
		TradePlayerInputMoneyFrameCopper:SetPoint("LEFT", TradePlayerInputMoneyFrameSilver, "RIGHT", 1, 0)
	end

	local function reskinButton(bu)
		bu:SetNormalTexture(0)
		bu:SetPushedTexture(0)
		local hl = bu:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetInside()
		bu.icon:SetTexCoord(unpack(DB.TexCoord))
		bu.icon:SetInside()
		bu.IconOverlay:SetInside()
		bu.IconOverlay2:SetInside()
		bu.bg = B.CreateBDFrame(bu.icon, .25)
		B.ReskinIconBorder(bu.IconBorder)
	end

	for i = 1, MAX_TRADE_ITEMS do
		_G["TradePlayerItem"..i.."SlotTexture"]:Hide()
		_G["TradePlayerItem"..i.."NameFrame"]:Hide()
		_G["TradeRecipientItem"..i.."SlotTexture"]:Hide()
		_G["TradeRecipientItem"..i.."NameFrame"]:Hide()

		reskinButton(_G["TradePlayerItem"..i.."ItemButton"])
		reskinButton(_G["TradeRecipientItem"..i.."ItemButton"])
	end

	local tradeHighlights = {
		TradeHighlightPlayer,
		TradeHighlightPlayerEnchant,
		TradeHighlightRecipient,
		TradeHighlightRecipientEnchant,
	}
	for _, highlight in pairs(tradeHighlights) do
		B.StripTextures(highlight)
		highlight:SetFrameStrata("HIGH")
		local bg = B.CreateBDFrame(highlight, 1)
		bg:SetBackdropColor(0, 1, 0, .15)
	end
end)