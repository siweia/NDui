local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	local WorldMapFrame = WorldMapFrame
	local BorderFrame = WorldMapFrame.BorderFrame

	F.StripTextures(WorldMapFrame)
	F.StripTextures(BorderFrame)
	WorldMapFramePortrait:SetAlpha(0)
	WorldMapFramePortraitFrame:SetAlpha(0)
	F.SetBD(WorldMapFrame, 1, 0, -3, 2)
	WorldMapFrameTopLeftCorner:SetAlpha(0)
	BorderFrame.Tutorial.Ring:Hide()
	F.ReskinMinMax(BorderFrame.MaximizeMinimizeFrame)
	F.ReskinClose(WorldMapFrameCloseButton)

	F.ReskinDropDown(WorldMapFrame.overlayFrames[1])
	WorldMapFrame.overlayFrames[2].Border:Hide()
	WorldMapFrame.overlayFrames[2].Background:Hide()
	WorldMapFrame.overlayFrames[2]:GetRegions():Hide()

	WorldMapFrame.SidePanelToggle.OpenButton:GetRegions():Hide()
	F.ReskinArrow(WorldMapFrame.SidePanelToggle.OpenButton, "right")
	WorldMapFrame.SidePanelToggle.CloseButton:GetRegions():Hide()
	F.ReskinArrow(WorldMapFrame.SidePanelToggle.CloseButton, "left")
	F.ReskinNavBar(WorldMapFrame.NavBar)
end)