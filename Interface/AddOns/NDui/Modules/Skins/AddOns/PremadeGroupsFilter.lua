local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")
local TT = B:GetModule("Tooltip")

function S:PGFSkin()
	if not C.db["Skins"]["BlizzardSkins"] then return end
	if not C.db["Skins"]["PGFSkin"] then return end
	if not IsAddOnLoaded("PremadeGroupsFilter") then return end

	local PGFDialog = _G.PremadeGroupsFilterDialog

	local tipStyled
	hooksecurefunc(PremadeGroupsFilter.Debug, "PopupMenu_Initialize", function()
		if tipStyled then return end
		for i = 1, PGFDialog:GetNumChildren() do
			local child = select(i, PGFDialog:GetChildren())
			if child and child.Shadow then
				TT.ReskinTooltip(child)
				tipStyled = true
				break
			end
		end
	end)

	hooksecurefunc(PGFDialog, "SetPoint", function(self, _, parent)
		if parent ~= LFGListFrame then
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", LFGListFrame, "TOPRIGHT", 5, 0)
		end
	end)

	local pairs = pairs
	local styled
	hooksecurefunc(PGFDialog, "Show", function(self)
		if styled then return end

		B.StripTextures(self)
		B.SetBD(self):SetAllPoints()
		B.ReskinClose(self.CloseButton)
		B.Reskin(self.ResetButton)
		B.Reskin(self.RefreshButton)
		B.ReskinDropDown(self.Difficulty.DropDown)
		B.ReskinInput(self.Expression)
		B.ReskinInput(self.Sorting.SortingExpression)
		if self.MoveableToggle then
			B.ReskinArrow(self.MoveableToggle, "left")
			self.MoveableToggle:SetPoint("TOPLEFT", 5, -5)
		end
		local button = self.MaxMinButtonFrame
		if button.MinimizeButton then
			B.ReskinArrow(button.MinimizeButton, "down")
			button.MinimizeButton:ClearAllPoints()
			button.MinimizeButton:SetPoint("RIGHT", self.CloseButton, "LEFT", -3, 0)
			B.ReskinArrow(button.MaximizeButton, "up")
			button.MaximizeButton:ClearAllPoints()
			button.MaximizeButton:SetPoint("RIGHT", self.CloseButton, "LEFT", -3, 0)
		end

		local names = {"Difficulty", "Defeated", "Members", "Tanks", "Heals", "Dps", "MPRating", "PVPRating"}
		for _, name in pairs(names) do
			local frame = self[name]
			if frame then
				local check = frame.Act
				if check then
					check:SetSize(26, 26)
					check:SetPoint("TOPLEFT", 5, -3)
					B.ReskinCheck(check)
				end
				local input = frame.Min
				if input then
					B.ReskinInput(input)
					B.ReskinInput(frame.Max)
				end
			end
		end

		styled = true
	end)

	hooksecurefunc(PGFDialog, "SetSize", function(self, width, height)
		if height == 427 then
			self:SetSize(width, 428)
		end
	end)

	B.ReskinCheck(UsePFGButton)
	UsePFGButton.text:SetWidth(35)
end