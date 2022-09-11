local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_Professions"] = function()
	local frame = ProfessionsFrame
	local craftingPage = ProfessionsFrame.CraftingPage

	B.ReskinPortraitFrame(frame)
	craftingPage.TutorialButton.Ring:Hide()
	B.Reskin(craftingPage.CreateButton)
	B.Reskin(craftingPage.CreateAllButton)

	local multiBox = craftingPage.CreateMultipleInputBox
	multiBox:DisableDrawLayer("BACKGROUND")
	B.ReskinEditBox(multiBox)
	B.ReskinArrow(multiBox.DecrementButton, "left")
	B.ReskinArrow(multiBox.IncrementButton, "right")

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
			button:SetNormalTexture(DB.blankTex)
			button:SetPushedTexture(DB.blankTex)
		end
	end

	local recipeList = craftingPage.RecipeList
	B.StripTextures(recipeList)
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

	hooksecurefunc(form, "Init", function(self)
		for slot in self.reagentSlotPool:EnumerateActive() do
			local button = slot.Button
			if button and not button.styled then
				button:SetNormalTexture(DB.blankTex)
				button:SetPushedTexture(DB.blankTex)
				button.bg = B.ReskinIcon(button.Icon)
				B.ReskinIconBorder(button.IconBorder, true)
				local hl = button:GetHighlightTexture()
				hl:SetColorTexture(1, 1, 1, .25)
				hl:SetInside(button.bg)

				button.styled = true
			end
		end
	end)

	local rankBar = craftingPage.RankBar
	rankBar.Mask:Hide()
	rankBar.Border:Hide()
	rankBar.Background:Hide()
	B.CreateBDFrame(rankBar.Fill, 1)

	B.ReskinArrow(craftingPage.LinkButton, "right")
	craftingPage.LinkButton:SetSize(20, 20)
	craftingPage.LinkButton:SetPoint("LEFT", rankBar.Fill, "RIGHT", 3, 0)

	-- todo: spec page /run select(2, ProfessionsFrame.TabSystem:GetChildren()):Click()

	B.Reskin(frame.SpecPage.UnlockTabButton)
	B.Reskin(frame.SpecPage.ApplyButton)
	B.StripTextures(frame.SpecPage.TreeView)
	B.CreateBDFrame(frame.SpecPage.TreeView, .25):SetInside()

	B.StripTextures(frame.SpecPage.DetailedView)
	B.CreateBDFrame(frame.SpecPage.DetailedView, .25):SetInside()
	B.Reskin(frame.SpecPage.DetailedView.UnlockPathButton)
	B.Reskin(frame.SpecPage.DetailedView.SpendPointsButton)
end