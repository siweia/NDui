local _, ns = ...
local B, C, L, DB = unpack(ns)

local function reskinMerchantItem(item)
	local name = item.Name
	local button = item.ItemButton
	local icon = button.icon
	local moneyFrame = _G[item:GetName().."MoneyFrame"]

	B.StripTextures(item)
	B.CreateBDFrame(item, .25)

	B.StripTextures(button)
	button:ClearAllPoints()
	button:SetPoint("LEFT", item, 4, 0)
	local hl = button:GetHighlightTexture()
	hl:SetColorTexture(1, 1, 1, .25)
	hl:SetInside()

	icon:SetInside()
	button.bg = B.ReskinIcon(icon)
	B.ReskinIconBorder(button.IconBorder)
	button.IconOverlay:SetInside()
	button.IconOverlay2:SetInside()

	name:SetFontObject(Number12Font)
	name:SetPoint("LEFT", button, "RIGHT", 2, 9)
	moneyFrame:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 3, 0)
end

local function reskinMerchantInteract(button)
	if DB.isNewPatch then
	button:GetRegions():Hide()
	B.ReskinIcon(button.Icon)
	else
	B.CreateBDFrame(button)
	end
	button:SetPushedTexture(0)
	button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
end

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	B.ReskinPortraitFrame(MerchantFrame)
	B.ReskinDropDown(MerchantFrameLootFilter)
	B.StripTextures(MerchantPrevPageButton)
	B.ReskinArrow(MerchantPrevPageButton, "left")
	B.StripTextures(MerchantNextPageButton)
	B.ReskinArrow(MerchantNextPageButton, "right")
	MerchantMoneyInset:Hide()
	MerchantMoneyBg:Hide()
	MerchantExtraCurrencyBg:SetAlpha(0)
	MerchantExtraCurrencyInset:SetAlpha(0)
	BuybackBG:SetAlpha(0)

	MerchantFrameTab1:ClearAllPoints()
	MerchantFrameTab1:SetPoint("CENTER", MerchantFrame, "BOTTOMLEFT", 50, -14)
	MerchantFrameTab2:SetPoint("LEFT", MerchantFrameTab1, "RIGHT", -15, 0)

	for i = 1, 2 do
		B.ReskinTab(_G["MerchantFrameTab"..i])
	end

	for i = 1, BUYBACK_ITEMS_PER_PAGE do
		local item = _G["MerchantItem"..i]
		reskinMerchantItem(item)

		for j = 1, 3 do
			local currency = _G["MerchantItem"..i.."AltCurrencyFrameItem"..j]
			local texture = _G["MerchantItem"..i.."AltCurrencyFrameItem"..j.."Texture"]
			currency:SetPoint("BOTTOMLEFT", item.ItemButton, "BOTTOMRIGHT", 3, 0)
			B.ReskinIcon(texture)
		end
	end

	MerchantBuyBackItem:SetHeight(44)
	reskinMerchantItem(MerchantBuyBackItem)

	reskinMerchantInteract(MerchantGuildBankRepairButton)

	reskinMerchantInteract(MerchantRepairAllButton)

	reskinMerchantInteract(MerchantRepairItemButton)

	if not DB.isNewPatch then
		MerchantGuildBankRepairButtonIcon:SetTexCoord(.595, .8075, .05, .52)
		MerchantRepairAllIcon:SetTexCoord(.31375, .53, .06, .52)
		local ic = MerchantRepairItemButton:GetRegions()
		ic:SetTexture("Interface\\Icons\\INV_Hammer_20")
		ic:SetTexCoord(unpack(DB.TexCoord))
	else
	reskinMerchantInteract(MerchantSellAllJunkButton)
	end

	hooksecurefunc("MerchantFrame_UpdateCurrencies", function()
		for i = 1, MAX_MERCHANT_CURRENCIES do
			local bu = _G["MerchantToken"..i]
			if bu and not bu.styled then
				local icon = _G["MerchantToken"..i.."Icon"]
				if icon then
					B.ReskinIcon(icon)
				end
				local count = _G["MerchantToken"..i.."Count"]
				if count then
					count:SetPoint("TOPLEFT", bu, "TOPLEFT", -2, 0) -- needs reveiw
				end

				bu.styled = true
			end
		end
	end)

	if not DB.isNewPatch then
		hooksecurefunc("MerchantFrame_UpdateRepairButtons", function()
			if CanGuildBankRepair() then
				MerchantRepairText:SetPoint("CENTER", MerchantFrame, "BOTTOMLEFT", 65, 73)
			end
		end)
	end

	-- StackSplitFrame

	local StackSplitFrame = StackSplitFrame
	B.StripTextures(StackSplitFrame)
	B.SetBD(StackSplitFrame)
	B.Reskin(StackSplitFrame.OkayButton)
	B.Reskin(StackSplitFrame.CancelButton)
	B.ReskinArrow(StackSplitFrame.LeftButton, "left")
	B.ReskinArrow(StackSplitFrame.RightButton, "right")
end)
