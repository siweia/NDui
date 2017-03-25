local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	local RecruitAFriendFrame = RecruitAFriendFrame
	local RecruitAFriendSentFrame = RecruitAFriendSentFrame

	RecruitAFriendFrame.NoteFrame:DisableDrawLayer("BACKGROUND")

	F.CreateBD(RecruitAFriendFrame)
	F.ReskinClose(RecruitAFriendFrameCloseButton)
	F.Reskin(RecruitAFriendFrame.SendButton)
	F.ReskinInput(RecruitAFriendNameEditBox)

	F.CreateBDFrame(RecruitAFriendFrame.NoteFrame, .25)

	F.CreateBD(RecruitAFriendSentFrame)
	F.Reskin(RecruitAFriendSentFrame.OKButton)
	F.ReskinClose(RecruitAFriendSentFrameCloseButton)
end)