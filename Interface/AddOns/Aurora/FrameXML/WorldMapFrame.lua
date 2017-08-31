local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	local r, g, b = C.r, C.g, C.b

	local WorldMapFrame = WorldMapFrame
	local BorderFrame = WorldMapFrame.BorderFrame

	WorldMapFrame.UIElementsFrame.CloseQuestPanelButton:GetRegions():Hide()
	WorldMapFrame.UIElementsFrame.OpenQuestPanelButton:GetRegions():Hide()
	BorderFrame.Bg:Hide()
	select(2, BorderFrame:GetRegions()):Hide()
	BorderFrame.portrait:SetTexture("")
	BorderFrame.portraitFrame:SetTexture("")
	for i = 5, 7 do
		select(i, BorderFrame:GetRegions()):SetAlpha(0)
	end
	BorderFrame.TopTileStreaks:SetTexture("")
	for i = 10, 14 do
		select(i, BorderFrame:GetRegions()):Hide()
	end
	BorderFrame.ButtonFrameEdge:Hide()
	BorderFrame.InsetBorderTop:Hide()
	BorderFrame.Inset.Bg:Hide()
	BorderFrame.Inset:DisableDrawLayer("BORDER")

	F.SetBD(BorderFrame, 1, 0, -3, 2)
	F.ReskinClose(BorderFrame.CloseButton)
	F.ReskinArrow(WorldMapFrame.UIElementsFrame.CloseQuestPanelButton, "left")
	F.ReskinArrow(WorldMapFrame.UIElementsFrame.OpenQuestPanelButton, "right")
	F.ReskinDropDown(WorldMapLevelDropDown)
	F.ReskinNavBar(WorldMapFrameNavBar)

	BorderFrame.CloseButton:SetPoint("TOPRIGHT", -9, -6)

	WorldMapLevelDropDown:SetPoint("TOPLEFT", -14, 2)

	-- [[ Size up / down buttons ]]

	for _, button in pairs{WorldMapFrame.BorderFrame.MaximizeMinimizeFrame.MaximizeButton, WorldMapFrame.BorderFrame.MaximizeMinimizeFrame.MinimizeButton} do

		button:SetSize(17, 17)
		button:ClearAllPoints()
		button:SetPoint("RIGHT", BorderFrame.CloseButton, "LEFT", -1, 0)

		F.Reskin(button)

		local function colourArrow(f)
			if f:IsEnabled() then
				for _, pixel in pairs(f.pixels) do
					pixel:SetVertexColor(r, g, b)
				end
			end
		end

		local function clearArrow(f)
			for _, pixel in pairs(f.pixels) do
				pixel:SetVertexColor(1, 1, 1)
			end
		end

		button.pixels = {}

		for i = 1, 8 do
			local tex = button:CreateTexture()
			tex:SetColorTexture(1, 1, 1)
			tex:SetSize(1, 1)
			tex:SetPoint("BOTTOMLEFT", 3+i, 3+i)
			tinsert(button.pixels, tex)
		end

		local hline = button:CreateTexture()
		hline:SetColorTexture(1, 1, 1)
		hline:SetSize(7, 1)
		tinsert(button.pixels, hline)

		local vline = button:CreateTexture()
		vline:SetColorTexture(1, 1, 1)
		vline:SetSize(1, 7)
		tinsert(button.pixels, vline)

		if button == WorldMapFrame.BorderFrame.MaximizeMinimizeFrame.MaximizeButton then
			hline:SetPoint("TOP", 1, -4)
			vline:SetPoint("RIGHT", -4, 1)
		else
			hline:SetPoint("BOTTOM", 1, 4)
			vline:SetPoint("LEFT", 4, 1)
		end

		button:SetScript("OnEnter", colourArrow)
		button:SetScript("OnLeave", clearArrow)
	end

	-- [[ Misc ]]

	WorldMapFrameTutorialButton.Ring:Hide()
	WorldMapFrameTutorialButton:SetPoint("TOPLEFT", WorldMapFrame, "TOPLEFT", -12, 12)

	do
		local topLine = WorldMapFrame.UIElementsFrame:CreateTexture()
		topLine:SetColorTexture(0, 0, 0)
		topLine:SetHeight(1)
		topLine:SetPoint("TOPLEFT", 0, 1)
		topLine:SetPoint("TOPRIGHT", 1, 1)

		local rightLine = WorldMapFrame.UIElementsFrame:CreateTexture()
		rightLine:SetColorTexture(0, 0, 0)
		rightLine:SetWidth(1)
		rightLine:SetPoint("BOTTOMRIGHT", 1, 0)
		rightLine:SetPoint("TOPRIGHT", 1, 1)
	end

	-- [[ Tracking options ]]

	local TrackingOptions = WorldMapFrame.UIElementsFrame.TrackingOptionsButton

	TrackingOptions:GetRegions():Hide()
	TrackingOptions.Background:Hide()
	TrackingOptions.IconOverlay:SetTexture("")
	TrackingOptions.Button.Border:Hide()

	-- Battlefield Minimap

	for i = 1, 9 do
		select(i, OpacityFrame:GetRegions()):Hide()
	end
	F.SetBD(OpacityFrame)
	F.ReskinSlider(OpacityFrameSlider)
end)