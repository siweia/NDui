local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:RegisterModule("Chat")
local cr, cg, cb = DB.r, DB.g, DB.b

local _G = _G
local pairs, ipairs, strsub, strlower = pairs, ipairs, string.sub, string.lower
local IsInGroup, IsInRaid, IsInGuild, IsShiftKeyDown, IsControlKeyDown = IsInGroup, IsInRaid, IsInGuild, IsShiftKeyDown, IsControlKeyDown
local ChatEdit_UpdateHeader, GetCVar, SetCVar, Ambiguate, GetTime = ChatEdit_UpdateHeader, GetCVar, SetCVar, Ambiguate, GetTime
local GetNumGuildMembers, GetGuildRosterInfo, IsGuildMember, UnitIsGroupLeader, UnitIsGroupAssistant = GetNumGuildMembers, GetGuildRosterInfo, IsGuildMember, UnitIsGroupLeader, UnitIsGroupAssistant
local CanCooperateWithGameAccount, BNInviteFriend, PlaySound = CanCooperateWithGameAccount, BNInviteFriend, PlaySound
local C_GuildInfo_IsGuildOfficer = C_GuildInfo.IsGuildOfficer
local C_BattleNet_GetAccountInfoByID = C_BattleNet.GetAccountInfoByID
local InviteToGroup = C_PartyInfo.InviteUnit
local GeneralDockManager = GeneralDockManager
local messageSoundID = SOUNDKIT.TELL_MESSAGE

local fontFile, fontOutline
module.MuteCache = {}

function module:TabSetAlpha(alpha)
	if self.glow:IsShown() and alpha ~= 1 then
		self:SetAlpha(1)
	end
end

local function updateChatAnchor(self, _, _, _, x, y)
	if not C.db["Chat"]["Lock"] then return end
	if not (x == 0 and y == 30) then
		self:ClearAllPoints()
		self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 30)
		self:SetWidth(C.db["Chat"]["ChatWidth"])
		self:SetHeight(C.db["Chat"]["ChatHeight"])
	end
end

local isScaling = false
function module:UpdateChatSize()
	if not C.db["Chat"]["Lock"] then return end
	if isScaling then return end
	isScaling = true

	if ChatFrame1:IsMovable() then
		ChatFrame1:SetUserPlaced(true)
	end
	if ChatFrame1.FontStringContainer then
		ChatFrame1.FontStringContainer:SetOutside(ChatFrame1)
	end
	ChatFrame1:ClearAllPoints()
	ChatFrame1:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 30)
	ChatFrame1:SetWidth(C.db["Chat"]["ChatWidth"])
	ChatFrame1:SetHeight(C.db["Chat"]["ChatHeight"])

	isScaling = false
end

local function BlackBackground(self)
	local frame = B.SetBD(self.Background)
	frame:SetShown(C.db["Chat"]["ChatBGType"] == 2)

	return frame
end

local function GradientBackground(self)
	local frame = CreateFrame("Frame", nil, self)
	frame:SetOutside(self.Background)
	frame:SetFrameLevel(0)
	frame:SetShown(C.db["Chat"]["ChatBGType"] == 3)

	local tex = B.SetGradient(frame, "H", 0, 0, 0, .7, 0)
	tex:SetOutside()
	local line = B.SetGradient(frame, "H", cr, cg, cb, .5, 0, nil, C.mult)
	line:SetPoint("BOTTOMLEFT", frame, "TOPLEFT")
	line:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT")

	return frame
end

local chatEditboxes = {}
local function UpdateEditBoxAnchor(eb)
	local parent = eb.__owner
	eb:ClearAllPoints()
	if C.db["Chat"]["BottomBox"] then
		eb:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 4, -10)
		eb:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -15, -34)
	else
		eb:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", 4, 26)
		eb:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -15, 50)
	end
end

local function UpdateEditboxFont(editbox)
	editbox:SetFont(DB.Font[1], C.db["Chat"]["EditFont"], "")
	editbox.header:SetFont(DB.Font[1], C.db["Chat"]["EditFont"], "")
end

function module:ToggleEditBoxAnchor()
	for _, eb in pairs(chatEditboxes) do
		UpdateEditboxFont(eb)
		UpdateEditBoxAnchor(eb)
	end
end

