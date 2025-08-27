local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")
local TT = B:GetModule("Tooltip")

local cr, cg, cb = DB.r, DB.g, DB.b
local select, pairs, ipairs, next, unpack = select, pairs, ipairs, next, unpack

function S:RematchFilter()
	B.StripTextures(self)
	B.Reskin(self)
	B.SetupArrow(self.Arrow, "right")
	self.Arrow:ClearAllPoints()
	self.Arrow:SetPoint("RIGHT")
	self.Arrow.SetPoint = B.Dummy
	self.Arrow:SetSize(14, 14)
end

function S:RematchButton()
	if self.styled then return end

	B.Reskin(self)
	self:DisableDrawLayer("BACKGROUND")
	self:DisableDrawLayer("BORDER")

	self.styled = true
end

function S:RematchIcon()
	if self.styled then return end

	if self.Border then self.Border:SetAlpha(0) end
	if self.Icon then
		self.Icon:SetTexCoord(unpack(DB.TexCoord))
		self.Icon.bg = B.CreateBDFrame(self.Icon)
	end
	if self.Level then
		if self.Level.BG then self.Level.BG:Hide() end
		if self.Level.Text then self.Level.Text:SetTextColor(1, 1, 1) end
	end
	if self.GetCheckedTexture then
		self:SetCheckedTexture(DB.pushedTex)
	end

	self.styled = true
end

function S:RematchInput()
	self:DisableDrawLayer("BACKGROUND")
	self:HideBackdrop()
	local bg = B.CreateBDFrame(self, 0, true)
	bg:SetPoint("TOPLEFT", 2, 0)
	bg:SetPoint("BOTTOMRIGHT", -2, 0)
end

local function scrollEndOnLeave(self)
	self.__texture:SetVertexColor(1, .8, 0)
end

function S:ReskinScrollEnd(direction)
	B.ReskinArrow(self, direction)
	if self.Texture then self.Texture:SetAlpha(0) end
	self:SetSize(16, 12)
	self.__texture:SetVertexColor(1, .8, 0)
	self:HookScript("OnLeave", scrollEndOnLeave)
end

function S:RematchScroll()
	B.StripTextures(self)
	B.ReskinTrimScroll(self.ScrollBar)
	S.ReskinScrollEnd(self.ScrollToTopButton, "up")
	S.ReskinScrollEnd(self.ScrollToBottomButton, "down")
end

function S:RematchDropdown()
	self:HideBackdrop()
	B.StripTextures(self, 0)
	B.CreateBDFrame(self, 0, true)
	if self.Icon then
		self.Icon:SetAlpha(1)
		B.CreateBDFrame(self.Icon)
	end
	local arrow = select(2, self:GetChildren())
	B.ReskinArrow(arrow, "down")
end

function S:RematchXP()
	B.StripTextures(self)
	self:SetTexture(DB.bdTex)
	B.CreateBDFrame(self, .25)
end

function S:RematchCard()
	self:HideBackdrop()
	if self.Source then B.StripTextures(self.Source) end
	B.StripTextures(self.Middle)
	B.CreateBDFrame(self.Middle, .25)
	if self.Middle.XP then S.RematchXP(self.Middle.XP) end
	if self.Bottom.AbilitiesBG then self.Bottom.AbilitiesBG:Hide() end
	if self.Bottom.BottomBG then self.Bottom.BottomBG:Hide() end
	local bg = B.CreateBDFrame(self.Bottom, .25)
	bg:SetPoint("TOPLEFT", -C.mult, -3)
end

function S:RematchInset()
	B.StripTextures(self)
	local bg = B.CreateBDFrame(self, .25)
	bg:SetPoint("TOPLEFT", 3, 0)
	bg:SetPoint("BOTTOMRIGHT", -3, 0)
end

local function buttonOnEnter(self)
	self.bg:SetBackdropColor(cr, cg, cb, .25)
end

local function buttonOnLeave(self)
	self.bg:SetBackdropColor(0, 0, 0, .25)
end

function S:RematchLockButton(button)
	B.StripTextures(button, 1)
	local bg = B.CreateBDFrame(button, .25, true)
	bg:SetInside(nil, 7, 7)
end

local function updateCollapseTexture(button, isExpanded)
	local atlas = isExpanded and "ui-questtrackerbutton-secondary-collapse" or "ui-questtrackerbutton-secondary-expand"
	button.__texture:SetAtlas(atlas, true)
end

local function headerEnter(header)
	header.bg:SetBackdropColor(cr, cg, cb, .25)
end

local function headerLeave(header)
	header.bg:SetBackdropColor(0, 0, 0, .25)
end

