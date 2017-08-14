local F, C = unpack(select(2, ...))

C.themes["Blizzard_AdventureMap"] = function()
	local dialog = AdventureMapQuestChoiceDialog
	for i = 1, 4 do
		select(i, dialog:GetRegions()):SetAlpha(0)
	end
	F.CreateBD(dialog)
	F.CreateSD(dialog)
	F.Reskin(dialog.AcceptButton)
	F.Reskin(dialog.DeclineButton)
	F.ReskinClose(dialog.CloseButton)
	F.ReskinScroll(dialog.Details.ScrollBar)

	dialog:HookScript("OnShow", function(self)
		if self.styled then return end
		for i = 6, 7 do
			local bu = select(i, dialog:GetChildren())
			if bu then
				bu.Icon:SetTexCoord(.08, .92, .08, .92)
				F.CreateBDFrame(bu.Icon)
				bu.ItemNameBG:Hide()
			end
		end
		dialog.Details.Child.TitleHeader:SetTextColor(1, 1, 1)
		dialog.Details.Child.ObjectivesHeader:SetTextColor(1, 1, 1)
		self.styled = true
	end)
end