function module:SkinChat()
	if not self or self.styled then return end

	local name = self:GetName()
	local font, fontSize = self:GetFont()
	self:SetFont(fontFile or font, fontSize, fontOutline)
	if fontOutline ~= "" then
		self:SetShadowColor(0, 0, 0, 0)
	end
	self:SetClampRectInsets(0, 0, 0, 0)
	self:SetClampedToScreen(false)

	self.__background = BlackBackground(self)
	self.__gradient = GradientBackground(self)

	local eb = _G[name.."EditBox"]
	eb:SetAltArrowKeyMode(false)
	eb:SetClampedToScreen(true)
	eb.__owner = self
	UpdateEditBoxAnchor(eb)
	B.StripTextures(eb, 2)
	B.SetBD(eb)
	UpdateEditboxFont(eb)
	tinsert(chatEditboxes, eb)

	local lang = _G[name.."EditBoxLanguage"]
	lang:GetRegions():SetAlpha(0)
	lang:SetPoint("TOPLEFT", eb, "TOPRIGHT", 5, 0)
	lang:SetPoint("BOTTOMRIGHT", eb, "BOTTOMRIGHT", 29, 0)
	B.SetBD(lang)

	local tab = _G[name.."Tab"]
	tab:SetAlpha(1)
	tab.Text:SetFont(fontFile or font, DB.Font[2]+2, fontOutline)
	tab.Text:SetShadowColor(0, 0, 0, 0)
	B.StripTextures(tab, 7)
	hooksecurefunc(tab, "SetAlpha", module.TabSetAlpha)

	local minimize = self.buttonFrame.minimizeButton
	if minimize then
		B.ReskinCollapse(minimize)
		minimize:GetNormalTexture():SetAlpha(0)
		minimize:GetPushedTexture():SetAlpha(0)
		minimize.__texture:DoCollapse(false)
		minimize:SetIgnoreParentScale(true)
		minimize:SetScale(UIParent:GetScale())
	end

	B.HideOption(self.buttonFrame)
	module:ToggleChatFrameTextures(self)

	self.oldAlpha = self.oldAlpha or 0 -- fix blizz error

	self:HookScript("OnMouseWheel", module.QuickMouseScroll)

	if self == GeneralDockManager.primary then
		local messageFrame = CommunitiesFrame and CommunitiesFrame.Chat and CommunitiesFrame.Chat.MessageFrame
		if messageFrame then
			messageFrame:SetFont(fontFile or font, fontSize, fontOutline)
		end
	end

	self.styled = true
end

function module:ToggleChatFrameTextures(frame)
	if C.db["Chat"]["ChatBGType"] == 1 then
		frame:EnableDrawLayer("BORDER")
		frame:EnableDrawLayer("BACKGROUND")
	else
		frame:DisableDrawLayer("BORDER")
		frame:DisableDrawLayer("BACKGROUND")
	end
end

function module:ToggleChatBackground()
	for _, chatFrameName in ipairs(CHAT_FRAMES) do
		local frame = _G[chatFrameName]
		if frame.__background then
			frame.__background:SetShown(C.db["Chat"]["ChatBGType"] == 2)
		end
		if frame.__gradient then
			frame.__gradient:SetShown(C.db["Chat"]["ChatBGType"] == 3)
		end
		module:ToggleChatFrameTextures(frame)
	end
end

-- Swith channels by Tab
local cycles = {
	{ chatType = "SAY", IsActive = function() return true end },
	{ chatType = "PARTY", IsActive = function() return IsInGroup() end },
	{ chatType = "RAID", IsActive = function() return IsInRaid() end },
	{ chatType = "INSTANCE_CHAT", IsActive = function() return IsPartyLFG() or C_PartyInfo.IsPartyWalkIn() end },
	{ chatType = "GUILD", IsActive = function() return IsInGuild() end },
	{ chatType = "OFFICER", IsActive = function() return C_GuildInfo_IsGuildOfficer() end },
	{ chatType = "CHANNEL", IsActive = function(_, editbox)
		if module.InWorldChannel and module.WorldChannelID then
			editbox:SetAttribute("channelTarget", module.WorldChannelID)
			return true
		end
	end },
	{ chatType = "SAY", IsActive = function() return true end },
}

function module:SwitchToChannel(chatType)
	self:SetAttribute("chatType", chatType)
	ChatEdit_UpdateHeader(self)
end

function module:UpdateTabChannelSwitch()
	if strsub(self:GetText(), 1, 1) == "/" then return end

	local isShiftKeyDown = IsShiftKeyDown()
	local currentType = self:GetAttribute("chatType")
	if isShiftKeyDown and (currentType == "WHISPER" or currentType == "BN_WHISPER") then
		module.SwitchToChannel(self, "SAY")
		return
	end

	local numCycles = #cycles
	for i = 1, numCycles do
		local cycle = cycles[i]
		if currentType == cycle.chatType then
			local from, to, step = i+1, numCycles, 1
			if isShiftKeyDown then
				from, to, step = i-1, 1, -1
			end
			for j = from, to, step do
				local nextCycle = cycles[j]
				if nextCycle:IsActive(self) then
					module.SwitchToChannel(self, nextCycle.chatType)
					return
				end
			end
		end
	end
end
hooksecurefunc("ChatEdit_CustomTabPressed", module.UpdateTabChannelSwitch)

