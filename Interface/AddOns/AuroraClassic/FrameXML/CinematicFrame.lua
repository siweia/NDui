local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	CinematicFrameCloseDialog:HookScript("OnShow", function(self)
		self:SetScale(UIParent:GetScale())
	end)

	F.CreateBD(CinematicFrameCloseDialog)
	F.CreateSD(CinematicFrameCloseDialog)
	F.Reskin(CinematicFrameCloseDialogConfirmButton)
	F.Reskin(CinematicFrameCloseDialogResumeButton)
end)