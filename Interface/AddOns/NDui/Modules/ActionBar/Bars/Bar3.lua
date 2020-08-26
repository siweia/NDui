local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local _G = _G
local tinsert = tinsert
local cfg = C.bars.bar3
local margin, padding = C.bars.margin, C.bars.padding

local function SetFrameSize(frame, size, num)
	size = size or frame.buttonSize
	num = num or frame.numButtons

	local layout = NDuiDB["Actionbar"]["Style"]
	if layout == 4 then
		frame:SetWidth(num*size + (num-1)*margin + 2*padding)
		frame:SetHeight(size + 2*padding)
	elseif layout == 5 then
		frame:SetWidth(6*size + 5*margin + 2*padding)
		frame:SetHeight(2*size + margin + 2*padding)
	else
		frame:SetWidth(19*size + 17*margin + 2*padding)
		frame:SetHeight(2*size + margin + 2*padding)
	end

	if layout < 4 then
		local button = _G["MultiBarBottomRightButton7"]
		button:SetPoint("TOPRIGHT", frame, -2*(size+margin) - padding, -padding)
	end

	if not frame.mover then
		frame.mover = B.Mover(frame, SHOW_MULTIBAR2_TEXT, "Bar3", frame.Pos)
	else
		frame.mover:SetSize(frame:GetSize())
	end

	if not frame.SetFrameSize then
		frame.buttonSize = size
		frame.numButtons = num
		frame.SetFrameSize = SetFrameSize
	end
end

function Bar:CreateBar3()
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}
	local layout = NDuiDB["Actionbar"]["Style"]
	if layout > 3 then cfg = C.bars.bar2 end

	local frame = CreateFrame("Frame", "NDui_ActionBar3", UIParent, "SecureHandlerStateTemplate")
	if layout == 4 then
		frame.Pos = {"BOTTOM", _G.NDui_ActionBar2, "TOP", 0, -margin}
	elseif layout == 5 then
		frame.Pos = {"LEFT", _G.NDui_ActionBar1, "TOPRIGHT", -margin, -margin/2}
	else
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 26}
	end

	MultiBarBottomRight:SetParent(frame)
	MultiBarBottomRight:EnableMouse(false)

	for i = 1, num do
		local button = _G["MultiBarBottomRightButton"..i]
		tinsert(buttonList, button)
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("TOPLEFT", frame, padding, -padding)
		elseif (i == 4 and layout < 4) or (i == 7 and layout == 5) then
			local previous = _G["MultiBarBottomRightButton1"]
			button:SetPoint("TOP", previous, "BOTTOM", 0, -margin)
		elseif i == 7 and layout < 4 then
			button:SetPoint("TOPRIGHT", frame, -2*(cfg.size+margin) - padding, -padding)
		elseif i == 10 and layout < 4 then
			local previous = _G["MultiBarBottomRightButton7"]
			button:SetPoint("TOP", previous, "BOTTOM", 0, -margin)
		else
			local previous = _G["MultiBarBottomRightButton"..i-1]
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