local _, ns = ...
local B, C, L, DB, F = unpack(ns)
local S = B:GetModule("Skins")
local TT = B:GetModule("Tooltip")

function S:PGFSkin()
	if not NDuiDB["Skins"]["PGFSkin"] then return end
	if not IsAddOnLoaded("PremadeGroupsFilter") then return end

	local tipStyled
	hooksecurefunc(PremadeGroupsFilter.Debug, "PopupMenu_Initialize", function()
		if tipStyled then return end
		for i = 1, 15 do
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
			self:SetPoint("TOPLEFT", LFGListFrame, "TOPRIGHT", 5, 1)
		end
	end)

	if not F then return end

	local pairs = pairs
	local styled
	hooksecurefunc(PremadeGroupsFilterDialog, "Show", function(self)
		if styled then return end

		F.StripTextures(self)
		F.CreateBD(self)
		F.CreateSD(self)
		F.ReskinClose(self.CloseButton)
		F.Reskin(self.ResetButton)
		F.Reskin(self.RefreshButton)
		F.ReskinDropDown(self.Difficulty.DropDown)
		F.StripTextures(self.Advanced)
		F.StripTextures(self.Expression)
		F.CreateGradient(F.CreateBDFrame(self.Expression, .25))

		local names = {"Difficulty", "Ilvl", "Noilvl", "Defeated", "Members", "Tanks", "Heals", "Dps"}
		for _, name in pairs(names) do
			local check = self[name].Act
			if check then
				check:SetSize(26, 26)
				check:SetPoint("TOPLEFT", 5, -3)
				F.ReskinCheck(check)
			end
			local input = self[name].Min
			if input then
				F.ReskinInput(input)
				F.ReskinInput(self[name].Max)
			end
		end

		styled = true
	end)

	F.ReskinCheck(UsePFGButton)
	UsePFGButton.text:SetWidth(35)
end