local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_MacroUI"] = function()
	MacroHorizontalBarLeft:Hide()
	B.StripTextures(MacroFrameTab1)
	B.StripTextures(MacroFrameTab2)

	B.StripTextures(MacroPopupFrame)
	B.StripTextures(MacroPopupFrame.BorderBox)
	MacroFrameTextBackground:HideBackdrop()

	MacroPopupFrame:SetHeight(525)
	MacroNewButton:ClearAllPoints()
	MacroNewButton:SetPoint("RIGHT", MacroExitButton, "LEFT", -1, 0)

	if DB.isNewPatch then
		B.ReskinTrimScroll(MacroFrame.MacroSelector.ScrollBar)

		local function handleMacroButton(button)
			local bg = B.ReskinIcon(button.Icon)
			button:DisableDrawLayer("BACKGROUND")
			button.SelectedTexture:SetColorTexture(1, .8, 0, .5)
			button.SelectedTexture:SetInside(bg)
			local hl = button:GetHighlightTexture()
			hl:SetColorTexture(1, 1, 1, .25)
			hl:SetInside(bg)
		end
		handleMacroButton(MacroFrameSelectedMacroButton)

		hooksecurefunc(MacroFrame.MacroSelector.ScrollBox, "Update", function(self)
			for i = 1, self.ScrollTarget:GetNumChildren() do
				local child = select(i, self.ScrollTarget:GetChildren())
				if not child.styled then
					handleMacroButton(child)

					child.styled = true
				end
			end
		end)

		B.ReskinIconSelector(MacroPopupFrame)
	else
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

		MacroPopupEditBox:DisableDrawLayer("BACKGROUND")
		B.ReskinInput(MacroPopupEditBox)
		B.ReskinScroll(MacroButtonScrollFrameScrollBar)
		B.ReskinScroll(MacroFrameScrollFrameScrollBar)
		B.ReskinScroll(MacroPopupScrollFrameScrollBar)
		B.SetBD(MacroPopupFrame)
		B.Reskin(MacroPopupFrame.BorderBox.OkayButton)
		B.Reskin(MacroPopupFrame.BorderBox.CancelButton)
	end

	B.ReskinPortraitFrame(MacroFrame)
	B.CreateBDFrame(MacroFrameScrollFrame, .25)
	B.Reskin(MacroDeleteButton)
	B.Reskin(MacroNewButton)
	B.Reskin(MacroExitButton)
	B.Reskin(MacroEditButton)
	B.Reskin(MacroSaveButton)
	B.Reskin(MacroCancelButton)
end