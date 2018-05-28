local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	local r, g, b = C.r, C.g, C.b

	local WorldMapFrame = _G.WorldMapFrame
	local BorderFrame = WorldMapFrame.BorderFrame

	F.StripTextures(WorldMapFrame)
	F.StripTextures(BorderFrame)
	WorldMapFramePortrait:SetAlpha(0)
	WorldMapFramePortraitFrame:SetAlpha(0)
	F.SetBD(WorldMapFrame, 1, 0, -3, 2)
	WorldMapFrameTopLeftCorner:SetAlpha(0)
	BorderFrame.Tutorial.Ring:Hide()
	F.ReskinClose(WorldMapFrameCloseButton)

	F.Reskin(WorldMapFrameHomeButton)
	WorldMapFrameHomeButtonLeft:Hide()
	F.StripTextures(WorldMapFrame.NavBar)
	WorldMapFrame.NavBar.overlay:Hide()

	F.ReskinDropDown(WorldMapFrame.overlayFrames[1])
	WorldMapFrame.overlayFrames[2].Border:Hide()
	WorldMapFrame.overlayFrames[2].Background:Hide()

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
			tex:SetSize(2, 2)
			tex:SetPoint("BOTTOMLEFT", 3+i, 3+i)
			tinsert(button.pixels, tex)
		end

		local hline = button:CreateTexture()
		hline:SetColorTexture(1, 1, 1)
		hline:SetSize(7, 2)
		tinsert(button.pixels, hline)

		local vline = button:CreateTexture()
		vline:SetColorTexture(1, 1, 1)
		vline:SetSize(2, 7)
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
end)