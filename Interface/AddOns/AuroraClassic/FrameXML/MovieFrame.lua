local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	MovieFrame.CloseDialog:HookScript("OnShow", function(self)
		self:SetScale(UIParent:GetScale())
	end)

	F.CreateBD(MovieFrame.CloseDialog)
	F.CreateSD(MovieFrame.CloseDialog)
	F.Reskin(MovieFrame.CloseDialog.ConfirmButton)
	F.Reskin(MovieFrame.CloseDialog.ResumeButton)
end)