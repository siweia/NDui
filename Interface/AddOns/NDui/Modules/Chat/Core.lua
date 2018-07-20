local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:RegisterModule("Chat")

-- Reskin Chat
local maxLines = 1024
local maxWidth, maxHeight = UIParent:GetWidth(), UIParent:GetHeight()

local function skinChat(self)
	if not self or (self and self.styled) then return end

	local name = self:GetName()
	local fontSize = select(2, self:GetFont())
	self:SetClampRectInsets(0, 0, 0, 0)
	self:SetMaxResize(maxWidth, maxHeight)
	self:SetMinResize(100, 50)
	self:SetFont(DB.Font[1], fontSize, DB.Font[3])
	self:SetShadowColor(0, 0, 0, 0)
	self:SetClampRectInsets(0, 0, 0, 0)
	self:SetClampedToScreen(false)
	if self:GetMaxLines() < maxLines then
		self:SetMaxLines(maxLines)
	end

	local eb = _G[name.."EditBox"]
	eb:SetAltArrowKeyMode(false)
	eb:ClearAllPoints()
	eb:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 24)
	eb:SetPoint("TOPRIGHT", self, "TOPRIGHT", -15, 54)
	B.CreateBD(eb)
	B.CreateTex(eb)
	for i = 3, 8 do
		select(i, eb:GetRegions()):SetAlpha(0)
	end

	local lang = _G[name.."EditBoxLanguage"]
	lang:GetRegions():SetAlpha(0)
	lang:SetPoint("TOPLEFT", eb, "TOPRIGHT", -2, 0)
	lang:SetPoint("BOTTOMRIGHT", eb, "BOTTOMRIGHT", 28, 0)
	B.CreateBD(lang)
	B.CreateTex(lang)

	local tab = _G[name.."Tab"]
	tab:SetAlpha(1)
	local tabFs = tab:GetFontString()
	tabFs:SetFont(DB.Font[1], DB.Font[2]+2, DB.Font[3])
	tabFs:SetShadowColor(0, 0, 0, 0)
	tabFs:SetTextColor(1, .8, 0)
	for i = 1, 10 do
		if i ~= 7 then
			select(i, tab:GetRegions()):SetTexture(nil)
		end
	end

	hooksecurefunc(tab, "SetAlpha", function(self, alpha)
		if alpha ~= 1 and (not self.isDocked or GeneralDockManager.selected:GetID() == self:GetID()) then
			self:SetAlpha(1)
		elseif alpha < .6 then
			self:SetAlpha(.6)
		end
	end)

	B.StripTextures(self)
	B.HideObject(self.buttonFrame)
	B.HideObject(self.ScrollBar)
	B.HideObject(self.ScrollToBottomButton)

	self.styled = true
end

-- Swith channels by Tab
local cycles = {
	{ chatType = "SAY", use = function() return 1 end },
    { chatType = "PARTY", use = function() return IsInGroup() end },
    { chatType = "RAID", use = function() return IsInRaid() end },
    { chatType = "INSTANCE_CHAT", use = function() return IsPartyLFG() end },
    { chatType = "GUILD", use = function() return IsInGuild() end },
	{ chatType = "CHANNEL", use = function(_, editbox)
		if DB.Client ~= "zhCN" then return false end
		local channels, inWorldChannel, number = {GetChannelList()}
		for i = 1, #channels do
			if channels[i] == L["World Channel Name"] then
				inWorldChannel = true
				number = channels[i-1]
				break
			end
		end
		if inWorldChannel then
			editbox:SetAttribute("channelTarget", number)
			return true
		else
			return false
		end
	end },
    { chatType = "SAY", use = function() return 1 end },
}

