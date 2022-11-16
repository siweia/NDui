local _, ns = ...
local B, C, L, DB = unpack(ns)

local flyoutFrame

-- [[ Professions ]]

local function reskinSlotButton(button)
	if button and not button.styled then
		button:SetNormalTexture(0)
		button:SetPushedTexture(0)
		button.bg = B.ReskinIcon(button.Icon)
		B.ReskinIconBorder(button.IconBorder, true)
		local hl = button:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetInside(button.bg)
		if button.SlotBackground then
			button.SlotBackground:Hide()
		end

		button.styled = true
	end
end

local function reskinArrowInput(box)
	box:DisableDrawLayer("BACKGROUND")
	B.ReskinEditBox(box)
	B.ReskinArrow(box.DecrementButton, "left")
	B.ReskinArrow(box.IncrementButton, "right")
end

local function reskinQualityContainer(container)
	local button = container.Button
	button:SetNormalTexture(0)
	button:SetPushedTexture(0)
	button:SetHighlightTexture(0)
	button.bg = B.ReskinIcon(button.Icon)
	B.ReskinIconBorder(button.IconBorder, true)
	reskinArrowInput(container.EditBox)
end

local function refreshFlyoutButtons(self)
	for i = 1, self.ScrollTarget:GetNumChildren() do
		local button = select(i, self.ScrollTarget:GetChildren())
		if button.IconBorder and not button.styled then
			button.bg = B.ReskinIcon(button.icon)
			button:SetNormalTexture(0)
			button:SetPushedTexture(0)
			button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			B.ReskinIconBorder(button.IconBorder, true)

			button.styled = true
		end
	end
end

local function reskinFlyouts(flyout)
	if not flyout.styled then
		B.StripTextures(flyout)
		B.SetBD(flyout):SetFrameLevel(2)
		B.ReskinCheck(flyout.HideUnownedCheckBox)
		flyout.HideUnownedCheckBox.bg:SetInside(nil, 6, 6)
		hooksecurefunc(flyout.ScrollBox, "Update", refreshFlyoutButtons)

		flyout.styled = true
	end
end

