local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if NDuiDB["Bags"]["Enable"] then return end
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end
	if not NDuiDB["Skins"]["DefaultBags"] then return end

	-- [[ Bank ]]

	BankSlotsFrame:DisableDrawLayer("BORDER")
	BankPortraitTexture:Hide()
	BankFrameMoneyFrameInset:Hide()
	BankFrameMoneyFrameBorder:Hide()

	-- "item slots" and "bag slots" text
	select(9, BankSlotsFrame:GetRegions()):SetDrawLayer("OVERLAY")
	select(10, BankSlotsFrame:GetRegions()):SetDrawLayer("OVERLAY")

	B.ReskinPortraitFrame(BankFrame)
	B.Reskin(BankFramePurchaseButton)
	B.ReskinTab(BankFrameTab1)
	B.ReskinTab(BankFrameTab2)
	B.ReskinInput(BankItemSearchBox)

	local function styleBankButton(bu)
		bu:SetNormalTexture("")
		bu:SetPushedTexture("")
		bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		bu.searchOverlay:SetOutside()

		bu.icon:SetTexCoord(unpack(DB.TexCoord))
		bu.bg = B.CreateBDFrame(bu.icon, .25)
		B.ReskinIconBorder(bu.IconBorder)

		local questTexture = bu.IconQuestTexture
		questTexture:SetDrawLayer("BACKGROUND")
		questTexture:SetSize(1, 1)
	end

	for i = 1, 28 do
		styleBankButton(_G["BankFrameItem"..i])
	end

	for i = 1, 7 do
		local bag = BankSlotsFrame["Bag"..i]
		bag:SetNormalTexture("")
		bag:SetPushedTexture("")
		bag:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		bag.SlotHighlightTexture:SetColorTexture(1, .8, 0, .25)
		bag.searchOverlay:SetOutside()

		bag.icon:SetTexCoord(unpack(DB.TexCoord))
		bag.bg = B.CreateBDFrame(bag.icon, .25)
		B.ReskinIconBorder(bag.IconBorder)
	end

	BankItemAutoSortButton:GetNormalTexture():SetTexCoord(.17, .83, .17, .83)
	BankItemAutoSortButton:GetPushedTexture():SetTexCoord(.17, .83, .17, .83)
	B.CreateBDFrame(BankItemAutoSortButton)
	local highlight = BankItemAutoSortButton:GetHighlightTexture()
	highlight:SetColorTexture(1, 1, 1, .25)
	highlight:SetAllPoints(BankItemAutoSortButton)

	hooksecurefunc("BankFrameItemButton_Update", function(button)
		if not button.isBag and button.IconQuestTexture:IsShown() then
			button.IconBorder:SetVertexColor(1, 1, 0)
		end
	end)

	-- [[ Reagent bank ]]

	ReagentBankFrame:DisableDrawLayer("BACKGROUND")
	ReagentBankFrame:DisableDrawLayer("BORDER")
	ReagentBankFrame:DisableDrawLayer("ARTWORK")

	B.Reskin(ReagentBankFrame.DespositButton)
	B.Reskin(ReagentBankFrameUnlockInfoPurchaseButton)

	-- make button more visible
	B.StripTextures(ReagentBankFrameUnlockInfo)
	ReagentBankFrameUnlockInfoBlackBG:SetColorTexture(.1, .1, .1)

	local reagentButtonsStyled = false
	ReagentBankFrame:HookScript("OnShow", function()
		if not reagentButtonsStyled then
			for i = 1, 98 do
				local button = _G["ReagentBankFrameItem"..i]
				styleBankButton(button)
				BankFrameItemButton_Update(button)
			end
			reagentButtonsStyled = true
		end
	end)
end)