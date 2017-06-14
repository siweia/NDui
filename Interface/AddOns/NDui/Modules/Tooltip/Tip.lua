local B, C, L, DB = unpack(select(2, ...))

local classification = {
	elite = " |cffcc8800"..ELITE.."|r",
	rare = " |cffff99cc"..L["Rare"].."|r",
	rareelite = " |cffff99cc"..L["Rare"].."|r ".."|cffcc8800"..ELITE.."|r",
	worldboss = " |cffff0000"..BOSS.."|r",
}
local find = string.find
local format = string.format
local COALESCED_REALM_TOOLTIP1 = string.split(FOREIGN_SERVER_LABEL, COALESCED_REALM_TOOLTIP)
local INTERACTIVE_REALM_TOOLTIP1 = string.split(INTERACTIVE_SERVER_LABEL, INTERACTIVE_REALM_TOOLTIP)

local function getUnit(self)
	local _, unit = self and self:GetUnit()
	if(not unit) then
		local mFocus = GetMouseFocus()
		unit = mFocus and (mFocus.unit or (mFocus.GetAttribute and mFocus:GetAttribute("unit"))) or "mouseover"
	end
	return unit
end

local function hideLines(self)
    for i = 3, self:NumLines() do
        local tiptext = _G["GameTooltipTextLeft"..i]
		local linetext = tiptext:GetText()
		if linetext then
			if NDuiDB["Tooltip"]["HidePVP"] and linetext == PVP_ENABLED then
				tiptext:SetText(nil)
				tiptext:Hide()
			elseif linetext:find(COALESCED_REALM_TOOLTIP1) or linetext:find(INTERACTIVE_REALM_TOOLTIP1) then
				tiptext:SetText(nil)
				tiptext:Hide()
				local pretiptext = _G["GameTooltipTextLeft"..i-1]
				pretiptext:SetText(nil)
				pretiptext:Hide()
				self:Show()
			elseif linetext == FACTION_HORDE then
				if NDuiDB["Tooltip"]["HideFaction"] then
					tiptext:SetText(nil)
					tiptext:Hide()
				else
					tiptext:SetText("|cffff5040"..linetext.."|r")
				end
			elseif linetext == FACTION_ALLIANCE then
				if NDuiDB["Tooltip"]["HideFaction"] then
					tiptext:SetText(nil)
					tiptext:Hide()
				else
					tiptext:SetText("|cff4080ff"..linetext.."|r")
				end
			end
		end
    end
end

local function getTarget(unit)
    if UnitIsUnit(unit, "player") then
        return ("|cffff0000%s|r"):format(">"..string.upper(YOU).."<")
    else
        return B.HexRGB(B.UnitColor(unit))..UnitName(unit).."|r"
    end
end

local function InsertFactionFrame(self, faction)
	if not self.factionFrame then
		local f = self:CreateTexture(nil, "OVERLAY")
		f:SetPoint("TOPRIGHT", 0, -5)
		f:SetBlendMode("ADD")
		self.factionFrame = f
	end
	self.factionFrame:SetTexture("Interface\\FriendsFrame\\PlusManz-"..faction)
	self.factionFrame:SetAlpha(.5)
end

local roleTex = {
	["HEALER"] = {.066, .222, .133, .445},
	["TANK"] = {.375, .532, .133, .445},
	["DAMAGER"] = {.66, .813, .133, .445},
}

local function InsertRoleFrame(self, role)
	if not self.roleFrame then
		local f = self:CreateTexture(nil, "OVERLAY")
		f:SetPoint("TOPRIGHT", self, "TOPLEFT", -1, -4)
		f:SetSize(20, 20)
		f:SetTexture("Interface\\LFGFrame\\UI-LFG-ICONS-ROLEBACKGROUNDS")
		B.CreateSD(f, 3, 3)
		self.roleFrame = f
	end
	self.roleFrame:SetTexCoord(unpack(roleTex[role]))
	self.roleFrame:SetAlpha(1)
	self.roleFrame.Shadow:SetAlpha(1)
end

GameTooltip:HookScript("OnTooltipCleared", function(self)
	if self.factionFrame and self.factionFrame:GetAlpha() ~= 0 then
		self.factionFrame:SetAlpha(0)
	end
	if self.roleFrame and self.roleFrame:GetAlpha() ~= 0 then
		self.roleFrame:SetAlpha(0)
		self.roleFrame.Shadow:SetAlpha(0)
	end
end)

