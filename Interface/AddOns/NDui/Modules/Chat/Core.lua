local B, C, L, DB = unpack(select(2, ...))
local module = NDui:RegisterModule("Chat")

-- Hook default elements
hooksecurefunc("FCFTab_UpdateColors", function(self, selected)
	if selected then
		self:SetAlpha(1)
		self:GetFontString():SetTextColor(1, .8, 0)
	else
		self:GetFontString():SetTextColor(.5, .5, .5)
		self:SetAlpha(.3)
	end
end)
FCF_FadeInChatFrame = function(self) self.hasBeenFaded = true end
FCF_FadeOutChatFrame = function(self) self.hasBeenFaded = false end

for i = 1, 15 do
	CHAT_FONT_HEIGHTS[i] = i + 9
end

ChatFrameMenuButton.Show = B.Dummy
ChatFrameMenuButton:Hide()
QuickJoinToastButton.Show = B.Dummy
QuickJoinToastButton:Hide()
BNToastFrame:SetClampedToScreen(true)
BNToastFrame:SetClampRectInsets(-15, 15, 15, -15)
BNToastFrame:HookScript("OnShow", function(self)
	self:ClearAllPoints()
	self:SetPoint("BOTTOMLEFT", ChatFrame1Tab, "TOPLEFT", 0, 25)
end)

-- Reskin Chat
local function skinChat(self)
	if not self or (self and self.styled) then return end

	local name = self:GetName()
	self:SetClampRectInsets(0, 0, 0, 0)
	self:SetMaxResize(UIParent:GetWidth(), UIParent:GetHeight())
	self:SetMinResize(100, 50)
	self:SetFont(unpack(DB.Font))
	self:SetShadowColor(0, 0, 0, 0)

	local frame = _G[name.."ButtonFrame"]
	frame:Hide()
	frame.Show = B.Dummy

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
	eb:HookScript("OnEditFocusGained", function() eb:Show() end)
	eb:HookScript("OnEditFocusLost", function() eb:Hide() end)

	local lang = _G[name.."EditBoxLanguage"]
	lang:GetRegions():SetAlpha(0)
	lang:SetPoint("TOPLEFT", eb, "TOPRIGHT", -2, 0)
	lang:SetPoint("BOTTOMRIGHT", eb, "BOTTOMRIGHT", 28, 0)
	B.CreateBD(lang)
	B.CreateTex(lang)
	lang:HookScript("OnMouseUp", function(_, btn)
		if btn == "RightButton" then
			ChatMenu:ClearAllPoints()
			ChatMenu:SetPoint("BOTTOMRIGHT", eb, 0, 30)
			ToggleFrame(ChatMenu)
		end
	end)

	local tab = _G[name.."Tab"]
	tab:SetAlpha(1)
	local tabFs = tab:GetFontString()
	tabFs:SetFont(DB.Font[1], DB.Font[2]+2, DB.Font[3])
	tabFs:SetShadowColor(0, 0, 0, 0)
	tabFs:SetTextColor(1, .8, 0)
	for i = 1, 6 do
		select(i, tab:GetRegions()):SetTexture(nil)
	end
	select(8, tab:GetRegions()):SetTexture(nil)
	select(9, tab:GetRegions()):SetTexture(nil)
	select(10, tab:GetRegions()):SetTexture(nil)

	self.styled = true
end

for i = 1, NUM_CHAT_WINDOWS do
	skinChat(_G["ChatFrame"..i])
end

hooksecurefunc("FCF_OpenTemporaryWindow", function()
	for _, chatFrameName in pairs(CHAT_FRAMES) do
		local frame = _G[chatFrameName]
		if frame.isTemporary then
			skinChat(frame)
		end
	end
end)

-- Swith channels by Tab
local cycles = {
	{ chatType = "SAY", use = function(self, editbox) return 1 end },
    { chatType = "PARTY", use = function(self, editbox) return IsInGroup() end },
    { chatType = "RAID", use = function(self, editbox) return IsInRaid() end },
    { chatType = "INSTANCE_CHAT", use = function(self, editbox) return IsPartyLFG() end },
    { chatType = "GUILD", use = function(self, editbox) return IsInGuild() end },
	{ chatType = "CHANNEL", use = function(self, editbox)
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
    { chatType = "SAY", use = function(self, editbox) return 1 end },
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
local f = NDui:EventFrame({"CHAT_MSG_WHISPER", "CHAT_MSG_BN_WHISPER"})
f:SetScript("OnEvent", function(self, event, ...)
	if not NDuiDB["Chat"]["Invite"] then return end

	local arg1, arg2, _, _, _, _, _, _, _, _, _, _, arg3 = ...
	local list = {string.split(" ", NDuiDB["Chat"]["Keyword"])}
	for _, word in pairs(list) do
		if (not IsInGroup() or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and strlower(arg1) == strlower(word) then
			if event == "CHAT_MSG_BN_WHISPER" then
				local gameID = select(6, BNGetFriendInfoByID(arg3))
				local _, charName, _, realmName = BNGetGameAccountInfo(gameID)
				if CanCooperateWithGameAccount(gameID) and (not NDuiDB["Chat"]["GuildInvite"] or B.UnitInGuild(charName.."-"..realmName)) then
					BNInviteFriend(gameID)
				end
			else
				if not NDuiDB["Chat"]["GuildInvite"] or B.UnitInGuild(arg2) then
					InviteToGroup(arg2)
				end
			end
		end
	end
end)

function module:OnLogin()
	-- Default
	SetCVar("chatStyle", "classic")
	InterfaceOptionsSocialPanelChatStyle:Hide()
	CombatLogQuickButtonFrame_CustomTexture:SetTexture(nil)

	-- Sticky
	if not NDuiDB["Chat"]["Sticky"] then
		ChatTypeInfo["WHISPER"].sticky = 0
		ChatTypeInfo["BN_WHISPER"].sticky = 0
	end

	-- Fading
	if NDuiDB["Chat"]["NoFade"] then
		for i = 1, 50 do
			if _G["ChatFrame"..i] then
				_G["ChatFrame"..i]:SetFading(false)
			end
		end
		hooksecurefunc("FCF_OpenTemporaryWindow", function()
			local cf = FCF_GetCurrentChatFrame():GetName() or nil
			if cf then
				_G[cf]:SetFading(false)
			end
		end)
	end

	-- Easy Resizing
	if NDuiDB["Chat"]["EasyResize"] then
		ChatFrame1Tab:HookScript("OnMouseDown", function(self, arg1)
			if arg1 == "LeftButton" then
				if select(8, GetChatWindowInfo(1)) then
					ChatFrame1:StartSizing("TOP")
				end
			end
		end)
		ChatFrame1Tab:SetScript("OnMouseUp", function(self, arg1)
			if arg1 == "LeftButton" then
				ChatFrame1:StopMovingOrSizing()
				FCF_SavePositionAndDimensions(ChatFrame1)
			end
		end)
	end

	-- Add Elements
	self:ChannelRename()
	self:Chatbar()
	self:ChatCopy()

	-- ProfanityFilter
	if not BNFeaturesEnabledAndConnected() then return end
	if not NDuiDB["Chat"]["Freedom"] then
		SetCVar("profanityFilter", 1)
	else
		SetCVar("profanityFilter", 0)
	end
end