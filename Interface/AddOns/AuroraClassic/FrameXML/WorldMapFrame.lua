local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	local WorldMapFrame = WorldMapFrame
	local BorderFrame = WorldMapFrame.BorderFrame

	F.ReskinPortraitFrame(WorldMapFrame)
	BorderFrame.NineSlice:Hide()
	BorderFrame.Tutorial.Ring:Hide()
	F.ReskinMinMax(BorderFrame.MaximizeMinimizeFrame)

	local overlayFrames = WorldMapFrame.overlayFrames
	F.ReskinDropDown(overlayFrames[1])
	overlayFrames[2]:DisableDrawLayer("BACKGROUND")
	overlayFrames[2]:DisableDrawLayer("OVERLAY")

	local sideToggle = WorldMapFrame.SidePanelToggle
	sideToggle.OpenButton:GetRegions():Hide()
	F.ReskinArrow(sideToggle.OpenButton, "right")
	sideToggle.CloseButton:GetRegions():Hide()
	F.ReskinArrow(sideToggle.CloseButton, "left")

	F.ReskinNavBar(WorldMapFrame.NavBar)
end)