local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:RegisterModule("Tooltip")

local cr, cg, cb = DB.r, DB.g, DB.b
local strfind, format, strupper, strlen, pairs, unpack = string.find, string.format, string.upper, string.len, pairs, unpack
local ICON_LIST = ICON_LIST
local HIGHLIGHT_FONT_COLOR = HIGHLIGHT_FONT_COLOR
local PVP, LEVEL, FACTION_HORDE, FACTION_ALLIANCE = PVP, LEVEL, FACTION_HORDE, FACTION_ALLIANCE
local YOU, TARGET, AFK, DND, DEAD, PLAYER_OFFLINE = YOU, TARGET, AFK, DND, DEAD, PLAYER_OFFLINE
local FOREIGN_SERVER_LABEL, INTERACTIVE_SERVER_LABEL = FOREIGN_SERVER_LABEL, INTERACTIVE_SERVER_LABEL
local LE_REALM_RELATION_COALESCED, LE_REALM_RELATION_VIRTUAL = LE_REALM_RELATION_COALESCED, LE_REALM_RELATION_VIRTUAL
local UnitIsPVP, UnitFactionGroup, UnitRealmRelationship = UnitIsPVP, UnitFactionGroup, UnitRealmRelationship
local UnitIsConnected, UnitIsDeadOrGhost, UnitIsAFK, UnitIsDND, UnitReaction = UnitIsConnected, UnitIsDeadOrGhost, UnitIsAFK, UnitIsDND, UnitReaction
local InCombatLockdown, IsShiftKeyDown = InCombatLockdown, IsShiftKeyDown
local GetCreatureDifficultyColor, UnitCreatureType, UnitClassification = GetCreatureDifficultyColor, UnitCreatureType, UnitClassification
local UnitIsWildBattlePet, UnitIsBattlePetCompanion, UnitBattlePetLevel = UnitIsWildBattlePet, UnitIsBattlePetCompanion, UnitBattlePetLevel
local UnitIsPlayer, UnitName, UnitPVPName, UnitRace, UnitLevel = UnitIsPlayer, UnitName, UnitPVPName, UnitRace, UnitLevel
local GetRaidTargetIndex, UnitGroupRolesAssigned, GetGuildInfo, IsInGuild = GetRaidTargetIndex, UnitGroupRolesAssigned, GetGuildInfo, IsInGuild
local C_PetBattles_GetNumAuras, C_PetBattles_GetAuraInfo = C_PetBattles.GetNumAuras, C_PetBattles.GetAuraInfo
local C_ChallengeMode_GetDungeonScoreRarityColor = C_ChallengeMode.GetDungeonScoreRarityColor
local C_PlayerInfo_GetPlayerMythicPlusRatingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary
local GameTooltip_ClearMoney, GameTooltip_ClearStatusBars, GameTooltip_ClearProgressBars = GameTooltip_ClearMoney, GameTooltip_ClearStatusBars, GameTooltip_ClearProgressBars
local ShouldUnitIdentityBeSecret = C_Secrets and C_Secrets.ShouldUnitIdentityBeSecret
local GetDisplayedItem = TooltipUtil and TooltipUtil.GetDisplayedItem

local classification = {
	elite = " |cffcc8800"..ELITE.."|r",
	rare = " |cffff99cc"..L["Rare"].."|r",
	rareelite = " |cffff99cc"..L["Rare"].."|r ".."|cffcc8800"..ELITE.."|r",
	worldboss = " |cffff0000"..BOSS.."|r",
}
local npcIDstring = "%s "..DB.InfoColor.."%s"
local ignoreString = "|cffff0000"..IGNORED..":|r %s"
local specPrefix = "|cffFFCC00"..SPECIALIZATION..": "..DB.InfoColor

function TT:GetUnit()
	local data = self:GetTooltipData()
	local guid = data and B:NotSecretValue(data.guid) and data.guid
	local unit = guid and UnitTokenFromGUID(guid)
	return unit, guid
end

