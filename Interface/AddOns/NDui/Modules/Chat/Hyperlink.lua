local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Chat")

local strfind, strmatch, strsub, gsub = string.find, string.match, string.sub, string.gsub
local strsplit, strlen = string.split, string.len

local IsModifierKeyDown, IsAltKeyDown, IsControlKeyDown, IsModifiedClick = IsModifierKeyDown, IsAltKeyDown, IsControlKeyDown, IsModifiedClick
local BNInviteFriend = BNInviteFriend
local CanCooperateWithGameAccount = CanCooperateWithGameAccount
local C_BattleNet_GetAccountInfoByID = C_BattleNet.GetAccountInfoByID

function module:Hyperlink_Show(link, button)
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
		local editBox = ChatEdit_ChooseBoxForSend()
		if editBox then
			editBox:Show()
			editBox:SetText(value)
			editBox:SetFocus()
			editBox:HighlightText()
		end
	end

	if hide then ChatEdit_ClearChat(ChatFrame1.editBox) end
end

function module:ItemRef_CopyName(link, button)
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

function module.SetItemRefHook(link, _, button)
	if B:IsSecretValue(link) then return end
	module:ItemRef_CopyName(link, button)
	module:Hyperlink_Show(link, button)
end

function module:Hyperlink()
	hooksecurefunc("SetItemRef", self.SetItemRefHook)
end