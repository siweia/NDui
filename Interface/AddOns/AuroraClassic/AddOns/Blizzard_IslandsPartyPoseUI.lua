local F, C = unpack(select(2, ...))

C.themes["Blizzard_IslandsPartyPoseUI"] = function()
	F.StripTextures(IslandsPartyPoseFrame)
	F.SetBD(IslandsPartyPoseFrame)
	F.Reskin(IslandsPartyPoseFrame.LeaveButton)
	F.StripTextures(IslandsPartyPoseFrame.ModelScene)
	F.CreateBDFrame(IslandsPartyPoseFrame.ModelScene, .25)
end