local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_TradeSkillUI"] = function()
	local r, g, b = DB.r, DB.g, DB.b

	B.ReskinPortraitFrame(TradeSkillFrame)
	TradeSkillFrameTitleText:Show()
	TradeSkillFramePortrait:SetAlpha(0)

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
				B.ReskinExpandOrCollapse(button)
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

	local detailsInset = TradeSkillFrame.DetailsInset
	detailsInset:Hide()
	local details = TradeSkillFrame.DetailsFrame
	details.Background:Hide()
	B.ReskinScroll(details.ScrollBar)
	B.Reskin(details.CreateAllButton)
	B.Reskin(details.CreateButton)
	B.Reskin(details.ExitButton)
	details.CreateMultipleInputBox:DisableDrawLayer("BACKGROUND")
	B.ReskinInput(details.CreateMultipleInputBox)
	B.ReskinArrow(details.CreateMultipleInputBox.DecrementButton, "left")
	B.ReskinArrow(details.CreateMultipleInputBox.IncrementButton, "right")

	local contents = details.Contents
	hooksecurefunc(contents.ResultIcon, "SetNormalTexture", function(self)
		if not self.styled then
			B.ReskinIcon(self:GetNormalTexture())
			self.IconBorder:SetAlpha(0)
			self.ResultBorder:SetAlpha(0)
			self.styled = true
		end
	end)
	for i = 1, #contents.Reagents do
		local reagent = contents.Reagents[i]
		B.ReskinIcon(reagent.Icon)
		reagent.NameFrame:Hide()
		local bg = B.CreateBDFrame(reagent.NameFrame, .2)
		bg:SetPoint("TOPLEFT", reagent.Icon, "TOPRIGHT", 2, 0)
		bg:SetPoint("BOTTOMRIGHT", -4, 0)
	end
	B.Reskin(details.ViewGuildCraftersButton)

	-- Guild Recipe

	TradeSkillFrame.TabardBorder:SetAlpha(0)
	TradeSkillFrame.TabardBackground:SetAlpha(0)

	local guildFrame = details.GuildFrame
	B.ReskinClose(guildFrame.CloseButton)
	for i = 1, 10 do
		select(i, guildFrame:GetRegions()):Hide()
	end
	guildFrame.Title:Show()
	B.SetBD(guildFrame)
	guildFrame:ClearAllPoints()
	guildFrame:SetPoint("BOTTOMLEFT", TradeSkillFrame, "BOTTOMRIGHT", 3, 0)
	B.ReskinScroll(guildFrame.Container.ScrollFrame.scrollBar)
	for i = 1, 9 do
		select(i, guildFrame.Container:GetRegions()):Hide()
	end
	B.CreateBD(guildFrame.Container, .25)
end