local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:RegisterModule("Maps")

function module:OnLogin()
	local WorldMapDetailFrame, WorldMapTitleButton, WorldMapFrame, WorldMapFrameTutorialButton = _G.WorldMapDetailFrame, _G.WorldMapTitleButton, _G.WorldMapFrame, _G.WorldMapFrameTutorialButton
	local formattext = DB.MyColor..": %.1f, %.1f"

	-- Default Settings
	SetCVar("lockedWorldMap", 0)
	WorldMapFrameTutorialButton:SetPoint("TOPLEFT", WorldMapFrame, "TOPLEFT", -12, -12)
	WorldMapFrame:SetScale(NDuiDB["Map"]["MapScale"])
	hooksecurefunc("WorldMap_ToggleSizeUp", function()
		if InCombatLockdown() then return end
		WorldMapFrame:SetScale(1)
	end)
	hooksecurefunc("WorldMap_ToggleSizeDown", function()
		if InCombatLockdown() then return end
		WorldMapFrame:SetScale(NDuiDB["Map"]["MapScale"])
	end)

	-- Generate Coords
	if not NDuiDB["Map"]["Coord"] then return end
	local player = B.CreateFS(WorldMapTitleButton, 14, "", false, "TOPLEFT", 50, -6)
	local cursor = B.CreateFS(WorldMapTitleButton, 14, "", false, "TOPLEFT", 180, -6)
	local width, height = WorldMapDetailFrame:GetWidth(), WorldMapDetailFrame:GetHeight()
	local scale = WorldMapDetailFrame:GetEffectiveScale()

	local function CursorCoords()
		local left, top = WorldMapDetailFrame:GetLeft() or 0, WorldMapDetailFrame:GetTop() or 0
		local x, y = GetCursorPosition()
		local cx = (x/scale - left) / width
		local cy = (top - y/scale) / height
		if cx < 0 or cx > 1 or cy < 0 or cy > 1 then return end
		return cx, cy
	end

	local function CoordsUpdate(player, cursor)
		local cx, cy = CursorCoords()
		local px, py = GetPlayerMapPosition("player")
		if cx and cy then
			cursor:SetFormattedText(MOUSE_LABEL..formattext, 100 * cx, 100 * cy)
		else
			cursor:SetText(MOUSE_LABEL..DB.MyColor..": --, --")
		end
		if not px or px == 0 or py == 0 then
			player:SetText(PLAYER..DB.MyColor..": --, --")
		else
			player:SetFormattedText(PLAYER..formattext, 100 * px, 100 * py)
		end
	end

	local updater = CreateFrame("Frame")
	local function UpdateCoords(self, elapsed)
		self.elapsed = self.elapsed - elapsed
		if self.elapsed <= 0 then
			self.elapsed = .1
			CoordsUpdate(player, cursor)
		end
	end

	B:RegisterEvent("WORLD_MAP_UPDATE", function()
		if WorldMapFrame:IsVisible() then
			updater.elapsed = .1
			updater:SetScript("OnUpdate", UpdateCoords)
		else
			updater.elapsed = nil
			updater:SetScript("OnUpdate", nil)
		end
	end)
end