-- Quick Scroll
local chatScrollInfo = {
	text = L["ChatScrollHelp"],
	buttonStyle = HelpTip.ButtonStyle.GotIt,
	targetPoint = HelpTip.Point.RightEdgeCenter,
	onAcknowledgeCallback = B.HelpInfoAcknowledge,
	callbackArg = "ChatScroll",
}

function module:QuickMouseScroll(dir)
	if not NDuiADB["Help"]["ChatScroll"] then
		HelpTip:Show(ChatFrame1, chatScrollInfo)
	end

	if dir > 0 then
		if IsShiftKeyDown() then
			self:ScrollToTop()
		elseif IsControlKeyDown() then
			self:ScrollUp()
			self:ScrollUp()
		end
	else
		if IsShiftKeyDown() then
			self:ScrollToBottom()
		elseif IsControlKeyDown() then
			self:ScrollDown()
			self:ScrollDown()
		end
	end
end

-- Autoinvite by whisper
local whisperList = {}
function module:UpdateWhisperList()
	B.SplitList(whisperList, C.db["Chat"]["Keyword"], true)
end

function module:IsUnitInGuild(unitName)
	if not unitName then return end
	for i = 1, GetNumGuildMembers() do
		local name = GetGuildRosterInfo(i)
		if name and Ambiguate(name, "none") == Ambiguate(unitName, "none") then
			return true
		end
	end

	return false
end

