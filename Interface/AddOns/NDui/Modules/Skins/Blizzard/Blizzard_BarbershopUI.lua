local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_BarbershopUI"] = function()
	local frame = BarberShopFrame

	B.Reskin(frame.AcceptButton)
	B.Reskin(frame.CancelButton)
	B.Reskin(frame.ResetButton)
end

local function ReskinCustomizeButton(button)
	B.Reskin(button)
	button.__bg:SetInside(nil, 3, 3)
end

C.themes["Blizzard_CharacterCustomize"] = function()
	local frame = CharCustomizeFrame

	ReskinCustomizeButton(frame.SmallButtons.ResetCameraButton)
	ReskinCustomizeButton(frame.SmallButtons.ZoomOutButton)
	ReskinCustomizeButton(frame.SmallButtons.ZoomInButton)
	ReskinCustomizeButton(frame.SmallButtons.RotateLeftButton)
	ReskinCustomizeButton(frame.SmallButtons.RotateRightButton)

	hooksecurefunc(frame, "SetSelectedCatgory", function(self)
		for button in self.selectionPopoutPool:EnumerateActive() do
			if not button.styled then
				B.ReskinArrow(button.DecrementButton, "left")
				B.ReskinArrow(button.IncrementButton, "right")

				local popoutButton = button.SelectionPopoutButton
				popoutButton.HighlightTexture:SetAlpha(0)
				popoutButton.NormalTexture:SetAlpha(0)
				ReskinCustomizeButton(popoutButton)
				B.StripTextures(popoutButton.Popout)
				local bg = B.SetBD(popoutButton.Popout, 1)
				bg:SetFrameLevel(popoutButton.Popout:GetFrameLevel())

				button.styled = true
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

	local TT = B:GetModule("Tooltip")
	TT.ReskinTooltip(CharCustomizeNoHeaderTooltip)
	CharCustomizeNoHeaderTooltip:SetScale(UIParent:GetScale())
end