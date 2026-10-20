local _, ns = ...
local B, C, L, DB = unpack(ns)

local flyoutFrame

local function reskinFlyoutButton(button)
	if not button.styled then
		button.bg = B.ReskinIcon(button.Icon)
		button:SetNormalTexture(0)
		button:SetPushedTexture(0)
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		button:GetHighlightTexture():SetInside(button.bg)
		button.SlotBackground:SetAlpha(0)
		B.ReskinIconBorder(button.IconBorder, true, true)

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

local function ReskinProfessionsFlyout(_, parent)
	if flyoutFrame then return end

	for i = 1, parent:GetNumChildren() do
		local child = select(i, parent:GetChildren())
		local checkbox = child.HideUnownedCheckbox
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
			refreshFlyoutButtons(flyoutFrame.ScrollBox)

			break
		end
	end
end

C.themes["Blizzard_ProfessionsTemplates"] = function()
	if OpenProfessionsItemFlyout then
		hooksecurefunc("OpenProfessionsItemFlyout", ReskinProfessionsFlyout)
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
		B.ReskinIconBorder(button.IconBorder, true, true)
		if button.SlotBackground then
			button.SlotBackground:SetAlpha(0)
		end
		if button.CropFrame then button.CropFrame:SetAlpha(0) end
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

local function reskinReagentSlots(form)
	for slot in form.reagentSlotPool:EnumerateActive() do
		reskinSlotButton(slot.Button)
		if slot.Checkbox and not slot.Checkbox.styled then
			B.ReskinCheck(slot.Checkbox)
			slot.Checkbox.styled = true
		end
	end
	if form.salvageSlot then reskinSlotButton(form.salvageSlot.Button) end
	if form.enchantSlot then reskinSlotButton(form.enchantSlot.Button) end
end

local function reskinStatusBar(bar)
	B.StripTextures(bar)
	bar:SetStatusBarTexture(DB.normTex)
	B.CreateBDFrame(bar, .25)
end

local function reskinProfessionForm(form)
	local button = form.OutputIcon
	if button then
		button.CircleMask:Hide()
		button.Icon:RemoveMaskTexture(button.CircleMask)
		button.CountShadow:SetAlpha(0)
		button.bg = B.ReskinIcon(button.Icon)
		B.ReskinIconBorder(button.IconBorder, nil, true)
		local hl = button:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetInside(button.bg)
	end

	local trackBox = form.TrackRecipeCheckbox
	if trackBox then
		B.ReskinCheck(trackBox)
		trackBox:SetSize(24, 24)
	end

	local checkBox = form.AllocateBestQualityCheckbox
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

	hooksecurefunc(form, "Init", reskinReagentSlots)
	reskinReagentSlots(form)
	if form.RecipeLevelBar then reskinStatusBar(form.RecipeLevelBar) end
	if form.RecipeLevelDropdown then B.ReskinDropDown(form.RecipeLevelDropdown) end
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

				item.bg = B.ReskinIcon(item.icon)
				B.ReskinIconBorder(item.IconBorder, true)
				itemContainer.NameFrame:SetAlpha(0)
				itemContainer.CritFrame:SetAlpha(0)
				itemContainer.BorderFrame:Hide()
				itemContainer.HighlightNameFrame:SetAlpha(0)
				itemContainer.PushedNameFrame:SetAlpha(0)
				itemContainer.bg = B.CreateBDFrame(itemContainer.HighlightNameFrame, .25)
			end

			local bonus = child.Multicraft
			if bonus then
				local item = bonus.Item
				item:SetNormalTexture(0)
				item:SetPushedTexture(0)
				item.bg = B.ReskinIcon(item.icon)
				B.ReskinIconBorder(item.IconBorder, true)
			end

			child.styled = true
		end
		if child.itemButtonPool then
			for button in child.itemButtonPool:EnumerateActive() do
				reskinFlyoutButton(button)
			end
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
	reskinOutputButtons(outputLog.ScrollBox)
end

local function updateRankBar(rankBar)
	-- Keep Blizzard's mask and progress interpolation, but replace the animated fill.
	rankBar.BarAnimation:Stop()
	rankBar.FlareFadeOut:Stop()
	rankBar.Flare:SetAlpha(0)
	rankBar.Fill:SetTexture(DB.normTex)
	rankBar.Fill:SetTexCoord(0, 1, 0, 1)
	rankBar.Fill:SetVertexColor(0, .7, 0)
end

function B:ReskinProfessionsRankBar()
	self.Border:SetAlpha(0)
	self.Background:SetAlpha(0)
	self.Rank.Text:SetFontObject(Game12Font)
	-- Book bars inherit a full-size fill even when their mask is much narrower.
	self.Fill:SetWidth(math.min(self.Fill:GetWidth(), self:GetMaskWidth(1)))
	B.CreateBDFrame(self.Fill, .25)
	B.ReskinArrow(self.ExpansionDropdownButton, "down")
	hooksecurefunc(self, "Update", updateRankBar)
	updateRankBar(self)
end

