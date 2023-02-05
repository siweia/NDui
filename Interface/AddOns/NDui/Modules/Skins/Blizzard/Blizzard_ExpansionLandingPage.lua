local _, ns = ...
local B, C, L, DB = unpack(ns)

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
				hooksecurefunc(panel.MajorFactionList.ScrollBox, "Update", function(self)
					for i = 1, self.ScrollTarget:GetNumChildren() do
						local child = select(i, self.ScrollTarget:GetChildren())
						if child.UnlockedState and not child.styled then
							child.UnlockedState.WatchFactionButton:SetSize(28, 28)
							B.ReskinCheck(child.UnlockedState.WatchFactionButton)
							child.UnlockedState.WatchFactionButton.Label:SetFontObject(Game20Font)
							child.styled = true
						end
					end
				end)
			end

			panel.styled = true
		end
	end)
end