local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	TaxiFrame:DisableDrawLayer("BORDER")
	TaxiFrame:DisableDrawLayer("OVERLAY")
	TaxiFrame.Bg:Hide()
	TaxiFrame.TitleBg:Hide()
	TaxiFrame.TopTileStreaks:Hide()

	F.SetBD(TaxiFrame, 3, -23, -5, 3)
	F.ReskinClose(TaxiFrame.CloseButton, "TOPRIGHT", TaxiRouteMap, "TOPRIGHT", -6, -6)
end)