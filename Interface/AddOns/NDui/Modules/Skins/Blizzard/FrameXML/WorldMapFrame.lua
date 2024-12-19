local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local WorldMapFrame = WorldMapFrame
	local BorderFrame = WorldMapFrame.BorderFrame

	B.ReskinPortraitFrame(WorldMapFrame)
	BorderFrame.NineSlice:Hide()
	BorderFrame.Tutorial.Ring:Hide()
	B.ReskinMinMax(BorderFrame.MaximizeMinimizeFrame)

	local overlayFrames = WorldMapFrame.overlayFrames
	B.ReskinDropDown(overlayFrames[1])
	B.StripTextures(overlayFrames[2], 3)
	B.StripTextures(overlayFrames[3], 3)
	overlayFrames[3].ActiveTexture:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Toggle")
	B.ReskinFilterReset(overlayFrames[2].ResetButton)

	local sideToggle = WorldMapFrame.SidePanelToggle
	sideToggle:SetFrameLevel(3)
	sideToggle.OpenButton:GetRegions():Hide()
	B.ReskinArrow(sideToggle.OpenButton, "right")
	sideToggle.CloseButton:GetRegions():Hide()
	B.ReskinArrow(sideToggle.CloseButton, "left")

	for i = 1, #overlayFrames do
		local frame = overlayFrames[i]
		local dropdown = frame.BountyDropdown
		if dropdown then
			B.ReskinArrow(dropdown, "right")
			break
		end
	end
end)