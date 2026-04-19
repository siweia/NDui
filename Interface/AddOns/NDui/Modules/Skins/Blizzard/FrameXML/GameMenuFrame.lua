local _, ns = ...
local B, C, L, DB = unpack(ns)

if DB.isNewPatch then

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	B.StripTextures(GameMenuFrame.Header)
	B.SetBD(GameMenuFrame)
	GameMenuFrame.Border:Hide()
	GameMenuFrame.Header.Text:SetFontObject(Game16Font)
	local line = GameMenuFrame.Header:CreateTexture(nil, "ARTWORK")
	line:SetSize(144, C.mult)
	line:SetPoint("BOTTOM", 0, 15)
	line:SetColorTexture(1, 1, 1, .25)

	local cr, cg, cb = DB.r, DB.g, DB.b

	hooksecurefunc(GameMenuFrame, "InitButtons", function(self)
		if not self.buttonPool then return end

		for button in self.buttonPool:EnumerateActive() do
			if not button.styled then
				button:DisableDrawLayer("BACKGROUND")
				button.bg = B.CreateBDFrame(button, 0, true)
				local hl = button:GetHighlightTexture()
				hl:SetColorTexture(cr, cg, cb, .25)
				hl:SetInside(button.bg)
				button.bg:SetInside()

				button.styled = true
			end
		end
	end)
end)

else

tinsert(C.defaultThemes, function()
	GameMenuFrameHeader:SetAlpha(0)
	GameMenuFrameHeader:ClearAllPoints()
	GameMenuFrameHeader:SetPoint("TOP", GameMenuFrame, 0, 7)
	B.StripTextures(GameMenuFrame)
	B.SetBD(GameMenuFrame)

	local buttons = {
		GameMenuButtonHelp,
		GameMenuButtonWhatsNew,
		GameMenuButtonStore,
		GameMenuButtonOptions,
		GameMenuButtonUIOptions,
		GameMenuButtonKeybindings,
		GameMenuButtonMacros,
		GameMenuButtonAddons,
		GameMenuButtonLogout,
		GameMenuButtonQuit,
		GameMenuButtonContinue
	}

	for _, button in next, buttons do
		B.Reskin(button)
	end
end)
end