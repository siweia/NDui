local F, C = unpack(select(2, ...))

C.themes["Blizzard_VoidStorageUI"] = function()
	F.SetBD(VoidStorageFrame, 20, 0, 0, 20)
	F.CreateBD(VoidStoragePurchaseFrame)
	F.StripTextures(VoidStorageBorderFrame)
	F.StripTextures(VoidStorageDepositFrame)
	F.StripTextures(VoidStorageWithdrawFrame)
	F.StripTextures(VoidStorageCostFrame)
	F.StripTextures(VoidStorageStorageFrame)
	VoidStorageFrameMarbleBg:Hide()
	VoidStorageFrameLines:Hide()
	select(2, VoidStorageFrame:GetRegions()):Hide()

	local function reskinIcons(bu, quality)
		if not bu.bg then
			bu:SetPushedTexture("")
			bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			bu.IconBorder:SetAlpha(0)
			bu.bg = F.CreateBDFrame(bu, .25)
			local bg, icon, _, search = bu:GetRegions()
			bg:Hide()
			icon:SetTexCoord(.08, .92, .08, .92)
			search:SetAllPoints(bu.bg)
		end

		local color = BAG_ITEM_QUALITY_COLORS[quality or 1]
		bu.bg:SetBackdropBorderColor(color.r, color.g, color.b)
	end

	local function hookItemsUpdate(doDeposit, doContents)
		local self = VoidStorageFrame
		if doDeposit then
			for i = 1, 9 do
				local quality = select(3, GetVoidTransferDepositInfo(i))
				local bu = _G["VoidStorageDepositButton"..i]
				reskinIcons(bu, quality)
			end
		end

		if doContents then
			for i = 1, 9 do
				local quality = select(3, GetVoidTransferWithdrawalInfo(i))
				local bu = _G["VoidStorageWithdrawButton"..i]
				reskinIcons(bu, quality)
			end

			for i = 1, 80 do
				local quality = select(6, GetVoidItemInfo(self.page, i))
				local bu = _G["VoidStorageStorageButton"..i]
				reskinIcons(bu, quality)
			end
		end
	end
	hooksecurefunc("VoidStorage_ItemsUpdate", hookItemsUpdate)

	for i = 1, 2 do
		local tab = VoidStorageFrame["Page"..i]
		tab:GetRegions():Hide()
		tab:SetCheckedTexture(C.media.checked)
		tab:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		tab:GetNormalTexture():SetTexCoord(.08, .92, .08, .92)
		F.CreateBG(tab)
	end

	VoidStorageFrame.Page1:ClearAllPoints()
	VoidStorageFrame.Page1:SetPoint("LEFT", VoidStorageFrame, "TOPRIGHT", 2, -60)

	F.Reskin(VoidStoragePurchaseButton)
	F.Reskin(VoidStorageHelpBoxButton)
	F.Reskin(VoidStorageTransferButton)
	F.ReskinClose(VoidStorageBorderFrame.CloseButton)
	F.ReskinInput(VoidItemSearchBox)
end