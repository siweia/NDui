local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_Transmog"] = function()
	B.ReskinPortraitFrame(TransmogFrame)
	B.ReskinTrimScroll(TransmogFrame.OutfitCollection.OutfitList.ScrollBar)
	B.Reskin(TransmogFrame.OutfitCollection.SaveOutfitButton)
	B.ReskinCheck(TransmogFrame.CharacterPreview.HideIgnoredToggle.Checkbox)

	local TabContent = TransmogFrame.WardrobeCollection.TabContent
	if TabContent then
		B.ReskinEditBox(TabContent.ItemsFrame.SearchBox)
		B.ReskinFilterButton(TabContent.ItemsFrame.FilterButton)
		B.ReskinEditBox(TabContent.SetsFrame.SearchBox)
		B.ReskinFilterButton(TabContent.SetsFrame.FilterButton)
		B.Reskin(TabContent.CustomSetsFrame.NewCustomSetButton)
		B.Reskin(TabContent.SituationsFrame.DefaultsButton)
		B.ReskinCheck(TabContent.SituationsFrame.EnabledToggle.Checkbox)
		B.Reskin(TabContent.SituationsFrame.ApplyButton)

		B.ReskinArrow(TabContent.ItemsFrame.PagedContent.PagingControls.PrevPageButton, "left")
		B.ReskinArrow(TabContent.ItemsFrame.PagedContent.PagingControls.NextPageButton, "right")
		B.ReskinArrow(TabContent.SetsFrame.PagedContent.PagingControls.PrevPageButton, "left")
		B.ReskinArrow(TabContent.SetsFrame.PagedContent.PagingControls.NextPageButton, "right")
		B.ReskinArrow(TabContent.CustomSetsFrame.PagedContent.PagingControls.PrevPageButton, "left")
		B.ReskinArrow(TabContent.CustomSetsFrame.PagedContent.PagingControls.NextPageButton, "right")
	end
end