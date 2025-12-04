local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_HousingDashboard"] = function()
	B.ReskinPortraitFrame(HousingDashboardFrame)
	B.Reskin(HousingDashboardFrame.HouseInfoContent.HouseFinderButton)
	B.ReskinDropDown(HousingDashboardFrame.HouseInfoContent.HouseDropdown)
	B.ReskinCheck(HousingDashboardFrame.HouseInfoContent.ContentFrame.HouseUpgradeFrame.WatchFavorButton)

	B.ReskinEditBox(HousingDashboardFrame.CatalogContent.SearchBox)
	B.ReskinFilterButton(HousingDashboardFrame.CatalogContent.Filters.FilterDropdown)
	B.ReskinTrimScroll(HousingDashboardFrame.CatalogContent.OptionsContainer.ScrollBar)
end