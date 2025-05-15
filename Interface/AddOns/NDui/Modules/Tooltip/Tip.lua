local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:RegisterModule("Tooltip")

local strfind, format, strupper, strlen, pairs = string.find, string.format, string.upper, string.len, pairs
local ICON_LIST = ICON_LIST
local PVP, LEVEL, FACTION_HORDE, FACTION_ALLIANCE = PVP, LEVEL, FACTION_HORDE, FACTION_ALLIANCE
local YOU, TARGET, AFK, DND, DEAD, PLAYER_OFFLINE = YOU, TARGET, AFK, DND, DEAD, PLAYER_OFFLINE
local FOREIGN_SERVER_LABEL, INTERACTIVE_SERVER_LABEL = FOREIGN_SERVER_LABEL, INTERACTIVE_SERVER_LABEL
local LE_REALM_RELATION_COALESCED, LE_REALM_RELATION_VIRTUAL = LE_REALM_RELATION_COALESCED, LE_REALM_RELATION_VIRTUAL
local UnitIsPVP, UnitFactionGroup, UnitRealmRelationship, UnitGUID = UnitIsPVP, UnitFactionGroup, UnitRealmRelationship, UnitGUID
local UnitIsConnected, UnitIsDeadOrGhost, UnitIsAFK, UnitIsDND, UnitReaction = UnitIsConnected, UnitIsDeadOrGhost, UnitIsAFK, UnitIsDND, UnitReaction
local InCombatLockdown, IsShiftKeyDown = InCombatLockdown, IsShiftKeyDown
local GetCreatureDifficultyColor, UnitCreatureType, UnitClassification = GetCreatureDifficultyColor, UnitCreatureType, UnitClassification
local UnitIsPlayer, UnitName, UnitPVPName, UnitClass, UnitRace, UnitLevel = UnitIsPlayer, UnitName, UnitPVPName, UnitClass, UnitRace, UnitLevel
local GetRaidTargetIndex, GetGuildInfo, IsInGuild = GetRaidTargetIndex, GetGuildInfo, IsInGuild
local GameTooltip_ClearMoney, GameTooltip_ClearStatusBars, GameTooltip_ClearProgressBars, GameTooltip_ClearWidgetSet = GameTooltip_ClearMoney, GameTooltip_ClearStatusBars, GameTooltip_ClearProgressBars, GameTooltip_ClearWidgetSet

local classification = {
	elite = " |cffcc8800"..ELITE.."|r",
	rare = " |cffff99cc"..L["Rare"].."|r",
	rareelite = " |cffff99cc"..L["Rare"].."|r ".."|cffcc8800"..ELITE.."|r",
	worldboss = " |cffff0000"..BOSS.."|r",
}
local npcIDstring = "%s "..DB.InfoColor.."%s"

function TT:GetMouseFocus()
	if GetMouseFoci then
		local frames = GetMouseFoci()
		return frames and frames[1]
	else
		return GetMouseFocus()
	end
end

function TT:GetUnit()
	local _, unit = self:GetUnit()
	if not unit then
		local mFocus = TT:GetMouseFocus()
		unit = mFocus and (mFocus.unit or (mFocus.GetAttribute and mFocus:GetAttribute("unit")))
	end
	return unit
end

function TT:HideLines()
	for i = 3, self:NumLines() do
		local tiptext = _G["GameTooltipTextLeft"..i]
		local linetext = tiptext:GetText()
		if linetext then
			if linetext == PVP then
				tiptext:SetText("")
				tiptext:Hide()
			elseif linetext == FACTION_HORDE then
				if C.db["Tooltip"]["FactionIcon"] then
					tiptext:SetText("")
					tiptext:Hide()
				else
					tiptext:SetText("|cffff5040"..linetext.."|r")
				end
			elseif linetext == FACTION_ALLIANCE then
				if C.db["Tooltip"]["FactionIcon"] then
					tiptext:SetText("")
					tiptext:Hide()
				else
					tiptext:SetText("|cff4080ff"..linetext.."|r")
				end
			end
		end
	end
end

function TT:GetLevelLine()
	for i = 2, self:NumLines() do
		local tiptext = _G["GameTooltipTextLeft"..i]
		local linetext = tiptext:GetText()
		if linetext and strfind(linetext, LEVEL) then
			return tiptext
		end
	end
end

function TT:GetTarget(unit)
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
		self.factionFrame = f
	end
	self.factionFrame:SetTexture("Interface\\Timer\\"..faction.."-Logo")
	self.factionFrame:SetAlpha(.5)
end

function TT:OnTooltipCleared()
	if self:IsForbidden() then return end

	if self.factionFrame and self.factionFrame:GetAlpha() ~= 0 then
		self.factionFrame:SetAlpha(0)
	end

	GameTooltip_ClearMoney(self)
	GameTooltip_ClearStatusBars(self)
	GameTooltip_ClearProgressBars(self)
	GameTooltip_ClearWidgetSet(self)
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

