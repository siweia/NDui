local _, ns = ...
local B, C, L, DB = unpack(ns)

local function ReskinReagentButton(reagent)
	reagent.bg = B.ReskinIcon(reagent.Icon)
	reagent.NameFrame:Hide()
	B.ReskinIconBorder(reagent.IconBorder)
	local bg = B.CreateBDFrame(reagent.NameFrame, .2)
	bg:SetPoint("TOPLEFT", reagent.Icon, "TOPRIGHT", 2, C.mult)
	bg:SetPoint("BOTTOMRIGHT", -4, C.mult)
	if reagent.SelectedTexture then
		reagent.SelectedTexture:SetColorTexture(1, 1, 1, .25)
		reagent.SelectedTexture:SetInside(reagent.bg)
	end
end

local function ResetBordeAlpha(self)
	self.IconBorder:SetAlpha(0)
end

C.themes["Blizzard_TradeSkillUI"] = function()
	local r, g, b = DB.r, DB.g, DB.b

	B.ReskinPortraitFrame(TradeSkillFrame)
	TradeSkillFrameTitleText:Show()
	TradeSkillFramePortrait:SetAlpha(0)
	TradeSkillFrame.DetailsInset:Hide()

	local rankFrame = TradeSkillFrame.RankFrame
	rankFrame:SetStatusBarTexture(DB.bdTex)
	rankFrame.SetStatusBarColor = B.Dummy
	rankFrame:GetStatusBarTexture():SetGradient("VERTICAL", .1, .3, .9, .2, .4, 1)
	rankFrame.BorderMid:Hide()
	rankFrame.BorderLeft:Hide()
	rankFrame.BorderRight:Hide()
	B.CreateBDFrame(rankFrame, .25)

	B.ReskinInput(TradeSkillFrame.SearchBox)
	TradeSkillFrame.SearchBox:SetWidth(200)
	B.ReskinFilterButton(TradeSkillFrame.FilterButton)
	B.ReskinArrow(TradeSkillFrame.LinkToButton, "right")

	-- Recipe List

	local recipe = TradeSkillFrame.RecipeList
	TradeSkillFrame.RecipeInset:Hide()
	B.ReskinScroll(recipe.scrollBar)

	for i = 1, #recipe.Tabs do
		local tab = recipe.Tabs[i]
		for i = 1, 6 do
			select(i, tab:GetRegions()):SetAlpha(0)
		end
		tab:SetHighlightTexture("")
		tab.bg = B.CreateBDFrame(tab, .25)
		tab.bg:SetPoint("TOPLEFT", 3, -3)
		tab.bg:SetPoint("BOTTOMRIGHT", -3, 0)
	end
	hooksecurefunc(recipe, "OnLearnedTabClicked", function()
		recipe.Tabs[1].bg:SetBackdropColor(r, g, b, .2)
		recipe.Tabs[2].bg:SetBackdropColor(0, 0, 0, .2)
	end)
	hooksecurefunc(recipe, "OnUnlearnedTabClicked", function()
		recipe.Tabs[1].bg:SetBackdropColor(0, 0, 0, .2)
		recipe.Tabs[2].bg:SetBackdropColor(r, g, b, .2)
	end)

	hooksecurefunc(recipe, "RefreshDisplay", function(self)
		for i = 1, #self.buttons do
			local button = self.buttons[i]
			if not button.styled then
				B.ReskinCollapse(button)
				if button.SubSkillRankBar then
					local bar = button.SubSkillRankBar
					B.StripTextures(bar)
					bar:SetStatusBarTexture(DB.bdTex)
					bar:SetPoint("RIGHT", -6, 0)
					B.CreateBDFrame(bar, .25)
				end

				button.styled = true
			end
			button:SetHighlightTexture("")
		end
	end)

	-- Recipe Details
	local detailsFrame = TradeSkillFrame.DetailsFrame
	detailsFrame.Background:Hide()
	B.ReskinScroll(detailsFrame.ScrollBar)
	B.Reskin(detailsFrame.CreateAllButton)
	B.Reskin(detailsFrame.CreateButton)
	B.Reskin(detailsFrame.ExitButton)
	detailsFrame.CreateMultipleInputBox:DisableDrawLayer("BACKGROUND")
	B.ReskinInput(detailsFrame.CreateMultipleInputBox)
	B.ReskinArrow(detailsFrame.CreateMultipleInputBox.DecrementButton, "left")
	B.ReskinArrow(detailsFrame.CreateMultipleInputBox.IncrementButton, "right")

	local contents = detailsFrame.Contents
	hooksecurefunc(contents.ResultIcon, "SetNormalTexture", function(self)
		if not self.styled then
			B.ReskinIcon(self:GetNormalTexture())
			self.IconBorder:SetAlpha(0)
			self.ResultBorder:Hide()
			self.styled = true
		end
	end)

	for i = 1, #contents.Reagents do
		ReskinReagentButton(contents.Reagents[i])
	end
	B.Reskin(detailsFrame.ViewGuildCraftersButton)

	for i = 1, #contents.OptionalReagents do
		ReskinReagentButton(contents.OptionalReagents[i])
	end

	local levelBar = contents.RecipeLevel
	B.StripTextures(levelBar)
	levelBar:SetStatusBarTexture(DB.bdTex)
	B.CreateBDFrame(levelBar, .25)
	B.ReskinFilterButton(contents.RecipeLevelSelector)

	-- Guild Recipe
	TradeSkillFrame.TabardBorder:SetAlpha(0)
	TradeSkillFrame.TabardBackground:SetAlpha(0)

	local guildFrame = detailsFrame.GuildFrame
	B.ReskinClose(guildFrame.CloseButton)
	B.StripTextures(guildFrame)
	B.SetBD(guildFrame)
	guildFrame:ClearAllPoints()
	guildFrame:SetPoint("BOTTOMLEFT", TradeSkillFrame, "BOTTOMRIGHT", 3, 0)
	B.StripTextures(guildFrame.Container)
	B.CreateBDFrame(guildFrame.Container, .25)
	B.ReskinScroll(guildFrame.Container.ScrollFrame.scrollBar)

	-- Optional reagents
	local reagentList = TradeSkillFrame.OptionalReagentList
	B.StripTextures(reagentList)
	B.SetBD(reagentList)
	reagentList:ClearAllPoints()
	reagentList:SetPoint("BOTTOMLEFT", TradeSkillFrame, "BOTTOMRIGHT", 40, 0)

	reagentList.HideUnownedButton:SetSize(24, 24)
	B.ReskinCheck(reagentList.HideUnownedButton)
	B.Reskin(reagentList.CloseButton)

	local scrollList = reagentList.ScrollList
	B.StripTextures(scrollList)
	local bg = B.CreateBDFrame(scrollList, .25)
	bg:SetPoint("TOPLEFT", 1, -2)
	bg:SetPoint("BOTTOMRIGHT", -25, 5)
	B.ReskinScroll(scrollList.ScrollFrame.scrollBar)

	reagentList:HookScript("OnShow", function()
		for i = 1, #scrollList.ScrollFrame.buttons do
			local button = scrollList.ScrollFrame.buttons[i]
			if not button.bg then
				button:DisableDrawLayer("ARTWORK")
				button.Icon:SetSize(32, 32)
				button.Icon:ClearAllPoints()
				button.Icon:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -3)
				button.bg = B.ReskinIcon(button.Icon)
				button.IconBorder:SetAlpha(0)
				hooksecurefunc(button, "SetState", ResetBordeAlpha)

				button.NameFrame:Hide()
				local bg = B.CreateBDFrame(button.NameFrame, .2)
				bg:SetPoint("TOPLEFT", button.Icon, "TOPRIGHT", 2, C.mult)
				bg:SetPoint("BOTTOMRIGHT", -4, 5)
			end
		end
	end)
end