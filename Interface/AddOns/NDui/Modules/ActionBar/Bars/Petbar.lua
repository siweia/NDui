local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local _G = _G
local tinsert = tinsert
local cfg = C.bars.petbar
local margin, padding = C.bars.margin, C.bars.padding

local function SetFrameSize(frame, size, num)
	size = size or frame.buttonSize
	num = num or frame.numButtons

	frame:SetWidth(num*size + (num-1)*margin + 2*padding)
	frame:SetHeight(size + 2*padding)
	if not frame.mover then
		frame.mover = B.Mover(frame, L["Pet Actionbar"], "PetBar", frame.Pos)
	else
		frame.mover:SetSize(frame:GetSize())
	end

	if not frame.SetFrameSize then
		frame.buttonSize = size
		frame.numButtons = num
		frame.SetFrameSize = SetFrameSize
	end
end

function Bar:CreatePetbar()
	local num = NUM_PET_ACTION_SLOTS
	local buttonList = {}

	local frame = CreateFrame("Frame", "NDui_ActionBarPet", UIParent, "SecureHandlerStateTemplate")
	local anchor = NDuiDB["Actionbar"]["Style"] == 4 and _G.NDui_ActionBar3 or _G.NDui_ActionBar2
	frame.Pos = {"BOTTOM", anchor, "TOP", 0, margin}

	PetActionBarFrame:SetParent(frame)
	PetActionBarFrame:EnableMouse(false)
	SlidingActionBarTexture0:SetTexture(nil)
	SlidingActionBarTexture1:SetTexture(nil)

	for i = 1, num do
		local button = _G["PetActionButton"..i]
		tinsert(buttonList, button)
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("LEFT", frame, padding, 0)
		else
			local previous = _G["PetActionButton"..i-1]
			button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
		end
	end

	frame.buttonList = buttonList
	SetFrameSize(frame, cfg.size, num)

	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; [pet] show; hide"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	if cfg.fader then
		Bar.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end
end