function TT:UnitExists(unit)
	if ShouldUnitIdentityBeSecret and ShouldUnitIdentityBeSecret(unit) then return end
	return unit and UnitExists(unit)
end

local FACTION_COLORS = {
	[FACTION_ALLIANCE] = "|cff4080ff%s|r",
	[FACTION_HORDE] = "|cffff5040%s|r",
}

local function replaceSpecInfo(str)
	return strfind(str, "%s") and specPrefix..str or str
end

function TT:GetLevelLine()
	for i = 2, self:NumLines() do
		local tiptext = _G["GameTooltipTextLeft"..i]
		if not tiptext then break end
		local linetext = tiptext:GetText()
		if linetext and strfind(linetext, LEVEL) then
			return tiptext, i
		end
	end
end

function TT:GetTarget(unit)
	if ShouldUnitIdentityBeSecret(unit) then return "" end
	if UnitIsUnit(unit, "player") then
		return format("|cffff0000%s|r", ">"..strupper(YOU).."<")
	else
		return B.HexRGB(B.UnitColor(unit))..UnitName(unit).."|r"
	end
end

function TT:InsertFactionFrame(faction)
	if not self.factionFrame then
		local f = self:CreateTexture(nil, "OVERLAY")
		f:SetPoint("TOPRIGHT", 0, -5)
		f:SetBlendMode("ADD")
		f:SetScale(.3)
		f:SetAlpha(.7)
		self.factionFrame = f
	end
	self.factionFrame:SetTexture("Interface\\Timer\\"..faction.."-Logo")
	self.factionFrame:Show()
end

function TT:InsertRoleFrame(role)
	if not self.roleFrame then
		local f = self:CreateTexture(nil, "OVERLAY")
		f:SetPoint("TOPRIGHT", self, -2, -2)
		f:SetSize(18, 18)
		self.roleFrame = f
	end
	B.ReskinSmallRole(self.roleFrame, role)
	self.roleFrame:Show()
end

function TT:OnTooltipCleared()
	if self:IsForbidden() then return end

	if self.factionFrame and self.factionFrame:IsShown() then
		self.factionFrame:Hide()
	end
	if self.roleFrame and self.roleFrame:IsShown() then
		self.roleFrame:Hide()
	end

	GameTooltip_ClearMoney(self)
	GameTooltip_ClearStatusBars(self)
	GameTooltip_ClearProgressBars(self)

	if self.bg then B.SetBorderColor(self.bg) end
end

function TT.GetDungeonScore(score)
	local color = C_ChallengeMode_GetDungeonScoreRarityColor(score) or HIGHLIGHT_FONT_COLOR
	return color:WrapTextInColorCode(score)
end

function TT:ShowUnitMythicPlusScore(unit)
	if not C.db["Tooltip"]["MythicScore"] then return end

	local summary = C_PlayerInfo_GetPlayerMythicPlusRatingSummary(unit)
	local score = summary and summary.currentSeasonScore
	if score and score > 0 then
		GameTooltip:AddLine(format(L["MythicScore"], TT.GetDungeonScore(score)))
	end
end

local function ShouldHideInCombat()
	local index = C.db["Tooltip"]["HideInCombat"]
	if index == 1 then
		return true
	elseif index == 2 then
		return IsAltKeyDown()
	elseif index == 3 then
		return IsShiftKeyDown()
	elseif index == 4 then
		return IsControlKeyDown()
	elseif index == 5 then
		return false
	end
end

local function CheckUnitStatus(func, unit, text)
	local status = func(unit)
	return B:NotSecretValue(status) and status and text
end

