local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Chat")

local strfind, strmatch, strsub, gsub = string.find, string.match, string.sub, string.gsub
local strsplit, strlen = string.split, string.len

local IsModifierKeyDown, IsAltKeyDown, IsControlKeyDown, IsModifiedClick = IsModifierKeyDown, IsAltKeyDown, IsControlKeyDown, IsModifiedClick
local BNInviteFriend = BNInviteFriend
local CanCooperateWithGameAccount = CanCooperateWithGameAccount
local C_BattleNet_GetAccountInfoByID = C_BattleNet.GetAccountInfoByID

local foundurl = false

local function convertLink(text, value)
	return "|Hurl:"..tostring(value).."|h"..DB.InfoColor..text.."|r|h"
end

local function highlightURL(_, url)
	foundurl = true
	return " "..convertLink("["..url.."]", url).." "
end

function module:SearchForURL(text, ...)
	foundurl = false

	if strfind(text, "%pTInterface%p+") or strfind(text, "%pTINTERFACE%p+") then
		foundurl = true
	end

	if not foundurl then
		--192.168.1.1:1234
		text = gsub(text, "(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:%d%d?%d?%d?%d?)(%s?)", highlightURL)
	end
	if not foundurl then
		--192.168.1.1
		text = gsub(text, "(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?)(%s?)", highlightURL)
	end
	if not foundurl then
		--www.teamspeak.com:3333
		text = gsub(text, "(%s?)([%w_-]+%.?[%w_-]+%.[%w_-]+:%d%d%d?%d?%d?)(%s?)", highlightURL)
	end
	if not foundurl then
		--http://www.google.com
		text = gsub(text, "(%s?)(%a+://[%w_/%.%?%%=~&-'%-]+)(%s?)", highlightURL)
	end
	if not foundurl then
		--www.google.com
		text = gsub(text, "(%s?)(www%.[%w_/%.%?%%=~&-'%-]+)(%s?)", highlightURL)
	end
	if not foundurl then
		--lol@lol.com
		text = gsub(text, "(%s?)([_%w-%.~-]+@[_%w-]+%.[_%w-%.]+)(%s?)", highlightURL)
	end

	self.am(self, text, ...)
end

function module:HyperlinkShowHook(link, _, button)
	local type, value = strmatch(link, "(%a+):(.+)")
	local hide
	if button == "LeftButton" and IsModifierKeyDown() then
		if type == "player" then
			local unit = strmatch(value, "([^:]+)")
			if IsAltKeyDown() then
				C_PartyInfo.InviteUnit(unit)
				hide = true
			elseif IsControlKeyDown() then
				C_GuildInfo.Invite(unit)
				hide = true
			end
		elseif type == "BNplayer" then
			local _, bnID = strmatch(value, "([^:]*):([^:]*):")
			if not bnID then return end
			local accountInfo = C_BattleNet_GetAccountInfoByID(bnID)
			if not accountInfo then return end
			local gameAccountInfo = accountInfo.gameAccountInfo
			local gameID = gameAccountInfo.gameAccountID
			if gameID and CanCooperateWithGameAccount(accountInfo) then
				if IsAltKeyDown() then
					BNInviteFriend(gameID)
					hide = true
				elseif IsControlKeyDown() then
					local charName = gameAccountInfo.characterName
					local realmName = gameAccountInfo.realmName
					C_GuildInfo.Invite(charName.."-"..realmName)
					hide = true
				end
			end
		elseif type == "worldmap" then
			local waypoint = C_Map.GetUserWaypointHyperlink()
			if waypoint then
				if ChatEdit_GetActiveWindow() then
					ChatEdit_InsertLink(waypoint)
				else
					ChatFrame_OpenChat(waypoint)
				end
			end
		end
	elseif type == "url" then
		local eb = LAST_ACTIVE_CHAT_EDIT_BOX or _G[self:GetName().."EditBox"]
		if eb then
			eb:Show()
			eb:SetText(value)
			eb:SetFocus()
			eb:HighlightText()
		end
	end

	if hide then ChatEdit_ClearChat(ChatFrame1.editBox) end
end

function module.SetItemRefHook(link, _, button)
	if strsub(link, 1, 6) == "player" and button == "LeftButton" and IsModifiedClick("CHATLINK") then
		if not StaticPopup_Visible("ADD_IGNORE") and not StaticPopup_Visible("ADD_FRIEND") and not StaticPopup_Visible("ADD_GUILDMEMBER") and not StaticPopup_Visible("ADD_RAIDMEMBER") and not StaticPopup_Visible("CHANNEL_INVITE") and not ChatEdit_GetActiveWindow() then
			local namelink, fullname
			if strsub(link, 7, 8) == "GM" then
				namelink = strsub(link, 10)
			elseif strsub(link, 7, 15) == "Community" then
				namelink = strsub(link, 17)
			else
				namelink = strsub(link, 8)
			end
			if namelink then fullname = strsplit(":", namelink) end

			if fullname and strlen(fullname) > 0 then
				local name, server = strsplit("-", fullname)
				if server and server ~= DB.MyRealm then name = fullname end

				if MailFrame and MailFrame:IsShown() then
					MailFrameTab_OnClick(nil, 2)
					SendMailNameEditBox:SetText(name)
					SendMailNameEditBox:HighlightText()
				elseif ChatEdit_GetActiveWindow() then
					ChatEdit_InsertLink(name)
				end
			end
		end
	end
end

function module:UrlCopy()
	for i = 1, NUM_CHAT_WINDOWS do
		if i ~= 2 then
			local chatFrame = _G["ChatFrame"..i]
			chatFrame.am = chatFrame.AddMessage
			chatFrame.AddMessage = self.SearchForURL
		end
	end

	local orig = ItemRefTooltip.SetHyperlink
	function ItemRefTooltip:SetHyperlink(link, ...)
		if link and strsub(link, 0, 3) == "url" then return end

		return orig(self, link, ...)
	end

	if not DB.isNewPatch then
		hooksecurefunc("ChatFrame_OnHyperlinkShow", self.HyperlinkShowHook)
	end
	hooksecurefunc("SetItemRef", self.SetItemRefHook)
end