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

C.themes["Blizzard_CharacterCustomize"] = function()
	local frame = CharCustomizeFrame

	ReskinCustomizeButton(frame.SmallButtons.ResetCameraButton)
	ReskinCustomizeButton(frame.SmallButtons.ZoomOutButton)
	ReskinCustomizeButton(frame.SmallButtons.ZoomInButton)
	ReskinCustomizeButton(frame.SmallButtons.RotateLeftButton)
	ReskinCustomizeButton(frame.SmallButtons.RotateRightButton)
	ReskinCustomizeButton(frame.RandomizeAppearanceButton)

	hooksecurefunc(frame, "UpdateOptionButtons", function(self)
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

		local optionPool = self.pools:GetPool("CustomizationOptionCheckButtonTemplate")
		if optionPool then
			for button in optionPool:EnumerateActive() do
				if not button.styled then
					B.ReskinCheck(button.Button)
					button.styled = true
				end
			end
		end
	end)
end