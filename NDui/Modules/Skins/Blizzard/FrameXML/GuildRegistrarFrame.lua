local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	GuildAvailableServicesText:SetTextColor(1, 1, 1)
	GuildAvailableServicesText:SetShadowColor(0, 0, 0)

	B.ReskinPortraitFrame(GuildRegistrarFrame, 15, -15, -30, 65)
	B.StripTextures(GuildRegistrarGreetingFrame)
	GuildRegistrarFrameEditBox:SetHeight(20)
	GuildRegistrarFrameEditBox:DisableDrawLayer("BACKGROUND")
	B.ReskinEditBox(GuildRegistrarFrameEditBox)
	B.Reskin(GuildRegistrarFrameGoodbyeButton)
	B.Reskin(GuildRegistrarFramePurchaseButton)
	B.Reskin(GuildRegistrarFrameCancelButton)
end)