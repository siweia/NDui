local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local _G = _G
local tinsert = tinsert
local cfg = C.Bars.petbar
local margin = C.Bars.margin

function Bar:CreatePetbar()
	local num = NUM_PET_ACTION_SLOTS
	local buttonList = {}

	local frame = CreateFrame("Frame", "NDui_ActionBarPet", UIParent, "SecureHandlerStateTemplate")
	frame.mover = B.Mover(frame, L["Pet Actionbar"], "PetBar", {"BOTTOM", _G.NDui_ActionBar2, "TOP", 0, margin})
	Bar.movers[7] = frame.mover

	PetActionBar:SetParent(frame)
	PetActionBar:EnableMouse(false)

	for i = 1, num do
		local button = _G["PetActionButton"..i]
		tinsert(buttonList, button)
		tinsert(Bar.buttons, button)
	end
	frame.buttons = buttonList

	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; [pet] show; hide"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	if cfg.fader then
		Bar.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end
end