function module.OnChatWhisper(event, ...)
	local msg, author, _, _, _, _, _, _, _, _, _, guid, presenceID = ...
	if B:IsSecretValue(author) then return end
	for word in pairs(whisperList) do
		if (not IsInGroup() or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and strlower(msg) == strlower(word) then
			if event == "CHAT_MSG_BN_WHISPER" then
				local accountInfo = C_BattleNet_GetAccountInfoByID(presenceID)
				if accountInfo then
					local gameAccountInfo = accountInfo.gameAccountInfo
					local gameID = gameAccountInfo.gameAccountID
					if gameID then
						local charName = gameAccountInfo.characterName
						local realmName = gameAccountInfo.realmName
						if CanCooperateWithGameAccount(accountInfo) and (not C.db["Chat"]["GuildInvite"] or module:IsUnitInGuild(charName.."-"..realmName)) then
							BNInviteFriend(gameID)
						end
					end
				end
			else
				if not C.db["Chat"]["GuildInvite"] or IsGuildMember(guid) then
					InviteToGroup(author)
				end
			end
		end
	end
end

function module:WhisperInvite()
	if not C.db["Chat"]["Invite"] then return end
	module:UpdateWhisperList()
	B:RegisterEvent("CHAT_MSG_WHISPER", module.OnChatWhisper)
	B:RegisterEvent("CHAT_MSG_BN_WHISPER", module.OnChatWhisper)
end

-- Sticky whisper
function module:ChatWhisperSticky()
	if C.db["Chat"]["Sticky"] then
		ChatTypeInfo["WHISPER"].sticky = 1
		ChatTypeInfo["BN_WHISPER"].sticky = 1
	else
		ChatTypeInfo["WHISPER"].sticky = 0
		ChatTypeInfo["BN_WHISPER"].sticky = 0
	end
end

-- Tab colors
function module:UpdateTabColors(selected)
	if selected then
		self.Text:SetTextColor(1, .8, 0)
		self.whisperIndex = 0
	else
		self.Text:SetTextColor(.5, .5, .5)
	end

	if self.whisperIndex == 1 then
		self.glow:SetVertexColor(1, .5, 1)
	elseif self.whisperIndex == 2 then
		self.glow:SetVertexColor(0, 1, .96)
	else
		self.glow:SetVertexColor(1, .8, 0)
	end
end

function module:UpdateTabEventColors(event)
	local tab = _G[self:GetName().."Tab"]
	local selected = GeneralDockManager.selected:GetID() == tab:GetID()
	if event == "CHAT_MSG_WHISPER" then
		tab.whisperIndex = 1
		module.UpdateTabColors(tab, selected)
	elseif event == "CHAT_MSG_BN_WHISPER" then
		tab.whisperIndex = 2
		module.UpdateTabColors(tab, selected)
	end
end

local whisperEvents = {
	["CHAT_MSG_WHISPER"] = true,
	["CHAT_MSG_BN_WHISPER"] = true,
}
function module:PlayWhisperSound(event, _, author)
	if not C.db["Chat"]["WhisperSound"] then return end

	if B:IsSecretValue(author) then return end
	if whisperEvents[event] then
		local name = Ambiguate(author, "none")
		local currentTime = GetTime()
		if module.MuteCache[name] == currentTime then return end

		if not self.soundTimer or currentTime > self.soundTimer then
			PlaySound(messageSoundID, "master")
		end
		self.soundTimer = currentTime + 5
	end
end

-- ProfanityFilter
local sideEffectFixed
local function FixLanguageFilterSideEffects()
	if sideEffectFixed then return end
	sideEffectFixed = true

	local OLD_GetFriendGameAccountInfo = C_BattleNet.GetFriendGameAccountInfo
	function C_BattleNet.GetFriendGameAccountInfo(...)
		local gameAccountInfo = OLD_GetFriendGameAccountInfo(...)
		if gameAccountInfo then
			gameAccountInfo.isInCurrentRegion = true
		end
		return gameAccountInfo
	end

	local OLD_GetFriendAccountInfo = C_BattleNet.GetFriendAccountInfo
	function C_BattleNet.GetFriendAccountInfo(...)
		local accountInfo = OLD_GetFriendAccountInfo(...)
		if accountInfo and accountInfo.gameAccountInfo then
			accountInfo.gameAccountInfo.isInCurrentRegion = true
		end
		return accountInfo
	end
end

function module:ToggleLanguageFilter()
	if C.db["Chat"]["Freedom"] then
		if GetCVar("portal") == "CN" then
			ConsoleExec("portal TW")
			FixLanguageFilterSideEffects()
		end
		SetCVar("profanityFilter", 0)
	else
		if sideEffectFixed then
			ConsoleExec("portal CN")
		end
		SetCVar("profanityFilter", 1)
	end
end

function module:HandleMinimizedFrame()
	local minFrame = self.minFrame
	if minFrame and not minFrame.styled then
		B.StripTextures(minFrame)
		B.Reskin(minFrame)
		minFrame.__bg:SetInside(nil, 5, 5)

		local maximizeButton = _G[minFrame:GetName().."MaximizeButton"]
		if maximizeButton then
			B.ReskinCollapse(maximizeButton)
			maximizeButton.__texture:DoCollapse(true)
		end

		minFrame.styled = true
	end
end

function module:OnLogin()
	fontFile = not C.db["Chat"]["SysFont"] and DB.Font[1]
	fontOutline = C.db["Skins"]["FontOutline"] and "OUTLINE" or ""

	for i = 1, NUM_CHAT_WINDOWS do
		local chatframe = _G["ChatFrame"..i]
		module.SkinChat(chatframe)
		ChatFrame_RemoveMessageGroup(chatframe, "CHANNEL")
	end

	hooksecurefunc("FCF_OpenTemporaryWindow", function()
		for _, chatFrameName in ipairs(CHAT_FRAMES) do
			local frame = _G[chatFrameName]
			if frame.isTemporary then
				module.SkinChat(frame)
			end
		end
	end)

	hooksecurefunc("FCFTab_UpdateColors", module.UpdateTabColors)
	hooksecurefunc("FloatingChatFrameManager_OnEvent", module.UpdateTabEventColors)
	hooksecurefunc(ChatFrameUtil, "ProcessMessageEventFilters", module.PlayWhisperSound)
	hooksecurefunc("FCF_MinimizeFrame", module.HandleMinimizedFrame)

	-- Default
	if CHAT_OPTIONS then CHAT_OPTIONS.HIDE_FRAME_ALERTS = true end -- only flash whisper
	SetCVar("chatStyle", "classic")
	SetCVar("chatMouseScroll", 1) -- enable mousescroll
	--SetCVar("whisperMode", "inline") -- blizz reset this on NPE
	CombatLogQuickButtonFrame_CustomTexture:SetTexture(nil)

	-- Add Elements
	module:ChatWhisperSticky()
	module:ChatFilter()
	--module:ChannelRename()
	module:Chatbar()
	module:ChatCopy()
	--module:UrlCopy()
	module:WhisperInvite()
	--module:ToggleLanguageFilter()

	-- Lock chatframe
	if C.db["Chat"]["Lock"] then
		module:UpdateChatSize()
		B:RegisterEvent("UI_SCALE_CHANGED", module.UpdateChatSize)
		hooksecurefunc(ChatFrame1, "SetPoint", updateChatAnchor)
		FCF_SavePositionAndDimensions(ChatFrame1)
	end

	-- Extra elements in chat tab menu
	do
		-- Font size
		local function IsSelected(height)
			local _, fontHeight = FCF_GetCurrentChatFrame():GetFont()
			return height == floor(fontHeight + .5)
		end

		local function SetSelected(height)
			FCF_SetChatWindowFontSize(nil, FCF_GetChatFrameByID(CURRENT_CHAT_FRAME_ID), height)
		end

		Menu.ModifyMenu("MENU_FCF_TAB", function(self, rootDescription, data)
			local fontSizeSubmenu = rootDescription:CreateButton(DB.InfoColor..L["MoreFontSize"])
			for i = 10, 30 do
				fontSizeSubmenu:CreateRadio((format(FONT_SIZE_TEMPLATE, i)), IsSelected, SetSelected, i)
			end
		end)
	end
end