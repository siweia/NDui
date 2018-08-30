local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Chat")

function module:UrlCopy()
	local foundurl = false

	local function linkconvert(text, value)
		return "|Hurl:"..tostring(value).."|h"..DB.InfoColor..text.."|r|h"
	end

	local function highlighturl(_, url)
		foundurl = true
		return " "..linkconvert("["..url.."]", url).." "
	end

	local function searchforurl(frame, text, ...)
		foundurl = false

		if string.find(text, "%pTInterface%p+") or string.find(text, "%pTINTERFACE%p+") then
			foundurl = true
		end

		if not foundurl then
			--192.168.1.1:1234
			text = string.gsub(text, "(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:%d%d?%d?%d?%d?)(%s?)", highlighturl)
		end
		if not foundurl then
			--192.168.1.1
			text = string.gsub(text, "(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?)(%s?)", highlighturl)
		end
		if not foundurl then
			--www.teamspeak.com:3333
			text = string.gsub(text, "(%s?)([%w_-]+%.?[%w_-]+%.[%w_-]+:%d%d%d?%d?%d?)(%s?)", highlighturl)
		end
		if not foundurl then
			--http://www.google.com
			text = string.gsub(text, "(%s?)(%a+://[%w_/%.%?%%=~&-'%-]+)(%s?)", highlighturl)
		end
		if not foundurl then
			--www.google.com
			text = string.gsub(text, "(%s?)(www%.[%w_/%.%?%%=~&-'%-]+)(%s?)", highlighturl)
		end
		if not foundurl then
			--lol@lol.com
			text = string.gsub(text, "(%s?)([_%w-%.~-]+@[_%w-]+%.[_%w-%.]+)(%s?)", highlighturl)
		end

		frame.am(frame, text, ...)
	end

	for i = 1, NUM_CHAT_WINDOWS do
		if i ~= 2 then
			local cf = _G["ChatFrame"..i]
			cf.am = cf.AddMessage
			cf.AddMessage = searchforurl
		end
	end

	local orig = ItemRefTooltip.SetHyperlink
	function ItemRefTooltip:SetHyperlink(link, ...)
		if link and link:sub(0, 3) == "url" then return end

		return orig(self, link, ...)
	end

	hooksecurefunc("ChatFrame_OnHyperlinkShow", function(frame, link, _, button)
		local type, value = link:match("(%a+):(.+)")
		local hide
		if button == "LeftButton" and IsModifierKeyDown() then
			if type == "player" then
				local unit = value:match("([^:]+)")
				if IsAltKeyDown() then
					InviteToGroup(unit)
					hide = true
				elseif IsControlKeyDown() then
					GuildInvite(unit)
					hide = true
				end
			elseif type == "BNplayer" then
				local _, bnID = value:match("([^:]*):([^:]*):")
				if not bnID then return end
				local _, _, _, _, _, gameID = BNGetFriendInfoByID(bnID)
				if gameID and CanCooperateWithGameAccount(gameID) then
					if IsAltKeyDown() then
						BNInviteFriend(gameID)
						hide = true
					elseif IsControlKeyDown() then
						local _, charName, _, realmName = BNGetGameAccountInfo(gameID)
						GuildInvite(charName.."-"..realmName)
						hide = true
					end
				end
			end
		elseif type == "url" then
			local eb = LAST_ACTIVE_CHAT_EDIT_BOX or _G[frame:GetName().."EditBox"]
			if eb then
				eb:Show()
				eb:SetText(value)
				eb:SetFocus()
				eb:HighlightText()
			end
		end

		if hide then ChatEdit_ClearChat(ChatFrame1.editBox) end
	end)

	hooksecurefunc("SetItemRef", function(link, _, button)
		if strsub(link, 1, 6) == "player" and button == "LeftButton" and IsModifiedClick("CHATLINK") then
			if not StaticPopup_Visible("ADD_IGNORE") and not StaticPopup_Visible("ADD_FRIEND") and not StaticPopup_Visible("ADD_GUILDMEMBER")
				and not StaticPopup_Visible("ADD_RAIDMEMBER") and not StaticPopup_Visible("CHANNEL_INVITE") and not ChatEdit_GetActiveWindow() then

				local namelink, name
				if strsub(link, 7, 8) == "GM" then
					namelink = strsub(link, 10)
				elseif strsub(link, 7, 15) == "Community" then
					namelink = strsub(link, 17)
				else
					namelink = strsub(link, 8)
				end
				if namelink then name = strsplit(":", namelink) end

				if name and strlen(name) > 0 then
					if MailFrame and MailFrame:IsShown() then
						MailFrameTab_OnClick(nil, 2)
						SendMailNameEditBox:SetText(name)
						SendMailNameEditBox:HighlightText()
					else
						local editBox = ChatEdit_ChooseBoxForSend()
						local hasText = (editBox:GetText() ~= "")
						ChatEdit_ActivateChat(editBox)
						editBox:Insert(name)
						if not hasText then editBox:HighlightText() end
					end
				end
			end
		end
	end)
end