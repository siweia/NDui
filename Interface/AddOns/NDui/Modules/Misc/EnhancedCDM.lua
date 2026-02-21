local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

-- Centralized BuffIconCooldownViewer
local activeButtons = {}
local lastVisible = 0

local function GetButtonSpacing(frame)
	return frame.iconPadding + frame:GetAdditionalPaddingOffset()
end

function M:CDM_RefreshBuffsAnchor()
	if not C.db["Misc"]["CentralBuffView"] then return end

	local cooldownViewer = BuffIconCooldownViewer
	if not cooldownViewer.hideWhenInactive then return end

	local numVisible = 0
	for itemFrame in cooldownViewer.itemFramePool:EnumerateActive() do
		if itemFrame.Icon and itemFrame:IsShown() then
			numVisible = numVisible + 1
			activeButtons[numVisible] = itemFrame
		end
	end
	for i = numVisible + 1, #activeButtons do
		if activeButtons[i] then
			activeButtons[i] = nil
		end
	end

	if numVisible == lastVisible then return end
	lastVisible = numVisible
	if numVisible == 0 then return end

	local buttonWidth = activeButtons[1]:GetWidth() or 32
	local spacing = GetButtonSpacing(cooldownViewer)
	local step = buttonWidth + spacing
	local totalWidth = (buttonWidth * numVisible) + (spacing * (numVisible - 1))
	local startX = (cooldownViewer:GetWidth() - totalWidth) / 2

	for i = 1, #activeButtons do
		local button = activeButtons[i]
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", cooldownViewer, "TOPLEFT", startX + ((i - 1) * step), 0)
	end
end

local function delayAnhor()
	C_Timer.After(0, M.CDM_RefreshBuffsAnchor) -- magic: refresh anchor after blizzard re-generated
end

local function hookButtons(self)
	for itemFrame in self.itemFramePool:EnumerateActive() do
		if itemFrame.Icon and not itemFrame.hooked then
			hooksecurefunc(itemFrame, "OnActiveStateChanged", delayAnhor)
			itemFrame.hooked = true
		end
	end
end

local function Handle_BuffIconCooldownViewer()
	if not BuffIconCooldownViewer then return end
	hooksecurefunc(BuffIconCooldownViewer, "RefreshLayout", hookButtons)
end

-- Centralized UtilityCooldownViewer
local buttonList = {}
function M:CDM_RefreshGrid()
	if not C.db["Misc"]["CentralUtilView"] then return end

	wipe(buttonList)
	local iconsPerRow = self.stride
	local isHorizontal = self.isHorizontal

	for itemFrame in self.itemFramePool:EnumerateActive() do
		if itemFrame:IsShown() then
			buttonList[itemFrame.layoutIndex] = itemFrame
		end
	end
	local numButtons = #buttonList
	if numButtons == 0 then return end

	local spacing = GetButtonSpacing(self)
	local leftover = numButtons % iconsPerRow
	if leftover == 0 then leftover = iconsPerRow end
	local frameSize = isHorizontal and self:GetWidth() or self:GetHeight()
	local buttonSize = isHorizontal and buttonList[1]:GetWidth() or buttonList[1]:GetHeight()
	local leftoverSize = buttonSize * leftover + (spacing * (leftover - 1))
	local centerOffset = (frameSize - leftoverSize) / 2

	for i = 1, numButtons do
		local button = buttonList[i]
		local row = floor((i - 1) / iconsPerRow)
		local col = (i - 1) % iconsPerRow
		local xOffset
		if i > numButtons - leftover and leftover < iconsPerRow then -- 最后一行，需要居中
			xOffset = centerOffset + col * (buttonSize + spacing)
		else
			xOffset = col * (buttonSize + spacing)
		end
		local yOffset = -row * (buttonSize + spacing)

		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", self, "TOPLEFT", isHorizontal and xOffset or (yOffset * -1), isHorizontal and yOffset or (xOffset * -1))
	end
end

local function Handle_UtilityCooldownViewer()
	if not UtilityCooldownViewer then return end
	hooksecurefunc(UtilityCooldownViewer, "RefreshLayout", M.CDM_RefreshGrid)
end

local function LoadScript()
	Handle_BuffIconCooldownViewer()
	Handle_UtilityCooldownViewer()
end

local function JustWait(event, addon)
	if addon == "Blizzard_CooldownViewer" then
		LoadScript()
		B:UnregisterEvent(event, JustWait)
	end
end

function M:EnhancedCDM()
	if not C.db["Skins"]["CooldownMgr"] then return end

	if C_AddOns.IsAddOnLoaded("Blizzard_CooldownViewer") then
		LoadScript()
	else
		B:RegisterEvent("ADDON_LOADED", JustWait)
	end
end
M:RegisterMisc("EnhancedCDM", M.EnhancedCDM)