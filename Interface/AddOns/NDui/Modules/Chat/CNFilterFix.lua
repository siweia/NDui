-- https://bbs.nga.cn/read.php?tid=27432996
-- oyg123
local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Chat")

local function _FriendsFrame_ShouldShowSummonButton(self)
	local id = self:GetParent().id
	if not id then
		return false, false
	end
	local enable = false
	local bType = self:GetParent().buttonType
	if (self:GetParent().buttonType == FRIENDS_BUTTON_TYPE_WOW) then
		local info = C_FriendList.GetFriendInfoByIndex(id)
		if not info or info.mobile or not info.connected or info.rafLinkType == Enum.RafLinkType.None then
			return false, false
		end
		return true, CanSummonFriend(info.guid)
	elseif (self:GetParent().buttonType == FRIENDS_BUTTON_TYPE_BNET) then
		--Get the information by BNet friends list index.
		local accountInfo = C_BattleNet.GetFriendAccountInfo(id)
		local restriction = FriendsFrame_GetInviteRestriction(id)
		if restriction ~= 9 or accountInfo.rafLinkType == Enum.RafLinkType.None then
			return false, false
		else
			return true, accountInfo.gameAccountInfo.canSummon
		end
	else
		return false, false
	end
end

local function _UnitPopup_IsInGroupWithPlayer(dropdownMenu)
	if dropdownMenu.accountInfo and dropdownMenu.accountInfo.gameAccountInfo.characterName then
		return UnitInParty(dropdownMenu.accountInfo.gameAccountInfo.characterName) or
		UnitInRaid(dropdownMenu.accountInfo.gameAccountInfo.characterName)
	elseif dropdownMenu.guid then
		return IsGUIDInGroup(dropdownMenu.guid)
	end
end

local function _UnitPopup_IsEnabled(dropdownFrame, unitPopupButton)
	if unitPopupButton.isUninteractable then
		return false
	end
	if unitPopupButton.dist and not CheckInteractDistance(dropdownFrame.unit, unitPopupButton.dist) then
		return false
	end
	if unitPopupButton.disabledInKioskMode and Kiosk.IsEnabled() then
		return false
	end
	return true
end

local function _CanGroupWithAccount(bnetIDAccount)
	if not bnetIDAccount then
		return false
	end
	local index = BNGetFriendIndex(bnetIDAccount)
	if not index then
		return false
	end
	local restriction = FriendsFrame_GetInviteRestriction(index)
	if restriction == 11 then
		restriction = 9
	end
	return restriction == 9
end

local _ShowRichPresenceOnly = function(client, wowProjectID, faction, realmID)
	if (client ~= BNET_CLIENT_WOW) or (wowProjectID ~= WOW_PROJECT_ID) then
		return true
	elseif (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC) and ((faction ~= playerFactionGroup) or (realmID ~= playerRealmID)) then
		return true
	else
		return false
	end
end
----hook的按钮script
local function FriendTipOnEnter(self)
	if self.buttonType == FRIENDS_BUTTON_TYPE_BNET then
		local accountInfo = C_BattleNet.GetFriendAccountInfo(self.id)
		local gameAccountInfo = accountInfo and accountInfo.gameAccountInfo
		if gameAccountInfo and gameAccountInfo.gameAccountID and not gameAccountInfo.isInCurrentRegion and
			not _ShowRichPresenceOnly(gameAccountInfo.clientProgram, gameAccountInfo.wowProjectID, gameAccountInfo.factionName, gameAccountInfo.realmID) then
			local areaName = gameAccountInfo.isWowMobile and LOCATION_MOBILE_APP or (gameAccountInfo.areaName or UNKNOWN)
			local realmName = gameAccountInfo.realmDisplayName or UNKNOWN
			FriendsFrameTooltip_SetLine(FriendsTooltipGameAccount1Info, nil, BNET_FRIEND_TOOLTIP_ZONE_AND_REALM:format(areaName, realmName), -4)
		end
	else
	-- print(self.buttonType, GetTime())
	end
end

