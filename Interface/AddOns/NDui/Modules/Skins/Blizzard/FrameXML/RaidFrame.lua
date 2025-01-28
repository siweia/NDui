local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	B.StripTextures(RaidInfoFrame)
	B.SetBD(RaidInfoFrame)
	B.ReskinCheck(RaidFrameAllAssistCheckButton)

	RaidInfoFrame:SetPoint("TOPLEFT", RaidFrame, "TOPRIGHT", 1, -28)

	B.Reskin(RaidFrameRaidInfoButton)
	B.Reskin(RaidFrameConvertToRaidButton)
	B.ReskinClose(RaidInfoCloseButton)
	if DB.isNewPatch then
		B.ReskinTrimScroll(RaidInfoFrame.ScrollBar)
	else
		B.ReskinScroll(RaidInfoScrollFrameScrollBar)
	end
	B.ReskinClose(RaidParentFrameCloseButton)

	B.ReskinPortraitFrame(RaidParentFrame)

	if RaidInfoInstanceLabel then
		local function handleHeader(header)
			B.StripTextures(header)
			local bg = B.CreateBDFrame(header, .25)
			bg:SetPoint("TOPLEFT", 2, 0)
			bg:SetPoint("BOTTOMRIGHT", -2, 0)
		end
		handleHeader(RaidInfoInstanceLabel)
		handleHeader(RaidInfoIDLabel)
		B.Reskin(RaidInfoCancelButton)
	end
end)