local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:RegisterModule("Maps")

function module:OnLogin()
	-- Scaling
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

	local player = B.CreateFS(WorldMapFrame.BorderFrame, 14, "", false, "TOPLEFT", 60, -6)
	local cursor = B.CreateFS(WorldMapFrame.BorderFrame, 14, "", false, "TOPLEFT", 180, -6)
	WorldMapFrame.BorderFrame.Tutorial:SetPoint("TOPLEFT", WorldMapFrame, "TOPLEFT", -12, -12)

	local mapBody = WorldMapFrame:GetCanvasContainer()
	local scale, width, height = mapBody:GetEffectiveScale(), mapBody:GetWidth(), mapBody:GetHeight()
	hooksecurefunc(WorldMapFrame, "OnFrameSizeChanged", function()
		width, height = mapBody:GetWidth(), mapBody:GetHeight()
	end)

	local function CursorCoords()
		local left, top = mapBody:GetLeft() or 0, mapBody:GetTop() or 0
		local x, y = GetCursorPosition()
		local cx = (x/scale - left) / width
		local cy = (top - y/scale) / height
		if cx < 0 or cx > 1 or cy < 0 or cy > 1 then return end
		return cx, cy
	end

	local function CoordsFormat(owner, none)
		local text = none and ": --, --" or ": %.1f, %.1f"
		return owner..DB.MyColor..text
	end

	local function UpdateCoords(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed > .1 then
			local cx, cy = CursorCoords()
			if cx and cy then
				cursor:SetFormattedText(CoordsFormat(L["Mouse"]), 100 * cx, 100 * cy)
			else
				cursor:SetText(CoordsFormat(L["Mouse"], true))
			end

			RunScript("NDuiMapCoords = C_Map.GetPlayerMapPosition(0, 'player')")
			if NDuiMapCoords then
				player:SetFormattedText(CoordsFormat(PLAYER), 100 * NDuiMapCoords.x, 100 * NDuiMapCoords.y)
			else
				player:SetText(CoordsFormat(PLAYER, true))
			end

			self.elapsed = 0
		end
	end

	local updater = CreateFrame("Frame")
	updater:SetScript("OnUpdate", UpdateCoords)
	updater:Hide()

	local function isUpdating(self)
		updater:SetShown(self:IsShown())
	end
	WorldMapFrame:HookScript("OnShow", isUpdating)
	WorldMapFrame:HookScript("OnHide", isUpdating)
end