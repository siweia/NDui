local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	GuildRegistrarFrameEditBox:SetHeight(20)
	AvailableServicesText:SetTextColor(1, 1, 1)
	AvailableServicesText:SetShadowColor(0, 0, 0)

	F.ReskinPortraitFrame(GuildRegistrarFrame)
	F.CreateBD(GuildRegistrarFrameEditBox, .25)
	F.Reskin(GuildRegistrarFrameGoodbyeButton)
	F.Reskin(GuildRegistrarFramePurchaseButton)
	F.Reskin(GuildRegistrarFrameCancelButton)
end)