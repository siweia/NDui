local F, C = unpack(select(2, ...))

C.themes["Blizzard_WarboardUI"] = function()
	F.ReskinClose(WarboardQuestChoiceFrame.CloseButton)

	hooksecurefunc(WarboardQuestChoiceFrame, "Update", function(self)
		for i = 1, self:GetNumOptions() do
			local option = self.Options[i]
			if not option.styled then
				F.Reskin(option.OptionButtonsContainer.OptionButton1)
				for i = 1, option.WidgetContainer:GetNumChildren() do
					local child = select(i, option.WidgetContainer:GetChildren())
					if child.Text then
						child.Text:SetTextColor(1, 1, 1)
						child.Text.SetTextColor = F.dummy
					end
					option.Header.Text:SetTextColor(1, 1, 1)
					option.Header.SetTextColor = F.dummy
					option.OptionText:SetTextColor(1, .8, 0)
					option.OptionText.SetTextColor = F.dummy
				end

				option.styled = true
			end
		end
	end)
end