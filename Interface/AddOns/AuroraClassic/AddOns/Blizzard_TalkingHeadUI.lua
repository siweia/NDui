local F, C = unpack(select(2, ...))

C.themes["Blizzard_TalkingHeadUI"] = function()
	local TalkingHeadFrame = TalkingHeadFrame
	TalkingHeadFrame:SetScale(.9)

	local portraitFrame = TalkingHeadFrame.PortraitFrame
	F.StripTextures(portraitFrame)
	portraitFrame.Portrait:SetAtlas(nil)
	portraitFrame.Portrait.SetAtlas = F.dummy

	local model = TalkingHeadFrame.MainFrame.Model
	model:SetPoint("TOPLEFT", 30, -27)
	model:SetSize(100, 100)
	model.PortraitBg:SetAtlas(nil)
	model.PortraitBg.SetAtlas = F.dummy

	local name = TalkingHeadFrame.NameFrame.Name
	name:SetTextColor(1, 0.82, 0.02)
	name.SetTextColor = F.dummy
	name:SetShadowColor(0, 0, 0, 0)

	local text = TalkingHeadFrame.TextFrame.Text
	text:SetTextColor(1, 1, 1)
	text.SetTextColor = F.dummy
	text:SetShadowColor(0, 0, 0, 0)

	local closeButton = TalkingHeadFrame.MainFrame.CloseButton
	F.ReskinClose(closeButton)
	closeButton:ClearAllPoints()
	closeButton:SetPoint("TOPRIGHT", -25, -25)
end