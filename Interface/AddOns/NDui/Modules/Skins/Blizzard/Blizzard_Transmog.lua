local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_Transmog"] = function()
	B.ReskinPortraitFrame(TransmogFrame)

	B.StripTextures(TransmogFrame.OutfitCollection)
	B.ReskinTrimScroll(TransmogFrame.OutfitCollection.OutfitList.ScrollBar)
	B.Reskin(TransmogFrame.OutfitCollection.SaveOutfitButton)
	B.Reskin(TransmogFrame.OutfitCollection.PurchaseOutfitButton)
	B.StripTextures(TransmogFrame.OutfitCollection.MoneyFrame)
	B.CreateBDFrame(TransmogFrame.OutfitCollection.MoneyFrame, .25)

	B.ReskinIconSelector(TransmogFrame.OutfitPopup)
	B.StripTextures(TransmogFrame.CharacterPreview)
	B.CreateBDFrame(TransmogFrame.CharacterPreview, .25):SetInside()
	TransmogFrame.CharacterPreview.Gradients:Hide()
	B.ReskinCheck(TransmogFrame.CharacterPreview.HideIgnoredToggle.Checkbox)
	B.Reskin(TransmogFrame.CharacterPreview.ClearAllPendingButton)

	B.StripTextures(TransmogFrame.WardrobeCollection)
	for _, tab in pairs(TransmogFrame.WardrobeCollection.TabHeaders.tabs) do
		if tab then
			B.ReskinTab(tab)
		end
	end

	local TabContent = TransmogFrame.WardrobeCollection.TabContent
	if TabContent then
		B.StripTextures(TabContent)
		B.ReskinEditBox(TabContent.ItemsFrame.SearchBox)
		B.ReskinFilterButton(TabContent.ItemsFrame.FilterButton)
		B.ReskinDropDown(TabContent.ItemsFrame.WeaponDropdown)
		B.ReskinEditBox(TabContent.SetsFrame.SearchBox)
		B.ReskinFilterButton(TabContent.SetsFrame.FilterButton)
		B.Reskin(TabContent.CustomSetsFrame.NewCustomSetButton)
		B.Reskin(TabContent.SituationsFrame.DefaultsButton)
		B.ReskinCheck(TabContent.SituationsFrame.EnabledToggle.Checkbox)
		B.Reskin(TabContent.SituationsFrame.ApplyButton)

		hooksecurefunc(TabContent.SituationsFrame, "Init", function(pool)
			for frame in TabContent.SituationsFrame.SituationFramePool:EnumerateActive() do
				if not frame.styled then
					if frame.Dropdown then
						B.ReskinDropDown(frame.Dropdown)
					end
					frame.styled = true
				end
			end
		end)

		B.ReskinArrow(TabContent.ItemsFrame.PagedContent.PagingControls.PrevPageButton, "left")
		B.ReskinArrow(TabContent.ItemsFrame.PagedContent.PagingControls.NextPageButton, "right")
		B.ReskinArrow(TabContent.SetsFrame.PagedContent.PagingControls.PrevPageButton, "left")
		B.ReskinArrow(TabContent.SetsFrame.PagedContent.PagingControls.NextPageButton, "right")
		B.ReskinArrow(TabContent.CustomSetsFrame.PagedContent.PagingControls.PrevPageButton, "left")
		B.ReskinArrow(TabContent.CustomSetsFrame.PagedContent.PagingControls.NextPageButton, "right")
	end
end