GameTooltip:HookScript("OnTooltipSetUnit", function(self)
	if NDuiDB["Tooltip"]["CombatHide"] and InCombatLockdown() then
		return self:Hide()
	end
	hideLines(self)

	local unit = getUnit(self)
    if UnitExists(unit) then
        local hexColor = B.HexRGB(B.UnitColor(unit))
        local ricon = GetRaidTargetIndex(unit)
        if ricon then
            local text = GameTooltipTextLeft1:GetText()
            GameTooltipTextLeft1:SetFormattedText(("%s %s"), ICON_LIST[ricon].."18|t", text)
        end

        if UnitIsPlayer(unit) then
			local unitName
			if NDuiDB["Tooltip"]["HideTitle"] and NDuiDB["Tooltip"]["HideRealm"] then
				unitName = UnitName(unit)
			elseif NDuiDB["Tooltip"]["HideTitle"] then
				unitName = GetUnitName(unit, true)
			elseif NDuiDB["Tooltip"]["HideRealm"] then
				unitName = UnitPVPName(unit) or UnitName(unit)
			end
			if unitName then GameTooltipTextLeft1:SetText(unitName) end

			local relationship = UnitRealmRelationship(unit)
			if(relationship == LE_REALM_RELATION_VIRTUAL) then
				self:AppendText(("|cffcccccc%s|r"):format(INTERACTIVE_SERVER_LABEL))
			end

			local status = (UnitIsAFK(unit) and AFK) or (UnitIsDND(unit) and DND) or (not UnitIsConnected(unit) and PLAYER_OFFLINE)
			if status then
				self:AppendText((" |cff00cc00<%s>|r"):format(status))
			end

			if NDuiDB["Tooltip"]["FactionIcon"] then
				local faction = UnitFactionGroup(unit)
				if faction and faction ~= "Neutral" then
					InsertFactionFrame(self, faction)
				end
			end

			if NDuiDB["Tooltip"]["LFDRole"] then
				local role = UnitGroupRolesAssigned(unit)
				if role ~= "NONE" then
					InsertRoleFrame(self, role)
				end
			end

			local unitGuild, tmp, tmp2 = GetGuildInfo(unit)
			local text = GameTooltipTextLeft2:GetText()
			if tmp then
				tmp2 = tmp2 + 1
				if NDuiDB["Tooltip"]["HideRank"] then
					GameTooltipTextLeft2:SetText("<"..text..">")
				else
					GameTooltipTextLeft2:SetText("<"..text..">  "..tmp.."("..tmp2..")")
				end
				if IsInGuild() and unitGuild == GetGuildInfo("player") then
					GameTooltipTextLeft2:SetTextColor(.25, 1, .25)
				else
					GameTooltipTextLeft2:SetTextColor(1, .1, .8)
				end
			end
		end

		local line1 = GameTooltipTextLeft1:GetText()
		GameTooltipTextLeft1:SetFormattedText("%s", hexColor..line1)

        local alive = not UnitIsDeadOrGhost(unit)
		local level
		if UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
			level = UnitBattlePetLevel(unit)
		else
			level = UnitLevel(unit)
		end

        if level then
			local boss
            if level == -1 then boss = "|cffff0000??|r" end

            local diff = GetCreatureDifficultyColor(level)
            local classify = UnitClassification(unit)
            local textLevel = ("%s%s%s|r"):format(B.HexRGB(diff), boss or ("%d"):format(level), classification[classify] or "")
			local tiptextLevel
			for i = 2, self:NumLines() do
                local tiptext = _G["GameTooltipTextLeft"..i]
				local linetext = tiptext:GetText()
				if(linetext and linetext:find(LEVEL)) then
					tiptextLevel = tiptext
				end
            end

			local creature = not UnitIsPlayer(unit) and UnitCreatureType(unit) or ""
            local unitClass = UnitIsPlayer(unit) and ("%s %s"):format(UnitRace(unit) or "", hexColor..(UnitClass(unit) or "").."|r") or ""
			if(tiptextLevel) then
				tiptextLevel:SetFormattedText(("%s %s%s %s"), textLevel, creature, unitClass, (not alive and "|cffCCCCCC"..DEAD.."|r" or ""))
			end
        end

        if UnitExists(unit.."target") then
			local tarRicon = GetRaidTargetIndex(unit.."target")
			local tar = ("%s%s"):format((tarRicon and ICON_LIST[tarRicon].."10|t") or "", getTarget(unit.."target"))
			self:AddLine(TARGET..": "..tar)
        end

		if alive then
			GameTooltipStatusBar:SetStatusBarColor(B.UnitColor(unit))
		else
			GameTooltipStatusBar:Hide()
		end
    else
        GameTooltipStatusBar:SetStatusBarColor(0, .9, 0)
    end

    if GameTooltipStatusBar:IsShown() then
        GameTooltipStatusBar:ClearAllPoints()
        GameTooltipStatusBar:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, 2)
        GameTooltipStatusBar:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, 2)
    end
