local F, C = unpack(select(2, ...))

C.themes["Blizzard_QuestChoice"] = function()
	local QuestChoiceFrame = QuestChoiceFrame

	for i = 1, 15 do
		select(i, QuestChoiceFrame:GetRegions()):Hide()
	end

	for i = 17, 19 do
		select(i, QuestChoiceFrame:GetRegions()):Hide()
	end

	local numOptions = #QuestChoiceFrame.Options
	for i = 1, numOptions do
		local option = QuestChoiceFrame["Option"..i]
		local rewards = option.Rewards
		local item = rewards.Item
		local currencies = rewards.Currencies

		option.Header.Background:Hide()
		option.Header.Text:SetTextColor(.9, .9, .9)
		option.Artwork:SetTexCoord(0.140625, 0.84375, 0.2265625, 0.78125)
		option.Artwork:SetSize(180, 71)
		option.Artwork:SetPoint("TOP", 0, -20)
		option.OptionText:SetTextColor(.9, .9, .9)

		item.Name:SetTextColor(1, 1, 1)
		item.Icon:SetTexCoord(.08, .92, .08, .92)
		item.bg = F.CreateBDFrame(item.Icon)

		for j = 1, 3 do
			local cu = currencies["Currency"..j]

			cu.Icon:SetTexCoord(.08, .92, .08, .92)
			F.CreateBDFrame(cu.Icon)
		end
		F.Reskin(option.OptionButton)
	end

	hooksecurefunc("QuestChoiceFrame_ShowRewards", function(numOptions)
		for i = 1, numOptions do
			local rewards = QuestChoiceFrame["Option"..i].Rewards
			rewards.Item.bg:SetBackdropBorderColor(rewards.Item.IconBorder:GetVertexColor())
			rewards.Item.IconBorder:Hide()
		end
	end)

	F.CreateBD(QuestChoiceFrame)
	F.CreateSD(QuestChoiceFrame)
	F.ReskinClose(QuestChoiceFrame.CloseButton)
end