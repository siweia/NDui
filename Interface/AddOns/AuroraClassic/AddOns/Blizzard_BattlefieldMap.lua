local F, C = unpack(select(2, ...))

C.themes["Blizzard_BattlefieldMap"] = function()
	local BattlefieldMapFrame = _G.BattlefieldMapFrame
	local BorderFrame = BattlefieldMapFrame.BorderFrame

	F.StripTextures(BorderFrame)
	F.SetBD(BattlefieldMapFrame, -1, 1, -1, 2)
	F.ReskinClose(BorderFrame.CloseButton)

	F.StripTextures(OpacityFrame)
	F.SetBD(OpacityFrame)
	F.ReskinSlider(OpacityFrameSlider, true)
end