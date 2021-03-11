local _, ns = ...
local B, C, L, DB = unpack(ns)

local function updateSelectedTexture(texture, shown)
	local button = texture.__owner
	if shown then
		button.bg:SetBackdropBorderColor(1, .8, 0)
	else
		button.bg:SetBackdropBorderColor(0, 0, 0)
	end
end

C.themes["Blizzard_RuneforgeUI"] = function()
	local frame = RuneforgeFrame
	B.ReskinClose(frame.CloseButton, nil, -70, -70)

	local createFrame = frame.CreateFrame
	B.Reskin(createFrame.CraftItemButton)
	B.ReplaceIconString(createFrame.Cost.Text)
	hooksecurefunc(createFrame.Cost.Text, "SetText", B.ReplaceIconString)

	local powerFrame = frame.CraftingFrame.PowerFrame
	B.StripTextures(powerFrame)
	B.SetBD(powerFrame, 1)

	hooksecurefunc(powerFrame.PowerList, "RefreshListDisplay", function(self)
		if not self.elements then return end

		for i = 1, self:GetNumElementFrames() do
			local button = self.elements[i]
			if button and not button.bg then
				button.Border:SetAlpha(0)
				button.CircleMask:Hide()
				button.bg = B.ReskinIcon(button.Icon)
				button.SelectedTexture:SetTexture("")
				button.SelectedTexture.__owner = button
				hooksecurefunc(button.SelectedTexture, "SetShown", updateSelectedTexture)
			end
		end
	end)

	local pageControl = powerFrame.PageControl
	B.ReskinArrow(pageControl.BackwardButton, "left")
	B.ReskinArrow(pageControl.ForwardButton, "right")

	local TT = B:GetModule("Tooltip")
	TT.ReskinTooltip(frame.ResultTooltip)
end