local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:RegisterModule("Maps")

function module:OnLogin()
	local WorldMapFrame = _G.WorldMapFrame
	local BorderFrame = WorldMapFrame.BorderFrame
	local mapBody = WorldMapFrame:GetCanvasContainer()
	local formatText = DB.MyColor..": %.1f, %.1f"
	local scale = mapBody:GetEffectiveScale()
	local width, height, mapID = mapBody:GetWidth(), mapBody:GetHeight()
	local position

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
			cursor:SetFormattedText(MOUSE_LABEL..formatText, 100 * cx, 100 * cy)
		else
			cursor:SetText(MOUSE_LABEL..DB.MyColor..": --, --")
		end

		position = C_Map.GetPlayerMapPosition(mapID, "player")
		if not position or (position.x == 0 and position.y == 0) then
			player:SetText(PLAYER..DB.MyColor..": --, --")
		else
			player:SetFormattedText(PLAYER..formatText, 100 * position.x, 100 * position.y)
			wipe(position)
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