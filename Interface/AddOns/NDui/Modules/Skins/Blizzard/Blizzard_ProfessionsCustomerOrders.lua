local _, ns = ...
local B, C, L, DB = unpack(ns)

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

local function reskinContainer(container)
	local button = container.Button
	button.bg = B.ReskinIcon(button.Icon)
	B.ReskinIconBorder(button.IconBorder)
	button:SetNormalTexture(0)
	button:SetPushedTexture(0)
	button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

	local box = container.EditBox
	box:DisableDrawLayer("BACKGROUND")
	B.ReskinEditBox(box)
	B.ReskinArrow(box.DecrementButton, "left")
	B.ReskinArrow(box.IncrementButton, "right")
end

local function reskinOrderIcon(child)
	if child.styled then return end

	local button = child:GetChildren()
	if button and button.IconBorder then
		button.bg = B.ReskinIcon(button.Icon)
		B.ReskinIconBorder(button.IconBorder)
	end
	child.styled = true
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
	B.ReskinTrimScroll(frame.BrowseOrders.CategoryList.ScrollBar)

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
	B.ReskinTrimScroll(recipeList.ScrollBar)

	hooksecurefunc(frame.BrowseOrders, "SetupTable", reskinBrowseOrders)
	hooksecurefunc(frame.BrowseOrders, "StartSearch", reskinListIcon)

	-- Form
	B.Reskin(frame.Form.BackButton)
	B.ReskinCheck(frame.Form.AllocateBestQualityCheckBox)
	B.ReskinCheck(frame.Form.TrackRecipeCheckBox.Checkbox)
	frame.Form.RecipeHeader:Hide()
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
	B.ReskinDropDown(frame.Form.OrderRecipientDropDown)
	B.ReskinDropDown(frame.Form.MinimumQuality.DropDown)

	local paymentContainer = frame.Form.PaymentContainer
	B.StripTextures(paymentContainer.NoteEditBox)
	local bg = B.CreateBDFrame(paymentContainer.NoteEditBox, .25)
	bg:SetPoint("TOPLEFT", 15, 5)
	bg:SetPoint("BOTTOMRIGHT", -18, 0)

	reskinMoneyInput(paymentContainer.TipMoneyInputFrame.GoldBox)
	reskinMoneyInput(paymentContainer.TipMoneyInputFrame.SilverBox)
	B.ReskinDropDown(paymentContainer.DurationDropDown)
	B.Reskin(paymentContainer.ListOrderButton)
	B.Reskin(paymentContainer.CancelOrderButton)

	local viewButton = paymentContainer.ViewListingsButton
	viewButton:SetAlpha(0)
	local buttonFrame = CreateFrame("Frame", nil, paymentContainer)
	buttonFrame:SetInside(viewButton)
	local tex = buttonFrame:CreateTexture(nil, "ARTWORK")
	tex:SetAllPoints()
	tex:SetTexture("Interface\\CURSOR\\Crosshair\\Repair")

	local current = frame.Form.CurrentListings
	B.StripTextures(current)
	B.SetBD(current)
	B.Reskin(current.CloseButton)
	B.ReskinTrimScroll(current.OrderList.ScrollBar)
	reskinListHeader(current.OrderList.HeaderContainer)
	B.StripTextures(current.OrderList)
	current:ClearAllPoints()
	current:SetPoint("LEFT", frame, "RIGHT", 10, 0)

	hooksecurefunc(frame.Form, "UpdateReagentSlots", function(self)
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
				B.ReskinCheck(slot.Checkbox)
				button.HighlightTexture:SetColorTexture(1, .8, 0, .5)
				button.HighlightTexture:SetInside(button.bg)

				button.styled = true
			end
		end
	end)

	local qualityDialog = frame.Form.QualityDialog
	B.StripTextures(qualityDialog)
	B.SetBD(qualityDialog)
	B.ReskinClose(qualityDialog.ClosePanelButton)
	B.Reskin(qualityDialog.AcceptButton)
	B.Reskin(qualityDialog.CancelButton)
	for i = 1, 3 do
		reskinContainer(qualityDialog["Container"..i])
	end

	-- Orders
	B.Reskin(frame.MyOrdersPage.RefreshButton)
	frame.MyOrdersPage.RefreshButton.__bg:SetInside(nil, 3, 3)
	B.StripTextures(frame.MyOrdersPage.OrderList)
	B.CreateBDFrame(frame.MyOrdersPage.OrderList, .25)
	reskinListHeader(frame.MyOrdersPage.OrderList.HeaderContainer)
	B.ReskinTrimScroll(frame.MyOrdersPage.OrderList.ScrollBar)

	hooksecurefunc(frame.MyOrdersPage.OrderList.ScrollBox, "Update", function(self)
		self:ForEachFrame(reskinOrderIcon)
	end)
end