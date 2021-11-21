local _, ns = ...
local B, C, L, DB = unpack(ns)

local function reskinPartyPose(frame)
	B.StripTextures(frame)
	if frame.Border then
		frame.Border:SetAlpha(0)
	end
	if frame.OverlayElements then
		frame.OverlayElements.Topper:SetAlpha(0)
	end
	B.SetBD(frame)
	B.Reskin(frame.LeaveButton)
	B.StripTextures(frame.ModelScene)
	B.CreateBDFrame(frame.ModelScene, .25)

	local rewardFrame = frame.RewardAnimations.RewardFrame
	local bg = B.SetBD(rewardFrame)
	bg:SetPoint("TOPLEFT", -5, 5)
	bg:SetPoint("BOTTOMRIGHT", rewardFrame.NameFrame, 0, -5)
	rewardFrame.NameFrame:SetAlpha(0)
	rewardFrame.IconBorder:SetAlpha(0)
	B.ReskinIcon(rewardFrame.Icon)
end

C.themes["Blizzard_IslandsPartyPoseUI"] = function()
	reskinPartyPose(IslandsPartyPoseFrame)
end

C.themes["Blizzard_WarfrontsPartyPoseUI"] = function()
	reskinPartyPose(WarfrontsPartyPoseFrame)
end