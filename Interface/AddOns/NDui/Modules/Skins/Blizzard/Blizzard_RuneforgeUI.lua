local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_RuneforgeUI"] = function()
	local frame = RuneforgeFrame

	local createFrame = frame.CreateFrame
	B.Reskin(createFrame.CraftItemButton)
	B.Reskin(createFrame.CloseButton)

	local powerFrame = frame.CraftingFrame.PowerFrame
	B.StripTextures(powerFrame)
	B.SetBD(powerFrame, 1)

	local pageControl = powerFrame.PageControl
	B.ReskinArrow(pageControl.BackwardButton, "left")
	B.ReskinArrow(pageControl.ForwardButton, "right")

	local TT = B:GetModule("Tooltip")
	TT.ReskinTooltip(frame.ResultTooltip)
end