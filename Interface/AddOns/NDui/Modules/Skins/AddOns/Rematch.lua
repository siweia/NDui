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
	self.Texture:SetAlpha(0)
	self:SetSize(16, 12)
	self.__texture:SetVertexColor(1, .8, 0)
	self:HookScript("OnLeave", scrollEndOnLeave)
end

function S:RematchScroll()
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

function S:RematchPetList()
	local buttons = self.ScrollFrame.Buttons
	if not buttons then return end

	for i = 1, #buttons do
		local button = buttons[i]
		if not button.styled then
			local parent
			if button.Pet then
				B.CreateBDFrame(button.Pet)
				if button.Rarity then button.Rarity:SetTexture(nil) end
				if button.LevelBack then button.LevelBack:SetTexture(nil) end
				button.LevelText:SetTextColor(1, 1, 1)
				parent = button.Pet
			end

			if button.Pets then
				for j = 1, 3 do
					local bu = button.Pets[j]
					bu:SetWidth(25)
					B.CreateBDFrame(bu)
				end
				if button.Border then button.Border:SetTexture(nil) end
				parent = button.Pets[3]
			end

			if button.Back then
				button.Back:SetTexture(nil)
				local bg = B.CreateBDFrame(button.Back, .25)
				bg:SetPoint("TOPLEFT", parent, "TOPRIGHT", 3, C.mult)
				bg:SetPoint("BOTTOMRIGHT", 0, C.mult)
				button.bg = bg
				button:HookScript("OnEnter", buttonOnEnter)
				button:HookScript("OnLeave", buttonOnLeave)
			end

			button.styled = true
		end
	end
end

function S:RematchSelectedOverlay()
	B.StripTextures(self.SelectedOverlay)
	local bg = B.CreateBDFrame(self.SelectedOverlay)
	bg:SetBackdropColor(1, .8, 0, .5)
	self.SelectedOverlay.bg = bg
end

function S:RematchLockButton(button)
	B.StripTextures(button, 1)
	local bg = B.CreateBDFrame(button, .25, true)
	bg:SetInside(nil, 7, 7)
end

function S:RematchTeamGroup(panel)
	if panel.styled then return end

	for i = 1, 3 do
		local button = panel.Pets[i]
		S.RematchIcon(button)
		button.bg = button.Icon.bg
		B.ReskinIconBorder(button.IconBorder, true)

		for j = 1, 3 do
			S.RematchIcon(button.Abilities[j])
		end
	end

	panel.styled = true
end

function S:RematchFlyoutButton(flyout)
	flyout:HideBackdrop()
	for i = 1, 2 do
		S.RematchIcon(flyout.Abilities[i])
	end
end

local function hookRematchPetButton(texture, _, _, _, y)
	if y == .5 then
		texture:SetTexCoord(.5625, 1, 0, .4375)
	elseif y == 1 then
		texture:SetTexCoord(0, .4375, 0, .4375)
	end
end

local styled
function S:ReskinRematchElements()
	if styled then return end

	TT.ReskinTooltip(RematchTooltip)
	--TT.ReskinTooltip(RematchTableTooltip)
	--[=[for i = 1, 3 do
		local menu = Rematch:GetMenuFrame(i, UIParent)
		B.StripTextures(menu.Title)
		local bg = B.CreateBDFrame(menu.Title)
		bg:SetBackdropColor(1, .8, .0, .25)
		B.StripTextures(menu)
		B.SetBD(menu, .7)
	end]=]

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

	if ALPTRematchOptionButton then
		ALPTRematchOptionButton:SetPushedTexture(0)
		ALPTRematchOptionButton:SetHighlightTexture(DB.bdTex)
		ALPTRematchOptionButton:GetHighlightTexture():SetVertexColor(1, 1, 1, .25)
		local tex = ALPTRematchOptionButton:GetNormalTexture()
		tex:SetTexCoord(unpack(DB.TexCoord))
		B.CreateBDFrame(tex)
	end

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

	--S.RematchSelectedOverlay(petsPanel)
	S.RematchInset(petsPanel.ResultsBar)
	S.RematchInput(petsPanel.Top.SearchBox)
	S.RematchFilter(petsPanel.Top.FilterButton)
	S.RematchScroll(petsPanel.List)

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

	if true then return end
	local targetPanel = loadoutPanel.TargetPanel
	if targetPanel then -- compatible
		B.StripTextures(targetPanel.Top)
		S.RematchInput(targetPanel.Top.SearchBox)
		S.RematchFilter(targetPanel.Top.BackButton)
		S.RematchScroll(targetPanel.List)

		hooksecurefunc(targetPanel, "FillHeader", function(_, button)
			if not button.styled then
				button.Border:SetTexture(nil)
				button.Back:SetTexture(nil)
				button.bg = B.CreateBDFrame(button.Back, .25)
				button.bg:SetInside()
				button:HookScript("OnEnter", buttonOnEnter)
				button:HookScript("OnLeave", buttonOnLeave)
				button.Expand:SetSize(8, 8)
				button.Expand:SetPoint("LEFT", 5, 0)
				button.Expand:SetTexture("Interface\\Buttons\\UI-PlusMinus-Buttons")
				hooksecurefunc(button.Expand, "SetTexCoord", hookRematchPetButton)

				button.styled = true
			end
		end)
	end

	-- RematchTeamPanel
	B.StripTextures(RematchTeamPanel.Top)
	S.RematchInput(RematchTeamPanel.Top.SearchBox)
	S.RematchFilter(RematchTeamPanel.Top.Teams)
	S.RematchScroll(RematchTeamPanel.List)
	S.RematchSelectedOverlay(RematchTeamPanel)

	B.StripTextures(RematchQueuePanel.Top)
	S.RematchFilter(RematchQueuePanel.Top.QueueButton)
	S.RematchScroll(RematchQueuePanel.List)
	S.RematchInset(RematchQueuePanel.Status)

	-- RematchOptionPanel
	S.RematchScroll(RematchOptionPanel.List)
	for i = 1, 4 do
		S.RematchIcon(RematchOptionPanel.Growth.Corners[i])
	end
	B.StripTextures(RematchOptionPanel.Top)
	S.RematchInput(RematchOptionPanel.Top.SearchBox)

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
		S:ReskinRematchElements()

		frame.styled = true
	end)

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

