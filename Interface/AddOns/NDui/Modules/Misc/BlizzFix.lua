local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

-- Unregister talent event
if PlayerTalentFrame then
	PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
else
	hooksecurefunc("TalentFrame_LoadUI", function()
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	end)
end

-- Fix blizz bug in addon list
local _AddonTooltip_Update = AddonTooltip_Update
function AddonTooltip_Update(owner)
	if not owner then return end
	if owner:GetID() < 1 then return end
	_AddonTooltip_Update(owner)
end

-- Fix Drag Collections taint
do
	local done
	local function setupMisc(event, addon)
		if event == "ADDON_LOADED" and addon == "Blizzard_Collections" then
			-- Fix undragable issue
			local checkBox = WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox
			checkBox.Label:ClearAllPoints()
			checkBox.Label:SetPoint("LEFT", checkBox, "RIGHT", 2, 1)
			checkBox.Label:SetWidth(152)

			CollectionsJournal:HookScript("OnShow", function()
				if not done then
					if InCombatLockdown() then
						B:RegisterEvent("PLAYER_REGEN_ENABLED", setupMisc)
					else
						B.CreateMF(CollectionsJournal)
					end
					done = true
				end
			end)
			B:UnregisterEvent(event, setupMisc)
		elseif event == "PLAYER_REGEN_ENABLED" then
			B.CreateMF(CollectionsJournal)
			B:UnregisterEvent(event, setupMisc)
		end
	end

	B:RegisterEvent("ADDON_LOADED", setupMisc)
end

-- Select target when click on raid units
do
	local function fixRaidGroupButton()
		for i = 1, 40 do
			local bu = _G["RaidGroupButton"..i]
			if bu and bu.unit and not bu.clickFixed then
				bu:SetAttribute("type", "target")
				bu:SetAttribute("unit", bu.unit)

				bu.clickFixed = true
			end
		end
	end

	local function setupMisc(event, addon)
		if event == "ADDON_LOADED" and addon == "Blizzard_RaidUI" then
			if not InCombatLockdown() then
				fixRaidGroupButton()
			else
				B:RegisterEvent("PLAYER_REGEN_ENABLED", setupMisc)
			end
			B:UnregisterEvent(event, setupMisc)
		elseif event == "PLAYER_REGEN_ENABLED" then
			if RaidGroupButton1 and RaidGroupButton1:GetAttribute("type") ~= "target" then
				fixRaidGroupButton()
				B:UnregisterEvent(event, setupMisc)
			end
		end
	end

	B:RegisterEvent("ADDON_LOADED", setupMisc)
end

-- Fix blizz guild news hyperlink error
do
	local function fixGuildNews(event, addon)
		if addon ~= "Blizzard_GuildUI" then return end

		local _GuildNewsButton_OnEnter = GuildNewsButton_OnEnter
		function GuildNewsButton_OnEnter(self)
			if not (self.newsInfo and self.newsInfo.whatText) then return end
			_GuildNewsButton_OnEnter(self)
		end

		B:UnregisterEvent(event, fixGuildNews)
	end
	B:RegisterEvent("ADDON_LOADED", fixGuildNews)
end

function M:HandleNDuiTitle()
	-- Square NDui logo texture
	local function replaceIconString(self, text)
		if not text then text = self:GetText() end
		if not text or text == "" then return end

		if strfind(text, "NDui") or strfind(text, "BaudErrorFrame") then
			local newText, count = gsub(text, "|T([^:]-):[%d+:]+|t", "|T"..DB.chatLogo..":12:24|t")
			if count > 0 then self:SetFormattedText("%s", newText) end
		end
	end

	hooksecurefunc("AddonList_InitAddon", function(entry)
		if not entry.logoHooked then
			replaceIconString(entry.Title)
			hooksecurefunc(entry.Title, "SetText", replaceIconString)

			entry.logoHooked = true
		end
	end)
end

-- Fix guild news jam
do
	local lastTime, timeGap = 0, 1.5
	local function updateGuildNews(self, event)
		if event == "PLAYER_ENTERING_WORLD" then
			QueryGuildNews()
		else
			if self:IsVisible() then
				local nowTime = GetTime()
				if nowTime - lastTime > timeGap then
					CommunitiesGuildNews_Update(self)
					lastTime = nowTime
				end
			end
		end
	end
	CommunitiesFrameGuildDetailsFrameNews:SetScript("OnEvent", updateGuildNews)
end