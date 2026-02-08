local _, ns = ...
local B, C, L, DB = unpack(ns)
if not C.Infobar.Location then return end

local module = B:GetModule("Infobar")
local info = module:RegisterInfobar("Zone", C.Infobar.LocationPos)
local mapModule = B:GetModule("Maps")

local format, unpack = string.format, unpack
local SELECTED_DOCK_FRAME, ChatFrame_OpenChat = SELECTED_DOCK_FRAME, ChatFrame_OpenChat
local GetSubZoneText, GetZoneText, GetZonePVPInfo, IsInInstance = GetSubZoneText, GetZoneText, GetZonePVPInfo, IsInInstance
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit

local zoneInfo = {
	sanctuary = {SANCTUARY_TERRITORY, {.41, .8, .94}},
	arena = {FREE_FOR_ALL_TERRITORY, {1, .1, .1}},
	friendly = {FACTION_CONTROLLED_TERRITORY, {.1, 1, .1}},
	hostile = {FACTION_CONTROLLED_TERRITORY, {1, .1, .1}},
	contested = {CONTESTED_TERRITORY, {1, .7, 0}},
	combat = {COMBAT_ZONE, {1, .1, .1}},
	neutral = {format(FACTION_CONTROLLED_TERRITORY, FACTION_STANDING_LABEL4), {1, .93, .76}}
}

local subzone, zone, pvpType, faction
local coordX, coordY = 0, 0

local function formatCoords()
	return format("%.1f, %.1f", coordX*100, coordY*100)
end

info.eventList = {
	"ZONE_CHANGED",
	"ZONE_CHANGED_INDOORS",
	"ZONE_CHANGED_NEW_AREA",
	"PLAYER_ENTERING_WORLD",
}

info.onEvent = function(self)
	subzone = GetSubZoneText()
	zone = GetZoneText()
	pvpType, _, faction = GetZonePVPInfo()
	pvpType = pvpType or "neutral"

	local r, g, b = unpack(zoneInfo[pvpType][2])
	self.text:SetText((subzone ~= "") and subzone or zone)
	self.text:SetTextColor(r, g, b)
end

local function UpdateCoords(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > .1 then
		local x, y = mapModule:GetPlayerMapPos(C_Map_GetBestMapForUnit("player"))
		if x then
			coordX, coordY = x, y
		else
			coordX, coordY = 0, 0
			self:SetScript("OnUpdate", nil)
		end
		self:onEnter()

		self.elapsed = 0
	end
end

info.onEnter = function(self)
	self:SetScript("OnUpdate", UpdateCoords)

	local _, anchor, offset = module:GetTooltipAnchor(info)
	GameTooltip:SetOwner(self, "ANCHOR_"..anchor, 0, offset)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(format("%s |cffffffff(%s)", zone, formatCoords()), 0,.6,1)

	if pvpType and not IsInInstance() then
		local r, g, b = unpack(zoneInfo[pvpType][2])
		if subzone and subzone ~= zone then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(subzone, r, g, b)
		end
		GameTooltip:AddLine(format(zoneInfo[pvpType][1], faction or ""), r, g, b)
	end

	GameTooltip:AddDoubleLine(" ", DB.LineString)
	GameTooltip:AddDoubleLine(" ", DB.LeftButton..L["WorldMap"].." ", 1,1,1, .6,.8,1)
	GameTooltip:AddDoubleLine(" ", DB.RightButton..L["Send My Pos"].." ", 1,1,1, .6,.8,1)
	GameTooltip:Show()
end

info.onLeave = function(self)
	self:SetScript("OnUpdate", nil)
	GameTooltip:Hide()
end

info.onMouseUp = function(_, btn)
	if btn == "LeftButton" then
		ToggleWorldMap()
	elseif btn == "RightButton" then
		local hasUnit = UnitExists("target") and not UnitIsPlayer("target")
		local unitName = nil
		if hasUnit then unitName = UnitName("target") end
		ChatFrame_OpenChat(format("%s: %s (%s) %s", L["My Position"], zone, formatCoords(), unitName or ""), SELECTED_DOCK_FRAME)
	end
end