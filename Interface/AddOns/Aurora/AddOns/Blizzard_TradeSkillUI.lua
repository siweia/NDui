local F, C = unpack(select(2, ...))

C.themes["Blizzard_TradeSkillUI"] = function()
	F.CreateBD(TradeSkillFrame)
	F.CreateSD(TradeSkillFrame)
	F.ReskinClose(TradeSkillFrameCloseButton)
	for i = 1, 17 do
		select(i, TradeSkillFrame:GetRegions()):Hide()
	end
	TradeSkillFrameTitleText:Show()
	TradeSkillFramePortrait:Hide()
	TradeSkillFramePortrait.Show = F.dummy

	local rankFrame = TradeSkillFrame.RankFrame
	rankFrame:SetStatusBarTexture(C.media.backdrop)
	rankFrame.SetStatusBarColor = F.dummy
	rankFrame:GetStatusBarTexture():SetGradient("VERTICAL", .1, .3, .9, .2, .4, 1)
	rankFrame.BorderMid:Hide()
	rankFrame.BorderLeft:Hide()
	rankFrame.BorderRight:Hide()
	local bg = CreateFrame("Frame", nil, rankFrame)
	bg:SetPoint("TOPLEFT", -1, 1)
	bg:SetPoint("BOTTOMRIGHT", 1, -1)
	bg:SetFrameLevel(rankFrame:GetFrameLevel()-1)
	F.CreateBD(bg, .25)

	F.ReskinInput(TradeSkillFrame.SearchBox)
	TradeSkillFrame.SearchBox:SetWidth(200)
	F.ReskinFilterButton(TradeSkillFrame.FilterButton)
	F.ReskinArrow(TradeSkillFrame.LinkToButton, "right")

	-- Recipe List
	local recipe = TradeSkillFrame.RecipeList
	F.ReskinTab(recipe.LearnedTab)
	F.ReskinTab(recipe.UnlearnedTab)
	TradeSkillFrame.RecipeInset:Hide()
	F.ReskinScroll(recipe.scrollBar)

	-- Recipe Details
	local detailsInset = TradeSkillFrame.DetailsInset
	detailsInset.Bg:Hide()
	detailsInset:DisableDrawLayer("BORDER")
	local details = TradeSkillFrame.DetailsFrame
	details.Background:Hide()
	F.ReskinScroll(details.ScrollBar)
	F.Reskin(details.CreateAllButton)
	F.Reskin(details.CreateButton)
	F.Reskin(details.ExitButton)
	F.ReskinInput(details.CreateMultipleInputBox)
	F.ReskinArrow(details.CreateMultipleInputBox.DecrementButton, "left")
	F.ReskinArrow(details.CreateMultipleInputBox.IncrementButton, "right")
	for i = 1, 9 do
		select(i, details.CreateMultipleInputBox:GetRegions()):Hide()
	end
	select(1, details.CreateMultipleInputBox:GetRegions()):Show()
	local contents = details.Contents
	contents.ResultIcon.Background:Hide()
	hooksecurefunc(contents.ResultIcon, "SetNormalTexture", function(self)
		if not self.styled then
			F.ReskinIcon(self:GetNormalTexture())
			self.styled = true
		end
	end)
	for i = 1, #contents.Reagents do
		local reagent = contents.Reagents[i]
		reagent.Icon:SetTexCoord(.08, .92, .08, .92)
		F.CreateBDFrame(reagent.Icon)
		reagent.NameFrame:Hide()
		local bg = F.CreateBDFrame(reagent.NameFrame, .2)
		bg:SetPoint("TOPLEFT", reagent.Icon, "TOPRIGHT", 2, 0)
		bg:SetPoint("BOTTOMRIGHT", -4, 0)
	end
	F.Reskin(details.ViewGuildCraftersButton)

	-- Guild Recipe
	local guildFrame = details.GuildFrame
	F.ReskinClose(guildFrame.CloseButton)
	for i = 1, 10 do
		select(i, guildFrame:GetRegions()):Hide()
	end
	guildFrame.Title:Show()
	F.CreateBD(guildFrame)
	F.CreateSD(guildFrame)
	guildFrame:ClearAllPoints()
	guildFrame:SetPoint("BOTTOMLEFT", TradeSkillFrame, "BOTTOMRIGHT", 2, 0)
	F.ReskinScroll(guildFrame.Container.ScrollFrame.scrollBar)
	for i = 1, 9 do
		select(i, guildFrame.Container:GetRegions()):Hide()
	end
	F.CreateBD(guildFrame.Container)
end