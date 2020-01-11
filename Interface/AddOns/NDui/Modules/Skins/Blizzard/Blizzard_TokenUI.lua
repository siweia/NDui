local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.themes["AuroraClassic"], function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	local r, g, b = DB.r, DB.g, DB.b

	TokenFramePopupCorner:Hide()
	TokenFramePopup:SetPoint("TOPLEFT", TokenFrame, "TOPRIGHT", 1, -28)
	B.StripTextures(TokenFramePopup)
	B.CreateBD(TokenFramePopup)
	B.CreateSD(TokenFramePopup)
	B.ReskinClose(TokenFramePopupCloseButton)
	B.ReskinCheck(TokenFramePopupInactiveCheckBox)
	B.ReskinCheck(TokenFramePopupBackpackCheckBox)

	local function updateButtons()
		local buttons = TokenFrameContainer.buttons
		if not buttons then return end

		for i = 1, #buttons do
			local bu = buttons[i]

			if not bu.styled then
				bu.highlight:SetPoint("TOPLEFT", 1, 0)
				bu.highlight:SetPoint("BOTTOMRIGHT", -1, 0)
				bu.highlight.SetPoint = B.Dummy
				bu.highlight:SetColorTexture(r, g, b, .2)
				bu.highlight.SetTexture = B.Dummy

				bu.categoryMiddle:SetAlpha(0)
				bu.categoryLeft:SetAlpha(0)
				bu.categoryRight:SetAlpha(0)

				bu.bg = B.ReskinIcon(bu.icon)

				if bu.expandIcon then
					bu.expBg = B.CreateBDFrame(bu.expandIcon, .25)
					bu.expBg:SetPoint("TOPLEFT", bu.expandIcon, -3, 3)
					bu.expBg:SetPoint("BOTTOMRIGHT", bu.expandIcon, 3, -3)
					B.CreateGradient(bu.expBg)
				end

				bu.styled = true
			end

			if bu.isHeader then
				bu.bg:Hide()
				bu.expBg:Show()
			else
				bu.bg:Show()
				bu.expBg:Hide()
			end
		end
	end

	TokenFrame:HookScript("OnShow", updateButtons)
	hooksecurefunc("TokenFrame_Update", updateButtons)
	hooksecurefunc(TokenFrameContainer, "update", updateButtons)

	B.ReskinScroll(TokenFrameContainerScrollBar)
end)