local _, ns = ...
local B, C, L, DB = unpack(ns)

local flyoutFrame

local function reskinFlyoutButton(button)
	if not button.styled then
		button.bg = B.ReskinIcon(button.icon)
		button:SetNormalTexture(0)
		button:SetPushedTexture(0)
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		B.ReskinIconBorder(button.IconBorder, true)

		button.styled = true
	end
end

local function refreshFlyoutButtons(self)
	for i = 1, self.ScrollTarget:GetNumChildren() do
		local button = select(i, self.ScrollTarget:GetChildren())
		if button.IconBorder then
			reskinFlyoutButton(button)
		end
	end
end

local function resetFrameStrata(frame)
	frame.bg:SetFrameStrata("LOW")
end

function B:ReskinProfessionsFlyout(parent)
	if flyoutFrame then return end

	for i = 1, parent:GetNumChildren() do
		local child = select(i, parent:GetChildren())
		local checkbox = child.HideUnownedCheckBox or child.HideUnownedCheckbox -- isWW
		if checkbox then
			flyoutFrame = child

			B.StripTextures(flyoutFrame)
			flyoutFrame.bg = B.SetBD(flyoutFrame)
			hooksecurefunc(flyoutFrame, "SetParent", resetFrameStrata)
			B.ReskinCheck(checkbox)
			checkbox.bg:SetInside(nil, 6, 6)
			B.ReskinTrimScroll(flyoutFrame.ScrollBar)
			reskinFlyoutButton(flyoutFrame.UndoItem)
			hooksecurefunc(flyoutFrame.ScrollBox, "Update", refreshFlyoutButtons)

			break
		end
	end
end

local function resetButton(button)
	button:SetNormalTexture(0)
	button:SetPushedTexture(0)
	local hl = button:GetHighlightTexture()
	hl:SetColorTexture(1, 1, 1, .25)
	hl:SetInside(button.bg)
end

local function reskinSlotButton(button)
	if button and not button.styled then
		button.bg = B.ReskinIcon(button.Icon)
		B.ReskinIconBorder(button.IconBorder, true)
		if button.SlotBackground then
			button.SlotBackground:Hide()
		end
		resetButton(button)
		hooksecurefunc(button, "Update", resetButton)

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

local function reskinProfessionForm(form)
	local button = form.OutputIcon
	if button then
		button.CircleMask:Hide()
		button.bg = B.ReskinIcon(button.Icon)
		B.ReskinIconBorder(button.IconBorder, nil, true)
		local hl = button:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetInside(button.bg)
	end

	local trackBox = form.TrackRecipeCheckBox or form.TrackRecipeCheckbox --isWW
	if trackBox then
		B.ReskinCheck(trackBox)
		trackBox:SetSize(24, 24)
	end

	local checkBox = form.AllocateBestQualityCheckBox or form.AllocateBestQualityCheckbox --isWW
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
end

local function reskinOutputButtons(self)
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
end

local function reskinOutputLog(outputLog)
	B.StripTextures(outputLog)
	B.SetBD(outputLog)
	B.ReskinClose(outputLog.ClosePanelButton)
	B.ReskinTrimScroll(outputLog.ScrollBar)
	hooksecurefunc(outputLog.ScrollBox, "Update", reskinOutputButtons)
end

