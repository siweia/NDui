local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")
local TT = B:GetModule("Tooltip")

function S:PGFSkin()
	if not C.db["Skins"]["BlizzardSkins"] then return end
	if not C.db["Skins"]["PGFSkin"] then return end
	if not C_AddOns.IsAddOnLoaded("PremadeGroupsFilter") then return end

	local DungeonPanel = _G.PremadeGroupsFilterDungeonPanel
	if not DungeonPanel then return end

	local ArenaPanel = _G.PremadeGroupsFilterArenaPanel
	local RBGPanel = _G.PremadeGroupsFilterRBGPanel
	local RaidPanel = _G.PremadeGroupsFilterRaidPanel
	local MiniPanel = _G.PremadeGroupsFilterMiniPanel
	local RolePanel = _G.PremadeGroupsFilterRolePanel
	local PGFDialog = _G.PremadeGroupsFilterDialog

	local names = {"Difficulty", "MPRating", "Members", "Tanks", "Heals", "DPS", "Partyfit", "BLFit", "BRFit", "Defeated", "MatchingId", "PvPRating", "NotDeclined"}

	local function handleDropdown(drop)
		B.StripTextures(drop)

		local bg = B.CreateBDFrame(drop, 0, true)
		bg:SetPoint("TOPLEFT", 16, -4)
		bg:SetPoint("BOTTOMRIGHT", -18, 8)

		local down = drop.Button
		down:ClearAllPoints()
		down:SetPoint("RIGHT", bg, -2, 0)
		B.ReskinArrow(down, "down")
	end

	local function handleGroup(panel)
		for _, name in pairs(names) do
			local frame = panel.Group[name]
			if frame then
				local check = frame.Act
				if check then
					check:SetSize(26, 26)
					check:SetPoint("TOPLEFT", 5, -1)
					B.ReskinCheck(check)
				end
				local input = frame.Min
				if input then
					B.ReskinInput(input)
					B.ReskinInput(frame.Max)
				end
				if frame.DropDown then
					handleDropdown(frame.DropDown)
				end
			end
		end

		B.ReskinInput(panel.Advanced.Expression)
	end

	local styled
	hooksecurefunc(PGFDialog, "Show", function(self)
		if styled then return end
		styled = true

		B.StripTextures(self)
		B.SetBD(self):SetAllPoints()
		B.ReskinClose(self.CloseButton)
		B.Reskin(self.ResetButton)
		B.Reskin(self.RefreshButton)

		B.ReskinInput(MiniPanel.Advanced.Expression)
		B.ReskinInput(MiniPanel.Sorting.Expression)

		local button = self.MaxMinButtonFrame
		if button.MinimizeButton then
			B.ReskinArrow(button.MinimizeButton, "down")
			button.MinimizeButton:ClearAllPoints()
			button.MinimizeButton:SetPoint("RIGHT", self.CloseButton, "LEFT", -3, 0)
			B.ReskinArrow(button.MaximizeButton, "up")
			button.MaximizeButton:ClearAllPoints()
			button.MaximizeButton:SetPoint("RIGHT", self.CloseButton, "LEFT", -3, 0)
		end

		handleGroup(RaidPanel)
		handleGroup(DungeonPanel)
		handleGroup(ArenaPanel)
		handleGroup(RBGPanel)
		handleGroup(RolePanel)

		for i = 1, 8 do
			local dungeon = DungeonPanel.Dungeons["Dungeon"..i]
			local check = dungeon and dungeon.Act
			if check then
				check:SetSize(26, 26)
				check:SetPoint("TOPLEFT", 5, -1)
				B.ReskinCheck(check)
			end
		end
	end)

	hooksecurefunc(PGFDialog, "ResetPosition", function(self)
		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", PVEFrame, "TOPRIGHT", 2, 0)
	end)
--[[
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
]]
	local button = UsePGFButton
	if button then
		B.ReskinCheck(button)
		button.text:SetWidth(35)
	end

	local popup = PremadeGroupsFilterStaticPopup
	if popup then
		B.StripTextures(popup)
		B.SetBD(popup)
		B.ReskinInput(popup.EditBox)
		B.Reskin(popup.Button1)
		B.Reskin(popup.Button2)
	end
end