function S:RematchCollapse()
	if self.Icon then
		self.Icon.isIgnored = true
		self.IconMask.isIgnored = true
	end
	B.StripTextures(self)
	self.bg = B.CreateBDFrame(self, .25)
	self.bg:SetInside()

	self.__texture = self:CreateTexture(nil, "OVERLAY")
	self.__texture:SetPoint("LEFT", 2, 0)
	self.__texture:SetSize(12, 12)
	self:HookScript("OnEnter", headerEnter)
	self:HookScript("OnLeave", headerLeave)

	updateCollapseTexture(self, self.isExpanded or self:GetParent().IsHeaderExpanded)
	hooksecurefunc(self, "SetExpanded", updateCollapseTexture)
end

local function handleHeaders(box)
	box:ForEachFrame(function(button)
		if button.ExpandIcon and not button.styled then
			S.RematchCollapse(button)
			button.styled = true
		end
	end)
end

function S:RematchHeaders()
	hooksecurefunc(self.ScrollBox, "Update", handleHeaders)
end

local function handleList(self)
	self:ForEachFrame(function(button)
		if not button.styled then
			button.Border:SetAlpha(0) -- too blur to use quality color
			button.bg = B.ReskinIcon(button.Icon)
			button.styled = true
		end
	end)
end

function S:RematchPetList()
	hooksecurefunc(self.ScrollBox, "Update", handleList)
end

