local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	F.CreateBD(TutorialFrame)
	F.CreateSD(TutorialFrame)

	TutorialFrameBackground:Hide()
	TutorialFrameBackground.Show = F.dummy
	TutorialFrame:DisableDrawLayer("BORDER")

	F.Reskin(TutorialFrameOkayButton, true)
	F.ReskinClose(TutorialFrameCloseButton)
	F.ReskinArrow(TutorialFramePrevButton, "left")
	F.ReskinArrow(TutorialFrameNextButton, "right")

	TutorialFrameOkayButton:ClearAllPoints()
	TutorialFrameOkayButton:SetPoint("BOTTOMLEFT", TutorialFrameNextButton, "BOTTOMRIGHT", 10, 0)

	-- because gradient alpha and OnUpdate doesn't work for some reason...

	if select(14, TutorialFrameOkayButton:GetRegions()) then
		select(14, TutorialFrameOkayButton:GetRegions()):Hide()
		select(15, TutorialFramePrevButton:GetRegions()):Hide()
		select(15, TutorialFrameNextButton:GetRegions()):Hide()
		select(14, TutorialFrameCloseButton:GetRegions()):Hide()
	end
	TutorialFramePrevButton:SetScript("OnEnter", nil)
	TutorialFrameNextButton:SetScript("OnEnter", nil)
	TutorialFrameOkayButton:SetBackdropColor(0, 0, 0, .25)
	TutorialFramePrevButton:SetBackdropColor(0, 0, 0, .25)
	TutorialFrameNextButton:SetBackdropColor(0, 0, 0, .25)
end)