local function reskinRankBar(rankBar)
	rankBar.Border:Hide()
	rankBar.Background:Hide()
	rankBar.Rank.Text:SetFontObject(Game12Font)
	B.CreateBDFrame(rankBar.Fill, 1)
	if DB.isWW then
		B.ReskinArrow(rankBar.ExpansionDropdownButton, "down")
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
	B.ReskinMinMax(frame.MaximizeMinimize)
	if DB.isWW then
		B.ReskinEditBox(craftingPage.MinimizedSearchBox)
		B.ReskinIcon(craftingPage.ConcentrationDisplay.Icon)
	end

	local guildFrame = craftingPage.GuildFrame
	B.StripTextures(guildFrame)
	B.CreateBDFrame(guildFrame, .25)
	B.StripTextures(guildFrame.Container)
	B.CreateBDFrame(guildFrame.Container, .25)
	B.ReskinTrimScroll(guildFrame.Container.ScrollBar)

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
			B.ReskinIconBorder(button.IconBorder)
			button:SetNormalTexture(0)
			button:SetPushedTexture(0)
		end
	end

	local recipeList = craftingPage.RecipeList
	B.StripTextures(recipeList)
	B.ReskinTrimScroll(recipeList.ScrollBar)
	if recipeList.BackgroundNineSlice then recipeList.BackgroundNineSlice:Hide() end -- in case blizz rename
	B.CreateBDFrame(recipeList, .25):SetInside()
	B.ReskinEditBox(recipeList.SearchBox)
	if DB.isWW then
		B.ReskinFilterButton(recipeList.FilterDropdown)
	else
		B.ReskinFilterButton(recipeList.FilterButton)
	end

	local form = craftingPage.SchematicForm
	B.StripTextures(form)
	form.Background:SetAlpha(0)
	B.CreateBDFrame(form, .25):SetInside()
	reskinProfessionForm(form)
	form.MinimalBackground:SetAlpha(0)

	local rankBar = craftingPage.RankBar
	reskinRankBar(rankBar)

	B.ReskinArrow(craftingPage.LinkButton, "right")
	craftingPage.LinkButton:SetSize(20, 20)
	craftingPage.LinkButton:SetPoint("LEFT", rankBar.Fill, "RIGHT", 3, 0)

	local specPage = frame.SpecPage
	B.Reskin(specPage.UnlockTabButton)
	B.Reskin(specPage.ApplyButton)
	B.Reskin(specPage.ViewTreeButton)
	B.Reskin(specPage.BackToFullTreeButton)
	B.Reskin(specPage.ViewPreviewButton)
	B.Reskin(specPage.BackToPreviewButton)
	specPage.TopDivider:Hide()
	specPage.VerticalDivider:Hide()
	specPage.PanelFooter:Hide()
	B.StripTextures(specPage.TreeView)
	specPage.TreeView.Background:Hide()
	local treeViewBG = B.CreateBDFrame(specPage.TreeView, .25)
	treeViewBG:SetInside()

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
	local detailedViewBG = B.CreateBDFrame(view, .25)
	detailedViewBG:SetInside()
	B.Reskin(view.UnlockPathButton)
	B.Reskin(view.SpendPointsButton)
	B.ReskinIcon(view.UnspentPoints.Icon)

	treeViewBG:SetPoint("BOTTOMRIGHT", detailedViewBG, "BOTTOMLEFT", -3, 0)

	-- log
	reskinOutputLog(craftingPage.CraftingOutputLog)

	-- Item flyout
	if OpenProfessionsItemFlyout then
		hooksecurefunc("OpenProfessionsItemFlyout", B.ReskinProfessionsFlyout)
	end

	-- Order page
	if not frame.OrdersPage then return end -- not exists in retail yet

	local browseFrame = frame.OrdersPage.BrowseFrame
	B.Reskin(browseFrame.SearchButton)
	B.Reskin(browseFrame.FavoritesSearchButton)
	browseFrame.FavoritesSearchButton:SetSize(22, 22)

	local recipeList = browseFrame.RecipeList
	B.StripTextures(recipeList)
	B.ReskinTrimScroll(recipeList.ScrollBar)
	if recipeList.BackgroundNineSlice then recipeList.BackgroundNineSlice:Hide() end -- in case blizz rename
	B.CreateBDFrame(recipeList, .25):SetInside()
	B.ReskinEditBox(recipeList.SearchBox)
	if DB.isWW then
		B.ReskinFilterButton(recipeList.FilterDropdown)
	else
		B.ReskinFilterButton(recipeList.FilterButton)
	end

	B.ReskinTab(browseFrame.PublicOrdersButton)
	B.ReskinTab(browseFrame.GuildOrdersButton)
	B.ReskinTab(browseFrame.PersonalOrdersButton)
	if DB.isWW then
		B.ReskinTab(browseFrame.NpcOrdersButton)
	end
	B.StripTextures(browseFrame.OrdersRemainingDisplay)
	B.CreateBDFrame(browseFrame.OrdersRemainingDisplay, .25)

	local orderList = browseFrame.OrderList
	B.StripTextures(orderList)
	orderList.Background:SetAlpha(0)
	B.CreateBDFrame(orderList, .25):SetInside()
	B.ReskinTrimScroll(orderList.ScrollBar)

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
	frame.OrdersPage:SetupTable() -- init header

	local orderView = frame.OrdersPage.OrderView
	B.Reskin(orderView.CreateButton)
	B.Reskin(orderView.StartRecraftButton)
	B.Reskin(orderView.StopRecraftButton)
	B.Reskin(orderView.CompleteOrderButton)
	reskinOutputLog(orderView.CraftingOutputLog)
	reskinRankBar(orderView.RankBar)

	local orderInfo = orderView.OrderInfo
	B.StripTextures(orderInfo)
	B.CreateBDFrame(orderInfo, .25):SetInside()
	B.Reskin(orderInfo.BackButton)
	B.Reskin(orderInfo.StartOrderButton)
	B.Reskin(orderInfo.DeclineOrderButton)
	B.Reskin(orderInfo.ReleaseOrderButton)
	B.StripTextures(orderInfo.NoteBox)
	B.CreateBDFrame(orderInfo.NoteBox, .25)

	local orderDetails = orderView.OrderDetails
	B.StripTextures(orderDetails)
	orderDetails.Background:SetAlpha(0)
	B.CreateBDFrame(orderDetails, .25):SetInside()
	reskinProfessionForm(orderDetails.SchematicForm)

	B.StripTextures(orderDetails.FulfillmentForm.NoteEditBox)
	B.CreateBDFrame(orderDetails.FulfillmentForm.NoteEditBox, .25)

	if DB.isWW then
		B.ReskinIcon(orderView.ConcentrationDisplay.Icon)

		local rewardsFrame = orderInfo.NPCRewardsFrame
		if rewardsFrame then
			rewardsFrame.Background:Hide()
			B.CreateBDFrame(rewardsFrame.Background, .25)
	
			local function handleRewardButton(button)
				if not button then return end
				B.StripTextures(button)
				button.bg = B.ReskinIcon(button.Icon)
				B.ReskinIconBorder(button.IconBorder, true)
			end
			handleRewardButton(rewardsFrame.RewardItem1)
			handleRewardButton(rewardsFrame.RewardItem2)
		end
	end

	-- InspectRecipeFrame
	local inspectFrame = InspectRecipeFrame
	if inspectFrame then
		B.ReskinPortraitFrame(inspectFrame)

		local form = inspectFrame.SchematicForm
		reskinProfessionForm(form)
		form.MinimalBackground:SetAlpha(0)
		B.CreateBDFrame(form, .25):SetInside()
	end
end