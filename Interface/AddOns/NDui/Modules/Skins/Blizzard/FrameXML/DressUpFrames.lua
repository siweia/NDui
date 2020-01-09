local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.themes["AuroraClassic"], function()
	-- Dressup Frame

	B.ReskinPortraitFrame(DressUpFrame)
	B.Reskin(DressUpFrameOutfitDropDown.SaveButton)
	B.Reskin(DressUpFrameCancelButton)
	B.Reskin(DressUpFrameResetButton)
	B.StripTextures(DressUpFrameOutfitDropDown)
	B.ReskinDropDown(DressUpFrameOutfitDropDown)

	DressUpFrameOutfitDropDown:SetHeight(32)
	DressUpFrameOutfitDropDown.SaveButton:SetPoint("LEFT", DressUpFrameOutfitDropDown, "RIGHT", -13, 2)
	DressUpFrameResetButton:SetPoint("RIGHT", DressUpFrameCancelButton, "LEFT", -1, 0)

	if DB.isNewPatch then
		B.ReskinMinMax(DressUpFrame.MaximizeMinimizeFrame)
	else
		B.ReskinMinMax(MaximizeMinimizeFrame)
	end

	-- SideDressUp

	B.StripTextures(SideDressUpFrame, 0)
	B.SetBD(SideDressUpFrame)
	B.Reskin(SideDressUpFrame.ResetButton)
	B.ReskinClose(SideDressUpFrameCloseButton)

	SideDressUpFrame:HookScript("OnShow", function(self)
		SideDressUpFrame:ClearAllPoints()
		SideDressUpFrame:SetPoint("LEFT", self:GetParent(), "RIGHT", 3, 0)
	end)
end)