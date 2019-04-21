local F, C = unpack(select(2, ...))

C.themes["Blizzard_WarboardUI"] = function()
	local reskinFont = AuroraConfig.reskinFont

	hooksecurefunc(WarboardQuestChoiceFrame, "Update", function(self)
		for i = 1, self:GetNumOptions() do
			local option = self.Options[i]
			if reskinFont then
				option.OptionText:SetTextColor(1, .8, 0)
				option.Header.Text:SetTextColor(1, 1, 1)
			end

			for i = 1, option.WidgetContainer:GetNumChildren() do
				local child = select(i, option.WidgetContainer:GetChildren())
				if child.Text and reskinFont then
					child.Text:SetTextColor(1, 1, 1)
				end

				if child.Spell then
					if not child.Spell.bg then
						child.Spell.Border:Hide()
						child.Spell.IconMask:Hide()
						child.Spell.bg = F.ReskinIcon(child.Spell.Icon)
					end

					if reskinFont then
						child.Spell.Text:SetTextColor(1, 1, 1)
					end
				end

				for j = 1, child:GetNumChildren() do
					local child2 = select(j, child:GetChildren())
					if child2 then
						if child2.Text and reskinFont then
							child2.Text:SetTextColor(1, 1, 1)
						end

						if child2.LeadingText and reskinFont then
							child2.LeadingText:SetTextColor(1, .8, 0)
						end

						if child2.Icon and not child2.Icon.bg then
							child2.Icon.bg = F.ReskinIcon(child2.Icon)
						end
					end
				end
			end

			if not option.styled then
				F.Reskin(option.OptionButtonsContainer.OptionButton1)
				F.Reskin(option.OptionButtonsContainer.OptionButton2)

				option.styled = true
			end
		end
	end)
	F.ReskinClose(WarboardQuestChoiceFrame.CloseButton)
end