local F, C = unpack(select(2, ...))

C.themes["Blizzard_BarbershopUI"] = function()
	for i = 1, 3 do
		select(i, BarberShopFrame:GetRegions()):Hide()
	end
	BarberShopFrameMoneyFrame:GetRegions():Hide()
	BarberShopAltFormFrameBackground:Hide()
	BarberShopAltFormFrameBorder:Hide()

	BarberShopAltFormFrame:ClearAllPoints()
	BarberShopAltFormFrame:SetPoint("BOTTOM", BarberShopFrame, "TOP", 0, -74)

	F.SetBD(BarberShopFrame, 44, -75, -40, 44)
	F.SetBD(BarberShopAltFormFrame, 0, 0, 2, -2)

	F.Reskin(BarberShopFrameOkayButton)
	F.Reskin(BarberShopFrameCancelButton)
	F.Reskin(BarberShopFrameResetButton)

	for i = 1, #BarberShopFrame.Selector do 
		local prevBtn, nextBtn = BarberShopFrame.Selector[i]:GetChildren() 
		F.ReskinArrow(prevBtn, "left") 
		F.ReskinArrow(nextBtn, "right") 
	end 

	-- [[ Banner frame ]]

	BarberShopBannerFrameBGTexture:Hide()

	F.SetBD(BarberShopBannerFrame, 25, -80, -20, 75)
end