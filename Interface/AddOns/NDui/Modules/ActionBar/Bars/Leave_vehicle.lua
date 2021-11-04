local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local _G = _G
local tinsert = tinsert
local cfg = C.Bars.leave_vehicle
local margin, padding = C.Bars.margin, C.Bars.padding

function Bar:CreateLeaveVehicle()
	local num = 1
	local size = cfg.size
	local buttonList = {}

	local frame = CreateFrame("Frame", "NDui_ActionBarExit", UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(num*size + (num-1)*margin + 2*padding)
	frame:SetHeight(size + 2*padding)
	frame.mover = B.Mover(frame, L["LeaveVehicle"], "LeaveVehicle", {"BOTTOM", UIParent, "BOTTOM", 320, 100})

	local button = CreateFrame("CheckButton", "NDui_LeaveVehicleButton", frame, "ActionButtonTemplate, SecureHandlerClickTemplate")
	tinsert(buttonList, button)
	button:SetSize(size, size)
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

	if cfg.fader then
		Bar.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end
end