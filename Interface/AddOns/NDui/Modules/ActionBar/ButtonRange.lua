local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

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

function Bar:OnUpdateRange(elapsed)
	self.elapsed = (self.elapsed or UPDATE_DELAY) - elapsed
	if self.elapsed <= 0 then
		self.elapsed = UPDATE_DELAY

		if not Bar:UpdateButtons() then
			self:Hide()
		end
	end
end
updater:SetScript("OnUpdate", Bar.OnUpdateRange)

function Bar:UpdateButtons()
	if next(buttonsToUpdate) then
		for button in pairs(buttonsToUpdate) do
			self.UpdateButtonUsable(button)
		end
		return true
	end

	return false
end

function Bar:UpdateButtonStatus()
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

function Bar:UpdateButtonUsable(force)
	if force then
		buttonColors[self] = nil
	end

	local action = self.action
	local isUsable, notEnoughMana = IsUsableAction(action)

	if isUsable then
		local inRange = IsActionInRange(action)
		if inRange == false then
			Bar.SetButtonColor(self, "oor")
		else
			Bar.SetButtonColor(self, "normal")
		end
	elseif notEnoughMana then
		Bar.SetButtonColor(self, "oom")
	else
		Bar.SetButtonColor(self, "unusable")
	end
end

function Bar:SetButtonColor(colorIndex)
	if buttonColors[self] == colorIndex then return end
	buttonColors[self] = colorIndex

	local r, g, b = unpack(colors[colorIndex])
	self.icon:SetVertexColor(r, g, b)
end

function Bar:Register()
	self:HookScript("OnShow", Bar.UpdateButtonStatus)
	self:HookScript("OnHide", Bar.UpdateButtonStatus)
	self:SetScript("OnUpdate", nil)
	Bar.UpdateButtonStatus(self)
end

local function button_UpdateUsable(button)
	Bar.UpdateButtonUsable(button, true)
end

function Bar:RegisterButtonRange(button)
	if button.Update then
		Bar.Register(button)
		hooksecurefunc(button, "Update", Bar.UpdateButtonStatus)
		hooksecurefunc(button, "UpdateUsable", button_UpdateUsable)
	end
end