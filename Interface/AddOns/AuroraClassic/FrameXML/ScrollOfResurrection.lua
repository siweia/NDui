local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	F.CreateBD(ScrollOfResurrectionSelectionFrame)
	F.CreateSD(ScrollOfResurrectionSelectionFrame)
	F.CreateBD(ScrollOfResurrectionFrame)
	F.CreateSD(ScrollOfResurrectionFrame)
	F.ReskinScroll(ScrollOfResurrectionSelectionFrameListScrollFrameScrollBar)
	F.ReskinInput(ScrollOfResurrectionSelectionFrameTargetEditBox)
	F.ReskinInput(ScrollOfResurrectionFrameNoteFrame)
	for i = 1, 6 do
		select(i, ScrollOfResurrectionFrameNoteFrame:GetRegions()):Hide()
	end
	F.Reskin(ScrollOfResurrectionSelectionFrameAcceptButton)
	F.Reskin(ScrollOfResurrectionSelectionFrameCancelButton)
	F.Reskin(ScrollOfResurrectionFrameAcceptButton)
	F.Reskin(ScrollOfResurrectionFrameCancelButton)
	F.CreateBD(ScrollOfResurrectionSelectionFrameList, .25)
end)