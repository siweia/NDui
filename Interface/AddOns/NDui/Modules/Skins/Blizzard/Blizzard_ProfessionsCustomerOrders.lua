local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_ProfessionsCustomerOrders"] = function()
	local frame = _G.ProfessionsCustomerOrdersFrame

	B.ReskinPortraitFrame(frame)
	for i = 1, 2 do
		B.ReskinTab(frame.Tabs[i])
	end
	B.StripTextures(frame.MoneyFrameBorder)
	B.CreateBDFrame(frame.MoneyFrameBorder, .25)
	B.StripTextures(frame.MoneyFrameInset)

	local searchBar = frame.BrowseOrders.SearchBar
	B.Reskin(searchBar.FavoritesSearchButton)
	searchBar.FavoritesSearchButton:SetSize(22, 22)
	B.ReskinEditBox(searchBar.SearchBox)
	B.Reskin(searchBar.SearchButton)

	local filterButton = searchBar.FilterButton
	B.ReskinFilterButton(filterButton)
	B.ReskinFilterReset(filterButton.ClearFiltersButton)

	B.StripTextures(frame.BrowseOrders.CategoryList)
	B.ReskinTrimScroll(frame.BrowseOrders.CategoryList.ScrollBar)
end