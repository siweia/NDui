local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.themes["AuroraClassic"], function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	local StackSplitFrame = StackSplitFrame

	B.StripTextures(StackSplitFrame)
	B.CreateBD(StackSplitFrame)
	B.CreateSD(StackSplitFrame)
	B.Reskin(StackSplitFrame.OkayButton)
	B.Reskin(StackSplitFrame.CancelButton)
end)