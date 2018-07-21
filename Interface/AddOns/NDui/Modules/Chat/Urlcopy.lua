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

	local orig = ChatFrame_OnHyperlinkShow
	function ChatFrame_OnHyperlinkShow(frame, link, text, button)
		local type, value = link:match("(%a+):(.+)")
		if IsAltKeyDown() and type == "player" then
			InviteToGroup(value:match("([^:]+)"))
		elseif IsModifierKeyDown() and type == "BNplayer" then
			local _, bnID = value:match("([^:]*):([^:]*):")
			if not bnID then return end
			local _, _, _, _, _, gameID = BNGetFriendInfoByID(bnID)
			if gameID and CanCooperateWithGameAccount(gameID) then
				if IsAltKeyDown() then
					BNInviteFriend(gameID)
				elseif IsControlKeyDown() then
					local _, charName, _, realmName = BNGetGameAccountInfo(gameID)
					GuildInvite(charName.."-"..realmName)
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
		else
			orig(self, link, text, button)
		end
	end
end