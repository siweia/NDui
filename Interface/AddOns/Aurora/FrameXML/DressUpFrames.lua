local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	-- Dressup Frame

	DressUpFramePortrait:Hide()
	for i = 1, 17 do
		select(i, DressUpFrame:GetRegions()):Hide()
	end
	select(8, DressUpFrame:GetRegions()):Show()
	DressUpFrameInset:Hide()
	MaximizeMinimizeFrame:GetRegions():Hide()

	F.SetBD(DressUpFrame, 5, 5, -5, 0)
	F.Reskin(DressUpFrameOutfitDropDown.SaveButton)
	F.Reskin(DressUpFrameCancelButton)
	F.Reskin(DressUpFrameResetButton)
	F.ReskinDropDown(DressUpFrameOutfitDropDown)
	F.ReskinClose(DressUpFrameCloseButton, "TOPRIGHT", DressUpFrame, "TOPRIGHT", -10, 0)

	DressUpFrameOutfitDropDown:SetHeight(32)
	DressUpFrameOutfitDropDown.SaveButton:SetPoint("LEFT", DressUpFrameOutfitDropDown, "RIGHT", -13, 2)
	DressUpFrameResetButton:SetPoint("RIGHT", DressUpFrameCancelButton, "LEFT", -1, 0)

	for _, button in pairs{MaximizeMinimizeFrame.MaximizeButton, MaximizeMinimizeFrame.MinimizeButton} do

		button:SetSize(17, 17)
		button:ClearAllPoints()
		button:SetPoint("RIGHT", DressUpFrameCloseButton, "LEFT", -1, 0)

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

		if button == MaximizeMinimizeFrame.MaximizeButton then
			hline:SetPoint("TOP", 1, -4)
			vline:SetPoint("RIGHT", -4, 1)
		else
			hline:SetPoint("BOTTOM", 1, 4)
			vline:SetPoint("LEFT", 4, 1)
		end

		button:SetScript("OnEnter", colourArrow)
		button:SetScript("OnLeave", clearArrow)
	end

	-- SideDressUp

	for i = 1, 4 do
		select(i, SideDressUpFrame:GetRegions()):Hide()
	end
	select(5, SideDressUpModelCloseButton:GetRegions()):Hide()

	SideDressUpModel:HookScript("OnShow", function(self)
		self:ClearAllPoints()
		self:SetPoint("LEFT", self:GetParent():GetParent(), "RIGHT", 1, 0)
	end)

	F.Reskin(SideDressUpModelResetButton)
	F.ReskinClose(SideDressUpModelCloseButton)

	SideDressUpModel.bg = CreateFrame("Frame", nil, SideDressUpModel)
	SideDressUpModel.bg:SetPoint("TOPLEFT", 0, 1)
	SideDressUpModel.bg:SetPoint("BOTTOMRIGHT", 1, -1)
	SideDressUpModel.bg:SetFrameLevel(SideDressUpModel:GetFrameLevel()-1)
	F.CreateBD(SideDressUpModel.bg)
end)