hooksecurefunc("ChatEdit_CustomTabPressed", function(self)
	if strsub(tostring(self:GetText()), 1, 1) == "/" then return end
    local currChatType = self:GetAttribute("chatType")
    for i, curr in ipairs(cycles) do
        if curr.chatType == currChatType then
            local h, r, step = i+1, #cycles, 1
            if IsShiftKeyDown() then h, r, step = i-1, 1, -1 end
            for j = h, r, step do
                if cycles[j]:use(self, currChatType) then
                    self:SetAttribute("chatType", cycles[j].chatType)
                    ChatEdit_UpdateHeader(self)
                    return
                end
            end
        end
    end
end)

-- Quick Scroll
hooksecurefunc("FloatingChatFrame_OnMouseScroll", function(self, dir)
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
end)

-- Autoinvite by whisper
function module:WhipserInvite()
	if not NDuiDB["Chat"]["Invite"] then return end

	local whisperList = {string.split(" ", NDuiDB["Chat"]["Keyword"])}

	local function onChatWhisper(event, ...)
		local arg1, arg2, _, _, _, _, _, _, _, _, _, _, arg3 = ...
		for _, word in pairs(whisperList) do
			if (not IsInGroup() or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and strlower(arg1) == strlower(word) then
				if event == "CHAT_MSG_BN_WHISPER" then
					local gameID = select(6, BNGetFriendInfoByID(arg3))
					if gameID then
						local _, charName, _, realmName = BNGetGameAccountInfo(gameID)
						if CanCooperateWithGameAccount(gameID) and (not NDuiDB["Chat"]["GuildInvite"] or B.UnitInGuild(charName.."-"..realmName)) then
							BNInviteFriend(gameID)
						end
					end
				else
					if not NDuiDB["Chat"]["GuildInvite"] or B.UnitInGuild(arg2) then
						InviteToGroup(arg2)
					end
				end
			end
		end
	end
	B:RegisterEvent("CHAT_MSG_WHISPER", onChatWhisper)
	B:RegisterEvent("CHAT_MSG_BN_WHISPER", onChatWhisper)
end

function module:OnLogin()
	for i = 1, NUM_CHAT_WINDOWS do
		skinChat(_G["ChatFrame"..i])
	end

	hooksecurefunc("FCF_OpenTemporaryWindow", function()
		for _, chatFrameName in next, CHAT_FRAMES do
			local frame = _G[chatFrameName]
			if frame.isTemporary then
				skinChat(frame)
			end
		end
	end)

	hooksecurefunc("FCFTab_UpdateColors", function(self, selected)
		if selected then
			self:GetFontString():SetTextColor(1, .8, 0)
		else
			self:GetFontString():SetTextColor(.5, .5, .5)
		end
	end)

	-- Font size
	for i = 1, 15 do
		CHAT_FONT_HEIGHTS[i] = i + 9
	end

	-- Default
	SetCVar("chatStyle", "classic")
	B.HideOption(InterfaceOptionsSocialPanelChatStyle)
	CombatLogQuickButtonFrame_CustomTexture:SetTexture(nil)

	-- Sticky
	if not NDuiDB["Chat"]["Sticky"] then
		ChatTypeInfo["WHISPER"].sticky = 0
		ChatTypeInfo["BN_WHISPER"].sticky = 0
	end

	-- Easy Resizing
	ChatFrame1Tab:HookScript("OnMouseDown", function(_, btn)
		if btn == "LeftButton" then
			if select(8, GetChatWindowInfo(1)) then
				ChatFrame1:StartSizing("TOP")
			end
		end
	end)
	ChatFrame1Tab:SetScript("OnMouseUp", function(_, btn)
		if btn == "LeftButton" then
			ChatFrame1:StopMovingOrSizing()
			FCF_SavePositionAndDimensions(ChatFrame1)
		end
	end)

	-- Add Elements
	self:ChatFilter()
	self:ChannelRename()
	self:Chatbar()
	self:ChatCopy()
	self:UrlCopy()
	self:WhipserInvite()

	-- ProfanityFilter
	if not BNFeaturesEnabledAndConnected() then return end
	if not NDuiDB["Chat"]["Freedom"] then
		SetCVar("profanityFilter", 1)
	else
		SetCVar("profanityFilter", 0)
	end
end