local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_HousingDashboard"] = function()
	B.ReskinPortraitFrame(HousingDashboardFrame)
	B.Reskin(HousingDashboardFrame.HouseInfoContent.HouseFinderButton)
	B.ReskinDropDown(HousingDashboardFrame.HouseInfoContent.HouseDropdown)
	B.ReskinCheck(HousingDashboardFrame.HouseInfoContent.ContentFrame.HouseUpgradeFrame.WatchFavorButton)
	B.Reskin(HousingDashboardFrame.HouseInfoContent.DashboardNoHousesFrame.NoHouseButton)

	B.ReskinEditBox(HousingDashboardFrame.CatalogContent.SearchBox)
	B.ReskinFilterButton(HousingDashboardFrame.CatalogContent.Filters.FilterDropdown)
	B.ReskinTrimScroll(HousingDashboardFrame.CatalogContent.OptionsContainer.ScrollBar)
end

C.themes["Blizzard_HousingModelPreview"] = function()
	B.StripTextures(HousingModelPreviewFrame)
	B.SetBD(HousingModelPreviewFrame)
	B.ReskinClose(HousingModelPreviewFrame.CloseButton)
end