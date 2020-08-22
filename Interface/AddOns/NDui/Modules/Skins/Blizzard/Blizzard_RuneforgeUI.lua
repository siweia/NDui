local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_RuneforgeUI"] = function()
	local frame = RuneforgeFrame

	local createFrame = frame.CreateFrame
	B.Reskin(createFrame.CraftItemButton)
	B.Reskin(createFrame.CloseButton)

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
			end
		end
	end)

	local pageControl = powerFrame.PageControl
	B.ReskinArrow(pageControl.BackwardButton, "left")
	B.ReskinArrow(pageControl.ForwardButton, "right")

	local TT = B:GetModule("Tooltip")
	TT.ReskinTooltip(frame.ResultTooltip)
end