local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	CharacterFrameInsetRight:DisableDrawLayer("BACKGROUND")
	CharacterFrameInsetRight:DisableDrawLayer("BORDER")

	F.ReskinPortraitFrame(CharacterFrame, true)

	local i = 1
	while _G["CharacterFrameTab"..i] do
		F.ReskinTab(_G["CharacterFrameTab"..i])
		i = i + 1
	end
end)