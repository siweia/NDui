local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.themes["AuroraClassic"], function()
	local r, g, b = DB.r, DB.g, DB.b

	for i = 1, 6 do
		select(i, GhostFrame:GetRegions()):Hide()
	end
	B.ReskinIcon(GhostFrameContentsFrameIcon)

	B.CreateBD(GhostFrame, .25)
	B.CreateSD(GhostFrame)
	B.CreateGradient(GhostFrame)
	GhostFrame:SetHighlightTexture(DB.bdTex)
	GhostFrame:GetHighlightTexture():SetVertexColor(r, g, b, .25)
end)