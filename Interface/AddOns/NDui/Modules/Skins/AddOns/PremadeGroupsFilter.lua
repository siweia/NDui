local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")
local TT = B:GetModule("Tooltip")

function S:PGFSkin()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end
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
			self:SetPoint("TOPLEFT", LFGListFrame, "TOPRIGHT", 5, C.mult)
		end
	end)

	local pairs = pairs
	local styled
	hooksecurefunc(PremadeGroupsFilterDialog, "Show", function(self)
		if styled then return end

		B.StripTextures(self)
		B.CreateBD(self)
		B.CreateSD(self)
		B.CreateTex(self)
		B.ReskinClose(self.CloseButton)
		B.Reskin(self.ResetButton)
		B.Reskin(self.RefreshButton)
		B.ReskinDropDown(self.Difficulty.DropDown)
		B.StripTextures(self.Advanced)
		B.ReskinInput(self.Expression)

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