C.themes["Blizzard_Professions"] = function()
	local frame = ProfessionsFrame
	local craftingPage = ProfessionsFrame.CraftingPage

	B.ReskinPortraitFrame(frame)
	craftingPage.TutorialButton.Ring:Hide()
	B.Reskin(craftingPage.CreateButton)
	B.Reskin(craftingPage.CreateAllButton)
	B.Reskin(craftingPage.ViewGuildCraftersButton)
	reskinArrowInput(craftingPage.CreateMultipleInputBox)

	local guildFrame = craftingPage.GuildFrame
	B.StripTextures(guildFrame)
	B.CreateBDFrame(guildFrame, .25)
	B.StripTextures(guildFrame.Container)
	B.CreateBDFrame(guildFrame.Container, .25)

	for i = 1, 3 do
		local tab = select(i, frame.TabSystem:GetChildren())
		if tab then
			B.ReskinTab(tab)
		end
	end

	-- Tools
	local slots = {"Prof0ToolSlot", "Prof0Gear0Slot", "Prof0Gear1Slot", "Prof1ToolSlot", "Prof1Gear0Slot", "Prof1Gear1Slot",
		"CookingToolSlot", "CookingGear0Slot", "FishingToolSlot", "FishingGear0Slot", "FishingGear1Slot"}
	for _, name in pairs(slots) do
		local button = craftingPage[name]
		if button then
			button.bg = B.ReskinIcon(button.icon)
			B.ReskinIconBorder(button.IconBorder) -- needs review, maybe no quality at all
			button:SetNormalTexture(0)
			button:SetPushedTexture(0)
		end
	end

	local recipeList = craftingPage.RecipeList
	B.StripTextures(recipeList)
	B.ReskinTrimScroll(recipeList.ScrollBar, true)
	if recipeList.BackgroundNineSlice then recipeList.BackgroundNineSlice:Hide() end -- in case blizz rename
	B.CreateBDFrame(recipeList, .25):SetInside()
	B.ReskinEditBox(recipeList.SearchBox)
	B.ReskinFilterButton(recipeList.FilterButton)

	local form = craftingPage.SchematicForm
	B.StripTextures(form)
	form.Background:SetAlpha(0)
	B.CreateBDFrame(form, .25):SetInside()

	local button = form.OutputIcon
	if button then
		button.CircleMask:Hide()
		button.bg = B.ReskinIcon(button.Icon)
		B.ReskinIconBorder(button.IconBorder, nil, true)
		local hl = button:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetInside(button.bg)
	end

	local trackBox = form.TrackRecipeCheckBox
	if trackBox then
		B.ReskinCheck(trackBox)
		trackBox:SetSize(24, 24)
	end

	local checkBox = form.AllocateBestQualityCheckBox
	if checkBox then
		B.ReskinCheck(checkBox)
		checkBox:SetSize(24, 24)
	end

	local qDialog = form.QualityDialog
	if qDialog then
		B.StripTextures(qDialog)
		B.SetBD(qDialog)
		B.ReskinClose(qDialog.ClosePanelButton)
		B.Reskin(qDialog.AcceptButton)
		B.Reskin(qDialog.CancelButton)

		reskinQualityContainer(qDialog.Container1)
		reskinQualityContainer(qDialog.Container2)
		reskinQualityContainer(qDialog.Container3)
	end

	hooksecurefunc(form, "Init", function(self)
		for slot in self.reagentSlotPool:EnumerateActive() do
			reskinSlotButton(slot.Button)
		end

		local slot = form.salvageSlot
		if slot then
			reskinSlotButton(slot.Button)
		end

		local slot = form.enchantSlot
		if slot then
			reskinSlotButton(slot.Button)
		end
		-- todo: salvage flyout, item flyout, recraft flyout
	end)

	local rankBar = craftingPage.RankBar
	rankBar.Border:Hide()
	rankBar.Background:Hide()
	B.CreateBDFrame(rankBar.Fill, 1)

	B.ReskinArrow(craftingPage.LinkButton, "right")
	craftingPage.LinkButton:SetSize(20, 20)
	craftingPage.LinkButton:SetPoint("LEFT", rankBar.Fill, "RIGHT", 3, 0)

	local specPage = frame.SpecPage
	B.Reskin(specPage.UnlockTabButton)
	B.Reskin(specPage.ApplyButton)
	B.StripTextures(specPage.TreeView)
	specPage.TreeView.Background:Hide()
	B.CreateBDFrame(specPage.TreeView, .25):SetInside()

	hooksecurefunc(specPage, "UpdateTabs", function(self)
		for tab in self.tabsPool:EnumerateActive() do
			if not tab.styled then
				tab.styled = true
				B.ReskinTab(tab)
			end
		end
	end)

	local view = specPage.DetailedView
	B.StripTextures(view)
	B.CreateBDFrame(view, .25):SetInside()
	B.Reskin(view.UnlockPathButton)
	B.Reskin(view.SpendPointsButton)
	B.ReskinIcon(view.UnspentPoints.Icon)

	-- log
	local outputLog = craftingPage.CraftingOutputLog
	B.StripTextures(outputLog)
	B.SetBD(outputLog)
	B.ReskinClose(outputLog.ClosePanelButton)
	B.ReskinTrimScroll(outputLog.ScrollBar, true)

	hooksecurefunc(outputLog.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if not child.styled then
				local itemContainer = child.ItemContainer
				if itemContainer then
					local item = itemContainer.Item
					item:SetNormalTexture(0)
					item:SetPushedTexture(0)
					item:SetHighlightTexture(0)

					local icon = item:GetRegions()
					item.bg = B.ReskinIcon(icon)
					B.ReskinIconBorder(item.IconBorder, true)
					itemContainer.CritFrame:SetAlpha(0)
					itemContainer.BorderFrame:Hide()
					itemContainer.HighlightNameFrame:SetAlpha(0)
					itemContainer.PushedNameFrame:SetAlpha(0)
					itemContainer.bg = B.CreateBDFrame(itemContainer.HighlightNameFrame, .25)
				end

				local bonus = child.CreationBonus
				if bonus then
					local item = bonus.Item
					B.StripTextures(item, 1)
					local icon = item:GetRegions()
					B.ReskinIcon(icon)
				end

				child.styled = true
			end

			local itemContainer = child.ItemContainer
			if itemContainer then
				itemContainer.Item.IconBorder:SetAlpha(0)

				local itemBG = itemContainer.bg
				if itemBG then
					if itemContainer.CritFrame:IsShown() then
						itemBG:SetBackdropBorderColor(1, .8, 0)
					else
						itemBG:SetBackdropBorderColor(0, 0, 0)
					end
				end
			end
		end
	end)

	-- Item flyout
	if OpenProfessionsItemFlyout then
		hooksecurefunc("OpenProfessionsItemFlyout", function()
			if flyoutFrame then return end

			for i = 1, frame:GetNumChildren() do
				local child = select(i, frame:GetChildren())
				if child.HideUnownedCheckBox then
					flyoutFrame = child
					reskinFlyouts(flyoutFrame)
					break
				end
			end
		end)
	end

	-- Order page
	if not frame.OrdersPage then return end -- not exists in retail yet

	local browseFrame = frame.OrdersPage.BrowseFrame
	B.Reskin(browseFrame.SearchButton)
	B.Reskin(browseFrame.FavoritesSearchButton)

	local recipeList = browseFrame.RecipeList
	B.StripTextures(recipeList)
	B.ReskinTrimScroll(recipeList.ScrollBar, true)
	if recipeList.BackgroundNineSlice then recipeList.BackgroundNineSlice:Hide() end -- in case blizz rename
	B.CreateBDFrame(recipeList, .25):SetInside()
	B.ReskinEditBox(recipeList.SearchBox)
	B.ReskinFilterButton(recipeList.FilterButton)

	B.ReskinTab(browseFrame.PublicOrdersButton)
	B.ReskinTab(browseFrame.GuildOrdersButton)
	B.ReskinTab(browseFrame.PersonalOrdersButton)
	B.StripTextures(browseFrame.OrdersRemainingDisplay)
	B.CreateBDFrame(browseFrame.OrdersRemainingDisplay, .25)

	local orderList = browseFrame.OrderList
	B.StripTextures(orderList)
	orderList.Background:SetAlpha(0)
	B.CreateBDFrame(orderList, .25):SetInside()

	hooksecurefunc(frame.OrdersPage, "SetupTable", function()
		local maxHeaders = orderList.HeaderContainer:GetNumChildren()
		for i = 1, maxHeaders do
			local header = select(i, orderList.HeaderContainer:GetChildren())
			if not header.styled then
				header:DisableDrawLayer("BACKGROUND")
				header.bg = B.CreateBDFrame(header)
				local hl = header:GetHighlightTexture()
				hl:SetColorTexture(1, 1, 1, .1)
				hl:SetAllPoints(header.bg)
				header.bg:SetPoint("TOPLEFT", 0, -2)
				header.bg:SetPoint("BOTTOMRIGHT", i < maxHeaders and -5 or 0, -2)

				header.styled = true
			end
		end
	end)
