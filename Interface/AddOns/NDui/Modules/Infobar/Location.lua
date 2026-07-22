local _, ns = ...
local B, C, L, DB = unpack(ns)
if not C.Infobar.Location then return end

local module = B:GetModule("Infobar")
local info = module:RegisterInfobar("Zone", C.Infobar.LocationPos)
local mapModule = B:GetModule("Maps")

local format, unpack = string.format, unpack
local WorldMapFrame = WorldMapFrame
local GetZonePVPInfo = C_PvP and C_PvP.GetZonePVPInfo or GetZonePVPInfo
local IsInInstance = IsInInstance
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

local function UpdateLocationText(self)
	if NDuiADB["ShowCoords"] then
		self.text:SetFormattedText("%s |cffffffff(%s)|r", subzone, formatCoords())
	else
		self.text:SetText(subzone)
	end
end

local function RefreshCoords(mapID)
	local x, y = mapModule:GetPlayerMapPos(mapID or C_Map_GetBestMapForUnit("player"))
	if x then
		coordX, coordY = x, y
	else
		coordX, coordY = 0, 0
	end
end

local function UpdateTooltip(self)
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
	GameTooltip:AddDoubleLine(" ", DB.ScrollButton..L["Switch Mode"].." ", 1,1,1, .6,.8,1)
	GameTooltip:AddDoubleLine(" ", DB.RightButton..L["Send My Pos"].." ", 1,1,1, .6,.8,1)
	GameTooltip:Show()
end

local function UpdateCoords(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > .1 then
		RefreshCoords()
		if NDuiADB["ShowCoords"] then
			UpdateLocationText(self)
		end
		if GameTooltip:IsOwned(self) then
			UpdateTooltip(self)
		end

		self.elapsed = 0
	end
end

info.eventList = {
	"ZONE_CHANGED",
	"ZONE_CHANGED_INDOORS",
	"ZONE_CHANGED_NEW_AREA",
	"PLAYER_ENTERING_WORLD",
}

info.onEvent = function(self)
	subzone = GetMinimapZoneText()
	zone = GetAreaText()
	pvpType, _, faction = GetZonePVPInfo()
	pvpType = pvpType or "neutral"

	local r, g, b = unpack(zoneInfo[pvpType][2])
	if NDuiADB["ShowCoords"] then
		RefreshCoords()
		self:SetScript("OnUpdate", UpdateCoords)
	end
	UpdateLocationText(self)
	self.text:SetTextColor(r, g, b)
end

info.onEnter = function(self)
	RefreshCoords()
	UpdateLocationText(self)
	self.elapsed = 0
	self:SetScript("OnUpdate", UpdateCoords)
	UpdateTooltip(self)
end

info.onLeave = function(self)
	if not NDuiADB["ShowCoords"] then
		self:SetScript("OnUpdate", nil)
	end
	GameTooltip:Hide()
end


local zoneString = "|cffffff00|Hworldmap:%d+:%d+:%d+|h[|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a %s: %s (%s) %s]|h|r"

info.onMouseUp = function(self, btn)
	if btn == "LeftButton" then
		if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end -- fix by LibShowUIPanel
		ToggleFrame(WorldMapFrame)
	elseif btn == "MiddleButton" then
		NDuiADB["ShowCoords"] = not NDuiADB["ShowCoords"]
		RefreshCoords()
		UpdateLocationText(self)
		self.elapsed = 0
		if NDuiADB["ShowCoords"] or GameTooltip:IsOwned(self) then
			self:SetScript("OnUpdate", UpdateCoords)
		else
			self:SetScript("OnUpdate", nil)
		end
		if GameTooltip:IsOwned(self) then
			UpdateTooltip(self)
		end
	elseif btn == "RightButton" then
		local mapID = C_Map_GetBestMapForUnit("player")
		if not mapID then return end
		RefreshCoords(mapID)
		local hasUnit = UnitExists("target") and not UnitIsPlayer("target")
		local unitName = hasUnit and UnitName("target") or ""
		print(format(zoneString, mapID, coordX*10000, coordY*10000, L["My Position"], zone, formatCoords(), unitName))
	end
end
