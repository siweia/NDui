local _, ns = ...
local ycc = ns.ycc
local _VIEW

local function setview(view)
	_VIEW = view
end

local function update()
	_VIEW = _VIEW or GetCVar"guildRosterView"
	local playerArea = GetRealZoneText()
	local buttons = GuildRosterContainer.buttons

	for _, button in ipairs(buttons) do
		-- why the fuck no continue?
		if button:IsShown() and button.online and button.guildIndex then
			if _VIEW == "tradeskill" then
				local _, _, _, headerName, _, _, _, _, _, _, _, zone = GetGuildTradeSkillInfo(button.guildIndex)
				if (not headerName) and UnitName("player") then
					if zone == playerArea then
						button.string2:SetText("|cff00ff00"..zone)
					end
				end
			else
				local _, rank, rankIndex, level, _, zone, _, _, _, _, _, _, _, _, _, repStanding = GetGuildRosterInfo(button.guildIndex)
				if _VIEW == "playerStatus" then
					button.string1:SetText(ycc.diffColor[level]..level)
					if zone == playerArea then
						button.string3:SetText("|cff00ff00"..zone)
					end
				elseif _VIEW == "guildStatus" then
					if rankIndex and rank then
						button.string2:SetText(ycc.guildRankColor[rankIndex]..rank)
					end
				elseif _VIEW == "achievement" then
					button.string1:SetText(ycc.diffColor[level]..level)
				elseif _VIEW == "reputation" then
					button.string1:SetText(ycc.diffColor[level]..level)
					if repStanding then
						button.string3:SetText(ycc.repColor[repStanding-4].._G["FACTION_STANDING_LABEL"..repStanding])
					end
				end
			end
		end
	end
end

local loaded = CreateFrame("Frame")
loaded:RegisterEvent("ADDON_LOADED")
loaded:SetScript("OnEvent", function(self, event, addon)
	if addon ~= "Blizzard_GuildUI" then return end

	hooksecurefunc("GuildRoster_SetView", setview)
	hooksecurefunc("GuildRoster_Update", update)
	hooksecurefunc(GuildRosterContainer, "update", update)

	self:UnregisterEvent(event)
end)