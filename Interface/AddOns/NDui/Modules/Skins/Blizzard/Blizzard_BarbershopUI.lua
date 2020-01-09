local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_BarbershopUI"] = function()
	for i = 1, 3 do
		select(i, BarberShopFrame:GetRegions()):Hide()
	end
	BarberShopFrameMoneyFrame:GetRegions():Hide()
	BarberShopAltFormFrameBackground:Hide()
	BarberShopAltFormFrameBorder:Hide()

	BarberShopAltFormFrame:ClearAllPoints()
	BarberShopAltFormFrame:SetPoint("BOTTOM", BarberShopFrame, "TOP", 0, -74)

	B.SetBD(BarberShopFrame, 44, -75, -40, 44)
	B.SetBD(BarberShopAltFormFrame, 0, 0, 2, -2)

	B.Reskin(BarberShopFrameOkayButton)
	B.Reskin(BarberShopFrameCancelButton)
	B.Reskin(BarberShopFrameResetButton)

	for i = 1, #BarberShopFrame.Selector do
		local prevBtn, nextBtn = BarberShopFrame.Selector[i]:GetChildren()
		B.ReskinArrow(prevBtn, "left")
		B.ReskinArrow(nextBtn, "right")
	end

	-- [[ Banner frame ]]

	BarberShopBannerFrameBGTexture:Hide()

	B.SetBD(BarberShopBannerFrame, 25, -80, -20, 75)
end