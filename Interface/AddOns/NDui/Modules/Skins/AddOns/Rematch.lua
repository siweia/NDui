local _, ns = ...
local B, C, L, DB, F, T = unpack(ns)
local module = B:GetModule("Skins")

function module:ReskinRematch()
	if not NDuiDB["Skins"]["Rematch"] then return end
	if not F then return end

	local RematchJournal = RematchJournal
	if not RematchJournal then return end

	local cr, cg, cb = DB.r, DB.g, DB.b
	local select, pairs, ipairs, next, unpack = select, pairs, ipairs, next, unpack

	local settings = RematchSettings
	settings.ColorPetNames = true
	settings.FixedPetCard = true
	RematchLoreFont:SetTextColor(1, 1, 1)

	local function reskinRematchClose(self)
		F.StripTextures(self.CloseButton)
		F.ReskinClose(self.CloseButton)
	end

	local function reskinRematchFilter(self)
		F.StripTextures(self)
		F.Reskin(self)
		self.Arrow:SetTexture(T.media.arrowRight)
		self.Arrow:SetPoint("RIGHT", self, "RIGHT", -5, 0)
		self.Arrow:SetSize(8, 8)
	end

	local function reskinRematchIcon(self)
		if self.styled then return end

		if self.IconBorder then self.IconBorder:Hide() end
		if self.Background then self.Background:Hide() end
		if self.Icon then
			self.Icon:SetTexCoord(unpack(DB.TexCoord))
			self.Icon.bg = F.CreateBDFrame(self.Icon)
			local hl = self.GetHighlightTexture and self:GetHighlightTexture() or select(3, self:GetRegions())
			if hl then
				hl:SetColorTexture(1, 1, 1, .25)
				hl:SetAllPoints(self.Icon)
			end
		end
		if self.Level then
			if self.Level.BG then self.Level.BG:Hide() end
			if self.Level.Text then self.Level.Text:SetTextColor(1, 1, 1) end
		end

		self.styled = true
	end

	local function reskinRematchInput(self)
		self:DisableDrawLayer("BACKGROUND")
		self:SetBackdrop(nil)
		local bg = F.CreateBDFrame(self, 0)
		bg:SetPoint("TOPLEFT", 2, 0)
		bg:SetPoint("BOTTOMRIGHT", -2, 0)
		F.CreateGradient(bg)
	end

	local function reskinRematchScroll(self)
		self.Background:Hide()
		F.StripTextures(self.ScrollFrame.ScrollBar)
		self.ScrollFrame.ScrollBar.thumbTexture = self.ScrollFrame.ScrollBar.ScrollThumb
		F.ReskinScroll(self.ScrollFrame.ScrollBar)
	end

	local function reskinRematchDropdown(self)
		self:SetBackdrop(nil)
		F.StripTextures(self, 0)
		F.CreateGradient(F.CreateBDFrame(self, 0))
		if self.Icon then
			self.Icon:SetAlpha(1)
			F.CreateBDFrame(self.Icon)
		end
		local arrow = self:GetChildren()
		F.ReskinArrow(arrow, "down")
	end

	local function reskinRematchXP(bar)
		F.StripTextures(bar)
		bar:SetStatusBarTexture(DB.bdTex)
		F.CreateBDFrame(bar, .25)
	end

	local function reskinPetCard(face)
		face:SetBackdrop(nil)
		if face.Source then F.StripTextures(face.Source) end
		F.StripTextures(face.Middle)
		F.CreateBDFrame(face.Middle, .25)
		if face.Middle.XP then reskinRematchXP(face.Middle.XP) end
		F.StripTextures(face.Bottom)
		local bg = F.CreateBDFrame(face.Bottom, .25)
		bg:SetPoint("TOPLEFT", -C.mult, -3)
	end

	local function reskinMenu(self)
		F.StripTextures(self.Title)
		local bg = F.CreateBDFrame(self.Title)
		bg:SetBackdropColor(1, .8, .0, .25)
		F.StripTextures(self)
		F.CreateSD(F.CreateBDFrame(self, .7))
	end

	local function resizeBackground()
		local parent = RematchJournal:IsShown() and RematchJournal or CollectionsJournal
		CollectionsJournal.bg:SetPoint("BOTTOMRIGHT", parent, C.mult, -C.mult)
	end

	local styled
	hooksecurefunc(RematchJournal, "ConfigureJournal", function()
		resizeBackground()

		if styled then return end

		hooksecurefunc("CollectionsJournal_UpdateSelectedTab", resizeBackground)
		B.ReskinTooltip(RematchTooltip)
		B.ReskinTooltip(RematchTableTooltip)
		for i = 1, 3 do
			local menu = Rematch:GetMenuFrame(i, UIParent)
			reskinMenu(menu)
		end

		F.StripTextures(RematchJournal)
		reskinRematchClose(RematchJournal)
		for _, tab in ipairs(RematchJournal.PanelTabs.Tabs) do
			F.ReskinTab(tab)
		end

		local buttons = {
			RematchHealButton,
			RematchBandageButton,
			RematchToolbar.SafariHat,
			RematchLesserPetTreatButton,
			RematchPetTreatButton,
			RematchToolbar.SummonRandom,
		}
		for _, button in pairs(buttons) do
			reskinRematchIcon(button)
		end
		F.StripTextures(RematchToolbar.PetCount)
		local bg = F.CreateBDFrame(RematchToolbar.PetCount, .25)
		bg:SetPoint("TOPLEFT", -10, -5)

		F.StripTextures(RematchPetPanel.Top)
		F.Reskin(RematchPetPanel.Top.Toggle)
		RematchPetPanel.Top.TypeBar:SetBackdrop(nil)
		for i = 1, 10 do
			local button = RematchPetPanel.Top.TypeBar.Buttons[i]
			reskinRematchIcon(button)
			local check = button:GetCheckedTexture()
			check:SetColorTexture(1, .8, 0, .25)
			check:SetAllPoints(button.Icon)
		end

		F.StripTextures(RematchPetPanel.Results)
		local bg = F.CreateBDFrame(RematchPetPanel.Results, .25)
		bg:SetPoint("TOPLEFT", 3, 0)
		bg:SetPoint("BOTTOMRIGHT", -3, 0)
		reskinRematchInput(RematchPetPanel.Top.SearchBox)
		reskinRematchFilter(RematchPetPanel.Top.Filter)
		reskinRematchScroll(RematchPetPanel.List)

		F.StripTextures(RematchLoadedTeamPanel)
		local bg = F.CreateBDFrame(RematchLoadedTeamPanel)
		bg:SetBackdropColor(1, .8, 0, .1)
		bg:SetPoint("TOPLEFT", -C.mult, -C.mult)
		bg:SetPoint("BOTTOMRIGHT", C.mult, C.mult)
		F.StripTextures(RematchLoadedTeamPanel.Footnotes)

		local target = RematchLoadoutPanel.Target
		F.StripTextures(target)
		F.CreateBDFrame(target, .25)
		reskinRematchFilter(target.TargetButton)
		target.ModelBorder:SetBackdrop(nil)
		target.ModelBorder:DisableDrawLayer("BACKGROUND")
		F.CreateBDFrame(target.ModelBorder, .25)
		F.StripTextures(target.LoadSaveButton)
		F.Reskin(target.LoadSaveButton)
		for i = 1, 3 do
			reskinRematchIcon(target["Pet"..i])
		end

		local flyout = RematchLoadoutPanel.Flyout
		flyout:SetBackdrop(nil)
		for i = 1, 2 do
			reskinRematchIcon(flyout.Abilities[i])
		end

		F.StripTextures(RematchTeamPanel.Top)
		reskinRematchInput(RematchTeamPanel.Top.SearchBox)
		reskinRematchFilter(RematchTeamPanel.Top.Teams)
		reskinRematchScroll(RematchTeamPanel.List)

		F.StripTextures(RematchQueuePanel.Top)
		reskinRematchFilter(RematchQueuePanel.Top.QueueButton)
		reskinRematchScroll(RematchQueuePanel.List)

		reskinRematchScroll(RematchOptionPanel.List)
		for i = 1, 4 do
			local bu = RematchOptionPanel.Growth.Corners[i]
			reskinRematchIcon(bu)
		end

		F.Reskin(RematchBottomPanel.SummonButton)
		F.ReskinCheck(UseRematchButton)
		F.ReskinCheck(RematchBottomPanel.UseDefault)
		F.Reskin(RematchBottomPanel.SaveButton)
		F.Reskin(RematchBottomPanel.SaveAsButton)
		F.Reskin(RematchBottomPanel.FindBattleButton)

		local petCard = RematchPetCard
		F.StripTextures(petCard)
		reskinRematchClose(petCard)
		F.StripTextures(petCard.Title)
		F.StripTextures(petCard.PinButton)
		F.ReskinArrow(petCard.PinButton, "up")
		petCard.PinButton:SetPoint("TOPLEFT", 5, -5)
		local bg = F.CreateBDFrame(petCard.Title, .7)
		bg:SetAllPoints(petCard)
		F.CreateSD(bg)
		reskinPetCard(petCard.Front)
		reskinPetCard(petCard.Back)
		for i = 1, 6 do
			local button = petCard.Front.Bottom.Abilities[i]
			button.IconBorder:Hide()
			F.ReskinIcon(button.Icon)
		end

		local abilityCard = RematchAbilityCard
		F.StripTextures(abilityCard, 15)
		F.CreateSD(F.CreateBDFrame(abilityCard, .7))
		abilityCard.Hints.HintsBG:Hide()

		local card = RematchWinRecordCard
		F.StripTextures(card)
		reskinRematchClose(card)
		F.StripTextures(card.Content)
		local bg = F.CreateBDFrame(card.Content, .25)
		bg:SetPoint("TOPLEFT", 2, -2)
		bg:SetPoint("BOTTOMRIGHT", -2, 2)
		local bg = F.SetBD(card.Content)
		bg:SetAllPoints(card)
		for _, result in pairs({"Wins", "Losses", "Draws"}) do
			reskinRematchInput(card.Content[result].EditBox)
			card.Content[result].Add.IconBorder:Hide()
		end
		F.Reskin(card.Controls.ResetButton)
		F.Reskin(card.Controls.SaveButton)
		F.Reskin(card.Controls.CancelButton)

		local dialog = RematchDialog
		F.StripTextures(dialog)
		F.SetBD(dialog)
		reskinRematchClose(dialog)

		reskinRematchIcon(dialog.Slot)
		reskinRematchInput(dialog.EditBox)
		F.StripTextures(dialog.Prompt)
		F.Reskin(dialog.Accept)
		F.Reskin(dialog.Cancel)
		F.Reskin(dialog.Other)
		F.ReskinCheck(dialog.CheckButton)
		reskinRematchInput(dialog.SaveAs.Name)
		reskinRematchInput(dialog.Send.EditBox)
		reskinRematchDropdown(dialog.SaveAs.Target)
		reskinRematchDropdown(dialog.TabPicker)
		reskinRematchIcon(dialog.Pet.Pet)

		local preferences = dialog.Preferences
		reskinRematchInput(preferences.MinHP)
		F.ReskinCheck(preferences.AllowMM)
		reskinRematchInput(preferences.MaxHP)
		reskinRematchInput(preferences.MinXP)
		reskinRematchInput(preferences.MaxXP)

		local iconPicker = dialog.TeamTabIconPicker
		F.ReskinScroll(iconPicker.ScrollFrame.ScrollBar)
		F.StripTextures(iconPicker)
		F.CreateBDFrame(iconPicker, .25)

		F.ReskinScroll(dialog.MultiLine.ScrollBar)
		select(2, dialog.MultiLine:GetChildren()):SetBackdrop(nil)
		local bg = F.CreateBDFrame(dialog.MultiLine, .25)
		bg:SetPoint("TOPLEFT", -5, 5)
		bg:SetPoint("BOTTOMRIGHT", 5, -5)

		local report = dialog.CollectionReport
		reskinRematchDropdown(report.ChartTypeComboBox)
		F.StripTextures(report.Chart)
		local bg = F.CreateBDFrame(report.Chart, .25)
		bg:SetPoint("TOPLEFT", -C.mult, -3)

		local border = report.RarityBarBorder
		border:Hide()
		local bg = F.CreateBDFrame(border, .25)
		bg:SetPoint("TOPLEFT", border, 6, -5)
		bg:SetPoint("BOTTOMRIGHT", border, -6, 5)

		local note = RematchNotes
		F.StripTextures(note)
		reskinRematchClose(note)
		F.StripTextures(note.LockButton, 2)
		note.LockButton:SetPoint("TOPLEFT")
		local bg = F.CreateBDFrame(note.LockButton, .25)
		bg:SetPoint("TOPLEFT", 7, -7)
		bg:SetPoint("BOTTOMRIGHT", -7, 7)

		local content = note.Content
		F.StripTextures(content)
		F.ReskinScroll(content.ScrollFrame.ScrollBar)
		local bg = F.CreateBDFrame(content.ScrollFrame, .25)
		bg:SetPoint("TOPLEFT", 0, 5)
		bg:SetPoint("BOTTOMRIGHT", 0, -2)
		local bg = F.CreateBDFrame(content.ScrollFrame)
		bg:SetAllPoints(note)
		F.CreateSD(bg)
		for _, icon in pairs({"Left", "Right"}) do
			local bu = content[icon.."Icon"]
			bu:SetMask(nil)
			F.ReskinIcon(bu)
		end

		F.Reskin(note.Controls.DeleteButton)
		F.Reskin(note.Controls.UndoButton)
		F.Reskin(note.Controls.SaveButton)

		styled = true
	end)

	hooksecurefunc(RematchTeamTabs, "Update", function(self)
		for _, tab in next, self.Tabs do
			reskinRematchIcon(tab)
			tab:SetSize(40, 40)
			tab.Icon:SetPoint("CENTER")
		end

		for _, direc in pairs({"UpButton", "DownButton"}) do
			reskinRematchIcon(self[direc])
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

	hooksecurefunc(RematchLoadoutPanel, "UpdateLoadouts", function(self)
		if not self then return end

		for i = 1, 3 do
			local loadout = self.Loadouts[i]
			if not loadout.styled then
				F.StripTextures(loadout)
				local bg = F.CreateBDFrame(loadout, .25)
				bg:SetPoint("BOTTOMRIGHT", C.mult, C.mult)
				reskinRematchIcon(loadout.Pet.Pet)
				reskinRematchXP(loadout.HP)
				reskinRematchXP(loadout.XP)
				loadout.XP:SetSize(255, 7)
				for j = 1, 3 do
					reskinRematchIcon(loadout.Abilities[j])
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
			for i = 1, 3 do
				local tab = typeBar.Tabs[i]
				if not tab.styled then
					F.StripTextures(tab)
					tab.bg = F.CreateBDFrame(tab)
					local r, g, b = tab.Selected.MidSelected:GetVertexColor()
					tab.bg:SetBackdropColor(r, g, b, .5)
					F.StripTextures(tab.Selected)

					tab.styled = true
				end
				tab.bg:SetShown(activeTypeMode == i)
			end
		end
	end)

	local function buttonOnEnter(self)
		self.bg:SetBackdropColor(cr, cg, cb, .25)
	end
	local function buttonOnLeave(self)
		self.bg:SetBackdropColor(0, 0, 0, .25)
	end

	local function reskinRematchPetList(self)
		local buttons = self.ScrollFrame.Buttons
		if not buttons then return end

		for i = 1, #buttons do
			local button = buttons[i]
			if not button.styled then
				local parent
				if button.Pet then
					F.CreateBDFrame(button.Pet)
					if button.Rarity then button.Rarity:SetTexture(nil) end
					if button.LevelBack then button.LevelBack:SetTexture(nil) end
					button.LevelText:SetTextColor(1, 1, 1)
					parent = button.Pet
				end

				if button.Pets then
					for j = 1, 3 do
						local bu = button.Pets[j]
						bu:SetWidth(25)
						F.CreateBDFrame(bu)
					end
					if button.Border then button.Border:SetTexture(nil) end
					parent = button.Pets[3]
				end

				if button.Back then
					button.Back:SetTexture(nil)
					local bg = F.CreateBDFrame(button.Back, .25)
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

	hooksecurefunc(RematchPetPanel.List, "Update", reskinRematchPetList)
	hooksecurefunc(RematchQueuePanel.List, "Update", reskinRematchPetList)
	hooksecurefunc(RematchTeamPanel.List, "Update", reskinRematchPetList)

	hooksecurefunc(RematchTeamPanel, "FillTeamListButton", function(self, key)
		local teamInfo = Rematch.teamInfo:Fetch(key)
		if not teamInfo then return end

		local panel = RematchTeamPanel
		if teamInfo.key == settings.loadedTeam then
			panel.SelectedOverlay:SetAllPoints(self.bg)
		end
	end)

	hooksecurefunc(RematchDialog, "FillTeam", function(self, frame)
		for i = 1, 3 do
			local button = frame.Pets[i]
			if not button.styled then
				reskinRematchIcon(button)
			end
			button.Icon.bg:SetBackdropBorderColor(button.IconBorder:GetVertexColor())

			for j = 1, 3 do
				local bu = button.Abilities[j]
				reskinRematchIcon(bu)
			end
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
					reskinRematchIcon(bu)
				end
			end
		end
	end)

	hooksecurefunc(Rematch, "FillPetTypeIcon", function(_, texture, _, prefix)
		if prefix then
			local button = texture:GetParent()
			reskinRematchIcon(button)
		end
	end)

	hooksecurefunc(Rematch, "MenuButtonSetChecked", function(_, button, isChecked, isRadio)
		if isChecked then
			local x = .5
			local y = isRadio and .5 or .25
			button.Check:SetTexCoord(x, x+.25, y-.25, y)
		else
			button.Check:SetTexCoord(0, 0, 0, 0)
		end

		if not button.styled then
			button.Check:SetVertexColor(cr, cg, cb)
			local bg = F.CreateBDFrame(button.Check, 0)
			bg:SetPoint("TOPLEFT", button.Check, 4, -4)
			bg:SetPoint("BOTTOMRIGHT", button.Check, -4, 4)
			F.CreateGradient(bg)

			button.styled = true
		end
	end)

	hooksecurefunc(Rematch, "FillCommonPetListButton", function(self, petID)
		local petInfo = Rematch.petInfo:Fetch(petID)
		local parentPanel = self:GetParent():GetParent():GetParent():GetParent()
		if petInfo.isSummoned then
			local overlay = parentPanel.SelectedOverlay
			if parentPanel == Rematch.PetPanel and overlay:IsShown() then
				overlay:SetAllPoints(self.bg)
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
				local bg = F.CreateBDFrame(checkButton, 0)
				checkButton.bgTex = F.CreateGradient(bg)
				checkButton.bg = bg
				self.HeaderBack:SetTexture(nil)
			end
			checkButton.bg:SetBackdropColor(0, 0, 0, 0)
			checkButton.bg:Show()
			checkButton.bgTex:Show()

			if self.optType == "header" then
				self.headerIndex = opt[3]
				checkButton:SetSize(8, 8)
				checkButton:SetPoint("LEFT", 5, 0)
				checkButton:SetTexture("Interface\\Buttons\\UI-PlusMinus-Buttons")
				checkButton.bg:SetBackdropColor(0, 0, 0, .25)
				checkButton.bg:SetPoint("TOPLEFT", 0, -2)
				checkButton.bg:SetPoint("BOTTOMRIGHT", 0, 2)
				checkButton.bgTex:Hide()

				local isCollapsed = settings.CollapsedOptHeaders[opt[3]]
				if isCollapsed then
					checkButton:SetTexCoord(0, .4375, 0, .4375)
				else
					checkButton:SetTexCoord(.5625, 1, 0, .4375)
				end
				if self.headerIndex == 0 and panel.allCollapsed then
					checkButton:SetTexCoord(0, .4375, 0, .4375)
				end
			elseif self.optType == "check" then
				checkButton:SetSize(22, 22)
				checkButton.bg:SetPoint("TOPLEFT", checkButton, 2, -2)
				checkButton.bg:SetPoint("BOTTOMRIGHT", checkButton, -2, 2)
				if self.isChecked and self.isDisabled then
					checkButton:SetTexCoord(.25, .5, .75, 1)
				elseif self.isChecked then
					checkButton:SetTexCoord(.5, .75, 0, .25)
				else
					checkButton:SetTexCoord(0, 0, 0, 0)
				end
			elseif self.optType == "radio" then
				local isChecked = settings[opt[2]] == opt[5]
				checkButton:SetSize(22, 22)
				checkButton.bg:SetPoint("TOPLEFT", checkButton, 2, -2)
				checkButton.bg:SetPoint("BOTTOMRIGHT", checkButton, -2, 2)
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
end