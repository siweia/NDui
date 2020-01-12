local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_IslandsPartyPoseUI"] = function()
	B.StripTextures(IslandsPartyPoseFrame)
	B.SetBD(IslandsPartyPoseFrame)
	B.Reskin(IslandsPartyPoseFrame.LeaveButton)
	B.StripTextures(IslandsPartyPoseFrame.ModelScene)
	B.CreateBDFrame(IslandsPartyPoseFrame.ModelScene, .25)

	local rewardFrame = IslandsPartyPoseFrame.RewardAnimations.RewardFrame
	local bg = B.CreateBDFrame(rewardFrame, nil, true)
	bg:SetPoint("TOPLEFT", -5, 5)
	bg:SetPoint("BOTTOMRIGHT", rewardFrame.NameFrame, 0, -5)
	rewardFrame.NameFrame:SetAlpha(0)
	rewardFrame.IconBorder:SetAlpha(0)
	B.ReskinIcon(rewardFrame.Icon)
end