function TT:OnTooltipSetUnit()
	if self:IsForbidden() or self ~= GameTooltip then return end

	if (not ShouldHideInCombat()) and InCombatLockdown() then
		self:Hide()
		return
	end

	local unit, guid = TT.GetUnit(self)
	if not unit or not TT:UnitExists(unit) then return end

	local isShiftKeyDown = IsShiftKeyDown()
	local isPlayer = UnitIsPlayer(unit)
	local unitFullName
	if isPlayer then
		local name, realm = UnitName(unit)
		unitFullName = name.."-"..(realm or DB.MyRealm)
		local pvpName = UnitPVPName(unit)
		local relationship = UnitRealmRelationship(unit)
		if not C.db["Tooltip"]["HideTitle"] and pvpName and pvpName ~= "" then
			name = pvpName
		end
		if realm and realm ~= "" then
			if isShiftKeyDown or not C.db["Tooltip"]["HideRealm"] then
				name = name.."-"..realm
			elseif relationship == LE_REALM_RELATION_COALESCED then
				name = name..FOREIGN_SERVER_LABEL
			elseif relationship == LE_REALM_RELATION_VIRTUAL then
				name = name..INTERACTIVE_SERVER_LABEL
			end
		end

		local status = CheckUnitStatus(UnitIsAFK, unit, AFK) or CheckUnitStatus(UnitIsDND, unit, DND) or (not UnitIsConnected(unit) and PLAYER_OFFLINE)
		if status then
			status = format(" |cffffcc00[%s]|r", status)
		end
		GameTooltipTextLeft1:SetFormattedText("%s", name..(status or ""))

		if C.db["Tooltip"]["FactionIcon"] then
			local faction = UnitFactionGroup(unit)
			if faction and faction ~= "Neutral" then
				TT.InsertFactionFrame(self, faction)
			end
		end

		if C.db["Tooltip"]["LFDRole"] then
			local role = UnitGroupRolesAssigned(unit)
			if role ~= "NONE" then
				TT.InsertRoleFrame(self, role)
			end
		end

		local guildName, rank, rankIndex, guildRealm = GetGuildInfo(unit)
		local hasText = GameTooltipTextLeft2:GetText()
		if guildName and hasText then
			local myGuild, _, _, myGuildRealm = GetGuildInfo("player")
			if IsInGuild() and guildName == myGuild and guildRealm == myGuildRealm then
				GameTooltipTextLeft2:SetTextColor(.25, 1, .25)
			else
				GameTooltipTextLeft2:SetTextColor(.6, .8, 1)
			end

			rankIndex = rankIndex + 1
			if C.db["Tooltip"]["HideRank"] then rank = "" end
			if guildRealm and isShiftKeyDown then
				guildName = guildName.."-"..guildRealm
			end
			if C.db["Tooltip"]["HideJunkGuild"] and not isShiftKeyDown then
				if strlen(guildName) > 31 then guildName = "..." end
			end
			GameTooltipTextLeft2:SetText("<"..guildName.."> "..rank.."("..rankIndex..")")
		end
	end

	local r, g, b = B.UnitColor(unit)
	local hexColor = B.HexRGB(r, g, b)
	local text = GameTooltipTextLeft1:GetText()
	if text then
		local ricon = GetRaidTargetIndex(unit)
		if ricon and B:NotSecretValue(ricon) and ricon <= 8 then
			ricon = ICON_LIST[ricon].."18|t "
		end
		GameTooltipTextLeft1:SetFormattedText(("%s%s%s"), ricon or "", hexColor, text)
	end
	self.StatusBar:SetStatusBarColor(r, g, b)

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
		local textLevel = format("%s%s%s|r", B.HexRGB(diff), boss or format("%d", level), classification[classify] or "")
		local tiptextLevel, index = TT.GetLevelLine(self)
		local unitClass = isPlayer and UnitClass(unit)
		if tiptextLevel then
			local reaction = UnitReaction(unit, "player")
			local standingText = not isPlayer and reaction and hexColor.._G["FACTION_STANDING_LABEL"..reaction].."|r " or ""

			local pvpFlag = isPlayer and UnitIsPVP(unit) and format(" |cffff0000%s|r", PVP) or ""
			local unitClassStr = isPlayer and format("%s %s", UnitRace(unit) or "", hexColor..(unitClass or "").."|r") or UnitCreatureType(unit) or ""

			tiptextLevel:SetFormattedText(("%s%s %s %s"), textLevel, pvpFlag, standingText..unitClassStr, (not alive and "|cffCCCCCC"..DEAD.."|r" or ""))
		end

		local specLine = index and _G["GameTooltipTextLeft"..(index+1)]
		local specText = specLine and specLine:GetText()
		if specText and unitClass and strfind(specText, unitClass) then
			specText = gsub(specText, "(.-)%S+$", replaceSpecInfo)
			specLine:SetText(specText)
		end
	end

	if TT:UnitExists(unit.."target") then
		local targetIcon = GetRaidTargetIndex(unit.."target")
		if targetIcon and B:NotSecretValue(targetIcon) and targetIcon <= 8 then
			targetIcon = ICON_LIST[targetIcon].."10|t"
		end
		self:AddLine(TARGET..": "..format("%s%s", targetIcon or "", TT:GetTarget(unit.."target")))
	end

	if not isPlayer and isShiftKeyDown then
		local npcID = B.GetNPCID(guid)
		if npcID then
			self:AddLine(format(npcIDstring, "NpcID:", npcID))
		end
	end

	if isPlayer then
		TT.InspectUnitItemLevel(self, unit)
		TT.ShowUnitMythicPlusScore(self, unit)
	end
	TT.PetInfo_Setup(self, unit)

	-- Ignore note
	local ignoreNote = unitFullName and NDuiADB["IgnoreNotes"][unitFullName]
	if ignoreNote then
		self:AddLine(format(ignoreString, ignoreNote), 1,1,1, 1)
	end
