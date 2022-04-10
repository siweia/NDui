local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	-- Dressup Frame

	B.ReskinPortraitFrame(DressUpFrame, 13, -10, -35, 75)
	B.Reskin(DressUpFrameCancelButton)
	B.Reskin(DressUpFrameResetButton)
	B.ReskinRotationButtons(DressUpModelFrame)

	DressUpFrameResetButton:SetPoint("RIGHT", DressUpFrameCancelButton, "LEFT", -2, 0)

	-- SideDressUp

	B.StripTextures(SideDressUpFrame, 0)
	select(5, SideDressUpModelCloseButton:GetRegions()):Hide()

	SideDressUpModel:HookScript("OnShow", function(self)
		self:ClearAllPoints()
		self:SetPoint("LEFT", self:GetParent():GetParent(), "RIGHT", C.mult, 0)
	end)

	B.Reskin(SideDressUpModelResetButton)
	B.ReskinClose(SideDressUpModelCloseButton)
	B.SetBD(SideDressUpModel)
end)
