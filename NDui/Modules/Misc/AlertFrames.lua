local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local _G = getfenv(0)
local ipairs = ipairs
local UIParent = _G.UIParent
local AlertFrame = _G.AlertFrame
local GroupLootContainer = _G.GroupLootContainer

local POSITION, ANCHOR_POINT, YOFFSET = "TOP", "BOTTOM", -10
local parentFrame

function M:CalculateAlertAnchor()
	local y = select(2, parentFrame:GetCenter())
	local screenHeight = UIParent:GetTop()
	if y > screenHeight/2 then
		POSITION = "TOP"
		ANCHOR_POINT = "BOTTOM"
		YOFFSET = -10
	else
		POSITION = "BOTTOM"
		ANCHOR_POINT = "TOP"
		YOFFSET = 10
	end
end

function M:AlertFrame_UpdateAnchor()
	M:CalculateAlertAnchor()

	self:ClearAllPoints()
	self:SetPoint(POSITION, parentFrame)
end

function M:GroupLootContainer_UpdateAnchor()
	M:CalculateAlertAnchor()

	GroupLootContainer:ClearAllPoints()
	GroupLootContainer:SetPoint(POSITION, parentFrame)
	if GroupLootContainer:IsShown() then
		M.UpdatGroupLootContainer(GroupLootContainer)
	end
end

function M:UpdatGroupLootContainer()
	local lastIdx = nil

	for i = 1, self.maxIndex do
		local frame = self.rollFrames[i]
		if frame then
			frame:ClearAllPoints()
			frame:SetPoint("CENTER", self, POSITION, 0, self.reservedSize * (i-1 + 0.5) * YOFFSET/10)
			lastIdx = i
		end
	end

	if lastIdx then
		self:SetHeight(self.reservedSize * lastIdx)
		self:Show()
	else
		self:Hide()
	end
end

function M:AlertFrame_SetPoint(relativeAlert)
	self:ClearAllPoints()
	self:SetPoint(POSITION, relativeAlert, ANCHOR_POINT, 0, YOFFSET)
end

function M:AlertFrame_AdjustQueuedAnchors(relativeAlert)
	for alertFrame in self.alertFramePool:EnumerateActive() do
		M.AlertFrame_SetPoint(alertFrame, relativeAlert)
		relativeAlert = alertFrame
	end

	return relativeAlert
end

function M:AlertFrame_AdjustAnchors(relativeAlert)
	if self.alertFrame:IsShown() then
		M.AlertFrame_SetPoint(self.alertFrame, relativeAlert)
		return self.alertFrame
	end

	return relativeAlert
end

function M:AlertFrame_AdjustAnchorsNonAlert(relativeAlert)
	if self.anchorFrame:IsShown() then
		M.AlertFrame_SetPoint(self.anchorFrame, relativeAlert)
		return self.anchorFrame
	end

	return relativeAlert
end

function M:AlertFrame_AdjustPosition()
	if self.alertFramePool then
		self.AdjustAnchors = M.AlertFrame_AdjustQueuedAnchors
	elseif not self.anchorFrame then
		self.AdjustAnchors = M.AlertFrame_AdjustAnchors
	elseif self.anchorFrame then
		self.AdjustAnchors = M.AlertFrame_AdjustAnchorsNonAlert
	end
end

function M:AlertFrame_Setup()
	parentFrame = CreateFrame("Frame", nil, UIParent)
	parentFrame:SetSize(200, 30)
	B.Mover(parentFrame, L["AlertFrames"], "AlertFrames", {"TOP", UIParent, 0, -40})

	GroupLootContainer:EnableMouse(false)
	GroupLootContainer.ignoreFramePositionManager = true

	for _, alertFrameSubSystem in ipairs(AlertFrame.alertFrameSubSystems) do
		M.AlertFrame_AdjustPosition(alertFrameSubSystem)
	end

	hooksecurefunc(AlertFrame, "AddAlertFrameSubSystem", function(_, alertFrameSubSystem)
		M.AlertFrame_AdjustPosition(alertFrameSubSystem)
	end)

	hooksecurefunc(AlertFrame, "UpdateAnchors", M.AlertFrame_UpdateAnchor)

	M:GroupLootContainer_UpdateAnchor()
	hooksecurefunc("GroupLootFrame_OpenNewFrame", M.GroupLootContainer_UpdateAnchor)
	hooksecurefunc("GroupLootContainer_Update", M.UpdatGroupLootContainer)
end
M:RegisterMisc("AlertFrame", M.AlertFrame_Setup)