end

function TT:RefreshStatusBar(value)
	if not self.text then
		self.text = B.CreateFS(self, 12, "")
	end
	local unit = TT.GetUnit(self:GetParent())
	if unit and UnitIsPlayer(unit) then
		self.text:SetFormattedText("%d", UnitHealthPercent(unit, true, CurveConstants.ScaleTo100))
	else
		self.text:SetText("")
	end
end

function TT:ReskinStatusBar()
	self.StatusBar:ClearAllPoints()
	self.StatusBar:SetPoint("BOTTOMLEFT", self.bg, "TOPLEFT", C.mult, 3)
	self.StatusBar:SetPoint("BOTTOMRIGHT", self.bg, "TOPRIGHT", -C.mult, 3)
	self.StatusBar:SetStatusBarTexture(DB.normTex)
	self.StatusBar:SetHeight(5)
	B.SetBD(self.StatusBar)
end

function TT:GameTooltip_ShowStatusBar()
	if not self or self:IsForbidden() then return end
	if not self.statusBarPool then return end

	local bar = self.statusBarPool:GetNextActive()
	if bar and not bar.styled then
		B.StripTextures(bar)
		B.CreateBDFrame(bar, .25)
		bar:SetStatusBarTexture(DB.normTex)

		bar.styled = true
	end
end

function TT:GameTooltip_ShowProgressBar()
	if not self or self:IsForbidden() then return end
	if not self.progressBarPool then return end

	local bar = self.progressBarPool:GetNextActive()
	if bar and not bar.styled then
		B.StripTextures(bar.Bar)
		B.CreateBDFrame(bar.Bar, .25)
		bar.Bar:SetStatusBarTexture(DB.normTex)

		bar.styled = true
	end
end

-- Anchor and mover
local cursorIndex = {
	[1] = "ANCHOR_NONE",
	[2] = "ANCHOR_CURSOR_LEFT",
	[3] = "ANCHOR_CURSOR",
	[4] = "ANCHOR_CURSOR_RIGHT"
}
local anchorIndex = {
	[1] = "TOPLEFT",
	[2] = "TOPRIGHT",
	[3] = "BOTTOMLEFT",
	[4] = "BOTTOMRIGHT",
}
local mover
function TT:GameTooltip_SetDefaultAnchor(parent)
	if self:IsForbidden() then return end
	if not parent or parent:IsForbidden() then return end

	local mode = C.db["Tooltip"]["CursorMode"]
	self:SetOwner(parent, cursorIndex[mode])
	if mode == 1 then
		if not mover then
			mover = B.Mover(self, L["Tooltip"], "GameTooltip", C.Tooltips.TipPos, 100, 100)
		end
		self:ClearAllPoints()
		self:SetPoint(anchorIndex[C.db["Tooltip"]["TipAnchor"]], mover)
	end