end

-- [[ Profession Orders ]]

local function hideCategoryButton(button)
	button.NormalTexture:Hide()
	button.SelectedTexture:SetColorTexture(0, .6, 1, .3)
	button.HighlightTexture:SetColorTexture(1, 1, 1, .1)
end

local function reskinListIcon(frame)
	if not frame.tableBuilder then return end

	for i = 1, 22 do
		local row = frame.tableBuilder.rows[i]
		if row then
			local cell = row.cells and row.cells[1]
			if cell and cell.Icon then
				if not cell.styled then
					cell.Icon.bg = B.ReskinIcon(cell.Icon)
					if cell.IconBorder then cell.IconBorder:Hide() end
					cell.styled = true
				end
				cell.Icon.bg:SetShown(cell.Icon:IsShown())
			end
		end
	end
end

local function reskinListHeader(headerContainer)
	local maxHeaders = headerContainer:GetNumChildren()
	for i = 1, maxHeaders do
		local header = select(i, headerContainer:GetChildren())
		if header and not header.styled then
			header:DisableDrawLayer("BACKGROUND")
			header.bg = B.CreateBDFrame(header)
			local hl = header:GetHighlightTexture()
			hl:SetColorTexture(1, 1, 1, .1)
			hl:SetAllPoints(header.bg)

			header.styled = true
		end

		if header.bg then
			header.bg:SetPoint("BOTTOMRIGHT", i < maxHeaders and -5 or 0, -2)
		end
	end
end

local function reskinBrowseOrders(frame)
	local headerContainer = frame.RecipeList and frame.RecipeList.HeaderContainer
	if headerContainer then
		reskinListHeader(headerContainer)
	end
end

local function reskinMoneyInput(box)
	B.ReskinEditBox(box)
	box.__bg:SetPoint("TOPLEFT", 0, -3)
	box.__bg:SetPoint("BOTTOMRIGHT", 0, 3)
