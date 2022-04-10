local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_MacroUI"] = function()
	MacroHorizontalBarLeft:Hide()
	B.StripTextures(MacroFrameTab1)
	B.StripTextures(MacroFrameTab2)

	B.StripTextures(MacroPopupFrame.BorderBox)
	B.StripTextures(MacroPopupScrollFrame)
	MacroPopupFrame:GetRegions():Hide()
	MacroPopupNameLeft:Hide()
	MacroPopupNameMiddle:Hide()
	MacroPopupNameRight:Hide()
	MacroFrameTextBackground:HideBackdrop()
	select(2, MacroFrameSelectedMacroButton:GetRegions()):Hide()
	MacroFrameSelectedMacroBackground:SetAlpha(0)
	MacroButtonScrollFrameTop:Hide()
	MacroButtonScrollFrameBottom:Hide()
	MacroButtonScrollFrameMiddle:Hide()

	MacroFrameSelectedMacroButton:SetPoint("TOPLEFT", MacroFrameSelectedMacroBackground, "TOPLEFT", 12, -16)
	MacroFrameSelectedMacroButtonIcon:SetPoint("TOPLEFT", C.mult, -C.mult)
	MacroFrameSelectedMacroButtonIcon:SetPoint("BOTTOMRIGHT", -C.mult, C.mult)
	MacroFrameSelectedMacroButtonIcon:SetTexCoord(.08, .92, .08, .92)

	MacroPopupFrame:HookScript("OnShow", function(self)
		self:SetPoint("TOPLEFT", MacroFrame, "TOPRIGHT", 3, 0)
	end)
	MacroPopupFrame:SetHeight(525)
	MacroNewButton:ClearAllPoints()
	MacroNewButton:SetPoint("RIGHT", MacroExitButton, "LEFT", -1, 0)

	for i = 1, MAX_ACCOUNT_MACROS do
		local bu = _G["MacroButton"..i]
		local ic = _G["MacroButton"..i.."Icon"]

		bu:SetCheckedTexture(DB.textures.pushed)
		select(2, bu:GetRegions()):Hide()
		local hl = bu:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)

		ic:SetTexCoord(.08, .92, .08, .92)
		ic:SetAllPoints()
		B.CreateBDFrame(bu, .25)
	end

	MacroPopupFrame:HookScript("OnShow", function()
		for i = 1, NUM_MACRO_ICONS_SHOWN do
			local bu = _G["MacroPopupButton"..i]
			local ic = _G["MacroPopupButton"..i.."Icon"]

			if not bu.styled then
				bu:SetCheckedTexture(DB.textures.pushed)
				select(2, bu:GetRegions()):Hide()
				local hl = bu:GetHighlightTexture()
				hl:SetColorTexture(1, 1, 1, .25)
				hl:SetAllPoints(ic)

				ic:SetPoint("TOPLEFT", C.mult, -C.mult)
				ic:SetPoint("BOTTOMRIGHT", -C.mult, C.mult)
				ic:SetTexCoord(.08, .92, .08, .92)
				B.CreateBDFrame(ic, .25)

				bu.styled = true
			end
		end
	end)

	B.ReskinPortraitFrame(MacroFrame)
	B.CreateBDFrame(MacroFrameScrollFrame, .25)
	B.StripTextures(MacroPopupFrame)
	B.SetBD(MacroPopupFrame)
	B.CreateBDFrame(MacroPopupEditBox, 0, true)
	B.CreateBDFrame(MacroFrameSelectedMacroButton, .25)
	B.Reskin(MacroDeleteButton)
	B.Reskin(MacroNewButton)
	B.Reskin(MacroExitButton)
	B.Reskin(MacroEditButton)
	B.Reskin(MacroPopupFrame.BorderBox.OkayButton)
	B.Reskin(MacroPopupFrame.BorderBox.CancelButton)
	B.Reskin(MacroSaveButton)
	B.Reskin(MacroCancelButton)
	B.ReskinScroll(MacroButtonScrollFrameScrollBar)
	B.ReskinScroll(MacroFrameScrollFrameScrollBar)
	B.ReskinScroll(MacroPopupScrollFrameScrollBar)
end