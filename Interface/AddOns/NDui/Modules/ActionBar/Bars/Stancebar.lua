local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local _G = _G
local tinsert = tinsert
local cfg = C.Bars.stancebar
local margin, padding = C.Bars.margin, C.Bars.padding

local function SetFrameSize(frame, size, num)
	size = size or frame.buttonSize
	num = num or frame.numButtons

	frame:SetWidth(num*size + (num-1)*margin + 2*padding)
	frame:SetHeight(size + 2*padding)
	if not frame.mover then
		frame.mover = B.Mover(frame, L["StanceBar"], "StanceBar", frame.Pos)
	else
		frame.mover:SetSize(frame:GetSize())
	end

	if not frame.SetFrameSize then
		frame.buttonSize = size
		frame.numButtons = num
		frame.SetFrameSize = SetFrameSize
	end
end

function Bar:CreateStancebar()
	local num = NUM_STANCE_SLOTS
	local NUM_POSSESS_SLOTS = NUM_POSSESS_SLOTS
	local buttonList = {}

	local frame = CreateFrame("Frame", "NDui_ActionBarStance", UIParent, "SecureHandlerStateTemplate")
	frame.Pos = {"BOTTOMLEFT", _G.NDui_ActionBar2, "TOPLEFT", 0, margin}
	frame.mover = B.Mover(frame, L["StanceBar"], "StanceBar", frame.Pos)

	-- StanceBar
	if C.db["Actionbar"]["ShowStance"] then
		StanceBarFrame:SetParent(frame)
		StanceBarFrame:EnableMouse(false)
		StanceBarLeft:SetTexture(nil)
		StanceBarMiddle:SetTexture(nil)
		StanceBarRight:SetTexture(nil)

		for i = 1, num do
			local button = _G["StanceButton"..i]
			tinsert(buttonList, button)
			tinsert(Bar.buttons, button)
		end
	end

	-- PossessBar
	PossessBarFrame:SetParent(frame)
	PossessBarFrame:EnableMouse(false)
	PossessBackground1:SetTexture(nil)
	PossessBackground2:SetTexture(nil)

	for i = 1, NUM_POSSESS_SLOTS do
		local button = _G["PossessButton"..i]
		tinsert(buttonList, button)
		button:ClearAllPoints()
		button:SetPoint("CENTER", buttonList[i])
	end

	frame.buttons = buttonList

	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	if cfg.fader then
		Bar.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end
end