local styled
function S:ReskinRematchElements()
	if styled then return end

	TT.ReskinTooltip(RematchTooltip)

	local toolbar = Rematch.toolbar

	local buttonName = {
		"HealButton", "BandageButton", "SafariHatButton",
		"LesserPetTreatButton", "PetTreatButton", "LevelingStoneButton", "RarityStoneButton",
		"ImportTeamButton", "ExportTeamButton", "RandomTeamButton", "SummonPetButton"
	}
	for _, name in pairs(buttonName) do
		local button = toolbar[name]
		if button then
			S.RematchIcon(button)
		end
	end

	B.StripTextures(toolbar)
	S.RematchButton(toolbar.TotalsButton)

	for _, name in pairs({"SummonButton", "SaveButton", "SaveAsButton", "FindBattleButton"}) do
		local button = Rematch.bottombar[name]
		if button then
			S.RematchButton(button)
		end
	end

	-- RematchPetPanel
	local petsPanel = Rematch.petsPanel
	B.StripTextures(petsPanel.Top)
	S.RematchButton(petsPanel.Top.ToggleButton)
	petsPanel.Top.ToggleButton.Back:Hide()
	petsPanel.Top.TypeBar.TabbedBorder:SetAlpha(0)
	for i = 1, 10 do
		S.RematchIcon(petsPanel.Top.TypeBar.Buttons[i])
	end

	S.RematchInset(petsPanel.ResultsBar)
	S.RematchInput(petsPanel.Top.SearchBox)
	S.RematchFilter(petsPanel.Top.FilterButton)
	S.RematchScroll(petsPanel.List)
	S.RematchPetList(petsPanel.List)

	-- RematchLoadedTeamPanel
	local loadoutPanel = Rematch.loadoutPanel

	B.StripTextures(loadoutPanel)
	local bg = B.CreateBDFrame(loadoutPanel)
	bg:SetBackdropColor(1, .8, 0, .1)
	bg:SetPoint("TOPLEFT", -C.mult, -C.mult)
	bg:SetPoint("BOTTOMRIGHT", C.mult, C.mult)

	S.RematchButton(Rematch.loadedTeamPanel.TeamButton)
	B.StripTextures(Rematch.loadedTeamPanel.NotesFrame)
	S.RematchButton(Rematch.loadedTeamPanel.NotesFrame.NotesButton)

	-- RematchLoadoutPanel
	local target = Rematch.loadedTargetPanel
	B.StripTextures(target)
	B.CreateBDFrame(target, .25)
	S.RematchButton(target.BigLoadSaveButton)

	-- Teams
	local team = Rematch.teamsPanel
	B.StripTextures(team.Top)
	S.RematchInput(team.Top.SearchBox)
	S.RematchFilter(team.Top.TeamsButton)
	S.RematchScroll(team.List)
	S.RematchCollapse(team.Top.AllButton)
	S.RematchHeaders(team.List)

	-- Targets
	local targets = Rematch.targetsPanel
	B.StripTextures(targets.Top)
	S.RematchInput(targets.Top.SearchBox)
	S.RematchScroll(targets.List)
	S.RematchCollapse(targets.Top.AllButton)
	S.RematchHeaders(targets.List)

	-- Queue
	local queue = Rematch.queuePanel
	B.StripTextures(queue.Top)
	S.RematchFilter(queue.Top.QueueButton)
	S.RematchScroll(queue.List)
	B.StripTextures(queue.PreferencesFrame)
	B.Reskin(queue.PreferencesFrame.PreferencesButton)
	S.RematchPetList(queue.List)

	-- Options
	local options = Rematch.optionsPanel
	B.StripTextures(options.Top)
	S.RematchInput(options.Top.SearchBox)
	S.RematchScroll(options.List)
	S.RematchCollapse(options.Top.AllButton)
	S.RematchHeaders(options.List)

	-- side tabs
	hooksecurefunc(Rematch.teamTabs, "Configure", function(self)
		for i = 1, #self.Tabs do
			local tab = self.Tabs[i]
			if tab and not tab.styled then
				B.StripTextures(tab)
				tab.IconMask:Hide()
				B.ReskinIcon(tab.Icon)
				tab.styled = true
			end
		end
	end)

	if true then return end -- todo: skin remain elements

	-- RematchPetCard
	local petCard = RematchPetCard
	B.StripTextures(petCard)
	B.ReskinClose(petCard.CloseButton)
	B.StripTextures(petCard.Title)
	B.StripTextures(petCard.PinButton)
	B.ReskinArrow(petCard.PinButton, "up")
	petCard.PinButton:SetPoint("TOPLEFT", 5, -5)
	local bg = B.SetBD(petCard.Title, .7)
	bg:SetAllPoints(petCard)
	S.RematchCard(petCard.Front)
	S.RematchCard(petCard.Back)
	for i = 1, 6 do
		local button = RematchPetCard.Front.Bottom.Abilities[i]
		button.IconBorder:Hide()
		select(8, button:GetRegions()):SetTexture(nil)
		B.ReskinIcon(button.Icon)
	end

	-- RematchAbilityCard
	local abilityCard = RematchAbilityCard
	B.StripTextures(abilityCard, 15)
	B.SetBD(abilityCard, .7)
	abilityCard.Hints.HintsBG:Hide()

	-- RematchWinRecordCard
	local card = RematchWinRecordCard
	B.StripTextures(card)
	B.ReskinClose(card.CloseButton)
	B.StripTextures(card.Content)
	local bg = B.CreateBDFrame(card.Content, .25)
	bg:SetPoint("TOPLEFT", 2, -2)
	bg:SetPoint("BOTTOMRIGHT", -2, 2)
	local bg = B.SetBD(card.Content)
	bg:SetAllPoints(card)
	for _, result in pairs({"Wins", "Losses", "Draws"}) do
		S.RematchInput(card.Content[result].EditBox)
		card.Content[result].Add.IconBorder:Hide()
	end
	B.Reskin(card.Controls.ResetButton)
	B.Reskin(card.Controls.SaveButton)
	B.Reskin(card.Controls.CancelButton)

	-- RematchDialog
	local dialog = RematchDialog
	B.StripTextures(dialog)
	B.SetBD(dialog)
	B.ReskinClose(dialog.CloseButton)

	S.RematchIcon(dialog.Slot)
	S.RematchInput(dialog.EditBox)
	B.StripTextures(dialog.Prompt)
	B.Reskin(dialog.Accept)
	B.Reskin(dialog.Cancel)
	B.Reskin(dialog.Other)
	B.ReskinCheck(dialog.CheckButton)
	S.RematchInput(dialog.SaveAs.Name)
	S.RematchInput(dialog.Send.EditBox)
	S.RematchDropdown(dialog.SaveAs.Target)
	S.RematchDropdown(dialog.TabPicker)
	S.RematchIcon(dialog.Pet.Pet)
	B.ReskinRadio(dialog.ConflictRadios.MakeUnique)
	B.ReskinRadio(dialog.ConflictRadios.Overwrite)

	local preferences = dialog.Preferences
	S.RematchInput(preferences.MinHP)
	B.ReskinCheck(preferences.AllowMM)
	S.RematchInput(preferences.MaxHP)
	S.RematchInput(preferences.MinXP)
	S.RematchInput(preferences.MaxXP)

	local iconPicker = dialog.TeamTabIconPicker
	B.ReskinScroll(iconPicker.ScrollFrame.ScrollBar)
	B.StripTextures(iconPicker)
	B.CreateBDFrame(iconPicker, .25)
	S.RematchInput(iconPicker.SearchBox)

	B.ReskinScroll(dialog.MultiLine.ScrollBar)
	select(2, dialog.MultiLine:GetChildren()):HideBackdrop()
	local bg = B.CreateBDFrame(dialog.MultiLine, .25)
	bg:SetPoint("TOPLEFT", -5, 5)
	bg:SetPoint("BOTTOMRIGHT", 5, -5)
	B.ReskinCheck(dialog.ShareIncludes.IncludePreferences)
	B.ReskinCheck(dialog.ShareIncludes.IncludeNotes)

	local report = dialog.CollectionReport
	S.RematchDropdown(report.ChartTypeComboBox)
	B.StripTextures(report.Chart)
	local bg = B.CreateBDFrame(report.Chart, .25)
	bg:SetPoint("TOPLEFT", -C.mult, -3)
	bg:SetPoint("BOTTOMRIGHT", C.mult, 2)
	B.ReskinRadio(report.ChartTypesRadioButton)
	B.ReskinRadio(report.ChartSourcesRadioButton)

	local border = report.RarityBarBorder
	border:Hide()
	local bg = B.CreateBDFrame(border, .25)
	bg:SetPoint("TOPLEFT", border, 6, -5)
	bg:SetPoint("BOTTOMRIGHT", border, -6, 5)

	styled = true
