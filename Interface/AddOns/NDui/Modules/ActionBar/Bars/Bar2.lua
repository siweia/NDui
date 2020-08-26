local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local _G = _G
local tinsert = tinsert
local cfg = C.bars.bar2
local margin, padding = C.bars.margin, C.bars.padding

local function SetFrameSize(frame, size, num)
	size = size or frame.buttonSize
	num = num or frame.numButtons

	frame:SetWidth(num*size + (num-1)*margin + 2*padding)
	frame:SetHeight(size + 2*padding)
	if not frame.mover then
		frame.mover = B.Mover(frame, SHOW_MULTIBAR1_TEXT, "Bar2", frame.Pos)
	else
		frame.mover:SetSize(frame:GetSize())
	end

	if not frame.SetFrameSize then
		frame.buttonSize = size
		frame.numButtons = num
		frame.SetFrameSize = SetFrameSize
	end
end

function Bar:CreateBar2()
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}
	local layout = NDuiDB["Actionbar"]["Style"]

	local frame = CreateFrame("Frame", "NDui_ActionBar2", UIParent, "SecureHandlerStateTemplate")
	frame.Pos = {"BOTTOM", _G.NDui_ActionBar1, "TOP", 0, -margin}

	MultiBarBottomLeft:SetParent(frame)
	MultiBarBottomLeft:EnableMouse(false)

	for i = 1, num do
		local button = _G["MultiBarBottomLeftButton"..i]
		tinsert(buttonList, button)
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("BOTTOMLEFT", frame, padding, padding)
		else
			local previous = _G["MultiBarBottomLeftButton"..i-1]
			button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
		end
	end

	frame.buttonList = buttonList
	SetFrameSize(frame, cfg.size, num)

	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	if cfg.fader then
		Bar.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end
end