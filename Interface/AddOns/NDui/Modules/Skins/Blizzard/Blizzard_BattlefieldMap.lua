local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_BattlefieldMap"] = function()
	local BattlefieldMapFrame = _G.BattlefieldMapFrame
	local BorderFrame = BattlefieldMapFrame.BorderFrame

	B.StripTextures(BorderFrame)
	B.SetBD(BattlefieldMapFrame, nil, -1, 1, -1, 2)
	B.ReskinClose(BorderFrame.CloseButton)

	B.StripTextures(OpacityFrame)
	B.SetBD(OpacityFrame)
	B.ReskinSlider(OpacityFrameSlider, true)
end