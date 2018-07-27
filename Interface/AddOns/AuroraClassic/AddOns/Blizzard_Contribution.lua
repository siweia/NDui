local F, C = unpack(select(2, ...))

C.themes["Blizzard_Contribution"] = function()
	local frame = ContributionCollectionFrame
	F.SetBD(frame)
	F.ReskinClose(frame.CloseButton)
	frame.CloseButton.CloseButtonBackground:Hide()
	frame.Background:Hide()

	hooksecurefunc(ContributionMixin, "Update", function(self)
		if not self.styled then
			self.Header.Text:SetTextColor(1, .8, 0)
			F.Reskin(self.ContributeButton)

			self.styled = true
		end
	end)

	hooksecurefunc(ContributionRewardMixin, "Setup", function(self)
		if not self.styled then
			self.RewardName:SetTextColor(1, 1, 1)
			self.Icon:SetTexCoord(.08, .92, .08, .92)
			self.Border:Hide()
			self:GetRegions():Hide()
			F.CreateBDFrame(self.Icon)

			self.styled = true
		end
	end)

	-- Tooltips
	if AuroraConfig.tooltips then
		ContributionBuffTooltip:DisableDrawLayer("BACKGROUND")
		F.CreateBDFrame(ContributionBuffTooltip)
		F.CreateSD(ContributionBuffTooltip)
		ContributionBuffTooltip.Icon:SetTexCoord(.08, .92, .08, .92)
		ContributionBuffTooltip.Border:SetAlpha(0)
	end
end