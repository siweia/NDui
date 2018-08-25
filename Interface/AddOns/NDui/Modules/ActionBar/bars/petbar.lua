local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")
local cfg = C.bars.petbar

function Bar:CreatePetbar()
	local padding, margin = 2, 3
	local num = NUM_PET_ACTION_SLOTS
	local buttonList = {}

	--create the frame to hold the buttons
	local frame = CreateFrame("Frame", "NDui_PetActionBar", UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(num*cfg.size + (num-1)*margin + 2*padding)
	frame:SetHeight(cfg.size + 2*padding)
	if NDuiDB["Actionbar"]["Style"] ~= 4 then
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 99}
	else
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 135}
	end
	frame:SetScale(NDuiDB["Actionbar"]["Scale"])

	--move the buttons into position and reparent them
	PetActionBarFrame:SetParent(frame)
	PetActionBarFrame:EnableMouse(false)
	SlidingActionBarTexture0:SetTexture(nil)
	SlidingActionBarTexture1:SetTexture(nil)

	for i = 1, num do
		local button = _G["PetActionButton"..i]
		table.insert(buttonList, button) --add the button object to the list
		button:SetSize(cfg.size, cfg.size)
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("LEFT", frame, padding, 0)
		else
			local previous = _G["PetActionButton"..i-1]
			button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
		end
		--cooldown fix
		local cd = _G["PetActionButton"..i.."Cooldown"]
		cd:SetAllPoints(button)
	end

	--show/hide the frame on a given state driver
	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; [pet] show; hide"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	--create drag frame and drag functionality
	if C.bars.userplaced then
		B.Mover(frame, L["Pet Actionbar"], "PetBar", frame.Pos)
	end

	--create the mouseover functionality
	if cfg.fader then
		B.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end
end