end

-- Tooltip skin
function TT:ReskinTooltip()
	if not self then
		if DB.isDeveloper then print("Unknown tooltip spotted.") end
		return
	end
	if self:IsForbidden() then return end
	self:SetScale(C.db["Tooltip"]["Scale"])

	if not self.tipStyled then
		self:HideBackdrop()
		if self.background then self.background:Hide() end
		self.bg = B.SetBD(self, .7)
		self.bg:SetInside(self)
		--self.bg:SetFrameLevel(self:GetFrameLevel())
		B.SetBorderColor(self.bg)

		if self.StatusBar then
			TT.ReskinStatusBar(self)
		end

		local header = self.CompareHeader
		if header then
			B.StripTextures(header)
			local bg = header:CreateTexture(nil, "ARTWORK")
			bg:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
			bg:SetTexCoord(0, .66, 0, .31)
			bg:SetVertexColor(cr, cg, cb, .8)
			bg:SetPoint("BOTTOM", 0, -4)
			bg:SetSize(100, 30)
		end

		self.tipStyled = true
	end
end

local function TooltipSetFont(font, size)
	B.SetFontSize(font, size)
	font:SetShadowColor(0, 0, 0, 0)
end

function TT:SetupTooltipFonts()
	local textSize = DB.Font[2] + 2
	local headerSize = DB.Font[2] + 4

	TooltipSetFont(GameTooltipHeaderText, headerSize)
	TooltipSetFont(GameTooltipText, textSize)
	TooltipSetFont(GameTooltipTextSmall, textSize)

	--[[if not GameTooltip.hasMoney then
		SetTooltipMoney(GameTooltip, 1, nil, "", "")
		SetTooltipMoney(GameTooltip, 1, nil, "", "")
		GameTooltip_ClearMoney(GameTooltip)
	end]]
	if GameTooltip.hasMoney then
		for i = 1, GameTooltip.numMoneyFrames do
			TooltipSetFont(_G["GameTooltipMoneyFrame"..i.."PrefixText"], textSize)
			TooltipSetFont(_G["GameTooltipMoneyFrame"..i.."SuffixText"], textSize)
		end
	end

	for _, tt in ipairs(GameTooltip.shoppingTooltips) do
		for i = 1, tt:GetNumRegions() do
			local region = select(i, tt:GetRegions())
			if region:IsObjectType("FontString") then
				TooltipSetFont(region, textSize)
			end
		end
	end
end

function TT:FixRecipeItemNameWidth()
	if self.GetName then
		local name = self:GetName()
		for i = 1, self:NumLines() do
			local line = _G[name.."TextLeft"..i]
			if line and B:NotSecretValue(line:GetWidth()) and line:GetHeight() > 40 then
				line:SetWidth(line:GetWidth() + 2)
			end
		end
	end

	if not self.bg then return end

	if C.db["Tooltip"]["ItemQuality"] then
		local name, link = GetDisplayedItem(self)
		if link then
			local quality = C_Item.GetItemQualityByID(link)
			local color = DB.QualityColors[quality or 1]
			if color then
				self.bg:SetBackdropBorderColor(color.r, color.g, color.b)
			end
		end
	else
		B.SetBorderColor(self.bg)
	end
end

function TT:ResetUnit(btn)
	if btn == "LSHIFT" and TT:UnitExists("mouseover") then
		GameTooltip:RefreshData()
	end
end

