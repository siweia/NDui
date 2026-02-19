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

	B.ReskinTrimScroll(MacroFrame.MacroSelector.ScrollBar)

	local function handleMacroButton(button)
		if button.styled then return end
		button.styled = true
		local bg = B.ReskinIcon(button.Icon)
		button:DisableDrawLayer("BACKGROUND")
		button.SelectedTexture:SetColorTexture(1, .8, 0, .5)
		button.SelectedTexture:SetInside(bg)
		local hl = button:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetInside(bg)
	end
	handleMacroButton(MacroFrameSelectedMacroButton)

	C_Timer.After(0, function() -- add delay to avoid taint
		hooksecurefunc(MacroFrame.MacroSelector.ScrollBox, "Update", function(self)
			if self.view then
				self:ForEachFrame(handleMacroButton)
			end
		end)
		MacroFrame.MacroSelector.ScrollBox:ForEachFrame(handleMacroButton)
	end)

	B.ReskinIconSelector(MacroPopupFrame)

	B.ReskinPortraitFrame(MacroFrame)
	B.CreateBDFrame(MacroFrameScrollFrame, .25)
	B.ReskinTrimScroll(MacroFrameScrollFrame.ScrollBar)
	B.Reskin(MacroDeleteButton)
	B.Reskin(MacroNewButton)
	B.Reskin(MacroExitButton)
	B.Reskin(MacroEditButton)
	B.Reskin(MacroSaveButton)
	B.Reskin(MacroCancelButton)
end