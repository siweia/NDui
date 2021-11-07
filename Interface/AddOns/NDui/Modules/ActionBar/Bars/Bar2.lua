local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local _G = _G
local tinsert = tinsert
local cfg = C.Bars.bar2
local margin = C.Bars.margin

function Bar:CreateBar2()
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}

	local frame = CreateFrame("Frame", "NDui_ActionBar2", UIParent, "SecureHandlerStateTemplate")
	frame.mover = B.Mover(frame, L["Actionbar"].."2", "Bar2", {"BOTTOM", _G.NDui_ActionBar1, "TOP", 0, -margin})
	Bar.movers[2] = frame.mover

	MultiBarBottomLeft:SetParent(frame)
	MultiBarBottomLeft:EnableMouse(false)
	MultiBarBottomLeft.QuickKeybindGlow:SetTexture("")

	for i = 1, num do
		local button = _G["MultiBarBottomLeftButton"..i]
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