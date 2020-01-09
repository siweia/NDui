local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.themes["AuroraClassic"], function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	CinematicFrameCloseDialog:HookScript("OnShow", function(self)
		self:SetScale(UIParent:GetScale())
	end)

	B.StripTextures(CinematicFrameCloseDialog)
	B.CreateBD(CinematicFrameCloseDialog)
	B.CreateSD(CinematicFrameCloseDialog)
	B.Reskin(CinematicFrameCloseDialogConfirmButton)
	B.Reskin(CinematicFrameCloseDialogResumeButton)
end)