function TT:OnTooltipSetUnit()
	if self:IsForbidden() then return end

	if (not ShouldHideInCombat()) and InCombatLockdown() then
		self:Hide()
		return
	end

	TT.HideLines(self)

	local unit = TT.GetUnit(self)
	if not unit or not UnitExists(unit) then return end

	local isShiftKeyDown = IsShiftKeyDown()
	local isPlayer = UnitIsPlayer(unit)
	if isPlayer then
		local name, realm = UnitName(unit)
		local pvpName = UnitPVPName(unit)
		local relationship = UnitRealmRelationship(unit)
		if not C.db["Tooltip"]["HideTitle"] and pvpName then
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

		local status = (UnitIsAFK(unit) and AFK) or (UnitIsDND(unit) and DND) or (not UnitIsConnected(unit) and PLAYER_OFFLINE)
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
		if ricon and ricon > 8 then ricon = nil end
		ricon = ricon and ICON_LIST[ricon].."18|t " or ""
		GameTooltipTextLeft1:SetFormattedText(("%s%s%s"), ricon, hexColor, text)
	end

	local alive = not UnitIsDeadOrGhost(unit)
	local level = UnitLevel(unit)

	if level then
		local boss
		if level == -1 then boss = "|cffff0000??|r" end

		local diff = GetCreatureDifficultyColor(level)
		local classify = UnitClassification(unit)
		local textLevel = format("%s%s%s|r", B.HexRGB(diff), boss or format("%d", level), classification[classify] or "")
		local tiptextLevel = TT.GetLevelLine(self)
		if tiptextLevel then
			local reaction = UnitReaction(unit, "player")
			local standingText = not isPlayer and reaction and hexColor.._G["FACTION_STANDING_LABEL"..reaction].."|r " or ""

			local pvpFlag = isPlayer and UnitIsPVP(unit) and format(" |cffff0000%s|r", PVP) or ""
			local unitClass = isPlayer and format("%s %s", UnitRace(unit) or "", hexColor..(UnitClass(unit) or "").."|r") or UnitCreatureType(unit) or ""

			tiptextLevel:SetFormattedText(("%s%s %s %s"), textLevel, pvpFlag, standingText..unitClass, (not alive and "|cffCCCCCC"..DEAD.."|r" or ""))
		end
	end

	if UnitExists(unit.."target") then
		local tarRicon = GetRaidTargetIndex(unit.."target")
		if tarRicon and tarRicon > 8 then tarRicon = nil end
		local tar = format("%s%s", (tarRicon and ICON_LIST[tarRicon].."10|t") or "", TT:GetTarget(unit.."target"))
		self:AddLine(TARGET..": "..tar)
	end

	if not isPlayer and isShiftKeyDown then
		local guid = UnitGUID(unit)
		local npcID = guid and B.GetNPCID(guid)
		if npcID then
			self:AddLine(format(npcIDstring, "NpcID:", npcID))
		end
	end

	if isPlayer then
		TT.InspectUnitItemLevel(self, unit)
	end

	self.StatusBar:SetStatusBarColor(r, g, b)
end

function TT:StatusBar_OnValueChanged(value)
	if self:IsForbidden() or not value then return end
	local min, max = self:GetMinMaxValues()
	if (value < min) or (value > max) then return end

	if not self.text then
		self.text = B.CreateFS(self, 12, "")
	end

	if value > 0 and max == 1 then
		self.text:SetFormattedText("%d%%", value*100)
		self:SetStatusBarColor(.6, .6, .6) -- Wintergrasp building
	else
		self.text:SetText(B.Numb(value).." | "..B.Numb(max))
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
	if not parent then return end

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

-- Fix comparison error on cursor
function TT:GameTooltip_ComparisonFix(anchorFrame, shoppingTooltip1, shoppingTooltip2, _, secondaryItemShown)
	local point = shoppingTooltip1:GetPoint(2)
	if secondaryItemShown then
		if point == "TOP" then
			shoppingTooltip1:ClearAllPoints()
			shoppingTooltip1:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT", 3, 0)
			shoppingTooltip2:ClearAllPoints()
			shoppingTooltip2:SetPoint("TOPLEFT", shoppingTooltip1, "TOPRIGHT", 3, 0)
		elseif point == "RIGHT" then
			shoppingTooltip1:ClearAllPoints()
			shoppingTooltip1:SetPoint("TOPRIGHT", anchorFrame, "TOPLEFT", -3, 0)
			shoppingTooltip2:ClearAllPoints()
			shoppingTooltip2:SetPoint("TOPRIGHT", shoppingTooltip1, "TOPLEFT", -3, 0)
		end
	else
		if point == "LEFT" then
			shoppingTooltip1:ClearAllPoints()
			shoppingTooltip1:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT", 3, 0)
		elseif point == "RIGHT" then
			shoppingTooltip1:ClearAllPoints()
			shoppingTooltip1:SetPoint("TOPRIGHT", anchorFrame, "TOPLEFT", -3, 0)
		end
	end
end

-- Tooltip skin
local fakeBg = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
fakeBg:SetBackdrop({ bgFile = DB.bdTex, edgeFile = DB.bdTex, edgeSize = 1 })
local function __GetBackdrop() return fakeBg:GetBackdrop() end
local function __GetBackdropColor() return 0, 0, 0, .7 end
local function __GetBackdropBorderColor() return 0, 0, 0 end

