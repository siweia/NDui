local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()		
	GhostFrameLeft:Hide()
	GhostFrameRight:Hide()
	GhostFrameMiddle:Hide()
	for i = 3, 6 do
		select(i, GhostFrame:GetRegions()):Hide()
	end
	GhostFrameContentsFrameIcon:SetTexCoord(.08, .92, .08, .92)

	local GhostBD = CreateFrame("Frame", nil, GhostFrameContentsFrame)
	GhostBD:SetPoint("TOPLEFT", GhostFrameContentsFrameIcon, -1, 1)
	GhostBD:SetPoint("BOTTOMRIGHT", GhostFrameContentsFrameIcon, 1, -1)
	F.CreateBD(GhostBD, 0)
	F.Reskin(GhostFrame)
end)