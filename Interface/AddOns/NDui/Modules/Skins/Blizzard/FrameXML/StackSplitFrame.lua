local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	local StackSplitFrame = StackSplitFrame

	B.StripTextures(StackSplitFrame)
	B.SetBD(StackSplitFrame)
	B.Reskin(StackSplitFrame.OkayButton)
	B.Reskin(StackSplitFrame.CancelButton)
	B.ReskinArrow(StackSplitFrame.LeftButton, "left")
	B.ReskinArrow(StackSplitFrame.RightButton, "right")
end)