local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	-- Dressup Frame

	DressUpFramePortrait:Hide()
	DressUpBackgroundTopLeft:Hide()
	DressUpBackgroundTopRight:Hide()
	DressUpBackgroundBotLeft:Hide()
	DressUpBackgroundBotRight:Hide()
	for i = 2, 5 do
		select(i, DressUpFrame:GetRegions()):Hide()
	end

	F.SetBD(DressUpFrame, 10, -12, -34, 74)
	F.Reskin(DressUpFrameOutfitDropDown.SaveButton)
	F.Reskin(DressUpFrameCancelButton)
	F.Reskin(DressUpFrameResetButton)
	F.ReskinDropDown(DressUpFrameOutfitDropDown)
	F.ReskinClose(DressUpFrameCloseButton, "TOPRIGHT", DressUpFrame, "TOPRIGHT", -38, -16)

	DressUpFrameOutfitDropDown:SetHeight(32)
	DressUpFrameOutfitDropDown.SaveButton:SetPoint("LEFT", DressUpFrameOutfitDropDown, "RIGHT", -13, 2)
	DressUpFrameResetButton:SetPoint("RIGHT", DressUpFrameCancelButton, "LEFT", -1, 0)

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