--[=[
	hooksecurefunc(Rematch, "FillCommonPetListButton", function(self, petID)
		local petInfo = Rematch.petInfo:Fetch(petID)
		local parentPanel = self:GetParent():GetParent():GetParent():GetParent()
		if petInfo.isSummoned and parentPanel == Rematch.PetPanel then
			local bg = parentPanel.SelectedOverlay.bg
			if bg then
				bg:ClearAllPoints()
				bg:SetAllPoints(self.bg)
			end
		end
	end)

	hooksecurefunc(Rematch, "DimQueueListButton", function(_, button)
		button.LevelText:SetTextColor(1, 1, 1)
	end)

	hooksecurefunc(RematchDialog, "FillTeam", function(_, frame)
		S:RematchTeamGroup(frame)
	end)

	local direcButtons = {"UpButton", "DownButton"}
	hooksecurefunc(RematchTeamTabs, "Update", function(self)
		for _, tab in next, self.Tabs do
			S.RematchIcon(tab)
			tab:SetSize(40, 40)
			tab.Icon:SetPoint("CENTER")
		end

		for _, direc in pairs(direcButtons) do
			S.RematchIcon(self[direc])
			self[direc]:SetSize(40, 40)
			self[direc].Icon:SetPoint("CENTER")
		end
	end)

	hooksecurefunc(RematchTeamTabs, "TabButtonUpdate", function(self, index)
		local selected = self:GetSelectedTab()
		local button = self:GetTabButton(index)
		if not button.Icon.bg then return end

		if index == selected then
			button.Icon.bg:SetBackdropBorderColor(1, 1, 1)
		else
			button.Icon.bg:SetBackdropBorderColor(0, 0, 0)
		end
	end)

	hooksecurefunc(RematchTeamTabs, "UpdateTabIconPickerList", function()
		local buttons = RematchDialog.TeamTabIconPicker.ScrollFrame.buttons
		for i = 1, #buttons do
			local button = buttons[i]
			for j = 1, 10 do
				local bu = button.Icons[j]
				if not bu.styled then
					bu:SetSize(26, 26)
					bu.Icon = bu.Texture
					S.RematchIcon(bu)
				end
			end
		end
	end)

	hooksecurefunc(RematchLoadoutPanel, "UpdateLoadouts", function(self)
		if not self then return end

		for i = 1, 3 do
			local loadout = self.Loadouts[i]
			if not loadout.styled then
				B.StripTextures(loadout)
				local bg = B.CreateBDFrame(loadout, .25)
				bg:SetPoint("BOTTOMRIGHT", C.mult, C.mult)
				S.RematchIcon(loadout.Pet.Pet)
				S.RematchXP(loadout.HP)
				S.RematchXP(loadout.XP)
				loadout.XP:SetSize(255, 7)
				loadout.HP.MiniHP:SetText("HP")
				for j = 1, 3 do
					S.RematchIcon(loadout.Abilities[j])
				end

				loadout.styled = true
			end

			local icon = loadout.Pet.Pet.Icon
			local iconBorder = loadout.Pet.Pet.IconBorder
			if icon.bg then
				icon.bg:SetBackdropBorderColor(iconBorder:GetVertexColor())
			end
		end
	end)

	local activeTypeMode = 1
	hooksecurefunc(RematchPetPanel, "SetTypeMode", function(_, typeMode)
		activeTypeMode = typeMode
	end)
	hooksecurefunc(RematchPetPanel, "UpdateTypeBar", function(self)
		local typeBar = self.Top.TypeBar
		if typeBar:IsShown() then
			for i = 1, 4 do
				local tab = typeBar.Tabs[i]
				if not tab then break end
				if not tab.styled then
					B.StripTextures(tab)
					tab.bg = B.CreateBDFrame(tab)
					local r, g, b = tab.Selected.MidSelected:GetVertexColor()
					tab.bg:SetBackdropColor(r, g, b, .5)
					B.StripTextures(tab.Selected)

					tab.styled = true
				end
				tab.bg:SetShown(activeTypeMode == i)
			end
		end
	end)

	hooksecurefunc(RematchPetPanel.List, "Update", S.RematchPetList)
	hooksecurefunc(RematchQueuePanel.List, "Update", S.RematchPetList)
	hooksecurefunc(RematchTeamPanel.List, "Update", S.RematchPetList)

	hooksecurefunc(RematchTeamPanel, "FillTeamListButton", function(self, key)
		local teamInfo = Rematch.teamInfo:Fetch(key)
		if not teamInfo then return end

		local panel = RematchTeamPanel
		if teamInfo.key == RematchSettings.loadedTeam then
			local bg = panel.SelectedOverlay.bg
			if bg then
				bg:ClearAllPoints()
				bg:SetAllPoints(self.bg)
			end
		end
	end)

	hooksecurefunc(RematchOptionPanel, "FillOptionListButton", function(self, index)
		local panel = RematchOptionPanel
		local opt = panel.opts[index]
		if opt then
			self.optType = opt[1]
			local checkButton = self.CheckButton
			if not checkButton.bg then
				checkButton.bg = B.CreateBDFrame(checkButton, 0, true)
				self.HeaderBack:SetTexture(nil)
			end
			checkButton.bg:SetBackdropColor(0, 0, 0, 0)
			checkButton.bg:Show()

			if self.optType == "header" then
				self.headerIndex = opt[3]
				self.Text:SetPoint("LEFT", checkButton, "RIGHT", 5, 0)
				checkButton:SetSize(8, 8)
				checkButton:SetPoint("LEFT", 5, 0)
				checkButton:SetTexture("Interface\\Buttons\\UI-PlusMinus-Buttons")
				checkButton.bg:SetBackdropColor(0, 0, 0, .25)
				checkButton.bg:SetPoint("TOPLEFT", checkButton, -3, 3)
				checkButton.bg:SetPoint("BOTTOMRIGHT", checkButton, 3, -3)

				local isExpanded = RematchSettings.ExpandedOptHeaders[opt[3]]
				if isExpanded then
					checkButton:SetTexCoord(.5625, 1, 0, .4375)
				else
					checkButton:SetTexCoord(0, .4375, 0, .4375)
				end
				if self.headerIndex == 0 and panel.allCollapsed then
					checkButton:SetTexCoord(0, .4375, 0, .4375)
				end
			elseif self.optType == "check" then
				checkButton:SetSize(22, 22)
				checkButton.bg:SetPoint("TOPLEFT", checkButton, 3, -3)
				checkButton.bg:SetPoint("BOTTOMRIGHT", checkButton, -3, 3)
				if self.isChecked and self.isDisabled then
					checkButton:SetTexCoord(.25, .5, .75, 1)
				elseif self.isChecked then
					checkButton:SetTexCoord(.5, .75, 0, .25)
				else
					checkButton:SetTexCoord(0, 0, 0, 0)
				end
			elseif self.optType == "radio" then
				local isChecked = RematchSettings[opt[2]] == opt[5]
				checkButton:SetSize(22, 22)
				checkButton.bg:SetPoint("TOPLEFT", checkButton, 3, -3)
				checkButton.bg:SetPoint("BOTTOMRIGHT", checkButton, -3, 3)
				if isChecked then
					checkButton:SetTexCoord(.5, .75, .25, .5)
				else
					checkButton:SetTexCoord(0, 0, 0, 0)
				end
			else
				checkButton.bg:Hide()
			end
		end
	end)
	

	-- Window mode
	hooksecurefunc(frame, "ConfigureFrame", function(self)
		if self.styled then return end

		B.StripTextures(self)
		B.SetBD(self)
		if self.CloseButton then
			B.ReskinClose(self.CloseButton)
		end
		for _, tab in ipairs(self.PanelTabs.Tabs) do
			B.ReskinTab(tab)
		end

		B.StripTextures(RematchMiniPanel)
		S:RematchTeamGroup(RematchMiniPanel)
		S:RematchFlyoutButton(RematchMiniPanel.Flyout)

		local titleBar = self.TitleBar
		B.StripTextures(titleBar)

		S:RematchLockButton(titleBar.MinimizeButton)
		S:RematchLockButton(titleBar.LockButton)
		S:RematchLockButton(titleBar.SinglePanelButton)
		S:ReskinRematchElements()

		self.styled = true
	end)]=]
end