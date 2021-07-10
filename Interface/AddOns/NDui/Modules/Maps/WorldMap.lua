local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:RegisterModule("Maps")

local select = select
local WorldMapFrame = WorldMapFrame
local CreateVector2D = CreateVector2D
local UnitPosition = UnitPosition
local C_Map_GetWorldPosFromMapPos = C_Map.GetWorldPosFromMapPos
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit

local mapRects = {}
local tempVec2D = CreateVector2D(0, 0)
local currentMapID, playerCoords, cursorCoords

function module:GetPlayerMapPos(mapID)
	tempVec2D.x, tempVec2D.y = UnitPosition("player")
	if not tempVec2D.x then return end

	local mapRect = mapRects[mapID]
	if not mapRect then
		local pos1 = select(2, C_Map_GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0)))
		local pos2 = select(2, C_Map_GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1)))
		if not pos1 or not pos2 then return end
		mapRect = {pos1, pos2}
		mapRect[2]:Subtract(mapRect[1])

		mapRects[mapID] = mapRect
	end
	tempVec2D:Subtract(mapRect[1])

	return tempVec2D.y/mapRect[2].y, tempVec2D.x/mapRect[2].x
end

function module:GetCursorCoords()
	if not WorldMapFrame.ScrollContainer:IsMouseOver() then return end

	local cursorX, cursorY = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
	if cursorX < 0 or cursorX > 1 or cursorY < 0 or cursorY > 1 then return end
	return cursorX, cursorY
end

local function CoordsFormat(owner, none)
	local text = none and ": --, --" or ": %.1f, %.1f"
	return owner..DB.MyColor..text
end

function module:UpdateCoords(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > .1 then
		local cursorX, cursorY = module:GetCursorCoords()
		if cursorX and cursorY then
			cursorCoords:SetFormattedText(CoordsFormat(L["Mouse"]), 100 * cursorX, 100 * cursorY)
		else
			cursorCoords:SetText(CoordsFormat(L["Mouse"], true))
		end

		if not currentMapID then
			playerCoords:SetText(CoordsFormat(PLAYER, true))
		else
			local x, y = module:GetPlayerMapPos(currentMapID)
			if not x or (x == 0 and y == 0) then
				playerCoords:SetText(CoordsFormat(PLAYER, true))
			else
				playerCoords:SetFormattedText(CoordsFormat(PLAYER), 100 * x, 100 * y)
			end
		end

		self.elapsed = 0
	end
end

function module:UpdateMapID()
	if self:GetMapID() == C_Map_GetBestMapForUnit("player") then
		currentMapID = self:GetMapID()
	else
		currentMapID = nil
	end
end

function module:SetupCoords()
	playerCoords = B.CreateFS(WorldMapFrame.BorderFrame, 14, "", false, "TOPLEFT", 60, -6)
	cursorCoords = B.CreateFS(WorldMapFrame.BorderFrame, 14, "", false, "TOPLEFT", 180, -6)
	WorldMapFrame.BorderFrame.Tutorial:SetPoint("TOPLEFT", WorldMapFrame, "TOPLEFT", -12, -12)

	hooksecurefunc(WorldMapFrame, "OnFrameSizeChanged", module.UpdateMapID)
	hooksecurefunc(WorldMapFrame, "OnMapChanged", module.UpdateMapID)

	local CoordsUpdater = CreateFrame("Frame", nil, WorldMapFrame.BorderFrame)
	CoordsUpdater:SetScript("OnUpdate", module.UpdateCoords)
end

function module:UpdateMapScale()
	if self.isMaximized and self:GetScale() ~= C.db["Map"]["MaxMapScale"] then
		self:SetScale(C.db["Map"]["MaxMapScale"])
	elseif not self.isMaximized and self:GetScale() ~= C.db["Map"]["MapScale"] then
		self:SetScale(C.db["Map"]["MapScale"])
	end
end

function module:UpdateMapAnchor()
	module.UpdateMapScale(self)
	B.RestoreMF(self)
end

function module:WorldMapScale()
	-- Fix worldmap cursor when scaling
	WorldMapFrame.ScrollContainer.GetCursorPosition = function(f)
		local x, y = MapCanvasScrollControllerMixin.GetCursorPosition(f)
		local scale = WorldMapFrame:GetScale()
		return x / scale, y / scale
	end

	B.CreateMF(WorldMapFrame, nil, true)
	hooksecurefunc(WorldMapFrame, "SynchronizeDisplayState", self.UpdateMapAnchor)
end

function module:SetupWorldMap()
	if C.db["Map"]["DisableMap"] then return end
	if IsAddOnLoaded("Mapster") then return end
	if IsAddOnLoaded("Leatrix_Maps") then return end

	-- Remove from frame manager
	WorldMapFrame:ClearAllPoints()
	WorldMapFrame:SetPoint("CENTER") -- init anchor
	WorldMapFrame:SetAttribute("UIPanelLayout-area", nil)
	WorldMapFrame:SetAttribute("UIPanelLayout-enabled", false)
	WorldMapFrame:SetAttribute("UIPanelLayout-allowOtherPanels", true)
	tinsert(UISpecialFrames, "WorldMapFrame")

	-- Hide stuff
	WorldMapFrame.BlackoutFrame:SetAlpha(0)
	WorldMapFrame.BlackoutFrame:EnableMouse(false)
	--QuestMapFrame:SetScript("OnHide", nil) -- fix map toggle taint -- fix by LibShowUIPanel

	self:WorldMapScale()
	self:SetupCoords()
	self:MapReveal()
end

function module:OnLogin()
	self:SetupWorldMap()
	self:SetupMinimap()
end