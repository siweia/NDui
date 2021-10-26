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
			B.ReplaceIconString(self.ContributeButton)
			hooksecurefunc(self.ContributeButton, "SetText", B.ReplaceIconString)

			B.StripTextures(self.Status)
			B.CreateBDFrame(self.Status, .25)

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