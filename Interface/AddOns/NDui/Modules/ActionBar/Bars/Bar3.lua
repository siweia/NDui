local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local _G = _G
local tinsert = tinsert
local cfg = C.Bars.bar3
local margin, padding = C.Bars.margin, C.Bars.padding

function Bar:CreateBar3()
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}

	local frame = CreateFrame("Frame", "NDui_ActionBar3", UIParent, "SecureHandlerStateTemplate")
	frame.mover = B.Mover(frame, L["Actionbar"].."3L", "Bar3L", {"RIGHT", _G.NDui_ActionBar1, "TOPLEFT", -margin, -padding/2})
	local child = CreateFrame("Frame", nil, frame)
	child:SetSize(1, 1)
	child.mover = B.Mover(child, L["Actionbar"].."3R", "Bar3R", {"LEFT", _G.NDui_ActionBar1, "TOPRIGHT", margin, -padding/2})
	frame.child = child

	Bar.movers[3] = frame.mover
	Bar.movers[4] = child.mover

	MultiBarBottomRight:SetParent(frame)
	MultiBarBottomRight:EnableMouse(false)

	for i = 1, num do
		local button = _G["MultiBarBottomRightButton"..i]
		tinsert(buttonList, button)
		tinsert(Bar.buttons, button)
	end
	frame.buttons = buttonList

	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	if cfg.fader then
		Bar.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end
end