function TT:FixStoneSoupError()
	local blockTooltips = {
		[556] = true -- Stone Soup
	}
	hooksecurefunc(_G.UIWidgetTemplateStatusBarMixin, "Setup", function(self)
		if self:IsForbidden() and blockTooltips[self.widgetSetID] and self.Bar then
			self.Bar.tooltip = nil
		end
	end)
end

function TT:OnLogin()
	GameTooltip:HookScript("OnTooltipCleared", TT.OnTooltipCleared)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, TT.OnTooltipSetUnit)
	--hooksecurefunc(GameTooltip.StatusBar, "SetValue", TT.RefreshStatusBar)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, TT.FixRecipeItemNameWidth)

	hooksecurefunc("GameTooltip_ShowStatusBar", TT.GameTooltip_ShowStatusBar)
	hooksecurefunc("GameTooltip_ShowProgressBar", TT.GameTooltip_ShowProgressBar)
	hooksecurefunc("GameTooltip_SetDefaultAnchor", TT.GameTooltip_SetDefaultAnchor)
	TT:SetupTooltipFonts()
	TT:FixStoneSoupError()

	-- Elements
	TT:ReskinTooltipIcons()
	TT:SetupTooltipID()
	TT:AzeriteArmor()
	B:RegisterEvent("MODIFIER_STATE_CHANGED", TT.ResetUnit)
end

-- Tooltip Skin Registration
local tipTable = {}
function TT:RegisterTooltips(addon, func)
	tipTable[addon] = func
end
local function addonStyled(_, addon)
	if tipTable[addon] then
		tipTable[addon]()
		tipTable[addon] = nil
	end
end
B:RegisterEvent("ADDON_LOADED", addonStyled)

TT:RegisterTooltips("NDui", function()
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
		QuestScrollFrame.StoryTooltip,
		QuestScrollFrame.CampaignTooltip,
		GeneralDockManagerOverflowButtonList,
		ReputationParagonTooltip,
		NamePlateTooltip,
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
		IMECandidatesFrame,
		QuickKeybindTooltip,
		GameSmallHeaderTooltip,
	}
	for _, f in pairs(tooltips) do
		f:HookScript("OnShow", TT.ReskinTooltip)
	end

	if SettingsTooltip then
		TT.ReskinTooltip(SettingsTooltip)
		SettingsTooltip:SetScale(UIParent:GetScale())
	end

	-- DropdownMenu
	local dropdowns = {"DropDownList", "L_DropDownList", "Lib_DropDownList"}
	local function reskinDropdown()
		for _, name in pairs(dropdowns) do
			for i = 1, UIDROPDOWNMENU_MAXLEVELS do
				local menu = _G[name..i.."MenuBackdrop"]
				if menu and not menu.styled then
					menu:HookScript("OnShow", TT.ReskinTooltip)
					menu.styled = true
				end
			end
		end
	end
	hooksecurefunc("UIDropDownMenu_CreateFrames", reskinDropdown)

	-- IME
	IMECandidatesFrame.selection:SetVertexColor(cr, cg, cb)

	-- Pet Tooltip
	PetBattlePrimaryUnitTooltip:HookScript("OnShow", function(self)
		self.Border:SetAlpha(0)
		if not self.iconStyled then
			if self.glow then self.glow:Hide() end
			self.Icon:SetTexCoord(unpack(DB.TexCoord))
			self.iconStyled = true
		end
	end)

	hooksecurefunc("PetBattleUnitTooltip_UpdateForUnit", function(self)
		local nextBuff, nextDebuff = 1, 1
		for i = 1, C_PetBattles_GetNumAuras(self.petOwner, self.petIndex) do
			local _, _, _, isBuff = C_PetBattles_GetAuraInfo(self.petOwner, self.petIndex, i)
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

	-- Others
	C_Timer.After(5, function()
		-- BagSync
		if BSYC_EventAlertTooltip then
			TT.ReskinTooltip(BSYC_EventAlertTooltip)
		end
		-- Libs
		if LibDBIconTooltip then
			TT.ReskinTooltip(LibDBIconTooltip)
		end
		if AceConfigDialogTooltip then
			TT.ReskinTooltip(AceConfigDialogTooltip)
		end
		-- TomTom
		if TomTomTooltip then
			TT.ReskinTooltip(TomTomTooltip)
		end
		-- RareScanner
		if RSMapItemToolTip then
			TT.ReskinTooltip(RSMapItemToolTip)
		end
		if LootBarToolTip then
			TT.ReskinTooltip(LootBarToolTip)
		end
		-- Narcissus
		if NarciGameTooltip then
			TT.ReskinTooltip(NarciGameTooltip)
		end
		-- Altoholic
		if AltoTooltip then
			TT.ReskinTooltip(AltoTooltip)
		end
	end)

	if C_AddOns.IsAddOnLoaded("BattlePetBreedID") then
		hooksecurefunc("BPBID_SetBreedTooltip", function(parent)
			if parent == FloatingBattlePetTooltip then
				TT.ReskinTooltip(BPBID_BreedTooltip2)
			else
				TT.ReskinTooltip(BPBID_BreedTooltip)
			end
		end)
	end

	-- MDT and DT
	if MDT and MDT.ShowInterface then
		local styledMDT
		hooksecurefunc(MDT, "ShowInterface", function()
			if not styledMDT then
				TT.ReskinTooltip(MDT.tooltip)
				TT.ReskinTooltip(MDT.pullTooltip)
				styledMDT = true
			end
		end)
	end
end)

