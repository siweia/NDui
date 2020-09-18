local _, ns = ...
local B, C, L, DB = unpack(ns)

-- /run LoadAddOn'Blizzard_GMChatUI' GMChatFrame:Show()
C.themes["Blizzard_GMChatUI"] = function()
	local frame = _G["GMChatFrame"]
	frame:SetClampRectInsets(0, 0, 0, 0)
	B.StripTextures(frame)
	local bg = B.SetBD(frame)
	bg:SetPoint("BOTTOMRIGHT", C.mult, -5)

	local eb = frame.editBox
	eb:SetAltArrowKeyMode(false)
	for i = 3, 8 do
		select(i, eb:GetRegions()):SetAlpha(0)
	end
	eb:ClearAllPoints()
	eb:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -7)
	eb:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -28, -32)

	local bg = B.SetBD(eb)
	bg:Hide()
	hooksecurefunc("ChatEdit_DeactivateChat", function(editBox)
		if editBox.isGM then bg:Hide() end
	end)
	hooksecurefunc("ChatEdit_ActivateChat", function(editBox)
		if editBox.isGM then bg:Show() end
	end)

	local lang = _G["GMChatFrameEditBoxLanguage"]
	lang:GetRegions():SetAlpha(0)
	lang:SetPoint("TOPLEFT", eb, "TOPRIGHT", 3, 0)
	lang:SetPoint("BOTTOMRIGHT", eb, "BOTTOMRIGHT", 28, 0)
	B.SetBD(lang)

	local tab = _G["GMChatTab"]
	B.StripTextures(tab)
	local bg = B.SetBD(tab)
	bg:SetBackdropColor(0, .6, 1, .3)
	tab:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 3)
	tab:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 28)
	GMChatTabIcon:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-Blizz")

	local close = GMChatFrameCloseButton
	B.ReskinClose(close)
	close:ClearAllPoints()
	close:SetPoint("RIGHT", tab, -5, 0)

	B.HideObject(frame.buttonFrame)
end