local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local _G = _G
local tinsert = tinsert
local margin = C.Bars.margin

function Bar:CreatePetbar()
	local num = NUM_PET_ACTION_SLOTS
	local buttonList = {}

	local frame = CreateFrame("Frame", "NDui_ActionBarPet", UIParent, "SecureHandlerStateTemplate")
	frame.mover = B.Mover(frame, L["Pet Actionbar"], "PetBar", {"BOTTOM", _G.NDui_ActionBar2, "TOP", 0, margin})
	Bar.movers[10] = frame.mover

	PetActionBarFrame:SetParent(frame)
	PetActionBarFrame:EnableMouse(false)
	SlidingActionBarTexture0:SetTexture(nil)
	SlidingActionBarTexture1:SetTexture(nil)

	for i = 1, num do
		local button = _G["PetActionButton"..i]
		tinsert(buttonList, button)
		tinsert(Bar.buttons, button)
		local hotkey = button.HotKey
		if hotkey then
			hotkey:ClearAllPoints()
			hotkey:SetPoint("TOPRIGHT")
		end
	end
	frame.buttons = buttonList

	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; [pet] show; hide"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)
end