local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")
local cfg = C.bars.bar3

function Bar:CreateBar3()
	local padding, margin = 2, 2
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}
	local layout = NDuiDB["Actionbar"]["Style"]
	if layout > 3 then cfg = C.bars.bar2 end

	--create the frame to hold the buttons
	local frame = CreateFrame("Frame", "NDui_ActionBar3", UIParent, "SecureHandlerStateTemplate")
	if layout == 4 then
		frame:SetWidth(num*cfg.size + (num-1)*margin + 2*padding)
		frame:SetHeight(cfg.size + 2*padding)
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 96}
	elseif layout == 5 then
		frame:SetWidth(6*cfg.size + 5*margin + 2*padding)
		frame:SetHeight(2*cfg.size + margin + 2*padding)
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 216, 24}
	else
		frame:SetWidth(19*cfg.size + 17*margin + 2*padding)
		frame:SetHeight(2*cfg.size + margin + 2*padding)
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 26}
	end
	frame:SetScale(NDuiDB["Actionbar"]["Scale"])

	--move the buttons into position and reparent them
	MultiBarBottomRight:SetParent(frame)
	MultiBarBottomRight:EnableMouse(false)

	for i = 1, num do
		local button = _G["MultiBarBottomRightButton"..i]
		table.insert(buttonList, button) --add the button object to the list
		button:SetSize(cfg.size, cfg.size)
		button:ClearAllPoints()
		if i == 1 then
			if layout == 4 then
				button:SetPoint("LEFT", frame, padding, 0)
			else
				button:SetPoint("TOPLEFT", frame, padding, -padding)
			end
		elseif (i == 4 and layout < 4) or (i == 7 and layout == 5) then
			local previous = _G["MultiBarBottomRightButton1"]
			button:SetPoint("TOP", previous, "BOTTOM", 0, -margin)
		elseif i == 7 and layout < 4 then
			local previous = _G["MultiBarBottomRightButton3"]
			button:SetPoint("LEFT", previous, "RIGHT", 13*cfg.size+13*margin, 0)
		elseif i == 10 and layout < 4 then
			local previous = _G["MultiBarBottomRightButton7"]
			button:SetPoint("TOP", previous, "BOTTOM", 0, -margin)
		else
			local previous = _G["MultiBarBottomRightButton"..i-1]
			button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
		end
	end

	--show/hide the frame on a given state driver
	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	--create drag frame and drag functionality
	if C.bars.userplaced then
		B.Mover(frame, SHOW_MULTIBAR2_TEXT, "Bar3", frame.Pos)
	end

	--create the mouseover functionality
	if cfg.fader then
		B.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end

	--fix stupid blizzard
	local function ToggleButtonGrid()
		if InCombatLockdown() then return end
		local showgrid = tonumber(GetCVar("alwaysShowActionBars"))
		for _, button in next, buttonList do
			button:SetAttribute("showgrid", showgrid)
			ActionButton_ShowGrid(button)
		end
	end
	hooksecurefunc("MultiActionBar_UpdateGrid", ToggleButtonGrid)
end