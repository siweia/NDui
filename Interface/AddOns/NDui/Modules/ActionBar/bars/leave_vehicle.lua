local B, C, L, DB = unpack(select(2, ...))
local Bar = NDui:GetModule("Actionbar")
local cfg = C.bars.leave_vehicle
local padding, margin = 10, 5

function Bar:CreateLeaveVehicle()
	local num = 1
	local buttonList = {}

	--create the frame to hold the buttons
	local frame = CreateFrame("Frame", "NDui_LeaveVehicleBar", UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(num*cfg.size + (num-1)*margin + 2*padding)
	frame:SetHeight(cfg.size + 2*padding)
	if NDuiDB["Actionbar"]["Style"] == 3 then
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 130}
	else
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 320, 100}
	end
	frame:SetScale(cfg.scale)

	--the button
	local button = CreateFrame("Button", "NDui_LeaveVehicleButton", frame)
	table.insert(buttonList, button) --add the button object to the list
	button:SetSize(cfg.size, cfg.size)
	button:SetPoint("BOTTOMLEFT", frame, padding, padding)
	button:RegisterForClicks("AnyUp")
	button:SetNormalTexture("INTERFACE\\PLAYERACTIONBARALT\\NATURAL")
	button:SetPushedTexture("INTERFACE\\PLAYERACTIONBARALT\\NATURAL")
	button:SetHighlightTexture("INTERFACE\\PLAYERACTIONBARALT\\NATURAL")
	local nt = button:GetNormalTexture()
	local pu = button:GetPushedTexture()
	local hi = button:GetHighlightTexture()
	nt:SetTexCoord(.0859375, .1679688, .359375, .4414063)
	pu:SetTexCoord(.001953125, .08398438, .359375, .4414063)
	hi:SetTexCoord(.6152344, .6972656, .359375, .4414063)
	hi:SetBlendMode("ADD")

	-- leave the taxi/vehicle
	local function UpdateVisible()
		if CanExitVehicle() then
			button:Show()
			button:GetNormalTexture():SetVertexColor(1, 1, 1)
			button:EnableMouse(true)
		else
			button:Hide()
		end
	end
	button:SetScript("OnClick", function(self)
		if UnitOnTaxi("player") then
			TaxiRequestEarlyLanding()
			self:GetNormalTexture():SetVertexColor(1, 0, 0)
			self:EnableMouse(false)
		else
			VehicleExit()
		end
	end)
	button:SetScript("OnEnter", MainMenuBarVehicleLeaveButton_OnEnter)
	button:SetScript("OnLeave", GameTooltip_Hide)
	hooksecurefunc("MainMenuBarVehicleLeaveButton_Update", UpdateVisible)

	--frame is visibile when no vehicle ui is visible
	frame.frameVisibility = "[petbattle] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	--create drag frame and drag functionality
	if C.bars.userplaced then
		B.Mover(frame, L["LeaveVehicle"], "LeaveVehicle", frame.Pos)
	end

	--create the mouseover functionality
	if cfg.fader then
		NDui.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end
end