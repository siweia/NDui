local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local _G = getfenv(0)
local next = _G.next
local HasAction = _G.HasAction
local IsUsableAction = _G.IsUsableAction
local IsActionInRange = _G.IsActionInRange
local TOOLTIP_UPDATE_TIME = TOOLTIP_UPDATE_TIME or .2

local rangeTimer = -1
local updater = CreateFrame("Frame")

function Bar:RangeUpdate()
	if self.__faderParent and self:GetEffectiveAlpha() < 1 then return end

	local icon = self.icon
	local action = self.action
	if not action then return end

	local isUsable, notEnoughMana = IsUsableAction(action)
	local inRange = IsActionInRange(action)

	if isUsable then -- Usable
		if inRange == false then -- Out of range
			icon:SetVertexColor(.8, .1, .1)
		else -- In range
			icon:SetVertexColor(1, 1, 1)
		end
	elseif notEnoughMana then -- Not enough power
		icon:SetVertexColor(.5, .5, 1)
	else -- Not usable
		icon:SetVertexColor(.3, .3, .3)
	end
end

function Bar:HookOnEnter()
	for _, button in next, Bar.activeButtons do
		button:HookScript("OnEnter", Bar.RangeUpdate)
	end
end

function Bar:OnUpdateRange(elapsed)
	if NDuiDB["Actionbar"]["Enable"] then
		rangeTimer = rangeTimer - elapsed
		if rangeTimer <= 0 then
			for _, button in next, Bar.activeButtons do
				local action = button.action
				if action and button:IsVisible() and HasAction(action) then
					Bar.RangeUpdate(button)
				end
			end
			rangeTimer = TOOLTIP_UPDATE_TIME
		end
	else
		self:SetScript("OnUpdate", nil)
	end
end
updater:SetScript("OnUpdate", Bar.OnUpdateRange)

function Bar:ResetRangeTimer()
	if NDuiDB["Actionbar"]["Enable"] then
		rangeTimer = -1
	else
		B:UnregisterEvent("PLAYER_TARGET_CHANGED", Bar.ResetRangeTimer)
	end
end
B:RegisterEvent("PLAYER_TARGET_CHANGED", Bar.ResetRangeTimer)