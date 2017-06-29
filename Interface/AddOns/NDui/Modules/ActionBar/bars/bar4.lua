local B, C, L, DB = unpack(select(2, ...))
local Bar = NDui:GetModule("Actionbar")
local cfg = C.bars.bar4
local padding, margin = 2, 2

function Bar:CreateBar4()
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}
	local layout = NDuiDB["Actionbar"]["Style"]

	--create the frame to hold the buttons
	local frame = CreateFrame("Frame", "NDui_ActionBar4", UIParent, "SecureHandlerStateTemplate")
	if layout == 1 or layout == 4 then
		frame:SetWidth(cfg.size + 2*padding)
		frame:SetHeight(num*cfg.size + (num-1)*margin + 2*padding)
		frame.Pos = {"RIGHT", UIParent, "RIGHT", -1, 0}
	elseif layout == 2 then
		frame:SetWidth(25*cfg.size + 25*margin + 2*padding)
		frame:SetHeight(2*cfg.size + margin + 2*padding)
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 26}
	elseif layout == 3 then
		frame:SetWidth(4*cfg.size + 3*margin + 2*padding)
		frame:SetHeight(3*cfg.size + 2*margin + 2*padding)
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 395, 26}
	end
	frame:SetScale(cfg.scale)

	--move the buttons into position and reparent them
	MultiBarRight:SetParent(frame)
	MultiBarRight:EnableMouse(false)

	for i = 1, num do
		local button = _G["MultiBarRightButton"..i]
		table.insert(buttonList, button) --add the button object to the list
		button:SetSize(cfg.size, cfg.size)
		button:ClearAllPoints()
		if layout == 1 or layout == 4 then
			if i == 1 then
				button:SetPoint("TOPRIGHT", frame, -padding, -padding)
			else
				local previous = _G["MultiBarRightButton"..i-1]
				button:SetPoint("TOP", previous, "BOTTOM", 0, -margin)
			end
		elseif layout == 2 then
			if i == 1 then
				button:SetPoint("TOPLEFT", frame, padding, -padding)
			elseif i == 4 then
				local previous = _G["MultiBarRightButton1"]
				button:SetPoint("TOP", previous, "BOTTOM", 0, -margin)
			elseif i == 7 then
				local previous = _G["MultiBarRightButton3"]
				button:SetPoint("LEFT", previous, "RIGHT", 19*cfg.size + 21*margin, 0)
			elseif i == 10 then
				local previous = _G["MultiBarRightButton7"]
				button:SetPoint("TOP", previous, "BOTTOM", 0, -margin)
			else
				local previous = _G["MultiBarRightButton"..i-1]
				button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
			end
		elseif layout == 3 then
			if i == 1 then
				button:SetPoint("TOPLEFT", frame, padding, -padding)
			elseif i == 5 or i == 9 then
				local previous = _G["MultiBarRightButton"..i-4]
				button:SetPoint("TOP", previous, "BOTTOM", 0, -margin)
			else
				local previous = _G["MultiBarRightButton"..i-1]
				button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
			end
		end
	end

	--show/hide the frame on a given state driver
	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	--create drag frame and drag functionality
	if C.bars.userplaced then
		B.Mover(frame, SHOW_MULTIBAR3_TEXT, "Bar4", frame.Pos)
	end

	--create the mouseover functionality
	if NDuiDB["Actionbar"]["Bar4Fade"] then
		NDui.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end

	--fix annoying visibility
	local f = NDui:EventFrame({"UNIT_EXITING_VEHICLE", "PET_BATTLE_CLOSE"})
	f:SetScript("OnEvent", function(self, event)
		if event == "PLAYER_REGEN_ENABLED" then
			InterfaceOptions_UpdateMultiActionBars()
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
			self:UnregisterEvent(f.savedEvent)
		else
			if InCombatLockdown() then
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
				f.savedEvent = event
			else
				InterfaceOptions_UpdateMultiActionBars()
			end
		end
	end)
end