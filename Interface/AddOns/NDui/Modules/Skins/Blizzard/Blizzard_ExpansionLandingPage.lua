local _, ns = ...
local B, C, L, DB = unpack(ns)

local function SkinFactionCategory(button)
	if button.UnlockedState and not button.styled then
		button.UnlockedState.WatchFactionButton:SetSize(28, 28)
		B.ReskinCheck(button.UnlockedState.WatchFactionButton)
		button.UnlockedState.WatchFactionButton.Label:SetFontObject(Game18Font)
		button.styled = true
	end
end

C.themes["Blizzard_ExpansionLandingPage"] = function()
	local frame = _G.ExpansionLandingPage
	local panel

	frame:HookScript("OnShow", function()
		if not panel then
			if frame.Overlay then
				for i = 1, frame.Overlay:GetNumChildren() do
					local child = select(i, frame.Overlay:GetChildren())
					if child.DragonridingPanel then
						panel = child
						break
					end
				end
			end
		end

		if panel and not panel.styled then
			panel.NineSlice:SetAlpha(0)
			panel.Background:SetAlpha(0)
			B.SetBD(panel)
		
			if panel.DragonridingPanel then
				B.Reskin(panel.DragonridingPanel.SkillsButton)
			end
			if panel.CloseButton then
				B.ReskinClose(panel.CloseButton)
			end
			if panel.MajorFactionList then
				B.ReskinTrimScroll(panel.MajorFactionList.ScrollBar)
				panel.MajorFactionList.ScrollBox:ForEachFrame(SkinFactionCategory)
				hooksecurefunc(panel.MajorFactionList.ScrollBox, "Update", function(self)
					self:ForEachFrame(SkinFactionCategory)
				end)
			end

			panel.styled = true
		end
	end)
end