end

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
	B.ReskinTrimScroll(frame.BrowseOrders.CategoryList.ScrollBar, true)

	hooksecurefunc(frame.BrowseOrders.CategoryList.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if child.Text and not child.styled then
				hideCategoryButton(child)
				hooksecurefunc(child, "Init", hideCategoryButton)

				child.styled = true
			end
		end
	end)

	local recipeList = frame.BrowseOrders.RecipeList
	B.StripTextures(recipeList)
	B.CreateBDFrame(recipeList.ScrollBox, .25):SetInside()
	B.ReskinTrimScroll(recipeList.ScrollBar, true)

	hooksecurefunc(frame.BrowseOrders, "SetupTable", reskinBrowseOrders)
	hooksecurefunc(frame.BrowseOrders, "StartSearch", reskinListIcon)

	-- Form
	B.Reskin(frame.Form.BackButton)
	B.ReskinCheck(frame.Form.TrackRecipeCheckBox.Checkbox)
	frame.Form.RecipeHeader:Hide() -- needs review
	B.CreateBDFrame(frame.Form.RecipeHeader, .25)
	B.StripTextures(frame.Form.LeftPanelBackground)
	B.StripTextures(frame.Form.RightPanelBackground)

	local itemButton = frame.Form.OutputIcon
	itemButton.CircleMask:Hide()
	itemButton.bg = B.ReskinIcon(itemButton.Icon)
	B.ReskinIconBorder(itemButton.IconBorder, true, true)

	local hl = itemButton:GetHighlightTexture()
	hl:SetColorTexture(1, 1, 1, .25)
	hl:SetInside(itemButton.bg)

	B.ReskinEditBox(frame.Form.OrderRecipientTarget)
	frame.Form.OrderRecipientTarget.__bg:SetPoint("TOPLEFT", -8, -2)
	frame.Form.OrderRecipientTarget.__bg:SetPoint("BOTTOMRIGHT", 0, 2)

	B.StripTextures(frame.Form.PaymentContainer.NoteEditBox)
	local bg = B.CreateBDFrame(frame.Form.PaymentContainer.NoteEditBox, .25)
	bg:SetPoint("TOPLEFT", 15, 5)
	bg:SetPoint("BOTTOMRIGHT", -18, 0)

	B.ReskinDropDown(frame.Form.OrderRecipientDropDown)
	reskinMoneyInput(frame.Form.PaymentContainer.TipMoneyInputFrame.GoldBox)
	reskinMoneyInput(frame.Form.PaymentContainer.TipMoneyInputFrame.SilverBox)
	B.ReskinDropDown(frame.Form.PaymentContainer.DurationDropDown)
	B.Reskin(frame.Form.PaymentContainer.ListOrderButton)

	local viewButton = frame.Form.PaymentContainer.ViewListingsButton
	viewButton:SetAlpha(0)
	local buttonFrame = CreateFrame("Frame", nil, frame.Form.PaymentContainer)
	buttonFrame:SetInside(viewButton)
	local tex = buttonFrame:CreateTexture(nil, "ARTWORK")
	tex:SetAllPoints()
	tex:SetTexture("Interface\\CURSOR\\Crosshair\\Repair")

	local current = frame.Form.CurrentListings
	B.StripTextures(current)
	B.SetBD(current)
	B.Reskin(current.CloseButton)
	B.ReskinTrimScroll(current.OrderList.ScrollBar, true)
	reskinListHeader(current.OrderList.HeaderContainer)
	B.StripTextures(current.OrderList)
	current:ClearAllPoints()
	current:SetPoint("LEFT", frame, "RIGHT", 10, 0)

	hooksecurefunc(frame.Form, "Init", function(self)
		for slot in self.reagentSlotPool:EnumerateActive() do
			local button = slot.Button		
			if button and not button.styled then
				button:SetNormalTexture(0)
				button:SetPushedTexture(0)
				button.bg = B.ReskinIcon(button.Icon)
				B.ReskinIconBorder(button.IconBorder, true)
				local hl = button:GetHighlightTexture()
				hl:SetColorTexture(1, 1, 1, .25)
				hl:SetInside(button.bg)
				if button.SlotBackground then
					button.SlotBackground:Hide()
				end
		
				button.styled = true
			end
		end
	end)

	-- Item flyout
	if OpenProfessionsItemFlyout then
		hooksecurefunc("OpenProfessionsItemFlyout", function()
			if flyoutFrame then return end

			for i = 1, frame:GetNumChildren() do
				local child = select(i, frame:GetChildren())
				if child.HideUnownedCheckBox then
					flyoutFrame = child
					reskinFlyouts(flyoutFrame)
					break
				end
			end
		end)
	end

	-- Orders
	B.Reskin(frame.MyOrdersPage.RefreshButton)
	frame.MyOrdersPage.RefreshButton.__bg:SetInside(nil, 3, 3)
	reskinListHeader(frame.MyOrdersPage.OrderList.HeaderContainer)
	B.ReskinTrimScroll(frame.MyOrdersPage.OrderList.ScrollBar, true)

	B.StripTextures(frame.MyOrdersPage.OrderList)
	B.CreateBDFrame(frame.MyOrdersPage.OrderList, .25)
end