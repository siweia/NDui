local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:RegisterModule("Tooltip")

function module:OnLogin()
	self:ExtraTipInfo()
	self:TargetedInfo()
	self:AzeriteArmor()
end

local classification = {
	elite = " |cffcc8800"..ELITE.."|r",
	rare = " |cffff99cc"..L["Rare"].."|r",
	rareelite = " |cffff99cc"..L["Rare"].."|r ".."|cffcc8800"..ELITE.."|r",
	worldboss = " |cffff0000"..BOSS.."|r",
}
local COALESCED_REALM_TOOLTIP1 = string.split(FOREIGN_SERVER_LABEL, COALESCED_REALM_TOOLTIP)
local INTERACTIVE_REALM_TOOLTIP1 = string.split(INTERACTIVE_SERVER_LABEL, INTERACTIVE_REALM_TOOLTIP)

local function getUnit(self)
	local _, unit = self and self:GetUnit()
	if not unit then
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
		if ricon and ricon > 8 then ricon = nil end
		if ricon then
			local text = GameTooltipTextLeft1:GetText()
			GameTooltipTextLeft1:SetFormattedText(("%s %s"), ICON_LIST[ricon].."18|t", text)
		end

		if UnitIsPlayer(unit) then
			local relationship = UnitRealmRelationship(unit)
			if relationship == LE_REALM_RELATION_VIRTUAL then
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

			local guildName, rank, rankIndex, guildRealm = GetGuildInfo(unit)
			local text = GameTooltipTextLeft2:GetText()
			if rank and text then
				rankIndex = rankIndex + 1
				if NDuiDB["Tooltip"]["HideRank"] then
					GameTooltipTextLeft2:SetText("<"..text..">")
				else
					GameTooltipTextLeft2:SetText("<"..text..">  "..rank.."("..rankIndex..")")
				end

				local myGuild, _, _, myGuildRealm = GetGuildInfo("player")
				if IsInGuild() and guildName == myGuild and guildRealm == myGuildRealm then
					GameTooltipTextLeft2:SetTextColor(.25, 1, .25)
				else
					GameTooltipTextLeft2:SetTextColor(.6, .8, 1)
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
				if linetext and linetext:find(LEVEL) then
					tiptextLevel = tiptext
				end
			end

			local creature = not UnitIsPlayer(unit) and UnitCreatureType(unit) or ""
			local unitClass = UnitIsPlayer(unit) and ("%s %s"):format(UnitRace(unit) or "", hexColor..(UnitClass(unit) or "").."|r") or ""
			if tiptextLevel then
				tiptextLevel:SetFormattedText(("%s %s%s %s"), textLevel, creature, unitClass, (not alive and "|cffCCCCCC"..DEAD.."|r" or ""))
			end
		end

		if UnitExists(unit.."target") then
			local tarRicon = GetRaidTargetIndex(unit.."target")
			if tarRicon and tarRicon > 8 then tarRicon = nil end
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
		GameTooltipStatusBar:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 2, 3)
		GameTooltipStatusBar:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -2, 3)
	end
end)

-- Tooltip statusbars
do
	GameTooltipStatusBar:SetStatusBarTexture(DB.normTex)
	GameTooltipStatusBar:SetHeight(5)
	B.CreateSD(GameTooltipStatusBar, 3, 3)
	local bg = B.CreateBG(GameTooltipStatusBar, 1)
	B.CreateBD(bg, .7)
	B.CreateSD(bg)
	B.CreateTex(bg)
end

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

hooksecurefunc("GameTooltip_ShowStatusBar", function(self)
	if self.statusBarPool then
		local bar = self.statusBarPool:Acquire()
		if bar and not bar.styled then
			local _, bd, tex = bar:GetRegions()
			tex:SetTexture(DB.normTex)
			bd:Hide()
			local bg = B.CreateBG(bd, 0)
			B.CreateBD(bg, .25)

			bar.styled = true
		end
	end
end)

hooksecurefunc("GameTooltip_ShowProgressBar", function(self)
	if self.progressBarPool then
		local bar = self.progressBarPool:Acquire()
		if bar and not bar.styled then
			B.StripTextures(bar.Bar, true)
			bar.Bar:SetStatusBarTexture(DB.normTex)
			B.CreateBD(bar, .25)
			bar:SetSize(216, 18)

			bar.styled = true
		end
	end
end)

-- Anchor and mover
local mover
hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
	if NDuiDB["Tooltip"]["Cursor"] then
		tooltip:SetOwner(parent, "ANCHOR_CURSOR_RIGHT")
	else
		if not mover then
			mover = B.Mover(tooltip, L["Tooltip"], "GameTooltip", C.Tooltips.TipPos, 240, 120)
		end
		tooltip:SetOwner(parent, "ANCHOR_NONE")
		tooltip:ClearAllPoints()
		tooltip:SetPoint("BOTTOMRIGHT", mover)
	end
end)

