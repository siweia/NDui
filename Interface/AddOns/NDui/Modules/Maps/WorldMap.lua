local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:RegisterModule("Maps")

local select, wipe, strmatch, gmatch, tinsert, pairs = select, wipe, strmatch, gmatch, tinsert, pairs
local tonumber, format, ceil, mod = tonumber, format, ceil, mod
local WorldMapFrame = WorldMapFrame
local CreateVector2D = CreateVector2D
local UnitPosition = UnitPosition
local C_Map_GetMapArtID = C_Map.GetMapArtID
local C_Map_GetMapArtLayers = C_Map.GetMapArtLayers
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local C_Map_GetWorldPosFromMapPos = C_Map.GetWorldPosFromMapPos
local C_MapExplorationInfo_GetExploredMapTextures = C_MapExplorationInfo.GetExploredMapTextures
local TexturePool_HideAndClearAnchors = TexturePool_HideAndClearAnchors

local mapRects = {}
local tempVec2D = CreateVector2D(0, 0)
local currentMapID, playerCoords, cursorCoords

function module:GetPlayerMapPos(mapID)
	if not mapID then return end
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
	playerCoords = B.CreateFS(WorldMapFrame.BorderFrame.TitleContainer, 14, "", false, "TOPLEFT", 60, -6)
	cursorCoords = B.CreateFS(WorldMapFrame.BorderFrame.TitleContainer, 14, "", false, "TOPLEFT", 180, -6)
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

local shownMapCache, exploredCache, fileDataIDs = {}, {}, {}

local function GetStringFromInfo(info)
	return format("W%dH%dX%dY%d", info.textureWidth, info.textureHeight, info.offsetX, info.offsetY)
end

local function GetShapesFromString(str)
	local w, h, x, y = strmatch(str, "W(%d*)H(%d*)X(%d*)Y(%d*)")
	return tonumber(w), tonumber(h), tonumber(x), tonumber(y)
end

local function RefreshFileIDsByString(str)
	wipe(fileDataIDs)

	for fileID in gmatch(str, "%d+") do
		tinsert(fileDataIDs, fileID)
	end
end

function module:MapData_RefreshOverlays(fullUpdate)
	wipe(shownMapCache)
	wipe(exploredCache)

	local mapID = WorldMapFrame.mapID
	if not mapID then return end

	local mapArtID = C_Map_GetMapArtID(mapID)
	local mapData = mapArtID and module.RawMapData[mapArtID]
	if not mapData then return end

	local exploredMapTextures = C_MapExplorationInfo_GetExploredMapTextures(mapID)
	if exploredMapTextures then
		for _, exploredTextureInfo in pairs(exploredMapTextures) do
			exploredCache[GetStringFromInfo(exploredTextureInfo)] = true
		end
	end

	if not self.layerIndex then
		self.layerIndex = WorldMapFrame.ScrollContainer:GetCurrentLayerIndex()
	end
	local layers = C_Map_GetMapArtLayers(mapID)
	local layerInfo = layers and layers[self.layerIndex]
	if not layerInfo then return end

	local TILE_SIZE_WIDTH = layerInfo.tileWidth
	local TILE_SIZE_HEIGHT = layerInfo.tileHeight

	-- Blizzard_SharedMapDataProviders\MapExplorationDataProvider: MapExplorationPinMixin:RefreshOverlays
	for i, exploredInfoString in pairs(mapData) do
		if not exploredCache[i] then
			local width, height, offsetX, offsetY = GetShapesFromString(i)
			RefreshFileIDsByString(exploredInfoString)
			local numTexturesWide = ceil(width/TILE_SIZE_WIDTH)
			local numTexturesTall = ceil(height/TILE_SIZE_HEIGHT)
			local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight

			for j = 1, numTexturesTall do
				if j < numTexturesTall then
					texturePixelHeight = TILE_SIZE_HEIGHT
					textureFileHeight = TILE_SIZE_HEIGHT
				else
					texturePixelHeight = mod(height, TILE_SIZE_HEIGHT)
					if texturePixelHeight == 0 then
						texturePixelHeight = TILE_SIZE_HEIGHT
					end
					textureFileHeight = 16
					while textureFileHeight < texturePixelHeight do
						textureFileHeight = textureFileHeight * 2
					end
				end
				for k = 1, numTexturesWide do
					local texture = self.overlayTexturePool:Acquire()
					if k < numTexturesWide then
						texturePixelWidth = TILE_SIZE_WIDTH
						textureFileWidth = TILE_SIZE_WIDTH
					else
						texturePixelWidth = width %TILE_SIZE_WIDTH
						if texturePixelWidth == 0 then
							texturePixelWidth = TILE_SIZE_WIDTH
						end
						textureFileWidth = 16
						while textureFileWidth < texturePixelWidth do
							textureFileWidth = textureFileWidth * 2
						end
					end
					texture:SetWidth(texturePixelWidth)
					texture:SetHeight(texturePixelHeight)
					texture:SetTexCoord(0, texturePixelWidth/textureFileWidth, 0, texturePixelHeight/textureFileHeight)
					texture:SetPoint("TOPLEFT", offsetX + (TILE_SIZE_WIDTH * (k-1)), -(offsetY + (TILE_SIZE_HEIGHT * (j - 1))))
					texture:SetTexture(fileDataIDs[((j - 1) * numTexturesWide) + k], nil, nil, "TRILINEAR")

					if C.db["Map"]["MapReveal"] then
						if C.db["Map"]["MapRevealGlow"] then
							texture:SetVertexColor(.7, .7, .7)
						else
							texture:SetVertexColor(1, 1, 1)
						end
						texture:SetDrawLayer("ARTWORK", -1)
						texture:Show()
						if fullUpdate then self.textureLoadGroup:AddTexture(texture) end
					else
						texture:Hide()
					end
					tinsert(shownMapCache, texture)
				end
			end
		end
	end
end

function module:MapData_ResetTexturePool(texture)
	texture:SetVertexColor(1, 1, 1)
	texture:SetAlpha(1)
	return TexturePool_HideAndClearAnchors(self, texture)
end

function module:RemoveMapFog()
	local bu = CreateFrame("CheckButton", nil, WorldMapFrame.BorderFrame.TitleContainer, "OptionsBaseCheckButtonTemplate")
	bu:SetHitRectInsets(-5, -5, -5, -5)
	bu:SetPoint("TOPRIGHT", -270, 0)
	bu:SetSize(26, 26)
	B.ReskinCheck(bu)
	bu:SetChecked(C.db["Map"]["MapReveal"])
	bu.text = B.CreateFS(bu, 14, L["Map Reveal"], false, "LEFT", 25, 0)

	for pin in WorldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
		hooksecurefunc(pin, "RefreshOverlays", module.MapData_RefreshOverlays)
		pin.overlayTexturePool.resetterFunc = module.MapData_ResetTexturePool
	end

	bu:SetScript("OnClick", function(self)
		C.db["Map"]["MapReveal"] = self:GetChecked()

		for i = 1, #shownMapCache do
			shownMapCache[i]:SetShown(C.db["Map"]["MapReveal"])
		end
	end)
end

function module:SetupWorldMap()
	if C.db["Map"]["DisableMap"] then return end
	if IsAddOnLoaded("Mapster") then return end

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
	self:RemoveMapFog()
end

function module:OnLogin()
	self:SetupWorldMap()
	self:SetupMinimap()
end
