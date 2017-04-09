local F, C = unpack(select(2, ...))

C.themes["Blizzard_Contribution"] = function()
	local r, g, b = C.r, C.g, C.b

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

	hooksecurefunc(ContributionMixin, "FindOrAcquireReward", function(self, rewardID)
		local reward = self.rewards[rewardID]
		if not reward.styled then
			reward.RewardName:SetTextColor(1, 1, 1)
			reward.Icon:SetTexCoord(.08, .92, .08, .92)
			reward.Border:Hide()
			F.CreateBDFrame(reward.Icon)

			reward.styled = true
		end
	end)

	-- Tooltips
	if AuroraConfig.tooltips then
		ContributionTooltip:SetBackdrop(nil)
		ContributionBuffTooltip:DisableDrawLayer("BACKGROUND")
		F.CreateBDFrame(ContributionTooltip)
		F.CreateBDFrame(ContributionBuffTooltip)
		ContributionBuffTooltip.Icon:SetTexCoord(.08, .92, .08, .92)
		ContributionBuffTooltip.Border:SetAlpha(0)
	end
end