local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local _G = _G
local tinsert = tinsert
local cfg = C.Bars.bar5
local margin, padding = C.Bars.margin, C.Bars.padding

local function SetFrameSize(frame, size, num)
	size = size or frame.buttonSize
	num = num or frame.numButtons

	frame:SetWidth(size + 2*padding)
	frame:SetHeight(num*size + (num-1)*margin + 2*padding)
	if not frame.mover then
		frame.mover = B.Mover(frame, SHOW_MULTIBAR4_TEXT, "Bar5", frame.Pos)
	else
		frame.mover:SetSize(frame:GetSize())
	end

	if not frame.SetFrameSize then
		frame.buttonSize = size
		frame.numButtons = num
		frame.SetFrameSize = SetFrameSize
	end
end

function Bar:CreateBar5()
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}
	local layout = NDuiDB["Actionbar"]["Style"]

	local frame = CreateFrame("Frame", "NDui_ActionBar5", UIParent, "SecureHandlerStateTemplate")
	if layout == 1 or layout == 4 or layout == 5 then
		frame.Pos = {"RIGHT", _G.NDui_ActionBar4, "LEFT", margin, 0}
	else
		frame.Pos = {"RIGHT", UIParent, "RIGHT", -1, 0}
	end

	MultiBarLeft:SetParent(frame)
	MultiBarLeft:EnableMouse(false)

	for i = 1, num do
		local button = _G["MultiBarLeftButton"..i]
		tinsert(buttonList, button)
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("TOPRIGHT", frame, -padding, -padding)
		else
			local previous = _G["MultiBarLeftButton"..i-1]
			button:SetPoint("TOP", previous, "BOTTOM", 0, -margin)
		end
	end

	frame.buttonList = buttonList
	SetFrameSize(frame, cfg.size, num)

	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	if NDuiDB["Actionbar"]["Bar5Fade"] and cfg.fader then
		Bar.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end
end