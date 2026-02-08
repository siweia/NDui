local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	B.SetBD(TutorialFrame)

	TutorialFrame:DisableDrawLayer("BORDER")
	B.Reskin(TutorialFrameOkayButton, true)
	TutorialFrameOkayButton:ClearAllPoints()
	TutorialFrameOkayButton:SetPoint("BOTTOMLEFT", TutorialFrameNextButton, "BOTTOMRIGHT", 10, 0)
	TutorialFrameOkayButton.__bg:SetBackdropColor(0, 0, 0, .25)
end)