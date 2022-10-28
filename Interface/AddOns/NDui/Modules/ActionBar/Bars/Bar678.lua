local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local _G = _G
local tinsert = tinsert
local cfg = C.Bars.bar5
local margin = C.Bars.margin

local function createBar(index, offset)
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}

	local frame = CreateFrame("Frame", "NDui_ActionBar"..index, UIParent, "SecureHandlerStateTemplate")
	frame.mover = B.Mover(frame, L["Actionbar"]..index, "Bar"..index, {"CENTER", UIParent, "CENTER", 0, offset})
	Bar.movers[index+1] = frame.mover

	_G["MultiBar"..(index-1)]:SetParent(frame)
	_G["MultiBar"..(index-1)]:EnableMouse(false)

	for i = 1, num do
		local button = _G["MultiBar"..(index-1).."Button"..i]
		tinsert(buttonList, button)
		tinsert(Bar.buttons, button)
	end
	frame.buttons = buttonList

	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	--if cfg.fader then
	--	frame.isDisable = not C.db["Actionbar"]["Bar5Fader"]
	--	Bar.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	--end
end

function Bar:CreateBar678()
	createBar(6, 0)
	createBar(7, 40)
	createBar(8, 80)
end