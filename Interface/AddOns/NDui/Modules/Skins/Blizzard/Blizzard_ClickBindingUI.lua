local _, ns = ...
local B, C, L, DB = unpack(ns)

local function updateNewGlow(self)
	if self.NewOutline:IsShown() then
		self.bg:SetBackdropBorderColor(0, .7, .08)
	else
		self.bg:SetBackdropBorderColor(0, 0, 0)
	end
end

local function updateIconGlow(self, show)
	if show then
		self.__owner.bg:SetBackdropBorderColor(0, .7, .08)
	else
		self.__owner.bg:SetBackdropBorderColor(0, 0, 0)
	end
end

local function reskinScrollChild(self)
	for i = 1, self.ScrollTarget:GetNumChildren() do
		local child = select(i, self.ScrollTarget:GetChildren())
		local icon = child and child.Icon
		if icon and not icon.bg then
			icon.bg = B.ReskinIcon(icon)
			child.Background:Hide()
			child.bg = B.CreateBDFrame(child.Background, .25)

			B.Reskin(child.DeleteButton)
			child.DeleteButton:SetSize(20, 20)
			child.FrameHighlight:SetInside(child.bg)
			child.FrameHighlight:SetColorTexture(1, 1, 1, .15) -- 0.25 might be too much

			child.NewOutline:SetTexture("")
			child.BindingText:SetFontObject(Game12Font)
			hooksecurefunc(child, "Init", updateNewGlow)

			local iconHighlight = child.IconHighlight
			iconHighlight:SetTexture("")
			iconHighlight.__owner = icon
			hooksecurefunc(iconHighlight, "SetShown", updateIconGlow)
		end
	end
end

local function updateButtonSelection(button, isSelected)
	if isSelected then
		button.bg:SetBackdropBorderColor(1, .8, 0)
	else
		button.bg:SetBackdropBorderColor(0, 0, 0)
	end
end

local function reskinPortraitIcon(button, texture)
	B.StripTextures(button)
	button.Portrait:SetTexture(texture)
	button.bg = B.ReskinIcon(button.Portrait)
	button.bg:SetBackdropColor(0, 0, 0)
	button.Highlight:SetColorTexture(1, 1, 1, .25)
	button.Highlight:SetInside(button.bg)
	hooksecurefunc(button, "SetSelectedState", updateButtonSelection)
end

C.themes["Blizzard_ClickBindingUI"] = function()
	local frame = _G.ClickBindingFrame

	B.ReskinPortraitFrame(frame)
	frame.TutorialButton.Ring:Hide()
	frame.TutorialButton:SetPoint("TOPLEFT", frame, "TOPLEFT", -12, 12)

	B.Reskin(frame.ResetButton)
	B.Reskin(frame.AddBindingButton)
	B.Reskin(frame.SaveButton)
	B.ReskinTrimScroll(frame.ScrollBar)

	frame.ScrollBoxBackground:Hide()
	hooksecurefunc(frame.ScrollBox, "Update", reskinScrollChild)

	reskinPortraitIcon(frame.SpellbookPortrait, 136830)
	reskinPortraitIcon(frame.MacrosPortrait, 136377)

	frame.TutorialFrame.NineSlice:Hide()
	B.SetBD(frame.TutorialFrame)

	if frame.EnableMouseoverCastCheckbox then
		B.ReskinCheck(frame.EnableMouseoverCastCheckbox)
	end
end