local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local activeButtons = {}
local lastVisible = 0

local function GetButtonSpacing(frame)
	return frame.iconPadding + frame:GetAdditionalPaddingOffset()
end

function M:CDM_RefreshBuffsAnchor()
	if not C.db["Misc"]["CentralCDM"] then return end

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

local function LoadScript()
	Handle_BuffIconCooldownViewer()
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