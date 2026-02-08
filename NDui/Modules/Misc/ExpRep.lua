local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

--[[
	一个工具条用来替代系统的经验条、声望条、神器经验等等
]]
local pairs = pairs
local min, floor = math.min, math.floor
local GetMaxPlayerLevel = GetMaxPlayerLevel
local FACTION_BAR_COLORS = FACTION_BAR_COLORS

function M:ExpBar_Update()
	local rest = self.restBar
	if rest then rest:Hide() end

	if UnitLevel("player") < GetMaxPlayerLevel() then
		local xp, mxp, rxp = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
		self:SetStatusBarColor(0, .7, 1)
		self:SetMinMaxValues(0, mxp)
		self:SetValue(xp)
		self:Show()
		if rxp then
			rest:SetMinMaxValues(0, mxp)
			rest:SetValue(min(xp + rxp, mxp))
			rest:Show()
		end
	elseif GetWatchedFactionInfo() then
		local _, standing, barMin, barMax, value = GetWatchedFactionInfo()
		--if standing == MAX_REPUTATION_REACTION then barMin, barMax, value = 0, 1, 1 end
		self:SetStatusBarColor(FACTION_BAR_COLORS[standing].r, FACTION_BAR_COLORS[standing].g, FACTION_BAR_COLORS[standing].b, .85)
		self:SetMinMaxValues(barMin, barMax)
		self:SetValue(value)
		self:Show()
	else
		self:Hide()
	end
end

function M:ExpBar_UpdateTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:ClearLines()
	GameTooltip:AddLine(LEVEL.." "..UnitLevel("player"), 0,.6,1)

	if UnitLevel("player") < GetMaxPlayerLevel() then
		GameTooltip:AddLine(" ")
		local xp, mxp, rxp = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
		GameTooltip:AddDoubleLine(XP..":", xp.." / "..mxp.." ("..floor(xp/mxp*100).."%)", .6,.8,1, 1,1,1)
		if rxp then
			GameTooltip:AddDoubleLine(TUTORIAL_TITLE26..":", "+"..rxp.." ("..floor(rxp/mxp*100).."%)", .6,.8,1, 1,1,1)
		end
	end

	if DB.MyClass == "HUNTER" then
		local currXP, nextXP = GetPetExperience()
		if nextXP ~= 0 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(PET.." Lv"..UnitLevel("pet"), 0,.6,1)
			GameTooltip:AddDoubleLine(XP..":", currXP.." / "..nextXP.." ("..floor(currXP/nextXP*100).."%)", .6,.8,1, 1,1,1)
		end
	end

	if GetWatchedFactionInfo() then
		local name, standing, barMin, barMax, value = GetWatchedFactionInfo()
		--[[if standing == MAX_REPUTATION_REACTION then
			barMax = barMin + 1e3
			value = barMax - 1
		end]]
		local standingtext = _G["FACTION_STANDING_LABEL"..standing] or UNKNOWN
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(name, 0,.6,1)
		GameTooltip:AddDoubleLine(standingtext, value - barMin.." / "..barMax - barMin.." ("..floor((value - barMin)/(barMax - barMin)*100).."%)", .6,.8,1, 1,1,1)
	end
	GameTooltip:Show()
end

function M:SetupScript(bar)
	bar.eventList = {
		"PLAYER_XP_UPDATE",
		"PLAYER_LEVEL_UP",
		"UPDATE_EXHAUSTION",
		"PLAYER_ENTERING_WORLD",
		"UPDATE_FACTION",
		"UNIT_INVENTORY_CHANGED",
		"ENABLE_XP_GAIN",
		"DISABLE_XP_GAIN",
	}
	for _, event in pairs(bar.eventList) do
		bar:RegisterEvent(event)
	end
	bar:SetScript("OnEvent", M.ExpBar_Update)
	bar:SetScript("OnEnter", M.ExpBar_UpdateTooltip)
	bar:SetScript("OnLeave", B.HideTooltip)
end

function M:Expbar()
	if C.db["Map"]["DisableMinimap"] then return end
	if not C.db["Misc"]["ExpRep"] then return end

	local bar = CreateFrame("StatusBar", "NDuiExpRepBar", MinimapCluster)
	bar:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", 5, -5)
	bar:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", -5, -5)
	bar:SetHeight(5)
	bar:SetHitRectInsets(0, 0, 0, -10)
	B.CreateSB(bar)

	local rest = CreateFrame("StatusBar", nil, bar)
	rest:SetAllPoints()
	rest:SetStatusBarTexture(DB.normTex)
	rest:SetStatusBarColor(0, .4, 1, .6)
	rest:SetFrameLevel(bar:GetFrameLevel() - 1)
	bar.restBar = rest

	M:SetupScript(bar)
end
M:RegisterMisc("ExpRep", M.Expbar)