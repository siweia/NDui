local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local IsUsableAction = _G.IsUsableAction
local IsActionInRange = _G.IsActionInRange
local ActionHasRange = _G.ActionHasRange
local TOOLTIP_UPDATE_TIME = TOOLTIP_UPDATE_TIME or .2

local rangeTimer = -1
local updater = CreateFrame("Frame")

function Bar:RangeUpdate()
	if self.__faderParent and self:GetEffectiveAlpha() < 1 then return end

	local icon = self.icon
	local ID = self.action
	if not ID then return end

	local isUsable, notEnoughMana = IsUsableAction(ID)
	local hasRange = ActionHasRange(ID)
	local inRange = IsActionInRange(ID)

	if isUsable then -- Usable
		if hasRange and inRange == false then -- Out of range
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

local hooked = {}
function Bar:HookOnEnter()
	if hooked[self] then return end

	self:HookScript("OnEnter", Bar.RangeUpdate)
	hooked[self] = true
end

function Bar:OnUpdateRange(elapsed)
	if NDuiDB["Actionbar"]["Enable"] then
		rangeTimer = rangeTimer - elapsed
		if rangeTimer <= 0 then
			for _, button in next, Bar.activeButtons do
				Bar.RangeUpdate(button)
				Bar.HookOnEnter(button)
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