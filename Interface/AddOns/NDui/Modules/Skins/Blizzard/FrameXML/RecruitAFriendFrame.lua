local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local RecruitAFriendFrame = RecruitAFriendFrame

	RecruitAFriendFrame.SplashFrame.Description:SetTextColor(1, 1, 1)
	B.Reskin(RecruitAFriendFrame.SplashFrame.OKButton)
	B.StripTextures(RecruitAFriendFrame.RewardClaiming)
	B.Reskin(RecruitAFriendFrame.RewardClaiming.ClaimOrViewRewardButton)
	B.Reskin(RecruitAFriendFrame.RecruitmentButton)

	local recruitList = RecruitAFriendFrame.RecruitList
	B.StripTextures(recruitList.Header)
	B.CreateBDFrame(recruitList.Header, .25)
	recruitList.ScrollFrameInset:Hide()
	B.ReskinTrimScroll(recruitList.ScrollBar)

	local recruitmentFrame = RecruitAFriendRecruitmentFrame
	B.StripTextures(recruitmentFrame)
	B.ReskinClose(recruitmentFrame.CloseButton)
	B.SetBD(recruitmentFrame)
	B.StripTextures(recruitmentFrame.EditBox)
	local bg = B.CreateBDFrame(recruitmentFrame.EditBox, .25)
	bg:SetPoint("TOPLEFT", -3, -3)
	bg:SetPoint("BOTTOMRIGHT", 0, 3)
	B.Reskin(recruitmentFrame.GenerateOrCopyLinkButton)

	local rewardsFrame = RecruitAFriendRewardsFrame
	B.StripTextures(rewardsFrame)
	B.ReskinClose(rewardsFrame.CloseButton)
	B.SetBD(rewardsFrame)

	rewardsFrame:HookScript("OnShow", function(self)
		for i = 1, self:GetNumChildren() do
			local child = select(i, self:GetChildren())
			local button = child and child.Button
			if button and not button.styled then
				B.ReskinIcon(button.Icon)
				button.IconBorder:Hide()
				button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

				button.styled = true
			end
		end
	end)
end)