function TT:ReskinTooltip()
	if not self then
		if DB.isDeveloper then print("Unknown tooltip spotted.") end
		return
	end
	if self:IsForbidden() then return end
	self:SetScale(C.db["Tooltip"]["Scale"])

	if not self.tipStyled then
		self:HideBackdrop()
		self:DisableDrawLayer("BACKGROUND")
		self.bg = B.SetBD(self, .7)
		self.bg:SetInside(self)
		self.bg:SetFrameLevel(self:GetFrameLevel())

		if self.StatusBar then
			TT.ReskinStatusBar(self)
		end

		if self.GetBackdrop then
			self.GetBackdrop = __GetBackdrop
			self.GetBackdropColor = __GetBackdropColor
			self.GetBackdropBorderColor = __GetBackdropBorderColor
		end

		self.tipStyled = true
	end

	B.SetBorderColor(self.bg)
	if C.db["Tooltip"]["ItemQuality"] and self.GetItem then
		local _, item = self:GetItem()
		if item then
			local quality = select(3, C_Item.GetItemInfo(item))
			local color = DB.QualityColors[quality or 1]
			if color then
				self.bg:SetBackdropBorderColor(color.r, color.g, color.b)
			end
		end
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

	if not GameTooltip.hasMoney then
		SetTooltipMoney(GameTooltip, 1, nil, "", "")
		SetTooltipMoney(GameTooltip, 1, nil, "", "")
		GameTooltip_ClearMoney(GameTooltip)
	end
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
	local name = self:GetName()
	for i = 1, self:NumLines() do
		local line = _G[name.."TextLeft"..i]
		if line:GetHeight() > 40 then
			line:SetWidth(line:GetWidth() + 1)
		end
	end
end

function TT:ResetUnit(btn)
	if btn == "LSHIFT" and UnitExists("mouseover") then
		GameTooltip:SetUnit("mouseover")
	end
end

function TT:OnLogin()
	GameTooltip.StatusBar = GameTooltipStatusBar
	GameTooltip:HookScript("OnTooltipCleared", TT.OnTooltipCleared)
	GameTooltip:HookScript("OnTooltipSetUnit", TT.OnTooltipSetUnit)
	GameTooltip.StatusBar:SetScript("OnValueChanged", TT.StatusBar_OnValueChanged)
	hooksecurefunc("GameTooltip_ShowStatusBar", TT.GameTooltip_ShowStatusBar)
	hooksecurefunc("GameTooltip_ShowProgressBar", TT.GameTooltip_ShowProgressBar)
	hooksecurefunc("GameTooltip_SetDefaultAnchor", TT.GameTooltip_SetDefaultAnchor)
	hooksecurefunc("GameTooltip_AnchorComparisonTooltips", TT.GameTooltip_ComparisonFix)
	TT:SetupTooltipFonts()
	GameTooltip:HookScript("OnTooltipSetItem", TT.FixRecipeItemNameWidth)
	ItemRefTooltip:HookScript("OnTooltipSetItem", TT.FixRecipeItemNameWidth)
	EmbeddedItemTooltip:HookScript("OnTooltipSetItem", TT.FixRecipeItemNameWidth)

	-- Elements
	TT:ReskinTooltipIcons()
	TT:SetupTooltipID()
	TT:TargetedInfo()
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
		GeneralDockManagerOverflowButtonList,
		NamePlateTooltip,
		WorldMapTooltip,
		IMECandidatesFrame,
		QueueStatusFrame,
	}
	for _, f in pairs(tooltips) do
		f:HookScript("OnShow", TT.ReskinTooltip)
	end

	B.ReskinClose(ItemRefCloseButton)

	if SettingsTooltip then
		TT.ReskinTooltip(SettingsTooltip)
		SettingsTooltip:SetScale(UIParent:GetScale())
	end

	-- DropdownMenu
	local function reskinDropdown()
		for _, name in pairs({"DropDownList", "L_DropDownList", "Lib_DropDownList"}) do
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
	local r, g, b = DB.r, DB.g, DB.b
	IMECandidatesFrame.selection:SetVertexColor(r, g, b)

	-- Others
	C_Timer.After(5, function()
		-- Lib minimap icon
		if LibDBIconTooltip then
			TT.ReskinTooltip(LibDBIconTooltip)
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
		-- Altoholic
		if AltoTooltip then
			TT.ReskinTooltip(AltoTooltip)
		end
	end)
end)

TT:RegisterTooltips("Blizzard_DebugTools", function()
	TT.ReskinTooltip(FrameStackTooltip)
	FrameStackTooltip:SetScale(UIParent:GetScale())
end)

TT:RegisterTooltips("Blizzard_EventTrace", function()
	TT.ReskinTooltip(EventTraceTooltip)
end)

TT:RegisterTooltips("Blizzard_LookingForGroupUI", function()
	TT.ReskinTooltip(LFGBrowseSearchEntryTooltip)
end)