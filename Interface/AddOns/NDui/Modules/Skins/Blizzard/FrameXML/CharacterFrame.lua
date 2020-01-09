local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.themes["AuroraClassic"], function()
	B.ReskinPortraitFrame(CharacterFrame)
	B.StripTextures(CharacterFrameInsetRight)

	for i = 1, 3 do
		B.ReskinTab(_G["CharacterFrameTab"..i])
	end
end)