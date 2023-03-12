local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	ScriptErrorsFrame:SetScale(UIParent:GetScale())
	B.StripTextures(ScriptErrorsFrame)
	B.SetBD(ScriptErrorsFrame)

	B.ReskinArrow(ScriptErrorsFrame.PreviousError, "left")
	B.ReskinArrow(ScriptErrorsFrame.NextError, "right")
	B.Reskin(ScriptErrorsFrame.Reload)
	B.Reskin(ScriptErrorsFrame.Close)
	if DB.isPatch10_1 then
		B.ReskinTrimScroll(ScriptErrorsFrame.ScrollFrame.ScrollBar)
	else
		B.ReskinScroll(ScriptErrorsFrameScrollBar)
	end
	B.ReskinClose(ScriptErrorsFrameClose)
end)