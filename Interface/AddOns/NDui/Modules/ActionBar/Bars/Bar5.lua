local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local _G = _G
local tinsert = tinsert
local cfg = C.Bars.bar5
local margin = C.Bars.margin

function Bar:CreateBar5()
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}

	local frame = CreateFrame("Frame", "NDui_ActionBar5", UIParent, "SecureHandlerStateTemplate")
	frame.mover = B.Mover(frame, L["Actionbar"].."5", "Bar5", {"RIGHT", _G.NDui_ActionBar4, "LEFT", margin, 0})
	Bar.movers[6] = frame.mover

	MultiBarLeft:SetParent(frame)
	MultiBarLeft:EnableMouse(false)
	MultiBarLeft.QuickKeybindGlow:SetTexture("")
	hooksecurefunc(MultiBarLeft, "SetScale", function(self, scale, force)
		if not force and scale ~= 1 then
			self:SetScale(1, true)
		end
	end)

	for i = 1, num do
		local button = _G["MultiBarLeftButton"..i]
		tinsert(buttonList, button)
		tinsert(Bar.buttons, button)
	end
	frame.buttons = buttonList

	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	if cfg.fader then
		frame.isDisable = not C.db["Actionbar"]["Bar5Fader"]
		Bar.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end
end