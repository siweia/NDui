local _, ns = ...
local B, C, L, DB = unpack(ns)

local function handleSpellButton(self)
	local slot, slotType = SpellBook_GetSpellBookSlot(self)
	local isPassive = C_Spell.IsSpellPassive(slot, SpellBookFrame.bookType)
	local name = self:GetName()
	local highlightTexture = _G[name.."Highlight"]
	if isPassive then
		highlightTexture:SetColorTexture(1, 1, 1, 0)
	else
		highlightTexture:SetColorTexture(1, 1, 1, .25)
	end

	local subSpellString = _G[name.."SubSpellName"]
	local isOffSpec = self.offSpecID ~= 0 and SpellBookFrame.bookType == BOOKTYPE_SPELL
	subSpellString:SetTextColor(1, 1, 1)

	if slotType == "FUTURESPELL" then
		local level = GetSpellAvailableLevel(slot, SpellBookFrame.bookType)
		if level and level > UnitLevel("player") then
			self.SpellName:SetTextColor(.7, .7, .7)
			subSpellString:SetTextColor(.7, .7, .7)
		end
	else
		if slotType == "SPELL" and isOffSpec then
			subSpellString:SetTextColor(.7, .7, .7)
		end
	end
	self.RequiredLevelString:SetTextColor(.7, .7, .7)

	local ic = _G[name.."IconTexture"]
	if ic.bg then
		ic.bg:SetShown(ic:IsShown())
	end

	if self.ClickBindingIconCover and self.ClickBindingIconCover:IsShown() then
		self.SpellName:SetTextColor(.7, .7, .7)
	end
end

local function reskinTalentFrameDialog(dialog)
	B.StripTextures(dialog)
	B.SetBD(dialog)
	if dialog.AcceptButton then B.Reskin(dialog.AcceptButton) end
	if dialog.CancelButton then B.Reskin(dialog.CancelButton) end
	if dialog.DeleteButton then B.Reskin(dialog.DeleteButton) end

	B.ReskinEditBox(dialog.NameControl.EditBox)
	dialog.NameControl.EditBox.__bg:SetPoint("TOPLEFT", -5, -10)
	dialog.NameControl.EditBox.__bg:SetPoint("BOTTOMRIGHT", 5, 10)
end

C.themes["Blizzard_PlayerSpells"] = function()
	local frame = PlayerSpellsFrame

	B.ReskinPortraitFrame(frame)
	B.Reskin(frame.TalentsFrame.ApplyButton)
	B.ReskinDropDown(frame.TalentsFrame.LoadSystem.Dropdown)
	B.Reskin(frame.TalentsFrame.InspectCopyButton)
	B.ReskinMinMax(frame.MaximizeMinimizeButton)

	frame.TalentsFrame.BlackBG:SetAlpha(.5)
	frame.TalentsFrame.Background:SetAlpha(.5)
	frame.TalentsFrame.BottomBar:SetAlpha(.5)

	B.ReskinEditBox(frame.TalentsFrame.SearchBox)
	frame.TalentsFrame.SearchBox.__bg:SetPoint("TOPLEFT", -4, -5)
	frame.TalentsFrame.SearchBox.__bg:SetPoint("BOTTOMRIGHT", 0, 5)

	for i = 1, 3 do
		local tab = select(i, frame.TabSystem:GetChildren())
		B.ReskinTab(tab)
	end

	hooksecurefunc(frame.SpecFrame, "UpdateSpecFrame", function(self)
		for specContentFrame in self.SpecContentFramePool:EnumerateActive() do
			if not specContentFrame.styled then
				B.Reskin(specContentFrame.ActivateButton)

				local role = GetSpecializationRole(specContentFrame.specIndex)
				if role then
					B.ReskinSmallRole(specContentFrame.RoleIcon, role)
				end

				if specContentFrame.SpellButtonPool then
					for button in specContentFrame.SpellButtonPool:EnumerateActive() do
						button.Ring:Hide()
						B.ReskinIcon(button.Icon)

						local texture = button.spellID and C_Spell.GetSpellTexture(button.spellID)
						if texture then
							button.Icon:SetTexture(texture)
						end
					end
				end

				specContentFrame.styled = true
			end
		end
	end)

	local dialog = ClassTalentLoadoutImportDialog
	if dialog then
		reskinTalentFrameDialog(dialog)
		B.StripTextures(dialog.ImportControl.InputContainer)
		B.CreateBDFrame(dialog.ImportControl.InputContainer, .25)
	end

	local dialog = ClassTalentLoadoutCreateDialog
	if dialog then
		reskinTalentFrameDialog(dialog)
	end

	local dialog = ClassTalentLoadoutEditDialog
	if dialog then
		reskinTalentFrameDialog(dialog)

		local editbox = dialog.LoadoutName
		if editbox then
			B.ReskinEditBox(editbox)
			editbox.__bg:SetPoint("TOPLEFT", -5, -5)
			editbox.__bg:SetPoint("BOTTOMRIGHT", 5, 5)
		end

		local check = dialog.UsesSharedActionBars
		if check then
			B.ReskinCheck(check.CheckButton)
			check.CheckButton.bg:SetInside(nil, 6, 6)
		end
	end

	local dialog = HeroTalentsSelectionDialog
	if dialog then
		B.StripTextures(dialog)
		B.SetBD(dialog, 1)
		B.ReskinClose(dialog.CloseButton)

		hooksecurefunc(dialog, "ShowDialog", function(self)
			for specFrame in self.SpecContentFramePool:EnumerateActive() do
				if not specFrame.styled then
					B.Reskin(specFrame.ActivateButton)
					B.Reskin(specFrame.ApplyChangesButton)
					specFrame.styled = true
				end
			end
		end)
	end

	local spellBook = PlayerSpellsFrame.SpellBookFrame
	if spellBook then
		spellBook.BookBGLeft:SetAlpha(.5)
		spellBook.BookBGRight:SetAlpha(.5)
		spellBook.BookBGHalved:SetAlpha(.5)
		spellBook.Bookmark:SetAlpha(.5)
		spellBook.BookCornerFlipbook:Hide()

		for i = 1, 3 do
			local tab = select(i, spellBook.CategoryTabSystem:GetChildren())
			B.ReskinTab(tab)
		end
		B.ReskinArrow(spellBook.PagedSpellsFrame.PagingControls.PrevPageButton, "left")
		B.ReskinArrow(spellBook.PagedSpellsFrame.PagingControls.NextPageButton, "right")
		spellBook.PagedSpellsFrame.PagingControls.PageText:SetTextColor(1, 1, 1)
		B.ReskinEditBox(spellBook.SearchBox)
		spellBook.SearchBox.__bg:SetPoint("TOPLEFT", -5, -3)
		spellBook.SearchBox.__bg:SetPoint("BOTTOMRIGHT", 2, 3)

		hooksecurefunc(spellBook.PagedSpellsFrame, "DisplayViewsForCurrentPage", function(self)
			for _, frame in self:EnumerateFrames() do
				if not frame.styled then
					if frame.Text then
						frame.Text:SetTextColor(1, .8, 0)
					end
					if frame.Name then
						frame.Name:SetTextColor(1, 1, 1)
					end
					if frame.SubName then
						frame.SubName:SetTextColor(.7, .7, .7)
					end

					frame.styled = true
				end
			end
		end)

		local button = spellBook.AssistedCombatRotationSpellFrame.Button
		if button then
			button.Border:Hide()
			button:SetPushedTexture(0)
			button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			B.ReskinIcon(button.Icon)
		end
	end
end