local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	B.StripTextures(GameMenuFrame.Header)
	GameMenuFrame.Header:ClearAllPoints()
	GameMenuFrame.Header:SetPoint("TOP", GameMenuFrame, 0, 7)
	B.SetBD(GameMenuFrame)
	GameMenuFrame.Border:Hide()

	local buttons = {
		"GameMenuButtonHelp",
		"GameMenuButtonWhatsNew",
		"GameMenuButtonStore",
		"GameMenuButtonMacros",
		"GameMenuButtonAddons",
		"GameMenuButtonLogout",
		"GameMenuButtonQuit",
		"GameMenuButtonContinue",
		"GameMenuButtonSettings",
		"GameMenuButtonEditMode",
	}
	for _, buttonName in next, buttons do
		local button = _G[buttonName]
		if button then
			B.Reskin(button)
		end
	end

	if DB.isWW then
		hooksecurefunc(GameMenuFrame, "InitButtons", function(self)
			if not self.buttonPool then return end

			for button in self.buttonPool:EnumerateActive() do
				if not button.styled then
					B.Reskin(button)
					button.styled = true
				end
			end
		end)
	end
end)