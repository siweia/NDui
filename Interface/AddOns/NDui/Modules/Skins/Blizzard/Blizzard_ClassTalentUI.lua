local _, ns = ...
local B, C, L, DB = unpack(ns)

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

C.themes["Blizzard_ClassTalentUI"] = function()
	local frame = ClassTalentFrame

	B.ReskinPortraitFrame(frame)
	B.Reskin(frame.TalentsTab.ApplyButton)
	B.ReskinDropDown(frame.TalentsTab.LoadoutDropDown.DropDownControl.DropDownMenu)
	B.Reskin(frame.TalentsTab.InspectCopyButton)

	B.ReskinEditBox(frame.TalentsTab.SearchBox)
	frame.TalentsTab.SearchBox.__bg:SetPoint("TOPLEFT", -4, -5)
	frame.TalentsTab.SearchBox.__bg:SetPoint("BOTTOMRIGHT", 0, 5)

	for i = 1, 2 do
		local tab = select(i, frame.TabSystem:GetChildren())
		B.ReskinTab(tab)
	end

	hooksecurefunc(frame.SpecTab, "UpdateSpecFrame", function(self)
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
end