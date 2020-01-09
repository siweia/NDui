local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_WarfrontsPartyPoseUI"] = function()
	B.StripTextures(WarfrontsPartyPoseFrame)
	B.SetBD(WarfrontsPartyPoseFrame)
	B.Reskin(WarfrontsPartyPoseFrame.LeaveButton)
	B.StripTextures(WarfrontsPartyPoseFrame.ModelScene)
	B.CreateBDFrame(WarfrontsPartyPoseFrame.ModelScene, .25)

	local rewardFrame = WarfrontsPartyPoseFrame.RewardAnimations.RewardFrame
	local bg = B.CreateBDFrame(rewardFrame)
	bg:SetPoint("TOPLEFT", -5, 5)
	bg:SetPoint("BOTTOMRIGHT", rewardFrame.NameFrame, 0, -5)
	B.CreateSD(bg)
	rewardFrame.NameFrame:SetAlpha(0)
	rewardFrame.IconBorder:SetAlpha(0)
	rewardFrame.Icon:SetTexCoord(.08, .92, .08, .92)
	B.CreateBDFrame(rewardFrame.Icon)
end