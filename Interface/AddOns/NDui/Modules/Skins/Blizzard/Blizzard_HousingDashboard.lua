local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_HousingDashboard"] = function()
	B.ReskinPortraitFrame(HousingDashboardFrame)
	B.ReskinDropDown(HousingDashboardFrame.HouseDropdown.Dropdown)
	B.ReskinTrimScroll(HousingDashboardFrame.CollectionContent.BlueprintCollection.ScrollBar)

	for _, tab in ipairs(HousingDashboardFrame.TabButtons) do
		B.ReskinSideTab(tab)
	end

	local catalogContent = HousingDashboardFrame.CatalogContent
	if catalogContent then
		B.ReskinEditBox(catalogContent.SearchBox, 22)
		B.ReskinFilterButton(catalogContent.Filters.FilterDropdown)
		B.ReskinTrimScroll(catalogContent.OptionsContainer.ScrollBar)
	end

	local infoContent = HousingDashboardFrame.HouseInfoContent
	if infoContent then
		B.Reskin(infoContent.HouseFinderButton)
		B.Reskin(infoContent.DashboardNoHousesFrame.NoHouseButton)
		B.ReskinCheck(infoContent.ContentFrame.HouseUpgradeFrame.WatchFavorButton)

		hooksecurefunc(infoContent.ContentFrame, "UpdateTabs", function(frame)
			for _, tab in pairs({frame.TabSystem:GetChildren()}) do
				if not tab.bg then
					B.ReskinTab(tab)
				end
			end
		end)
	end
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

C.themes["Blizzard_HousingCornerstone"] = function()
	local frame = HousingCornerstonePurchaseFrame
	if frame then
		B.StripTextures(frame)
		B.SetBD(frame)
		B.Reskin(frame.BuyButton)
		B.ReskinClose(frame.CloseButton)
		B.StripTextures(frame.MoneyFrameBackdrop)
		B.CreateBDFrame(frame.MoneyFrameBackdrop, .25)
	end

	local frame = HousingCornerstoneVisitorFrame
	if frame then
		B.StripTextures(frame)
		B.SetBD(frame)
		B.ReskinClose(frame.CloseButton)
	end
end