local function updateSideTabIcon(tab)
	tab.Icon:SetSize(36, 36)
	tab.Icon:SetTexCoord(unpack(DB.TexCoord))
end

local function reskinSideTab(tab)
	tab.Background:SetAlpha(0)
	tab.Icon:RemoveMaskTexture(tab.Mask)
	tab.bg = B.ReskinIcon(tab.Icon, true)
	tab.SelectedTexture:SetColorTexture(DB.r, DB.g, DB.b, .35)
	tab.SelectedTexture:SetAllPoints(tab.Icon)
	tab.HighlightTexture:SetColorTexture(1, 1, 1, .25)
	tab.HighlightTexture:SetAllPoints(tab.Icon)
	tab.TabGlow:SetColorTexture(DB.r, DB.g, DB.b, .35)
	tab.TabGlow:SetAllPoints(tab.Icon)
	hooksecurefunc(tab, "UpdateIconInterior", updateSideTabIcon)
	updateSideTabIcon(tab)
end

local function reskinRecipeListButtons(self)
	for i = 1, self.ScrollTarget:GetNumChildren() do
		local button = select(i, self.ScrollTarget:GetChildren())
		if not button.styled then
			if button.SelectedOverlay then
				button.SelectedOverlay:SetColorTexture(DB.r, DB.g, DB.b, .25)
				button.SelectedOverlay:SetAllPoints()
				button.HighlightOverlay:SetColorTexture(1, 1, 1, .1)
				button.HighlightOverlay:SetAllPoints()
				button.styled = true
			elseif button.CollapseButton then
				B.Reskin(button)
				button.__bg:SetInside(nil, 0, 2)
				reskinStatusBar(button.RankBar)
				button.styled = true
			end
		end
	end
end

C.themes["Blizzard_Professions"] = function()
	local frame = ProfessionsFrame
	local craftingPage = frame.CraftingPage

	B.ReskinPortraitFrame(frame)
	frame.Bg:SetAlpha(0)
	B.StripTextures(craftingPage)
	craftingPage.TutorialButton.Ring:Hide()
	B.Reskin(craftingPage.CreateButton)
	B.Reskin(craftingPage.CreateAllButton)
	B.Reskin(craftingPage.ViewGuildCraftersButton)
	reskinArrowInput(craftingPage.CreateMultipleInputBox)
	B.ReskinEditBox(craftingPage.MinimizedSearchBox)
	B.ReskinIcon(craftingPage.ConcentrationDisplay.Icon)

	reskinSideTab(frame.ProfessionsOverviewTab)
	for _, tab in ipairs(frame.rightProfessionTabs) do
		reskinSideTab(tab)
	end
	-- The book addon only provides templates; Camelot creates its page in this window.
	B.ReskinProfessionsBook(frame.BookPage)

	local guildFrame = craftingPage.GuildFrame
	B.StripTextures(guildFrame)
	B.CreateBDFrame(guildFrame, .25)
	B.StripTextures(guildFrame.Container)
	B.CreateBDFrame(guildFrame.Container, .25)
	B.ReskinTrimScroll(guildFrame.Container.ScrollBar)

	for _, button in ipairs(craftingPage.InventorySlots) do
		button.bg = B.ReskinIcon(button.icon)
		B.ReskinIconBorder(button.IconBorder)
		button:SetNormalTexture(0)
		button:SetPushedTexture(0)
	end

	local recipeList = craftingPage.RecipeList
	B.StripTextures(recipeList)
	B.ReskinTrimScroll(recipeList.ScrollBar)
	B.CreateBDFrame(recipeList, .25):SetInside()
	B.ReskinEditBox(recipeList.SearchBox)
	B.ReskinFilterButton(recipeList.FilterDropdown)
	hooksecurefunc(recipeList.ScrollBox, "Update", reskinRecipeListButtons)
	reskinRecipeListButtons(recipeList.ScrollBox)

	local searchResults = craftingPage.MinimizedSearchResults
	B.ReskinPortraitFrame(searchResults)
	B.ReskinTrimScroll(searchResults.ScrollBar)

	local form = craftingPage.SchematicForm
	B.StripTextures(form)
	form.Background:SetAlpha(0)
	form.MinimalBackground:SetAlpha(0)
	B.CreateBDFrame(form, .25):SetInside()
	reskinProfessionForm(form)

	B.ReskinProfessionsRankBar(craftingPage.RankBar)
	craftingPage.LinkButton.Background:SetAlpha(0)
	B.Reskin(craftingPage.LinkButton)
	reskinOutputLog(craftingPage.CraftingOutputLog)

	local inspectFrame = InspectRecipeFrame
	if inspectFrame then
		B.ReskinPortraitFrame(inspectFrame)
		local inspectForm = inspectFrame.SchematicForm
		B.StripTextures(inspectForm)
		if inspectForm.MinimalBackground then inspectForm.MinimalBackground:SetAlpha(0) end
		B.CreateBDFrame(inspectForm, .25):SetInside()
		reskinProfessionForm(inspectForm)
	end
end
