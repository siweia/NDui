local B, C, L, DB = unpack(select(2, ...))
if not C.Infobar.Location then return end

local module = NDui:GetModule("Infobar")
local info = module:RegisterInfobar(C.Infobar.LocationPos)

local zoneInfo = {
	sanctuary = {SANCTUARY_TERRITORY, {.41, .8, .94}},
	arena = {FREE_FOR_ALL_TERRITORY, {1, .1, .1}},
	friendly = {FACTION_CONTROLLED_TERRITORY, {.1, 1, .1}},
	hostile = {FACTION_CONTROLLED_TERRITORY, {1, .1, .1}},
	contested = {CONTESTED_TERRITORY, {1, .7, 0}},
	combat = {COMBAT_ZONE, {1, .1, .1}},
	neutral = {format(FACTION_CONTROLLED_TERRITORY, FACTION_STANDING_LABEL4), {1, .93, .76}}
}

local subzone, zone, pvp
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
	subzone, zone, pvp = GetSubZoneText(), GetZoneText(), {GetZonePVPInfo()}
	if not pvp[1] then pvp[1] = "neutral" end
	local r, g, b = unpack(zoneInfo[pvp[1]][2])
	self.text:SetText((subzone ~= "") and subzone or zone)
	self.text:SetTextColor(r, g, b)
end

local function isInvasionPoint()
	local mapName = GetMapInfo()
	local invaName = C_Scenario.GetInfo()
	if mapName and mapName:match("InvasionPoint") and invaName then
		return true
	end
end

info.onEnter = function(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -15)
	GameTooltip:ClearLines()

	if GetPlayerMapPosition("player") then
		self:SetScript("OnUpdate", function(self, elapsed)
			self.timer = (self.timer or 0) + elapsed
			if self.timer > .1 then
				coordX, coordY = GetPlayerMapPosition("player")
				self:GetScript("OnEnter")(self)
				self.timer = 0
			end
		end)
	end
	GameTooltip:AddLine(format("%s |cffffffff(%s)", zone, formatCoords()), 0,.6,1)

	if pvp[1] and not IsInInstance() then
		local r, g, b = unpack(zoneInfo[pvp[1]][2])
		if subzone and subzone ~= zone then 
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(subzone, r, g, b)
		end
		GameTooltip:AddLine(format(zoneInfo[pvp[1]][1], pvp[3] or ""), r, g, b)
	end

	GameTooltip:AddDoubleLine(" ", DB.LineString)
	GameTooltip:AddDoubleLine(" ", DB.LeftButton..L["WorldMap"].." ", 1,1,1, .6,.8,1)
	if isInvasionPoint() then
		GameTooltip:AddDoubleLine(" ", DB.ScrollButton..L["Search Invasion Group"].." ", 1,1,1, .6,.8,1)
	end
	GameTooltip:AddDoubleLine(" ", DB.RightButton..L["Send My Pos"].." ", 1,1,1, .6,.8,1)
	GameTooltip:Show()
end

info.onLeave = function()
	info:SetScript("OnUpdate", nil)
	GameTooltip:Hide()
end

info.onMouseUp = function(_, btn)
	if btn == "LeftButton" then
		ToggleFrame(WorldMapFrame)
	elseif btn == "MiddleButton" and isInvasionPoint() then
		PVEFrame_ShowFrame("GroupFinderFrame", LFGListPVEStub)
		LFGListCategorySelection_SelectCategory(LFGListFrame.CategorySelection, 6, 0)
		LFGListCategorySelection_StartFindGroup(LFGListFrame.CategorySelection, zone)
	elseif btn == "RightButton" then
		ChatFrame_OpenChat(format("%s: %s (%s)", L["My Position"], zone, formatCoords()), SELECTED_DOCK_FRAME)
	end
end