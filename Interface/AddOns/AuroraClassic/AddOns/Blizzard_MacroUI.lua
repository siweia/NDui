local F, C = unpack(select(2, ...))

C.themes["Blizzard_MacroUI"] = function()
	select(18, MacroFrame:GetRegions()):Hide()
	MacroHorizontalBarLeft:Hide()
	select(21, MacroFrame:GetRegions()):Hide()
	F.StripTextures(MacroFrameTab1)
	F.StripTextures(MacroFrameTab2)

	for i = 1, 8 do
		select(i, MacroPopupFrame.BorderBox:GetRegions()):Hide()
	end
	for i = 1, 3 do
		select(i, MacroPopupScrollFrame:GetRegions()):Hide()
	end
	MacroPopupFrame:GetRegions():Hide()
	MacroPopupNameLeft:Hide()
	MacroPopupNameMiddle:Hide()
	MacroPopupNameRight:Hide()
	MacroFrameTextBackground:SetBackdrop(nil)
	select(2, MacroFrameSelectedMacroButton:GetRegions()):Hide()
	MacroFrameSelectedMacroBackground:SetAlpha(0)
	MacroButtonScrollFrameTop:Hide()
	MacroButtonScrollFrameBottom:Hide()
	MacroButtonScrollFrameMiddle:Hide()

	MacroFrameSelectedMacroButton:SetPoint("TOPLEFT", MacroFrameSelectedMacroBackground, "TOPLEFT", 12, -16)
	MacroFrameSelectedMacroButtonIcon:SetPoint("TOPLEFT", 1, -1)
	MacroFrameSelectedMacroButtonIcon:SetPoint("BOTTOMRIGHT", -1, 1)
	MacroFrameSelectedMacroButtonIcon:SetTexCoord(.08, .92, .08, .92)

	MacroPopupFrame:SetPoint("TOPLEFT", MacroFrame, "TOPRIGHT", 1, 0)
	MacroPopupFrame:SetHeight(525)
	MacroNewButton:ClearAllPoints()
	MacroNewButton:SetPoint("RIGHT", MacroExitButton, "LEFT", -1, 0)

	for i = 1, MAX_ACCOUNT_MACROS do
		local bu = _G["MacroButton"..i]
		local ic = _G["MacroButton"..i.."Icon"]

		bu:SetCheckedTexture(C.media.checked)
		select(2, bu:GetRegions()):Hide()

		ic:SetPoint("TOPLEFT", 1, -1)
		ic:SetPoint("BOTTOMRIGHT", -1, 1)
		ic:SetTexCoord(.08, .92, .08, .92)

		F.CreateBD(bu, .25)
	end

	MacroPopupFrame:HookScript("OnShow", function()
		for i = 1, NUM_MACRO_ICONS_SHOWN do
			local bu = _G["MacroPopupButton"..i]
			local ic = _G["MacroPopupButton"..i.."Icon"]

			if not bu.styled then
				bu:SetCheckedTexture(C.media.checked)
				select(2, bu:GetRegions()):Hide()

				ic:SetPoint("TOPLEFT", 1, -1)
				ic:SetPoint("BOTTOMRIGHT", -1, 1)
				ic:SetTexCoord(.08, .92, .08, .92)

				F.CreateBD(bu, .25)
				bu.styled = true
			end
		end
	end)

	F.ReskinPortraitFrame(MacroFrame, true)
	F.CreateBD(MacroFrameScrollFrame, .25)
	F.CreateBD(MacroPopupFrame)
	F.CreateSD(MacroPopupFrame)
	F.CreateBD(MacroPopupEditBox, .25)
	F.CreateBD(MacroFrameSelectedMacroButton, .25)
	F.Reskin(MacroDeleteButton)
	F.Reskin(MacroNewButton)
	F.Reskin(MacroExitButton)
	F.Reskin(MacroEditButton)
	F.Reskin(MacroPopupFrame.BorderBox.OkayButton)
	F.Reskin(MacroPopupFrame.BorderBox.CancelButton)
	F.Reskin(MacroSaveButton)
	F.Reskin(MacroCancelButton)
	F.ReskinScroll(MacroButtonScrollFrameScrollBar)
	F.ReskinScroll(MacroFrameScrollFrameScrollBar)
	F.ReskinScroll(MacroPopupScrollFrameScrollBar)
end