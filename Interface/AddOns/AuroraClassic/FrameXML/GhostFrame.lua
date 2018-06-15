local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	local r, g, b = C.r, C.g, C.b

	for i = 1, 6 do
		select(i, GhostFrame:GetRegions()):Hide()
	end
	F.ReskinIcon(GhostFrameContentsFrameIcon)

	F.CreateBD(GhostFrame, .25)
	F.CreateSD(GhostFrame)
	F.CreateGradient(GhostFrame)
	GhostFrame:SetHighlightTexture(C.media.backdrop)
	GhostFrame:GetHighlightTexture():SetVertexColor(r, g, b, .25)
end)