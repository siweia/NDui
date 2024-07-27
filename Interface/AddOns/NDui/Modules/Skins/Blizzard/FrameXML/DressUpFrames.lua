local _, ns = ...
local B, C, L, DB = unpack(ns)

local function ResetToggleTexture(button, texture)
	button:GetNormalTexture():SetTexCoord(unpack(DB.TexCoord))
	button:GetNormalTexture():SetInside()
	button:SetNormalTexture(texture)
	button:GetPushedTexture():SetTexCoord(unpack(DB.TexCoord))
	button:GetPushedTexture():SetInside()
	button:SetPushedTexture(texture)
end

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local r, g, b = DB.r, DB.g, DB.b

	-- Dressup Frame

	B.ReskinPortraitFrame(DressUpFrame)
	B.Reskin(DressUpFrameCancelButton)
	B.Reskin(DressUpFrameResetButton)
	B.ReskinMinMax(DressUpFrame.MaximizeMinimizeFrame)

	B.Reskin(DressUpFrame.LinkButton)
	B.Reskin(DressUpFrame.ToggleOutfitDetailsButton)
	ResetToggleTexture(DressUpFrame.ToggleOutfitDetailsButton, 1392954) -- 70_professions_scroll_01

	B.StripTextures(DressUpFrame.OutfitDetailsPanel)
	local bg = B.SetBD(DressUpFrame.OutfitDetailsPanel)
	bg:SetInside(nil, 11, 11)

	hooksecurefunc(DressUpFrame.OutfitDetailsPanel, "Refresh", function(self)
		if self.slotPool then
			for slot in self.slotPool:EnumerateActive() do
				if not slot.bg then
					slot.bg = B.ReskinIcon(slot.Icon)
					B.ReskinIconBorder(slot.IconBorder, true, true)
				end
			end
		end
	end)

	DressUpFrameResetButton:SetPoint("RIGHT", DressUpFrameCancelButton, "LEFT", -1, 0)

	B.ReskinCheck(TransmogAndMountDressupFrame.ShowMountCheckButton)
	B.ReskinModelControl(DressUpFrame.ModelScene)

	local selectionPanel = DressUpFrame.SetSelectionPanel
	if selectionPanel then
		B.StripTextures(selectionPanel)
		B.SetBD(selectionPanel):SetInside(nil, 9, 9)

		local function SetupSetButton(button)
			if button.styled then return end
			button.bg = B.ReskinIcon(button.Icon)
			B.ReskinIconBorder(button.IconBorder, true, true)
			button.BackgroundTexture:SetAlpha(0)
			button.SelectedTexture:SetColorTexture(1, .8, 0, .25)
			button.HighlightTexture:SetColorTexture(1, 1, 1, .25)
			button.styled = true
		end

		hooksecurefunc(selectionPanel.ScrollBox, "Update", function(self)
			self:ForEachFrame(SetupSetButton)
		end)
	end

	B.ReskinDropDown(DressUpFrameOutfitDropdown)
	B.Reskin(DressUpFrameOutfitDropdown.SaveButton)

	-- SideDressUp

	B.StripTextures(SideDressUpFrame, 0)
	B.SetBD(SideDressUpFrame)
	B.Reskin(SideDressUpFrame.ResetButton)
	B.ReskinClose(SideDressUpFrameCloseButton)

	SideDressUpFrame:HookScript("OnShow", function(self)
		SideDressUpFrame:ClearAllPoints()
		SideDressUpFrame:SetPoint("LEFT", self:GetParent(), "RIGHT", 3, 0)
	end)

	-- Outfit frame

	B.StripTextures(WardrobeOutfitEditFrame)
	WardrobeOutfitEditFrame.EditBox:DisableDrawLayer("BACKGROUND")
	B.SetBD(WardrobeOutfitEditFrame)
	local bg = B.CreateBDFrame(WardrobeOutfitEditFrame.EditBox, .25, true)
	bg:SetPoint("TOPLEFT", -5, -3)
	bg:SetPoint("BOTTOMRIGHT", 5, 3)
	B.Reskin(WardrobeOutfitEditFrame.AcceptButton)
	B.Reskin(WardrobeOutfitEditFrame.CancelButton)
	B.Reskin(WardrobeOutfitEditFrame.DeleteButton)
end)