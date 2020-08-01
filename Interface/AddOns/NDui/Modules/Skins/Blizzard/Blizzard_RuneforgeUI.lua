local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_RuneforgeUI"] = function()
	local frame = RuneforgeFrame

	local createFrame = frame.CreateFrame
	B.Reskin(createFrame.CraftItemButton)
	B.Reskin(createFrame.CloseButton)

	local powerFrame = frame.CraftingFrame.PowerFrame
	B.StripTextures(powerFrame)
	B.SetBD(powerFrame, nil, -10, 0, 10, 55)
	powerFrame:ClearAllPoints()
	powerFrame:SetPoint("LEFT", frame, "RIGHT", -10, 0)

	powerFrame:HookScript("OnShow", function(self)
		if self.PowerList and self.PowerList.powerPool then
			for button in self.PowerList.powerPool:EnumerateActive() do
				if button:IsShown() and not button.bg then
					button.Border:SetAlpha(0)
					button.CircleMask:Hide()
					button.bg = B.ReskinIcon(button.Icon)
				end
			end
		end
	end)

	local scrollBar = RuneforgeFrameScrollBar
	B.ReskinScroll(scrollBar)
	local anchorF, parent, anchorT, x, y = scrollBar:GetPoint()
	scrollBar:SetPoint(anchorF, parent, anchorT, x-15, y)
end