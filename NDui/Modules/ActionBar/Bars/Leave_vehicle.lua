local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local _G = _G
local tinsert = tinsert
local UnitOnTaxi, TaxiRequestEarlyLanding, VehicleExit = UnitOnTaxi, TaxiRequestEarlyLanding, VehicleExit
local padding = C.Bars.padding

function Bar:UpdateVehicleButton()
	local frame = _G["NDui_ActionBarExit"]
	if not frame then return end

	local size = C.db["Actionbar"]["VehButtonSize"]
	local framSize = size + 2*padding
	frame.buttons[1]:SetSize(size, size)
	frame:SetSize(framSize, framSize)
	frame.mover:SetSize(framSize, framSize)
end

function Bar:CreateLeaveVehicle()
	local buttonList = {}

	local frame = CreateFrame("Frame", "NDui_ActionBarExit", UIParent, "SecureHandlerStateTemplate")
	frame.mover = B.Mover(frame, L["LeaveVehicle"], "LeaveVehicle", {"BOTTOM", UIParent, "BOTTOM", 320, 100})

	local button = CreateFrame("CheckButton", "NDui_LeaveVehicleButton", frame, "ActionButtonTemplate, SecureHandlerClickTemplate")
	tinsert(buttonList, button)
	button:SetPoint("BOTTOMLEFT", frame, padding, padding)
	button:RegisterForClicks("AnyUp")
	button.icon:SetTexture("INTERFACE\\VEHICLES\\UI-Vehicles-Button-Exit-Up")
	button.icon:SetTexCoord(.216, .784, .216, .784)
	button.icon:SetDrawLayer("ARTWORK")
	button.icon.__lockdown = true

	button:SetScript("OnEnter", MainMenuBarVehicleLeaveButton_OnEnter)
	button:SetScript("OnLeave", B.HideTooltip)
	button:SetScript("OnClick", function(self)
		if UnitOnTaxi("player") then
			TaxiRequestEarlyLanding()
		else
			VehicleExit()
		end
		self:SetChecked(true)
	end)
	button:SetScript("OnShow", function(self)
		self:SetChecked(false)
	end)

	frame.buttons = buttonList

	frame.frameVisibility = "[canexitvehicle]c;[mounted]m;n"
	RegisterStateDriver(frame, "exit", frame.frameVisibility)

	frame:SetAttribute("_onstate-exit", [[ if CanExitVehicle() then self:Show() else self:Hide() end ]])
	if not CanExitVehicle() then frame:Hide() end
end