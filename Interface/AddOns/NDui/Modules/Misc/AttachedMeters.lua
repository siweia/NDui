local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local maxMeters = 3 -- MAX_DAMAGE_METER_SESSION_WINDOWS

local options = {
	[1] = {},
	[2] = {},
	[3] = {},
}

local pointData = {
	[1] = {relFrom = "BOTTOM", relTo = "TOP", xOffset = 0, yOffset = 0},
	[2] = {relFrom = "TOP", relTo = "BOTTOM", xOffset = 0, yOffset = 0},
	[3] = {relFrom = "RIGHT", relTo = "LEFT", xOffset = 32, yOffset = 0},
	[4] = {relFrom = "LEFT", relTo = "RIGHT", xOffset = -32, yOffset = 0},
}

local frameIndex = {
	[2] = {0, 1, 3}, -- window2 targets: disable, win1, win3
	[3] = {0, 1, 2}, -- window3 targets: disable, win1, win2
}

local function GetWindowFrame(index)
	local frame
	if index and index > 0 then
		frame = _G["DamageMeterSessionWindow"..index]
	end
	return frame
end

function M:AttachedMeters_UpdateConfig()
	for i = 1, maxMeters do
		local frame = _G["DamageMeterSessionWindow"..i]
		if frame then
			local option = options[i]
			local targetIndex = C.db["Misc"]["W"..i.."Target"]
			local index = frameIndex[i] and frameIndex[i][targetIndex]

			option.width = frame:GetWidth()
			option.height = frame:GetHeight()
			option.attachedTargetIndex = index
			option.attachedTarget = GetWindowFrame(index)
			option.attachedPoint = C.db["Misc"]["W"..i.."Point"]
		end
	end
end

function M:AttachedMeters_Setup()
	if options[2].attachedTargetIndex == 3 and options[3].attachedTargetIndex == 2 then
		UIErrorsFrame:AddMessage(DB.InfoColor..L["AttachedError"])
		return
	end

	for i = 2, maxMeters do
		local frame = _G["DamageMeterSessionWindow"..i]
		if frame then
			local option = options[i]
			local tarOption = options[option.attachedTargetIndex]
			if option.attachedTarget and tarOption then
				if option.attachedPoint > 2 then -- changed the width or height by the attached size
					frame:SetHeight(tarOption.height)
				else
					frame:SetWidth(tarOption.width)
				end
				frame.ResizeButton:StopMovingOrSizing() -- help to remember size and anchor
				frame:ClearAllPoints()
				local anchorInfo = pointData[option.attachedPoint]
				frame:SetPoint(anchorInfo.relFrom, option.attachedTarget, anchorInfo.relTo, anchorInfo.xOffset, anchorInfo.yOffset)
			--	frame:SetLocked(true) -- this taint the duratioSeconds
			end
		end
	end
end

function M:AttachedMeters_Start()
	M:AttachedMeters_UpdateConfig()
	M:AttachedMeters_Setup()
end

local function LoadScript()
	C_Timer.After(2, M.AttachedMeters_Start)
	hooksecurefunc(DamageMeter, "OnEditModeExit", M.AttachedMeters_Start)
end

local function JustWait(event, addon)
	if addon == "Blizzard_DamageMeter" then
		LoadScript()
		B:UnregisterEvent(event, JustWait)
	end
end

function M:AttachedMeters()
	if not C.db["Skins"]["DamageMeter"] then return end

	if C_AddOns.IsAddOnLoaded("Blizzard_DamageMeter") then
		LoadScript()
	else
		B:RegisterEvent("ADDON_LOADED", JustWait)
	end
end
M:RegisterMisc("AttachedMeters", M.AttachedMeters)