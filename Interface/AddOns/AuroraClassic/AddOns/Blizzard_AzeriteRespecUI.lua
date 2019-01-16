local F, C = unpack(select(2, ...))

C.themes["Blizzard_AzeriteRespecUI"] = function()
	for i = 1, 14 do
		select(i, AzeriteRespecFrame:GetRegions()):Hide()
	end
	F.CreateBDFrame(AzeriteRespecFrame.Background)
	AzeriteRespecFrame.NineSlice:Hide()
	F.SetBD(AzeriteRespecFrame)
	F.ReskinClose(AzeriteRespecFrameCloseButton)
	AzeriteRespecFrame.ItemSlot.Icon:SetTexCoord(.08, .92, .08, .92)
	F.CreateBDFrame(AzeriteRespecFrame.ItemSlot.Icon)

	F.StripTextures(AzeriteRespecFrame.ButtonFrame)
	AzeriteRespecFrame.ButtonFrame:GetRegions():SetAlpha(0)
	AzeriteRespecFrame.ButtonFrame.MoneyFrameEdge:Hide()
	local bg = F.CreateBDFrame(AzeriteRespecFrame.ButtonFrame, .25)
	bg:SetPoint("TOPLEFT", AzeriteRespecFrame.ButtonFrame.MoneyFrameEdge, 3, 0)
	bg:SetPoint("BOTTOMRIGHT", AzeriteRespecFrame.ButtonFrame.MoneyFrameEdge, 0, 2)
	F.Reskin(AzeriteRespecFrame.ButtonFrame.AzeriteRespecButton)
end