end)

GameTooltipStatusBar:SetStatusBarTexture(DB.normTex)
GameTooltipStatusBar:SetHeight(5)
B.CreateSD(GameTooltipStatusBar, 3, 3)
local bg = B.CreateBG(GameTooltipStatusBar, 3)
B.CreateBD(bg, .7)
B.CreateTex(bg)

GameTooltipStatusBar:SetScript("OnValueChanged", function(self, value)
    if not value then return end
    local min, max = self:GetMinMaxValues()
    if (value < min) or (value > max) then return end
	local unit = getUnit(GameTooltip)
    if UnitExists(unit) then
		min, max = UnitHealth(unit), UnitHealthMax(unit)
		if not self.text then
			self.text = B.CreateFS(self, 12, "")
		end
		self.text:Show()
		local hp = B.Numb(min).." / "..B.Numb(max)
		self.text:SetText(hp)
	end
end)

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
	local frame = GetMouseFocus()
    if NDuiDB["Tooltip"]["Cursor"] then
		if parent then
			tooltip:SetOwner(parent, "ANCHOR_CURSOR_RIGHT")
		end
	else
		tooltip:ClearAllPoints()
		if parent then
			tooltip:SetOwner(parent, "ANCHOR_NONE")
		end
        tooltip:SetPoint(unpack(C.Tooltips.TipPos))
    end
    tooltip.default = 1
end)

local function style(frame)
	if not frame then return end
	frame:SetScale(NDuiDB["Tooltip"]["Scale"])

	if not frame.bg then
		frame:SetBackdrop(nil)
		local bg = B.CreateBG(frame, 0)
		bg:SetFrameLevel(frame:GetFrameLevel())
		B.CreateBD(bg, .7)
		B.CreateTex(bg)
		frame.bg = bg

		-- other gametooltip-like support
		local function getBackdrop() return bg:GetBackdrop() end
		frame.GetBackdrop = getBackdrop

		local function getBackdropColor() return 0, 0, 0, .7 end
		frame.GetBackdropColor = getBackdropColor

		local function getBackdropBorderColor() return 0, 0, 0 end
		frame.GetBackdropBorderColor = getBackdropBorderColor
	end

	frame.bg:SetBackdropBorderColor(0, 0, 0)
	if NDuiDB["Tooltip"]["ClassColor"] and frame.GetItem then
		local _, item = frame:GetItem()
		if item then
			local quality = select(3, GetItemInfo(item))
			local color = BAG_ITEM_QUALITY_COLORS[quality or 1]
			if color then
				frame.bg:SetBackdropBorderColor(color.r, color.g, color.b)
			end
		end
	end

    if frame.NumLines and frame:NumLines() > 0 then
        for index = 1, frame:NumLines() do
            if index == 1 then
                _G[frame:GetName().."TextLeft"..index]:SetFont(DB.TipFont[1], DB.TipFont[2] + 2, DB.TipFont[3])
            else
                _G[frame:GetName().."TextLeft"..index]:SetFont(unpack(DB.TipFont))
            end
            _G[frame:GetName().."TextRight"..index]:SetFont(unpack(DB.TipFont))
        end
    end
end

local function extrastyle(f)
	if not f.styled then
		f:DisableDrawLayer("BACKGROUND")
		style(f)
		f.styled = true
	end
end

