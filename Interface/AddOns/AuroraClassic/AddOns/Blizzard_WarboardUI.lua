local F, C = unpack(select(2, ...))

C.themes["Blizzard_WarboardUI"] = function()
	for i = 1, 13 do
		select(i, WarboardQuestChoiceFrame:GetRegions()):Hide()
	end
	select(5, WarboardQuestChoiceFrame:GetRegions()):Show()
	WarboardQuestChoiceFrame.GarrCorners:Hide()
	WarboardQuestChoiceFrame.Background:Hide()
	F.SetBD(WarboardQuestChoiceFrame)
	F.ReskinClose(WarboardQuestChoiceFrame.CloseButton)

	for _, option in pairs(WarboardQuestChoiceFrame.Options) do
		F.Reskin(option.OptionButton)
		option.Header.Text:SetTextColor(1, .8, 0)
		option.OptionText:SetTextColor(1, 1, 1)
	end
end