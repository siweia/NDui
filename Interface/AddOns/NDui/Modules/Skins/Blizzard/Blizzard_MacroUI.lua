local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_MacroUI"] = function()
	MacroHorizontalBarLeft:Hide()
	B.StripTextures(MacroFrameTab1)
	B.StripTextures(MacroFrameTab2)

	B.StripTextures(MacroPopupFrame)
	B.StripTextures(MacroPopupFrame.BorderBox)
	B.StripTextures(MacroPopupScrollFrame)
	B.HideBackdrop(MacroFrameTextBackground) -- isNewPatch

	MacroPopupFrame:SetHeight(525)
	MacroNewButton:ClearAllPoints()
	MacroNewButton:SetPoint("RIGHT", MacroExitButton, "LEFT", -1, 0)

	local function reskinMacroButton(button)
		if button.styled then return end

		button:DisableDrawLayer("BACKGROUND")
		button:SetCheckedTexture(DB.textures.pushed)
		local hl = button:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetInside()

		local icon = _G[button:GetName().."Icon"]
		icon:SetTexCoord(unpack(DB.TexCoord))
		icon:SetInside()
		B.CreateBDFrame(icon, .25)

		button.styled = true
	end

	reskinMacroButton(MacroFrameSelectedMacroButton)

	for i = 1, MAX_ACCOUNT_MACROS do
		reskinMacroButton(_G["MacroButton"..i])
	end

	MacroPopupFrame:HookScript("OnShow", function(self)
		for i = 1, NUM_MACRO_ICONS_SHOWN do
			reskinMacroButton(_G["MacroPopupButton"..i])
		end
		self:SetPoint("TOPLEFT", MacroFrame, "TOPRIGHT", 3, 0)
	end)

	B.ReskinPortraitFrame(MacroFrame)
	B.CreateBDFrame(MacroFrameScrollFrame, .25)
	B.SetBD(MacroPopupFrame)
	MacroPopupEditBox:DisableDrawLayer("BACKGROUND")
	B.ReskinInput(MacroPopupEditBox)
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