-- Tooltip skin
local function style(self)
	self:SetScale(NDuiDB["Tooltip"]["Scale"])

	if not self.tipStyled then
		self:SetBackdrop(nil)
		local bg = B.CreateBG(self, 0)
		bg:SetFrameLevel(self:GetFrameLevel())
		B.CreateBD(bg, .7)
		B.CreateSD(bg)
		B.CreateTex(bg)
		self.bg = bg

		-- other gametooltip-like support
		self.GetBackdrop = function() return bg:GetBackdrop() end
		self.GetBackdropColor = function() return 0, 0, 0, .7 end
		self.GetBackdropBorderColor = function() return 0, 0, 0 end

		self.tipStyled = true
	end

	self.bg:SetBackdropBorderColor(0, 0, 0)
	if NDuiDB["Tooltip"]["ClassColor"] and self.GetItem then
		local _, item = self:GetItem()
		if item then
			local quality = select(3, GetItemInfo(item))
			local color = BAG_ITEM_QUALITY_COLORS[quality or 1]
			if color then
				self.bg:SetBackdropBorderColor(color.r, color.g, color.b)
			end
		end
	end

	if self.NumLines and self:NumLines() > 0 then
		for index = 1, self:NumLines() do
			if index == 1 then
				_G[self:GetName().."TextLeft"..index]:SetFont(DB.TipFont[1], DB.TipFont[2] + 2, DB.TipFont[3])
			else
				_G[self:GetName().."TextLeft"..index]:SetFont(unpack(DB.TipFont))
			end
			_G[self:GetName().."TextRight"..index]:SetFont(unpack(DB.TipFont))
		end
	end
end

local function extrastyle(self)
	if not self.styled then
		self:DisableDrawLayer("BACKGROUND")
		style(self)

		self.styled = true
	end
end

hooksecurefunc("GameTooltip_SetBackdropStyle", function(self)
	if not self.tipStyled then return end
	self:SetBackdrop(nil)
end)

local function addonStyled(_, addon)
	if addon == "Blizzard_DebugTools" then
		local tooltips = {
			FrameStackTooltip,
			EventTraceTooltip
		}
		for _, tip in pairs(tooltips) do
			tip:SetParent(UIParent)
			tip:SetFrameStrata("TOOLTIP")
			tip:HookScript("OnShow", style)
		end

	elseif addon == "NDui" then
		if IsAddOnLoaded("AuroraClassic") then
			local F, C = unpack(AuroraClassic)
			F.ReskinClose(FloatingBattlePetTooltip.CloseButton)
			F.ReskinClose(FloatingPetBattleAbilityTooltip.CloseButton)
			F.ReskinClose(FloatingGarrisonMissionTooltip.CloseButton)
			AuroraOptionstooltips:SetAlpha(0)
			AuroraOptionstooltips:Disable()
			AuroraConfig.tooltips = false
		end

		local tooltips = {
			ChatMenu,
			EmoteMenu,
			LanguageMenu,
			VoiceMacroMenu,
			GameTooltip,
			EmbeddedItemTooltip,
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
			QuestScrollFrame.StoryTooltip,
			GeneralDockManagerOverflowButtonList,
			ReputationParagonTooltip,
			QuestScrollFrame.WarCampaignTooltip,
			NamePlateTooltip,
			LibDBIconTooltip,
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
		hooksecurefunc("UIDropDownMenu_CreateFrames", function()
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

		-- Pet Tooltip
		local petTips = {
			PetBattlePrimaryUnitTooltip.Delimiter,
			PetBattlePrimaryUnitTooltip.Delimiter2,
			PetBattlePrimaryAbilityTooltip.Delimiter1,
			PetBattlePrimaryAbilityTooltip.Delimiter2,
			FloatingPetBattleAbilityTooltip.Delimiter1,
			FloatingPetBattleAbilityTooltip.Delimiter2,
			FloatingBattlePetTooltip.Delimiter,
		}
		for _, element in pairs(petTips) do
			element:SetColorTexture(0, 0, 0)
			element:SetHeight(1.2)
		end

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

		-- MeetingShit
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
			GarrisonBuildingFrame.BuildingLevelTooltip,
			GarrisonFollowerAbilityWithoutCountersTooltip,
			GarrisonFollowerMissionAbilityWithoutCountersTooltip
		}
		for _, f in pairs(gt) do
			if f then
				f:HookScript("OnShow", extrastyle)
			end
		end

	elseif addon == "Blizzard_PVPUI" then
		ConquestTooltip:HookScript("OnShow", style)

	elseif addon == "Blizzard_Contribution" then
		ContributionBuffTooltip:HookScript("OnShow", extrastyle)
		ContributionBuffTooltip.Icon:SetTexCoord(unpack(DB.TexCoord))
		ContributionBuffTooltip.Border:SetAlpha(0)

	elseif addon == "Blizzard_EncounterJournal" then
		EncounterJournalTooltip:HookScript("OnShow", style)
		EncounterJournalTooltip.Item1.icon:SetTexCoord(unpack(DB.TexCoord))
		EncounterJournalTooltip.Item2.icon:SetTexCoord(unpack(DB.TexCoord))

	elseif addon == "Blizzard_Calendar" then
		local gt = {
			CalendarContextMenu,
			CalendarInviteStatusContextMenu,
		}
		for _, f in pairs(gt) do
			if f then
				f:HookScript("OnShow", style)
			end
		end

	elseif addon == "Blizzard_IslandsQueueUI" then
		local tip = IslandsQueueFrameTooltip
		tip:GetParent():GetParent():HookScript("OnShow", style)
		tip:GetParent().IconBorder:SetAlpha(0)
		tip:GetParent().Icon:SetTexCoord(unpack(DB.TexCoord))
	end
end
B:RegisterEvent("ADDON_LOADED", addonStyled)