local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local IsUsableAction = _G.IsUsableAction
local IsActionInRange = _G.IsActionInRange
local ActionHasRange = _G.ActionHasRange

function Bar:RangeOnUpdate()
	if not self.rangeTimer then return end

	if self.rangeTimer == TOOLTIP_UPDATE_TIME then
		Bar.RangeUpdate(self)
	end
end

function Bar:RangeUpdate()
	if NDuiDB["Actionbar"]["Enable"] then
		local bar = self:GetParent():GetParent()
		if bar and bar:GetAlpha() < 1 then return end
	end

	local icon = self.icon
	local normalTexture = self.NormalTexture
	local ID = self.action
	if not ID then return end

	local IsUsable, NotEnoughMana = IsUsableAction(ID)
	local HasRange = ActionHasRange(ID)
	local InRange = IsActionInRange(ID)

	if IsUsable then -- Usable
		if HasRange and InRange == false then -- Out of range
			icon:SetVertexColor(.9, .1, .1)
			normalTexture:SetVertexColor(.9, .1, .1)
		else -- In range
			icon:SetVertexColor(1, 1, 1)
			normalTexture:SetVertexColor(1, 1, 1)
		end
	elseif NotEnoughMana then -- Not enough power
		icon:SetVertexColor(.3, .3, 1)
		normalTexture:SetVertexColor(.3, .3, 1)
	else -- Not usable
		icon:SetVertexColor(.3, .3, .3)
		normalTexture:SetVertexColor(.3, .3, .3)
	end
end

hooksecurefunc("ActionButton_OnUpdate", Bar.RangeOnUpdate)
hooksecurefunc("ActionButton_Update", Bar.RangeUpdate)
hooksecurefunc("ActionButton_UpdateUsable", Bar.RangeUpdate)