local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_EngravingUI"] = function()
	local EngravingFrame = EngravingFrame
	if EngravingFrame then
		B.StripTextures(EngravingFrame)
		B.StripTextures(EngravingFrameSideInset)
		B.SetBD(EngravingFrame.Border, nil, 2, -2, 2, C.mult)
		B.ReskinEditBox(EngravingFrameSearchBox)
		B.ReskinDropDown(EngravingFrameFilterDropDown)
		B.ReskinScroll(EngravingFrameScrollFrameScrollBar)
	end

	local button = RuneFrameControlButton
	if button then
		local icon, highlight, checked = button:GetRegions()
		B.ReskinIcon(icon)
		highlight:SetColorTexture(1, 1, 1, .25)
		checked:SetColorTexture(1, .8, 0, .5)
	end
end