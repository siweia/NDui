local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	ScriptErrorsFrame:SetScale(UIParent:GetScale())
	B.StripTextures(ScriptErrorsFrame)
	B.SetBD(ScriptErrorsFrame)

	B.Reskin(select(4, ScriptErrorsFrame:GetChildren()))
	B.ReskinArrow(select(5, ScriptErrorsFrame:GetChildren()), "left")
	B.ReskinArrow(select(6, ScriptErrorsFrame:GetChildren()), "right")
	B.Reskin(select(7, ScriptErrorsFrame:GetChildren()))
	B.ReskinTrimScroll(ScriptErrorsFrame.ScrollFrame.ScrollBar)
	B.ReskinClose(ScriptErrorsFrameClose)
end)