local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local _G = getfenv(0)
local UIParent = _G.UIParent
local GroupLootContainer = _G.GroupLootContainer

local POSITION, YOFFSET = "TOP", -10
local parentFrame

function M:GroupLootContainer_UpdateAnchor()
	local y = select(2, parentFrame:GetCenter())
	local screenHeight = UIParent:GetTop()
	if y > screenHeight/2 then
		POSITION = "TOP"
		YOFFSET = -10
	else
		POSITION = "BOTTOM"
		YOFFSET = 10
	end

	GroupLootContainer:ClearAllPoints()
	GroupLootContainer:SetPoint(POSITION, parentFrame)
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

function M:AlertFrame_Setup()
	parentFrame = CreateFrame("Frame", nil, UIParent)
	parentFrame:SetSize(200, 30)
	B.Mover(parentFrame, L["AlertFrames"], "AlertFrames", {"TOP", UIParent, 0, -40})

	GroupLootContainer:EnableMouse(false)
	GroupLootContainer.ignoreFramePositionManager = true

	M:GroupLootContainer_UpdateAnchor()
	hooksecurefunc("GroupLootFrame_OpenNewFrame", M.GroupLootContainer_UpdateAnchor)
	hooksecurefunc("GroupLootContainer_Update", M.UpdatGroupLootContainer)
end
M:RegisterMisc("AlertFrame", M.AlertFrame_Setup)