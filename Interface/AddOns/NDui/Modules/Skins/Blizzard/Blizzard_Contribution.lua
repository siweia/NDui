local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_Contribution"] = function()
	local frame = ContributionCollectionFrame
	B.SetBD(frame)
	B.ReskinClose(frame.CloseButton)
	frame.CloseButton.CloseButtonBackground:Hide()
	frame.Background:Hide()

	hooksecurefunc(ContributionMixin, "Update", function(self)
		if not self.styled then
			self.Header.Text:SetTextColor(1, .8, 0)
			B.Reskin(self.ContributeButton)

			self.styled = true
		end
	end)

	hooksecurefunc(ContributionRewardMixin, "Setup", function(self)
		if not self.styled then
			self.RewardName:SetTextColor(1, 1, 1)
			self.Border:Hide()
			self:GetRegions():Hide()
			B.ReskinIcon(self.Icon)

			self.styled = true
		end
	end)
end

C.themes["Blizzard_PlayerChoiceUI"] = function()
	B.ReskinClose(PlayerChoiceFrame.CloseButton)

	local function reskinOptionButton(self)
		if self.button1 and not self.button1.styled then
			B.Reskin(self.button1)
			self.button1.styled = true
		end
	end
	for i = 1, 4 do
		local option = PlayerChoiceFrame.Options[i]
		hooksecurefunc(option.OptionButtonsContainer, "ConfigureButtons", reskinOptionButton)
	end
end

C.themes["Blizzard_Soulbinds"] = function()
	B.ReskinClose(SoulbindViewer.CloseButton)
	B.Reskin(SoulbindViewer.ActivateButton)
end

C.themes["Blizzard_CovenantPreviewUI"] = function()
	B.ReskinClose(CovenantPreviewFrame.CloseButton)
	B.Reskin(CovenantPreviewFrame.SelectButton)
	CovenantPreviewFrame.InfoPanel.Description:SetTextColor(1, 1, 1)
	CovenantPreviewFrame.InfoPanel.AbilitiesLabel:SetTextColor(1, .8, 0)
end