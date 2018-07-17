local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	F.CreateBD(StackSplitFrame)
	F.CreateSD(StackSplitFrame)
	StackSplitFrame:GetRegions():Hide()
	F.Reskin(StackSplitOkayButton)
	F.Reskin(StackSplitCancelButton)
end)