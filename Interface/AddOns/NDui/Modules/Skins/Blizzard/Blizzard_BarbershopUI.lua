local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:GetModule("Tooltip")

C.themes["Blizzard_BarbershopUI"] = function()
	local frame = BarberShopFrame

	B.Reskin(frame.AcceptButton)
	B.Reskin(frame.CancelButton)
	B.Reskin(frame.ResetButton)
end

local function ReskinCustomizeButton(button)
	B.Reskin(button)
	button.__bg:SetInside(nil, 5, 5)
end

local function ReskinCustomizeTooltip(tooltip)
	TT.ReskinTooltip(tooltip)
	tooltip:SetScale(UIParent:GetScale())
end

local function ReskinCustomizeArrow(button, direction)
	B.StripTextures(button, 0)

	local tex = button:CreateTexture(nil, "ARTWORK")
	tex:SetInside(button, 3, 3)
	B.SetupArrow(tex, direction)
	button.__texture = tex

	button:HookScript("OnEnter", B.Texture_OnEnter)
	button:HookScript("OnLeave", B.Texture_OnLeave)
end

C.themes["Blizzard_CharacterCustomize"] = function()
	local frame = CharCustomizeFrame

	ReskinCustomizeButton(frame.SmallButtons.ResetCameraButton)
	ReskinCustomizeButton(frame.SmallButtons.ZoomOutButton)
	ReskinCustomizeButton(frame.SmallButtons.ZoomInButton)
	ReskinCustomizeButton(frame.SmallButtons.RotateLeftButton)
	ReskinCustomizeButton(frame.SmallButtons.RotateRightButton)
	ReskinCustomizeButton(frame.RandomizeAppearanceButton)

	hooksecurefunc(frame, "UpdateOptionButtons", function(self)
		if self.selectionPopoutPool then -- isWW: removed
			for button in self.selectionPopoutPool:EnumerateActive() do
				if not button.styled then
					ReskinCustomizeArrow(button.DecrementButton, "left")
					ReskinCustomizeArrow(button.IncrementButton, "right")

					local popoutButton = button.Button
					popoutButton.HighlightTexture:SetAlpha(0)
					popoutButton.NormalTexture:SetAlpha(0)
					ReskinCustomizeButton(popoutButton)
					B.StripTextures(popoutButton.Popout)
					local bg = B.SetBD(popoutButton.Popout, 1)
					bg:SetFrameLevel(popoutButton.Popout:GetFrameLevel())

					button.styled = true
				end
			end
		end

		if self.dropdownPool then
			for option in self.dropdownPool:EnumerateActive() do
				if not option.styled then
					B.Reskin(option.Dropdown)
					B.Reskin(option.DecrementButton)
					B.Reskin(option.IncrementButton)
					option.styled = true
				end
			end
		end

		if self.sliderPool then
			for slider in self.sliderPool:EnumerateActive() do
				if not slider.styled then
					B.ReskinSlider(slider)
					slider.styled = true
				end
			end
		end

		local optionPool = self.pools:GetPool("CharCustomizeOptionCheckButtonTemplate")
		for button in optionPool:EnumerateActive() do
			if not button.styled then
				B.ReskinCheck(button.Button)
				button.styled = true
			end
		end
	end)

	if not DB.isWW then
		ReskinCustomizeTooltip(CharCustomizeTooltip)
	end
	ReskinCustomizeTooltip(CharCustomizeNoHeaderTooltip)
end