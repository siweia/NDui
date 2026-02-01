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

-- Fix Professions drag taint in combat
do
	local done
	local function setupMisc(event, addon)
		if event == "ADDON_LOADED" and addon == "Blizzard_ProfessionsBook" then
			ProfessionsBookFrame:HookScript("OnShow", function()
				if not done then
					if InCombatLockdown() then
						B:RegisterEvent("PLAYER_REGEN_ENABLED", setupMisc)
					else
						B.CreateMF(ProfessionsBookFrame)
					end
					done = true
				end
			end)
			B:UnregisterEvent(event, setupMisc)
		elseif event == "PLAYER_REGEN_ENABLED" then
			B.CreateMF(ProfessionsBookFrame)
			B:UnregisterEvent(event, setupMisc)
		end
	end

	B:RegisterEvent("ADDON_LOADED", setupMisc)
end

-- Fix blizzard ui error
local coordStart = 0.0625;
local coordEnd = 1 - coordStart;
local textureUVs = {			-- keys have to match pieceNames in nineSliceSetup table
	TopLeftCorner = { setWidth = true, setHeight = true, ULx = 0.5078125, ULy = coordStart, LLx = 0.5078125, LLy = coordEnd, URx = 0.6171875, URy = coordStart, LRx = 0.6171875, LRy = coordEnd },
	TopRightCorner = { setWidth = true, setHeight = true, ULx = 0.6328125, ULy = coordStart, LLx = 0.6328125, LLy = coordEnd, URx = 0.7421875, URy = coordStart, LRx = 0.7421875, LRy = coordEnd },
	BottomLeftCorner = { setWidth = true, setHeight = true, ULx = 0.7578125, ULy = coordStart, LLx = 0.7578125, LLy = coordEnd, URx = 0.8671875, URy = coordStart, LRx = 0.8671875, LRy = coordEnd },
	BottomRightCorner = { setWidth = true, setHeight = true, ULx = 0.8828125, ULy = coordStart, LLx = 0.8828125, LLy = coordEnd, URx = 0.9921875, URy = coordStart, LRx = 0.9921875, LRy = coordEnd },
	TopEdge = { setHeight = true, ULx = 0.2578125, ULy = "repeatX", LLx = 0.3671875, LLy = "repeatX", URx = 0.2578125, URy = coordStart, LRx = 0.3671875, LRy = coordStart },
	BottomEdge = { setHeight = true, ULx = 0.3828125, ULy = "repeatX", LLx = 0.4921875, LLy = "repeatX", URx = 0.3828125, URy = coordStart, LRx = 0.4921875, LRy = coordStart },
	LeftEdge = { setWidth = true, ULx = 0.0078125, ULy = coordStart, LLx = 0.0078125, LLy = "repeatY", URx = 0.1171875, URy = coordStart, LRx = 0.1171875, LRy = "repeatY" },
	RightEdge = { setWidth = true, ULx = 0.1328125, ULy = coordStart, LLx = 0.1328125, LLy = "repeatY", URx = 0.2421875, URy = coordStart, LRx = 0.2421875, LRy = "repeatY" },
	Center = { ULx = 0, ULy = 0, LLx = 0, LLy = "repeatY", URx = "repeatX", URy = 0, LRx = "repeatX", LRy = "repeatY" },
};
local function GetBackdropCoordValue(coord, pieceSetup, repeatX, repeatY)
	local value = pieceSetup[coord];
	if value == "repeatX" then
		return repeatX;
	elseif value == "repeatY" then
		return repeatY;
	else
		return value;
	end
end
local function SetupBackdropTextureCoordinates(region, pieceSetup, repeatX, repeatY)
	region:SetTexCoord(	GetBackdropCoordValue("ULx", pieceSetup, repeatX, repeatY), GetBackdropCoordValue("ULy", pieceSetup, repeatX, repeatY),
						GetBackdropCoordValue("LLx", pieceSetup, repeatX, repeatY), GetBackdropCoordValue("LLy", pieceSetup, repeatX, repeatY),
						GetBackdropCoordValue("URx", pieceSetup, repeatX, repeatY), GetBackdropCoordValue("URy", pieceSetup, repeatX, repeatY),
						GetBackdropCoordValue("LRx", pieceSetup, repeatX, repeatY), GetBackdropCoordValue("LRy", pieceSetup, repeatX, repeatY));
end
function BackdropTemplateMixin:SetupTextureCoordinates()
	local width = self:GetWidth();
	if B:IsSecretValue(width) then return end -- needs review
	local height = self:GetHeight();
	local effectiveScale = self:GetEffectiveScale();
	local edgeSize = self:GetEdgeSize();
	local edgeRepeatX = max(0, (width / edgeSize) * effectiveScale - 2 - coordStart);
	local edgeRepeatY = max(0, (height / edgeSize) * effectiveScale - 2 - coordStart);

	for pieceName, pieceSetup in pairs(textureUVs) do
		local region = self[pieceName];
		if region then
			if pieceName == "Center" then
				local repeatX = 1;
				local repeatY = 1;
				if self.backdropInfo.tile then
					local divisor = self.backdropInfo.tileSize;
					if not divisor or divisor == 0 then
						divisor = edgeSize;
					end
					if divisor ~= 0 then
						repeatX = (width / divisor) * effectiveScale;
						repeatY = (height / divisor) * effectiveScale;
					end
				end
				SetupBackdropTextureCoordinates(region, pieceSetup, repeatX, repeatY);
			else
				SetupBackdropTextureCoordinates(region, pieceSetup, edgeRepeatX, edgeRepeatY);
			end
		end
	end
end