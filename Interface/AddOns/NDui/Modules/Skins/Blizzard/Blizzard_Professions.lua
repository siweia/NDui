local _, ns = ...
local B, C, L, DB = unpack(ns)

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

	for i = 1, 2 do
		local tab = select(i, frame.TabSystem:GetChildren())
		B.ReskinTab(tab)
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
	if recipeList.BackgroundNineSlice then recipeList.BackgroundNineSlice:Hide() end -- in cast blizz rename
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
end