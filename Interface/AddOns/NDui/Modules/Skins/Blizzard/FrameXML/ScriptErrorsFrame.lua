local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.themes["AuroraClassic"], function()
	ScriptErrorsFrame:SetScale(UIParent:GetScale())
	B.StripTextures(ScriptErrorsFrame)
	B.SetBD(ScriptErrorsFrame)

	B.ReskinArrow(ScriptErrorsFrame.PreviousError, "left")
	B.ReskinArrow(ScriptErrorsFrame.NextError, "right")
	B.Reskin(ScriptErrorsFrame.Reload)
	B.Reskin(ScriptErrorsFrame.Close)
	B.ReskinScroll(ScriptErrorsFrameScrollBar)
	B.ReskinClose(ScriptErrorsFrameClose)
end)