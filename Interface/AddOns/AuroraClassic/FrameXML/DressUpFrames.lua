local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	-- Dressup Frame

	F.ReskinPortraitFrame(DressUpFrame)
	F.Reskin(DressUpFrameOutfitDropDown.SaveButton)
	F.Reskin(DressUpFrameCancelButton)
	F.Reskin(DressUpFrameResetButton)
	F.StripTextures(DressUpFrameOutfitDropDown)
	F.ReskinDropDown(DressUpFrameOutfitDropDown)

	DressUpFrameOutfitDropDown:SetHeight(32)
	DressUpFrameOutfitDropDown.SaveButton:SetPoint("LEFT", DressUpFrameOutfitDropDown, "RIGHT", -13, 2)
	DressUpFrameResetButton:SetPoint("RIGHT", DressUpFrameCancelButton, "LEFT", -1, 0)

	if C.isNewPatch then
		F.ReskinMinMax(DressUpFrame.MaximizeMinimizeFrame)
	else
		F.ReskinMinMax(MaximizeMinimizeFrame)
	end

	-- SideDressUp

	F.StripTextures(SideDressUpFrame, 0)
	F.SetBD(SideDressUpFrame)
	F.Reskin(SideDressUpFrame.ResetButton)
	F.ReskinClose(SideDressUpFrameCloseButton)

	SideDressUpFrame:HookScript("OnShow", function(self)
		SideDressUpFrame:ClearAllPoints()
		SideDressUpFrame:SetPoint("LEFT", self:GetParent(), "RIGHT", 3, 0)
	end)
end)