local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_ClassTalentUI"] = function()
	local frame = ClassTalentFrame

	B.ReskinPortraitFrame(frame)
	B.Reskin(frame.TalentsTab.ApplyButton)
	B.ReskinDropDown(frame.TalentsTab.LoadoutDropDown.DropDownControl.DropDownMenu)

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
				specContentFrame.styled = true
			end
		end
	end)

	local dialog = ClassTalentImportDialog or ClassTalentLoadoutImportDialog
	if dialog then
		B.StripTextures(dialog)
		B.SetBD(dialog)
		B.Reskin(dialog.AcceptButton)
		B.Reskin(dialog.CancelButton)

		B.StripTextures(dialog.ImportBox)
		B.CreateBDFrame(dialog.ImportBox, .25)
	end
end