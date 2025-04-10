local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_EngravingUI"] = function()
	local EngravingFrame = EngravingFrame
	if EngravingFrame then
		B.StripTextures(EngravingFrame)
		B.StripTextures(EngravingFrameSideInset)
		B.SetBD(EngravingFrame.Border, nil, 1, -2)
		B.ReskinEditBox(EngravingFrameSearchBox)
		B.ReskinDropDown(EngravingFrame.FilterDropdown)
		B.ReskinScroll(EngravingFrameScrollFrameScrollBar)

		for i = 1, 15 do
			local header = _G["EngravingFrameHeader"..i]
			if header then
				B.Reskin(header)
			end
		end

		if EngravingFrame_UpdateRuneList then
			hooksecurefunc("EngravingFrame_UpdateRuneList", function(self)
				for _, button in ipairs(self.scrollFrame.buttons) do
					if not button.styled then
						button:SetNormalTexture(0)
						local hl = button:GetHighlightTexture()
						hl:SetColorTexture(1, 1, 1, .25)
						hl:SetInside()
						button.selectedTex:SetColorTexture(1, .8, 0, .5)
						button.selectedTex:SetInside()
						B.ReskinIcon(button.icon)
		
						button.styled = true
					end
				end
			end)
		end
	end

	local button = RuneFrameControlButton
	if button then
		local icon, highlight, checked = button:GetRegions()
		B.ReskinIcon(icon)
		highlight:SetColorTexture(1, 1, 1, .25)
		checked:SetColorTexture(1, .8, 0, .5)
	end
end