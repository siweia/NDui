local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	-- Cinematic

	CinematicFrameCloseDialog:HookScript("OnShow", function(self)
		self:SetScale(UIParent:GetScale())
	end)

	B.StripTextures(CinematicFrameCloseDialog)
	B.SetBD(CinematicFrameCloseDialog)
	B.Reskin(CinematicFrameCloseDialogConfirmButton)
	B.Reskin(CinematicFrameCloseDialogResumeButton)

	-- Movie

	local closeDialog = MovieFrame.CloseDialog

	closeDialog:HookScript("OnShow", function(self)
		self:SetScale(UIParent:GetScale())
	end)

	B.StripTextures(closeDialog)
	B.SetBD(closeDialog)
	B.Reskin(closeDialog.ConfirmButton)
	B.Reskin(closeDialog.ResumeButton)
end)