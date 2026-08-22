local _, ns = ...
local B = ns[1]
local C = ns[2]
local TT = B:GetModule("Tooltip")

local mapTooltip
local activePoiInfo
local originalTryShowTooltip
local installed

-- Keep this in sync with Blizzard_FrameXMLUtil/AreaPoiUtil.lua.
local function TryShowTooltip(region, anchor, poiInfo, customFn)
	if not poiInfo.tooltipWidgetSet then
		return originalTryShowTooltip(region, anchor, poiInfo, customFn)
	end

	local hasDescription = poiInfo.description and poiInfo.description ~= ""
	local isTimed, hideTimer = C_AreaPoiInfo.IsAreaPOITimed(poiInfo.areaPoiID)
	local showTimer = not poiInfo.forceHideTimer and (poiInfo.secondsLeft or (isTimed and not hideTimer))
	local hasWidgetSet = poiInfo.tooltipWidgetSet ~= nil

	local hasTooltip = hasDescription or showTimer or hasWidgetSet
	local addedTooltipLine = false

	if hasTooltip then
		local verticalPadding

		activePoiInfo = poiInfo
		mapTooltip:SetOwner(region, anchor)
		if region:HasDisplayName() then
			GameTooltip_SetTitle(mapTooltip, region:GetDisplayName(), HIGHLIGHT_FONT_COLOR)
			addedTooltipLine = true
		end

		if hasDescription then
			GameTooltip_AddNormalLine(mapTooltip, poiInfo.description)
			addedTooltipLine = true
		end

		if showTimer then
			local secondsLeft = poiInfo.secondsLeft or C_AreaPoiInfo.GetAreaPOISecondsLeft(poiInfo.areaPoiID)
			if secondsLeft and secondsLeft > 0 then
				local timeString = SecondsToTime(secondsLeft)
				timeString = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(timeString)
				GameTooltip_AddNormalLine(mapTooltip, MAP_TOOLTIP_TIME_LEFT:format(timeString))
				addedTooltipLine = true
			end
		end

		if poiInfo.textureKit == "OribosGreatVault" then
			GameTooltip_AddBlankLineToTooltip(mapTooltip)
			GameTooltip_AddInstructionLine(mapTooltip, ORIBOS_GREAT_VAULT_POI_TOOLTIP_INSTRUCTIONS, false)
			addedTooltipLine = true
		end

		if hasWidgetSet then
			local padding = addedTooltipLine and poiInfo.addPaddingAboveTooltipWidgets and 10
			local overflow = GameTooltip_AddWidgetSet(mapTooltip, poiInfo.tooltipWidgetSet, padding)
			if overflow then
				verticalPadding = -overflow
			end
		end

		if poiInfo.textureKit then
			local backdropStyle = GAME_TOOLTIP_TEXTUREKIT_BACKDROP_STYLES[poiInfo.textureKit]
			if backdropStyle then
				SharedTooltip_SetBackdropStyle(mapTooltip, backdropStyle)
			end
		end

		if customFn then
			customFn(mapTooltip)
		end

		mapTooltip:Show()

		if verticalPadding then
			mapTooltip:SetPadding(0, verticalPadding)
		end

		return true
	end

	return false
end

local function OnTooltipUpdate(self, elapsed)
	local owner = self:GetOwner()
	if not owner or not owner:GetMap() or owner.poiInfo ~= activePoiInfo then
		self:Hide()
		return
	end

	GameTooltip_OnUpdate(self, elapsed)
end

local function GetUnprotectedFunctionEnvironment(func)
	if type(func) ~= "function" then return end

	local success, environment = pcall(getfenv, func)
	if not success or type(environment) ~= "table" then return end

	local environmentMeta = getmetatable(environment)
	if environmentMeta ~= nil and (type(environmentMeta) ~= "table" or environmentMeta.__environment ~= nil) then return end

	return environment
end

local function InstallFix()
	if installed then return end

	local tryShowTooltip = AreaPOIPinMixin and AreaPOIPinMixin.TryShowTooltip
	local onMouseLeave = AreaPOIPinMixin and AreaPOIPinMixin.OnMouseLeave
	if not tryShowTooltip or not onMouseLeave then return end

	local tryShowEnv = GetUnprotectedFunctionEnvironment(tryShowTooltip)
	local onMouseLeaveEnv = GetUnprotectedFunctionEnvironment(onMouseLeave)
	if not tryShowEnv or not onMouseLeaveEnv then return end

	local originalAreaPoiUtil = tryShowEnv.AreaPoiUtil
	if type(originalAreaPoiUtil) ~= "table" or type(originalAreaPoiUtil.TryShowTooltip) ~= "function" then return end

	local areaPoiUtil = setmetatable({TryShowTooltip = TryShowTooltip}, {__index = originalAreaPoiUtil})
	local getAppropriateTooltip = onMouseLeaveEnv.GetAppropriateTooltip
	if type(getAppropriateTooltip) ~= "function" then return end

	local hideTooltips = {
		Hide = function()
			mapTooltip:Hide()
			getAppropriateTooltip():Hide()
		end,
	}
	local newTryShowEnv = setmetatable({AreaPoiUtil = areaPoiUtil}, {__index = tryShowEnv})
	local newOnMouseLeaveEnv = setmetatable({
		GetAppropriateTooltip = function()
			return hideTooltips
		end,
	}, {__index = onMouseLeaveEnv})

	if not pcall(setfenv, tryShowTooltip, newTryShowEnv) then return end
	if not pcall(setfenv, onMouseLeave, newOnMouseLeaveEnv) then
		pcall(setfenv, tryShowTooltip, tryShowEnv)
		return
	end

	originalTryShowTooltip = originalAreaPoiUtil.TryShowTooltip
	installed = true
end

local function OnAddOnLoaded(_, addonName)
	if addonName ~= "Blizzard_SharedMapDataProviders" then return end

	InstallFix()
	B:UnregisterEvent("ADDON_LOADED", OnAddOnLoaded)
end

function TT:SetupMapPOITooltip()
	if C.db["Tooltip"]["DisableMapPOITooltipFix"] then return end
	if C_AddOns.IsAddOnLoaded("!MapTooltipTaintFix") then return end

	mapTooltip = CreateFrame("GameTooltip", "NDuiMapPOITooltip", UIParent, "GameTooltipTemplate")
	mapTooltip:SetScript("OnShow", GameTooltip_OnShow)
	mapTooltip:SetScript("OnUpdate", OnTooltipUpdate)
	mapTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	mapTooltip:SetText(" ")
	mapTooltip:Show()
	mapTooltip:Hide()

	if AreaPOIPinMixin then
		InstallFix()
	else
		B:RegisterEvent("ADDON_LOADED", OnAddOnLoaded)
	end
end