NDui:EventFrame("ADDON_LOADED"):SetScript("OnEvent", function(_, _, addon)
	if addon == "Blizzard_DebugTools" and not IsAddOnLoaded("Aurora") then
		FrameStackTooltip:HookScript("OnShow", style)
		EventTraceTooltip:HookScript("OnShow", style)

	elseif addon == "NDui" then
		local tooltips = {
			ChatMenu,
			EmoteMenu,
			LanguageMenu,
			VoiceMacroMenu,
			GameTooltip,
			ItemRefTooltip,
			ItemRefShoppingTooltip1,
			ItemRefShoppingTooltip2,
			ShoppingTooltip1,
			ShoppingTooltip2,
			AutoCompleteBox,
			FriendsTooltip,
			WorldMapTooltip,
			WorldMapCompareTooltip1,
			WorldMapCompareTooltip2,
			WorldMapCompareTooltip3,
			FriendsMenuXPMenuBackdrop,
			FriendsMenuXPSecureMenuBackdrop,
			QuestScrollFrame.StoryTooltip,
			GeneralDockManagerOverflowButtonList,
			ReputationParagonTooltip,
		}
		for _, f in pairs(tooltips) do
			if f then
				f:HookScript("OnShow", style)
			end
		end

		local extra = {
			QueueStatusFrame,
			FloatingGarrisonFollowerTooltip,
			FloatingGarrisonFollowerAbilityTooltip,
			FloatingGarrisonMissionTooltip,
			GarrisonFollowerAbilityTooltip,
			GarrisonFollowerTooltip,
			FloatingGarrisonShipyardFollowerTooltip,
			GarrisonShipyardFollowerTooltip,
			BattlePetTooltip,
			PetBattlePrimaryAbilityTooltip,
			PetBattlePrimaryUnitTooltip,
			FloatingBattlePetTooltip,
			FloatingPetBattleAbilityTooltip,
			IMECandidatesFrame
		}
		for _, f in pairs(extra) do
			if f then
				f:HookScript("OnShow", extrastyle)
			end
		end

		-- DropdownMenu
		hooksecurefunc("UIDropDownMenu_CreateFrames", function(level, index)
			for i = 1, UIDROPDOWNMENU_MAXLEVELS do
				local menu = _G["DropDownList"..i.."MenuBackdrop"]
				if menu and not menu.styled then
					menu:HookScript("OnShow", style)
					menu.styled = true
				end

				local menu2 = _G["Lib_DropDownList"..i.."MenuBackdrop"]
				if menu2 and not menu2.styled then
					menu2:HookScript("OnShow", style)
					menu2.styled = true
				end
			end
		end)

		-- IME
		local r, g, b = DB.cc.r, DB.cc.g, DB.cc.b
		IMECandidatesFrame.selection:SetVertexColor(r, g, b)

		-- Tooltip StatusBar
		hooksecurefunc("GameTooltip_ShowStatusBar", function(self)
			local bar = _G[self:GetName().."StatusBar"..self.shownStatusBars]
			if bar and not bar.styled then
				local _, bd, tex = bar:GetRegions()
				tex:SetTexture(DB.normTex)
				bd:Hide()
				local bg = B.CreateBG(bd)
				B.CreateBD(bg, .2)
				bar.styled = true
			end
		end)

		local bars = {WorldMapTaskTooltipStatusBar, ReputationParagonTooltipStatusBar}
		for _, bar in pairs(bars) do
			if not bar.styled then
				for i = 1, 7 do
					select(i, bar.Bar:GetRegions()):Hide()
				end
				bar.Bar:SetStatusBarTexture(DB.normTex)
				bar.Bar.Label:Show()
				local bg = select(7, bar.Bar:GetRegions())
				local newBg = B.CreateBG(bg, 3)
				B.CreateBD(newBg, .3)
				bar.styled = true
			end
		end

		-- Pet Tooltip
		PetBattlePrimaryUnitTooltip.Delimiter:SetColorTexture(0, 0, 0)
		PetBattlePrimaryUnitTooltip.Delimiter:SetHeight(1)
		PetBattlePrimaryUnitTooltip.Delimiter2:SetColorTexture(0, 0, 0)
		PetBattlePrimaryUnitTooltip.Delimiter2:SetHeight(1)
		PetBattlePrimaryAbilityTooltip.Delimiter1:SetHeight(1)
		PetBattlePrimaryAbilityTooltip.Delimiter1:SetColorTexture(0, 0, 0)
		PetBattlePrimaryAbilityTooltip.Delimiter2:SetHeight(1)
		PetBattlePrimaryAbilityTooltip.Delimiter2:SetColorTexture(0, 0, 0)
		FloatingPetBattleAbilityTooltip.Delimiter1:SetHeight(1)
		FloatingPetBattleAbilityTooltip.Delimiter1:SetColorTexture(0, 0, 0)
		FloatingPetBattleAbilityTooltip.Delimiter2:SetHeight(1)
		FloatingPetBattleAbilityTooltip.Delimiter2:SetColorTexture(0, 0, 0)
		FloatingBattlePetTooltip.Delimiter:SetColorTexture(0, 0, 0)
		FloatingBattlePetTooltip.Delimiter:SetHeight(1)

		PetBattlePrimaryUnitTooltip:HookScript("OnShow", function(self)
			if not self.tipStyled then
				if self.glow then self.glow:Hide() end
				self.Border:Hide()
				self.Icon:SetTexCoord(unpack(DB.TexCoord))
				self.tipStyled = true
			end
		end)

		hooksecurefunc("PetBattleUnitTooltip_UpdateForUnit", function(self)
			local nextBuff, nextDebuff = 1, 1
			for i = 1, C_PetBattles.GetNumAuras(self.petOwner, self.petIndex) do
				local _, _, _, isBuff = C_PetBattles.GetAuraInfo(self.petOwner, self.petIndex, i)
				if isBuff and self.Buffs then
					local frame = self.Buffs.frames[nextBuff]
					if frame and frame.Icon then
						frame.Icon:SetTexCoord(unpack(DB.TexCoord))
					end
					nextBuff = nextBuff + 1
				elseif (not isBuff) and self.Debuffs then
					local frame = self.Debuffs.frames[nextDebuff]
					if frame and frame.Icon then
						frame.DebuffBorder:Hide()
						frame.Icon:SetTexCoord(unpack(DB.TexCoord))
					end
					nextDebuff = nextDebuff + 1
				end
			end
		end)

		-- Addon Supports
		if IsAddOnLoaded("MeetingStone") then
			local tips = {
				NetEaseGUI20_Tooltip51,
				NetEaseGUI20_Tooltip52,
			}
			for _, f in pairs(tips) do
				if f then
					f:HookScript("OnShow", style)
				end
			end
		end

	elseif addon == "Blizzard_Collections" then
		local pet = {
			PetJournalPrimaryAbilityTooltip,
			PetJournalSecondaryAbilityTooltip,
		}
		for _, f in pairs(pet) do
			if f then
				f:HookScript("OnShow", extrastyle)
			end
		end

		PetJournalPrimaryAbilityTooltip.Delimiter1:SetHeight(1)
		PetJournalPrimaryAbilityTooltip.Delimiter1:SetColorTexture(0, 0, 0)
		PetJournalPrimaryAbilityTooltip.Delimiter2:SetHeight(1)
		PetJournalPrimaryAbilityTooltip.Delimiter2:SetColorTexture(0, 0, 0)

	elseif addon == "Blizzard_GarrisonUI" then
		local gt = {
			GarrisonMissionMechanicTooltip,
			GarrisonMissionMechanicFollowerCounterTooltip,
			GarrisonShipyardMapMissionTooltip,
			GarrisonBonusAreaTooltip,
			GarrisonBuildingFrame.BuildingLevelTooltip
		}
		for _, f in pairs(gt) do
			if f then
				f:HookScript("OnShow", extrastyle)
			end
		end

	elseif addon == "Blizzard_OrderHallUI" then
		local gt = {
			GarrisonFollowerAbilityWithoutCountersTooltip,
			GarrisonFollowerMissionAbilityWithoutCountersTooltip,
		}
		for _, f in pairs(gt) do
			if f then
				f:HookScript("OnShow", extrastyle)
			end
		end

	elseif addon == "Blizzard_PVPUI" then
		local gt = {
			ConquestTooltip,
			PVPRewardTooltip,
		}
		for _, f in pairs(gt) do
			if f then
				f:HookScript("OnShow", style)
			end
		end

	elseif addon == "Blizzard_Contribution" then
		local gt = {
			ContributionTooltip,
			ContributionBuffTooltip,
		}
		for _, f in pairs(gt) do
			if f then
				f:HookScript("OnShow", extrastyle)
			end
		end
		ContributionBuffTooltip.Icon:SetTexCoord(unpack(DB.TexCoord))
		ContributionBuffTooltip.Border:SetAlpha(0)

	elseif addon == "Blizzard_EncounterJournal" then
		local f = EncounterJournalTooltip
		if f then
			f:HookScript("OnShow", style)
		end
		EncounterJournalTooltip.Item1.icon:SetTexCoord(unpack(DB.TexCoord))
		EncounterJournalTooltip.Item2.icon:SetTexCoord(unpack(DB.TexCoord))
	end
end)

-- Reskin Closebutton
if IsAddOnLoaded("Aurora") then
	local F, C = unpack(Aurora)
	F.ReskinClose(FloatingBattlePetTooltip.CloseButton)
	F.ReskinClose(FloatingPetBattleAbilityTooltip.CloseButton)
	F.ReskinClose(FloatingGarrisonMissionTooltip.CloseButton)
end