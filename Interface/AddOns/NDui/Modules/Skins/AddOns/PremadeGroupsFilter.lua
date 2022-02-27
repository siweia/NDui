local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")
local TT = B:GetModule("Tooltip")

function S:PGFSkin()
	if not C.db["Skins"]["BlizzardSkins"] then return end
	if not C.db["Skins"]["PGFSkin"] then return end
	if not IsAddOnLoaded("PremadeGroupsFilter") then return end

	local tipStyled
	hooksecurefunc(PremadeGroupsFilter.Debug, "PopupMenu_Initialize", function()
		if tipStyled then return end
		for i = 1, PremadeGroupsFilterDialog:GetNumChildren() do
			local child = select(i, PremadeGroupsFilterDialog:GetChildren())
			if child and child.Shadow then
				TT.ReskinTooltip(child)
				tipStyled = true
				break
			end
		end
	end)

	hooksecurefunc(PremadeGroupsFilterDialog, "SetPoint", function(self, _, parent)
		if parent ~= LFGListFrame then
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", LFGListFrame, "TOPRIGHT", 5, 0)
		end
	end)

	local pairs = pairs
	local styled
	hooksecurefunc(PremadeGroupsFilterDialog, "Show", function(self)
		if styled then return end

		B.StripTextures(self)
		B.SetBD(self)
		B.ReskinClose(self.CloseButton)
		B.Reskin(self.ResetButton)
		B.Reskin(self.RefreshButton)
		B.ReskinDropDown(self.Difficulty.DropDown)
		B.StripTextures(self.Advanced)
		B.ReskinInput(self.Expression)
		B.ReskinInput(self.Sorting.SortingExpression)
		if self.MoveableToggle then
			B.ReskinArrow(self.MoveableToggle, "left")
			self.MoveableToggle:SetPoint("TOPLEFT", 5, -5)
		end
		if self.MinimizeButton then
			B.ReskinArrow(self.MinimizeButton, "down")
			self.MinimizeButton:ClearAllPoints()
			self.MinimizeButton:SetPoint("RIGHT", self.CloseButton, "LEFT", -3, 0)
			B.ReskinArrow(self.MaximizeButton, "up")
			self.MaximizeButton:ClearAllPoints()
			self.MaximizeButton:SetPoint("RIGHT", self.CloseButton, "LEFT", -3, 0)
		end

		local names = {"Difficulty", "Ilvl", "Noilvl", "Defeated", "Members", "Tanks", "Heals", "Dps"}
		for _, name in pairs(names) do
			local check = self[name].Act
			if check then
				check:SetSize(26, 26)
				check:SetPoint("TOPLEFT", 5, -3)
				B.ReskinCheck(check)
			end
			local input = self[name].Min
			if input then
				B.ReskinInput(input)
				B.ReskinInput(self[name].Max)
			end
		end

		styled = true
	end)

	B.ReskinCheck(UsePFGButton)
	UsePFGButton.text:SetWidth(35)
end