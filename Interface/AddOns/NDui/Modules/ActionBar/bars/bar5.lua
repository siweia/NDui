local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")
local cfg = C.bars.bar5

function Bar:CreateBar5()
	local padding, margin = 2, 2
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}
	local layout = NDuiDB["Actionbar"]["Style"]

	--create the frame to hold the buttons
	local frame = CreateFrame("Frame", "NDui_ActionBar5", UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(cfg.size + 2*padding)
	frame:SetHeight(num*cfg.size + (num-1)*margin + 2*padding)
	if layout == 1 or layout == 4 or layout == 5 then
		frame.Pos = {"RIGHT", UIParent, "RIGHT", -(frame:GetWidth()-1), 0}
	else
		frame.Pos = {"RIGHT", UIParent, "RIGHT", -1, 0}
	end
	frame:SetScale(NDuiDB["Actionbar"]["Scale"])

	--move the buttons into position and reparent them
	MultiBarLeft:SetParent(frame)
	MultiBarLeft:EnableMouse(false)
	hooksecurefunc(MultiBarLeft, "SetScale", function(self, scale)
		if scale < 1 then self:SetScale(1) end
	end)

	for i = 1, num do
		local button = _G["MultiBarLeftButton"..i]
		table.insert(buttonList, button) --add the button object to the list
		button:SetSize(cfg.size, cfg.size)
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("TOPRIGHT", frame, -padding, -padding)
		else
			local previous = _G["MultiBarLeftButton"..i-1]
			button:SetPoint("TOP", previous, "BOTTOM", 0, -margin)
		end
	end

	--show/hide the frame on a given state driver
	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	--create drag frame and drag functionality
	if C.bars.userplaced then
		B.Mover(frame, SHOW_MULTIBAR4_TEXT, "Bar5", frame.Pos)
	end

	--create the mouseover functionality
	if NDuiDB["Actionbar"]["Bar5Fade"] and cfg.fader then
		B.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end
end