end

function S:ReskinRematch()
	if not C.db["Skins"]["BlizzardSkins"] then return end
	if not C.db["Skins"]["Rematch"] then return end

	local frame = Rematch and Rematch.frame
	if not frame then return end

	if RematchSettings then
		RematchSettings.ColorPetNames = true
		RematchSettings.FixedPetCard = true
	end
	--RematchLoreFont:SetTextColor(1, 1, 1)

	local function resizeJournal()
		local isShown = frame:IsShown() and frame
		CollectionsJournal.bg:SetPoint("BOTTOMRIGHT", isShown or CollectionsJournal, C.mult, -C.mult)
		CollectionsJournal.CloseButton:SetAlpha(isShown and 0 or 1)
	end

	hooksecurefunc(frame, "OnShow", function()
		resizeJournal()

		if frame.styled then return end

		hooksecurefunc("PetJournal_UpdatePetLoadOut", resizeJournal)
		hooksecurefunc("CollectionsJournal_UpdateSelectedTab", resizeJournal)

		B.StripTextures(frame)
		frame.TitleBar.Portrait:SetAlpha(0)
		B.ReskinClose(frame.TitleBar.CloseButton)

		local tabs = frame.PanelTabs
		for i = 1, tabs:GetNumChildren() do
			local tab = select(i, tabs:GetChildren())
			B.ReskinTab(tab)
			tab.Highlight:SetAlpha(0)
		end

		B.ReskinCheck(frame.BottomBar.UseRematchCheckButton)

		frame.styled = true
	end)

	S:ReskinRematchElements()

	local journal = Rematch.journal
	hooksecurefunc(journal, "PetJournalOnShow", function()
		if journal.styled then return end
		B.ReskinCheck(journal.UseRematchCheckButton)

		journal.styled = true
	end)

	hooksecurefunc(RematchNotesCard, "Update", function(self)
		if self.styled then return end

		B.StripTextures(self)
		B.ReskinClose(self.CloseButton)
		S:RematchLockButton(self.LockButton)
		self.LockButton:SetPoint("TOPLEFT")

		local content = self.Content
		B.ReskinScroll(content.ScrollFrame.ScrollBar)
		local bg = B.CreateBDFrame(content.ScrollFrame, .25)
		bg:SetPoint("TOPLEFT", 0, 5)
		bg:SetPoint("BOTTOMRIGHT", 0, -2)
		local bg = B.SetBD(content.ScrollFrame)
		bg:SetAllPoints(self)

		S.RematchButton(self.Content.Bottom.DeleteButton)
		S.RematchButton(self.Content.Bottom.UndoButton)
		S.RematchButton(self.Content.Bottom.SaveButton)

		self.styled = true
	end)

	local loadoutBG
	hooksecurefunc(Rematch.loadoutPanel, "Update", function(self)
		if not self then return end

		for i = 1, 3 do
			local loadout = self.Loadouts[i]
			if not loadout.styled then
				for i = 1, 9 do
					select(i, loadout:GetRegions()):Hide()
				end
				loadout.Pet.Border:SetAlpha(0)
				local bg = B.CreateBDFrame(loadout, .25)
				bg:SetPoint("BOTTOMRIGHT", C.mult, C.mult)
				S.RematchIcon(loadout.Pet)
				S.RematchXP(loadout.HpBar)
				S.RematchXP(loadout.XpBar)
			--	for j = 1, 3 do
			--		S.RematchIcon(loadout.Abilities[j])
			--	end

				loadout.styled = true
			end

			local icon = loadout.Pet.Icon
			local iconBorder = loadout.Pet.Border
			if icon.bg then
				local r, g, b = iconBorder:GetVertexColor()
				icon.bg:SetBackdropBorderColor(r, g, b)
			end
		end
	end)
end