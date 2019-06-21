local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	local closeDialog = MovieFrame.CloseDialog

	closeDialog:HookScript("OnShow", function(self)
		self:SetScale(UIParent:GetScale())
	end)

	F.StripTextures(closeDialog)
	F.CreateBD(closeDialog)
	F.CreateSD(closeDialog)
	F.Reskin(closeDialog.ConfirmButton)
	F.Reskin(closeDialog.ResumeButton)
end)