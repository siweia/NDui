local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	B.SetBD(TutorialFrame)

	TutorialFrameBackground:Hide()
	TutorialFrameBackground.Show = B.Dummy
	TutorialFrame:DisableDrawLayer("BORDER")

	B.Reskin(TutorialFrameOkayButton, true)
	B.ReskinClose(TutorialFrameCloseButton)
	B.ReskinArrow(TutorialFramePrevButton, "left")
	B.ReskinArrow(TutorialFrameNextButton, "right")

	TutorialFrameOkayButton:ClearAllPoints()
	TutorialFrameOkayButton:SetPoint("BOTTOMLEFT", TutorialFrameNextButton, "BOTTOMRIGHT", 10, 0)

	TutorialFramePrevButton:SetScript("OnEnter", nil)
	TutorialFrameNextButton:SetScript("OnEnter", nil)
	TutorialFrameOkayButton.__bg:SetBackdropColor(0, 0, 0, .25)
	TutorialFramePrevButton.__bg:SetBackdropColor(0, 0, 0, .25)
	TutorialFrameNextButton.__bg:SetBackdropColor(0, 0, 0, .25)
end)