local _, ns = ...
local ycc = ns.ycc

local FRIENDS_LEVEL_TEMPLATE = FRIENDS_LEVEL_TEMPLATE:gsub("%%d", "%%s")
FRIENDS_LEVEL_TEMPLATE = FRIENDS_LEVEL_TEMPLATE:gsub("%$d", "%$s")
local function friendsFrame()
	local scrollFrame = FriendsFrameFriendsScrollFrame
	local buttons = scrollFrame.buttons
	local playerArea = GetRealZoneText()

	for i = 1, #buttons do
		local nameText, infoText
		local button = buttons[i]
		if button:IsShown() then
			if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
				local name, level, class, area, connected, _, _ = GetFriendInfo(button.id)
				if connected then
					nameText = ycc.classColor[class]..name.."|r, "..format(FRIENDS_LEVEL_TEMPLATE, ycc.diffColor[level]..level.."|r", class)
					if area == playerArea then
						infoText = format("|cff00ff00%s|r", area)
					end
				end
			elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
				local _, presenceName, _, _, _, gameID, client, isOnline = BNGetFriendInfo(button.id)
				if isOnline and client == BNET_CLIENT_WOW then
					local _, charName, _, _, _, faction, _, class, _, zoneName = BNGetGameAccountInfo(gameID)
					if presenceName and charName and class and faction == UnitFactionGroup("player") then
						nameText = presenceName.." "..FRIENDS_WOW_NAME_COLOR_CODE.."("..ycc.classColor[class]..charName..FRIENDS_WOW_NAME_COLOR_CODE..")"
						if zoneName == playerArea then
							infoText = format("|cff00ff00%s|r", zoneName)
						end
					end
				end
			end
		end

		if nameText then button.name:SetText(nameText) end
		if infoText then button.info:SetText(infoText) end
	end
end
hooksecurefunc(FriendsFrameFriendsScrollFrame, "update", friendsFrame)
hooksecurefunc("FriendsFrame_UpdateFriends", friendsFrame)