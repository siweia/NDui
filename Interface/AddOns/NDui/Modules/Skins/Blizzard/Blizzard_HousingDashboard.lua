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

C.themes["Blizzard_HousingCreateNeighborhood"] = function()
	local guildNeighbor = HousingCreateGuildNeighborhoodFrame
	if guildNeighbor then
		B.StripTextures(guildNeighbor)
		B.SetBD(guildNeighbor)
		B.Reskin(guildNeighbor.ConfirmButton)
		B.Reskin(guildNeighbor.CancelButton)
		B.ReskinEditBox(guildNeighbor.NeighborhoodNameEditBox)
	end

	local confirmFrame = guildNeighbor.ConfirmationFrame
	if confirmFrame then
		B.Reskin(confirmFrame.ConfirmButton)
		B.Reskin(confirmFrame.CancelButton)
	end

	local charterFrame = HousingCreateNeighborhoodCharterFrame
	if charterFrame then
		B.StripTextures(charterFrame)
		B.SetBD(charterFrame)
		B.ReskinEditBox(charterFrame.NeighborhoodNameEditBox)
		B.Reskin(charterFrame.ConfirmButton)
		B.Reskin(charterFrame.CancelButton)
	end
end

C.themes["Blizzard_HousingCharter"] = function()
	local frame = HousingCharterFrame
	if frame then
		B.StripTextures(frame)
		B.SetBD(frame)
		B.Reskin(frame.RequestButton)
		B.Reskin(frame.SettingsButton)
		B.Reskin(frame.CloseButton)
	end
end