local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	local RecruitAFriendFrame = RecruitAFriendFrame

	RecruitAFriendFrame.SplashFrame.Description:SetTextColor(1, 1, 1)
	F.Reskin(RecruitAFriendFrame.SplashFrame.OKButton)
	F.StripTextures(RecruitAFriendFrame.RewardClaiming)
	F.Reskin(RecruitAFriendFrame.RewardClaiming.ClaimOrViewRewardButton)
	F.Reskin(RecruitAFriendFrame.RecruitmentButton)

	local recruitList = RecruitAFriendFrame.RecruitList
	F.StripTextures(recruitList.Header)
	F.CreateBDFrame(recruitList.Header, .25)
	recruitList.ScrollFrameInset:Hide()
	F.ReskinScroll(recruitList.ScrollFrame.scrollBar)

	local recruitmentFrame = RecruitAFriendRecruitmentFrame
	F.StripTextures(recruitmentFrame)
	F.ReskinClose(recruitmentFrame.CloseButton)
	F.SetBD(recruitmentFrame)
	F.StripTextures(recruitmentFrame.EditBox)
	local bg = F.CreateBDFrame(recruitmentFrame.EditBox, .25)
	bg:SetPoint("TOPLEFT", -3, -3)
	bg:SetPoint("BOTTOMRIGHT", 0, 3)
	F.Reskin(recruitmentFrame.GenerateOrCopyLinkButton)

	local rewardsFrame = RecruitAFriendRewardsFrame
	F.StripTextures(rewardsFrame)
	F.ReskinClose(rewardsFrame.CloseButton)
	F.SetBD(rewardsFrame)

	rewardsFrame:HookScript("OnShow", function(self)
		for i = 1, self:GetNumChildren() do
			local child = select(i, self:GetChildren())
			local button = child and child.Button
			if button and not button.styled then
				F.ReskinIcon(button.Icon)
				button.IconBorder:Hide()
				button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

				button.styled = true
			end
		end
	end)
end)