TT:RegisterTooltips("Blizzard_DebugTools", function()
	TT.ReskinTooltip(FrameStackTooltip)
	FrameStackTooltip:SetScale(UIParent:GetScale())
end)

TT:RegisterTooltips("Blizzard_EventTrace", function()
	TT.ReskinTooltip(EventTraceTooltip)
end)

TT:RegisterTooltips("Blizzard_Collections", function()
	PetJournalPrimaryAbilityTooltip:HookScript("OnShow", TT.ReskinTooltip)
	PetJournalSecondaryAbilityTooltip:HookScript("OnShow", TT.ReskinTooltip)
	PetJournalPrimaryAbilityTooltip.Delimiter1:SetHeight(1)
	PetJournalPrimaryAbilityTooltip.Delimiter1:SetColorTexture(0, 0, 0)
	PetJournalPrimaryAbilityTooltip.Delimiter2:SetHeight(1)
	PetJournalPrimaryAbilityTooltip.Delimiter2:SetColorTexture(0, 0, 0)
end)

TT:RegisterTooltips("Blizzard_GarrisonUI", function()
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
		f:HookScript("OnShow", TT.ReskinTooltip)
	end
end)

TT:RegisterTooltips("Blizzard_PVPUI", function()
	ConquestTooltip:HookScript("OnShow", TT.ReskinTooltip)
end)

TT:RegisterTooltips("Blizzard_Contribution", function()
	ContributionBuffTooltip:HookScript("OnShow", TT.ReskinTooltip)
	ContributionBuffTooltip.Icon:SetTexCoord(unpack(DB.TexCoord))
	ContributionBuffTooltip.Border:SetAlpha(0)
end)

TT:RegisterTooltips("Blizzard_EncounterJournal", function()
	EncounterJournalTooltip:HookScript("OnShow", TT.ReskinTooltip)
	EncounterJournalTooltip.Item1.icon:SetTexCoord(unpack(DB.TexCoord))
	EncounterJournalTooltip.Item1.IconBorder:SetAlpha(0)
	EncounterJournalTooltip.Item2.icon:SetTexCoord(unpack(DB.TexCoord))
	EncounterJournalTooltip.Item2.IconBorder:SetAlpha(0)
end)

TT:RegisterTooltips("Blizzard_PerksProgram", function()
	if PerksProgramTooltip then
		TT.ReskinTooltip(PerksProgramTooltip)
		PerksProgramTooltip:SetScale(UIParent:GetScale())
	end
end)