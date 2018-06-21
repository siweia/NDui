local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:RegisterModule("Maps")

local mapRects = {}
local tempVec2D = CreateVector2D(0, 0)

function module:GetPlayerMapPos(mapID)
	tempVec2D.x, tempVec2D.y = UnitPosition("player")
	if not tempVec2D.x then return end

	local mapRect = mapRects[mapID]
	if not mapRect then
		mapRect = {}
		mapRect[1] = select(2, C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0)))
		mapRect[2] = select(2, C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1)))
		mapRect[2]:Subtract(mapRect[1])

		mapRects[mapID] = mapRect
	end
	tempVec2D:Subtract(mapRect[1])

	return (tempVec2D.y/mapRect[2].y), (tempVec2D.x/mapRect[2].x)
end

function module:OnLogin()
	local WorldMapFrame = _G.WorldMapFrame
	local BorderFrame = WorldMapFrame.BorderFrame
	local mapBody = WorldMapFrame:GetCanvasContainer()
	local formatText = DB.MyColor..": %.1f, %.1f"
	local scale = mapBody:GetEffectiveScale()
	local width, height, mapID = mapBody:GetWidth(), mapBody:GetHeight()

	-- Default Settings
	BorderFrame.Tutorial:SetPoint("TOPLEFT", WorldMapFrame, "TOPLEFT", -12, -12)
	if not WorldMapFrame.isMaximized then WorldMapFrame:SetScale(NDuiDB["Map"]["MapScale"]) end
	hooksecurefunc(WorldMapFrame, "Minimize", function(self)
		if InCombatLockdown() then return end
		self:SetScale(NDuiDB["Map"]["MapScale"])
	end)
	hooksecurefunc(WorldMapFrame, "Maximize", function(self)
		if InCombatLockdown() then return end
		self:SetScale(1)
	end)

	-- Generate Coords
	if not NDuiDB["Map"]["Coord"] then return end
	local player = B.CreateFS(BorderFrame, 14, "", false, "TOPLEFT", 60, -6)
	local cursor = B.CreateFS(BorderFrame, 14, "", false, "TOPLEFT", 180, -6)

	hooksecurefunc(WorldMapFrame, "OnFrameSizeChanged", function()
		width, height = mapBody:GetWidth(), mapBody:GetHeight()
	end)

	hooksecurefunc(WorldMapFrame, "OnMapChanged", function(self)
		mapID = self:GetMapID()
	end)

	local function CursorCoords()
		local left, top = mapBody:GetLeft() or 0, mapBody:GetTop() or 0
		local x, y = GetCursorPosition()
		local cx = (x/scale - left) / width
		local cy = (top - y/scale) / height
		if cx < 0 or cx > 1 or cy < 0 or cy > 1 then return end
		return cx, cy
	end

	local function CoordsUpdate(player, cursor)
		local cx, cy = CursorCoords()
		if cx and cy then
			cursor:SetFormattedText(L["Mouse"]..formatText, 100 * cx, 100 * cy)
		else
			cursor:SetText(L["Mouse"]..DB.MyColor..": --, --")
		end

		local x, y = self:GetPlayerMapPos(mapID)
		if not x or (x == 0 and y == 0) then
			player:SetText(PLAYER..DB.MyColor..": --, --")
		else
			player:SetFormattedText(PLAYER..formatText, 100 * x, 100 * y)
		end
	end

	local function UpdateCoords(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed > .1 then
			CoordsUpdate(player, cursor)
			self.elapsed = 0
		end
	end

	local updater = CreateFrame("Frame")
	updater:SetScript("OnUpdate", UpdateCoords)
	updater:Hide()

	local function updaterVisibility(self) updater:SetShown(self:IsShown()) end
	WorldMapFrame:HookScript("OnShow", updaterVisibility)
	WorldMapFrame:HookScript("OnHide", updaterVisibility)
end