function module:CNLanguageFilterFix()
	----hook的方法：
	hooksecurefunc("UnitPopup_OnUpdate", function()
		if DropDownList1:IsShown() then
			local count, tempCount
			local isOk = false
			for level, dropdownFrame in pairs(OPEN_DROPDOWNMENUS) do
				if (dropdownFrame) then
					count = 0
					for index, value in ipairs(UnitPopupMenus[dropdownFrame.which]) do
						if (UnitPopupShown[level][index] == 1) then
							count = count + 1
							local enable = _UnitPopup_IsEnabled(dropdownFrame, UnitPopupButtons[value])
							if (value == "BN_INVITE" or value == "BN_SUGGEST_INVITE" or value == "BN_REQUEST_INVITE") then
								local currentDropDown = UIDROPDOWNMENU_OPEN_MENU
								local isInGroupWithPlayer = _UnitPopup_IsInGroupWithPlayer(currentDropDown)
								if not currentDropDown.bnetIDAccount or not _CanGroupWithAccount(currentDropDown.bnetIDAccount) or isInGroupWithPlayer then
									enable = false
								end
								isOk = true
							end
							local diff = (level > 1) and 0 or 1
							if (UnitPopupButtons[value].isSubsectionTitle) then
								tempCount = count + diff
								count = count + 1
							else
								tempCount = count + diff
							end
							if (isOk) then
								if enable then
									UIDropDownMenu_EnableButton(level, tempCount)
								end
								return
							end
						end
					end
				end
			end
		end
	end)
	
	hooksecurefunc("FriendsFrame_SummonButton_Update", function(self)
		local shouldShow, enable = _FriendsFrame_ShouldShowSummonButton(self)
		self:SetShown(shouldShow)
		local start, duration = GetSummonFriendCooldown()
		if (duration > 0) then
			self.duration = duration
			self.start = start
		else
			self.duration = nil
			self.start = nil
		end
		local normalTexture = self:GetNormalTexture()
		local pushedTexture = self:GetPushedTexture()
		self.enabled = enable
		if (enable) then
			normalTexture:SetVertexColor(1, 1, 1)
			pushedTexture:SetVertexColor(1, 1, 1)
		else
			normalTexture:SetVertexColor(.4, .4, .4)
			pushedTexture:SetVertexColor(.4, .4, .4)
		end
		CooldownFrame_Set(_G[self:GetName() .. "Cooldown"], start, duration, ((enable and 0) or 1))
	end)
	
	hooksecurefunc("FriendsFrame_UpdateFriendButton", function(button)
		if button.id and button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
			local accountInfo = C_BattleNet.GetFriendAccountInfo(button.id)
			if accountInfo.gameAccountInfo.isOnline then
				local restriction = FriendsFrame_GetInviteRestriction(button.id)
				if restriction == 11 then
					restriction = 9
				end
				local shouldShowSummonButton
				if restriction ~= 9 or accountInfo.rafLinkType == Enum.RafLinkType.None then
					shouldShowSummonButton = false
				else
					shouldShowSummonButton = true
				end
				button.gameIcon:SetShown(not shouldShowSummonButton)
				if restriction == 9 then
					button.travelPassButton:Enable()
				end
			end
		end
	end)

	if (FriendsListFrameScrollFrame.buttons) then
		for i = 1, #FriendsListFrameScrollFrame.buttons do
			FriendsListFrameScrollFrame.buttons[i].travelPassButton:HookScript("OnEnter", function(self)
				local restriction = FriendsFrame_GetInviteRestriction(self:GetParent().id)
				if (restriction == 11) then
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					local guid = FriendsFrame_GetPlayerGUIDFromIndex(self:GetParent().id)
					local inviteType = GetDisplayedInviteType(guid)
					if (inviteType == "INVITE") then
						GameTooltip:SetText(TRAVEL_PASS_INVITE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
					elseif (inviteType == "SUGGEST_INVITE") then
						GameTooltip:SetText(SUGGEST_INVITE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
					else --inviteType == "REQUEST_INVITE"
						GameTooltip:SetText(REQUEST_INVITE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
						--For REQUEST_INVITE, we'll display other members in the group if there are any.
						local group = C_SocialQueue.GetGroupForPlayer(guid)
						local members = C_SocialQueue.GetGroupMembers(group)
						local numDisplayed = 0
						for i = 1, #members do
							if (members[i].guid ~= guid) then
								if (numDisplayed == 0) then
									GameTooltip:AddLine(SOCIAL_QUEUE_ALSO_IN_GROUP)
								elseif (numDisplayed >= 7) then
									GameTooltip:AddLine(SOCIAL_QUEUE_AND_MORE, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, 1)
									break
								end
								local name, color = SocialQueueUtil_GetRelationshipInfo(members[i].guid, nil, members[i].clubId)
								GameTooltip:AddLine(color .. name .. FONT_COLOR_CODE_CLOSE)
								numDisplayed = numDisplayed + 1
							end
						end
					end
					GameTooltip:Show()
				end
			end)
	
			FriendsListFrameScrollFrame.buttons[i]:HookScript("OnEnter", function(self)
				FriendTipOnEnter(self)
			end)
		end
	----FriendsListFrameScrollFrame.buttons[i].OnEnter会在FriendsTooltip.OnUpdate的时候被调用
		FriendsTooltip:HookScript("OnUpdate", function(self)
			if self.hasBroadcast and self.button then
				FriendTipOnEnter(self.button)
			end
		end)
	end
end