local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_VoidStorageUI"] = function()
	B.SetBD(VoidStorageFrame, nil, 20, 0, 0, 20)
	B.CreateBDFrame(VoidStoragePurchaseFrame)
	B.StripTextures(VoidStorageBorderFrame)
	B.StripTextures(VoidStorageDepositFrame)
	B.StripTextures(VoidStorageWithdrawFrame)
	B.StripTextures(VoidStorageCostFrame)
	B.StripTextures(VoidStorageStorageFrame)
	VoidStorageFrameMarbleBg:Hide()
	VoidStorageFrameLines:Hide()
	select(2, VoidStorageFrame:GetRegions()):Hide()

	local function reskinIcons(bu, quality)
		if not bu.bg then
			bu:SetPushedTexture(0)
			bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			bu.IconBorder:SetAlpha(0)
			bu.bg = B.CreateBDFrame(bu, .25)
			bu.bg:SetBackdropColor(.3, .3, .3, .3)
			local bg, icon, _, search = bu:GetRegions()
			bg:Hide()
			icon:SetTexCoord(unpack(DB.TexCoord))
			search:SetAllPoints(bu.bg)
		end

		local color = DB.QualityColors[quality or 1]
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
		tab:SetCheckedTexture(DB.textures.pushed)
		tab:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		tab:GetNormalTexture():SetTexCoord(unpack(DB.TexCoord))
		B.CreateBDFrame(tab)
	end

	VoidStorageFrame.Page1:ClearAllPoints()
	VoidStorageFrame.Page1:SetPoint("LEFT", VoidStorageFrame, "TOPRIGHT", 2, -60)

	B.Reskin(VoidStoragePurchaseButton)
	B.Reskin(VoidStorageTransferButton)
	B.ReskinClose(VoidStorageBorderFrame.CloseButton)
	B.ReskinInput(VoidItemSearchBox)
end