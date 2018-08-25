local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")
local cfg = C.bars.stancebar

function Bar:CreateStancebar()
	local padding, margin = 2, 5
	local num = NUM_STANCE_SLOTS
	local NUM_POSSESS_SLOTS = NUM_POSSESS_SLOTS
	local buttonList = {}

	--make a frame that fits the size of all microbuttons
	local frame = CreateFrame("Frame", "NDui_StanceBar", UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(num*cfg.size + (num-1)*margin + 2*padding)
	frame:SetHeight(cfg.size + 2*padding)
	if NDuiDB["Actionbar"]["Style"] ~= 4 then
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", -42, 99}
	else
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", -42, 135}
	end
	frame:SetScale(NDuiDB["Actionbar"]["Scale"])

	--STANCE BAR

	--move the buttons into position and reparent them
	StanceBarFrame:SetParent(frame)
	StanceBarFrame:EnableMouse(false)
	StanceBarLeft:SetTexture(nil)
	StanceBarMiddle:SetTexture(nil)
	StanceBarRight:SetTexture(nil)

	for i = 1, num do
		local button = _G["StanceButton"..i]
		table.insert(buttonList, button) --add the button object to the list
		button:SetSize(cfg.size, cfg.size)
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("BOTTOMLEFT", frame, padding, padding)
		else
			local previous = _G["StanceButton"..i-1]
			button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
		end
	end

	--POSSESS BAR

	--move the buttons into position and reparent them
	PossessBarFrame:SetParent(frame)
	PossessBarFrame:EnableMouse(false)
	PossessBackground1:SetTexture(nil)
	PossessBackground2:SetTexture(nil)

	for i = 1, NUM_POSSESS_SLOTS do
		local button = _G["PossessButton"..i]
		table.insert(buttonList, button) --add the button object to the list
		button:SetSize(cfg.size, cfg.size)
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("BOTTOMLEFT", frame, padding, padding)
		else
			local previous = _G["PossessButton"..i-1]
			button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
		end
	end

	--show/hide the frame on a given state driver
	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	--create drag frame and drag functionality
	if C.bars.userplaced then
		B.Mover(frame, L["StanceBar"], "StanceBar", frame.Pos)
	end

	--create the mouseover functionality
	if cfg.fader then
		B.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end
end