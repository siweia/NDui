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
	B.Reskin(DressUpFrameOutfitDropDown.SaveButton)
	B.Reskin(DressUpFrameCancelButton)
	B.Reskin(DressUpFrameResetButton)
	B.StripTextures(DressUpFrameOutfitDropDown)
	B.ReskinDropDown(DressUpFrameOutfitDropDown)
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

	DressUpFrameOutfitDropDown:SetHeight(32)
	DressUpFrameOutfitDropDown.SaveButton:SetPoint("LEFT", DressUpFrameOutfitDropDown, "RIGHT", -13, 2)
	DressUpFrameResetButton:SetPoint("RIGHT", DressUpFrameCancelButton, "LEFT", -1, 0)

	B.ReskinCheck(TransmogAndMountDressupFrame.ShowMountCheckButton)
	B.ReskinModelControl(DressUpFrame.ModelScene)

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

	B.StripTextures(WardrobeOutfitFrame)
	B.SetBD(WardrobeOutfitFrame, .7)

	hooksecurefunc(WardrobeOutfitFrame, "Update", function(self)
		for i = 1, C_TransmogCollection.GetNumMaxOutfits() do
			local button = self.Buttons[i]
			if button and button:IsShown() and not button.styled then
				B.ReskinIcon(button.Icon)
				button.Selection:SetColorTexture(1, 1, 1, .25)
				button.Highlight:SetColorTexture(r, g, b, .25)

				button.styled = true
			end
		end
	end)

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