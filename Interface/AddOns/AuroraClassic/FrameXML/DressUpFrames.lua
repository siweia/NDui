local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
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

	F.ReskinMinMax(MaximizeMinimizeFrame)

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
	F.CreateBDFrame(SideDressUpModel)
end)
