local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	GuildRegistrarFrameTop:Hide()
	GuildRegistrarFrameBottom:Hide()
	GuildRegistrarFrameMiddle:Hide()
	select(19, GuildRegistrarFrame:GetRegions()):Hide()

	GuildRegistrarFrameEditBox:SetHeight(20)
	AvailableServicesText:SetTextColor(1, 1, 1)
	AvailableServicesText:SetShadowColor(0, 0, 0)

	F.ReskinPortraitFrame(GuildRegistrarFrame, true)
	F.CreateBD(GuildRegistrarFrameEditBox, .25)
	F.Reskin(GuildRegistrarFrameGoodbyeButton)
	F.Reskin(GuildRegistrarFramePurchaseButton)
	F.Reskin(GuildRegistrarFrameCancelButton)
end)