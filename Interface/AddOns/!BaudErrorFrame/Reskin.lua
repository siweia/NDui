local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
	f:UnregisterEvent("PLAYER_ENTERING_WORLD")
	if IsAddOnLoaded("AuroraClassic") then
		local F = unpack(AuroraClassic)
		F.ReskinScroll(BaudErrorFrameListScrollBoxScrollBarScrollBar)
		F.ReskinScroll(BaudErrorFrameDetailScrollFrameScrollBar)
	end
	if IsAddOnLoaded("NDui") then
		local B = unpack(NDui)
		B.CreateBD(BaudErrorFrame)
		B.CreateSD(BaudErrorFrame)
		B.CreateTex(BaudErrorFrame)
		B.StripTextures(BaudErrorFrameDetailScrollBox)
		local BG2 = CreateFrame("Frame", nil, BaudErrorFrame)
		BG2:SetPoint("CENTER", BaudErrorFrame, "CENTER", 0, -81)
		BG2:SetSize(BaudErrorFrameEditBox:GetWidth() + 56, BaudErrorFrameEditBox:GetHeight() + 10)
		B.CreateBD(BG2)
		for _, button in next, {BaudErrorFrameClearButton, BaudErrorFrameCloseButton, BaudErrorFrameReloadUIButton} do
			B.CreateBD(button)
			B.CreateBC(button)
		end
	end
end)