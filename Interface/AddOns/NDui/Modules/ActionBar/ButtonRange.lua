local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:RegisterModule("ButtonRange")

local next, pairs, unpack = next, pairs, unpack
local HasAction, IsUsableAction, IsActionInRange = HasAction, IsUsableAction, IsActionInRange

local UPDATE_DELAY = .2
local buttonColors, buttonsToUpdate = {}, {}
local updater = CreateFrame("Frame")

local colors = {
	["normal"] = {1, 1, 1},
	["oor"] = {.8, .1, .1},
	["oom"] = {.5, .5, 1},
	["unusable"] = {.3, .3, .3}
}

function module:OnUpdateRange(elapsed)
	self.elapsed = (self.elapsed or UPDATE_DELAY) - elapsed
	if self.elapsed <= 0 then
		self.elapsed = UPDATE_DELAY

		if not module:UpdateButtons() then
			self:Hide()
		end
	end
end
updater:SetScript("OnUpdate", module.OnUpdateRange)

function module:UpdateButtons()
	if next(buttonsToUpdate) then
		for button in pairs(buttonsToUpdate) do
			self.UpdateButtonUsable(button)
		end
		return true
	end

	return false
end

function module:UpdateButtonStatus()
	local action = self.action

	if action and self:IsVisible() and HasAction(action) then
		buttonsToUpdate[self] = true
	else
		buttonsToUpdate[self] = nil
	end

	if next(buttonsToUpdate) then
		updater:Show()
	end
end

function module:UpdateButtonUsable(force)
	if force then
		buttonColors[self] = nil
	end

	local action = self.action
	local isUsable, notEnoughMana = IsUsableAction(action)

	if isUsable then
		local inRange = IsActionInRange(action)
		if inRange == false then
			module.SetButtonColor(self, "oor")
		else
			module.SetButtonColor(self, "normal")
		end
	elseif notEnoughMana then
		module.SetButtonColor(self, "oom")
	else
		module.SetButtonColor(self, "unusable")
	end
end

function module:SetButtonColor(colorIndex)
	if buttonColors[self] == colorIndex then return end
	buttonColors[self] = colorIndex

	local r, g, b = unpack(colors[colorIndex])
	self.icon:SetVertexColor(r, g, b)
end

function module:Register()
	self:HookScript("OnShow", module.UpdateButtonStatus)
	self:HookScript("OnHide", module.UpdateButtonStatus)
	self:SetScript("OnUpdate", nil)
	module.UpdateButtonStatus(self)
end

local function button_UpdateUsable(button)
	module.UpdateButtonUsable(button, true)
end

function module:OnLogin()
	hooksecurefunc("ActionButton_OnUpdate", self.Register)
	hooksecurefunc("ActionButton_Update", self.UpdateButtonStatus)
	hooksecurefunc("ActionButton_UpdateUsable", button_UpdateUsable)
end