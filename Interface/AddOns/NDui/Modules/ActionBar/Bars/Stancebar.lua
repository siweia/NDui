local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local _G = _G
local tinsert, mod, min, ceil = tinsert, mod, min, ceil
local cfg = C.Bars.stancebar
local margin, padding = C.Bars.margin, C.Bars.padding

local num = NUM_STANCE_SLOTS or 10
local NUM_POSSESS_SLOTS = NUM_POSSESS_SLOTS or 2

function Bar:UpdateStanceBar()
	local frame = _G["NDui_ActionBarStance"]
	if not frame then return end

	local size = C.db["Actionbar"]["BarStanceSize"]
	local fontSize = C.db["Actionbar"]["BarStanceFont"]
	local perRow = C.db["Actionbar"]["BarStancePerRow"]

	for i = 1, 12 do
		local button = frame.buttons[i]
		button:SetSize(size, size)
		if i < 11 then
			button:ClearAllPoints()
			if i == 1 then
				button:SetPoint("TOPLEFT", frame, padding, -padding)
			elseif mod(i-1, perRow) ==  0 then
				button:SetPoint("TOP", frame.buttons[i-perRow], "BOTTOM", 0, -margin)
			else
				button:SetPoint("LEFT", frame.buttons[i-1], "RIGHT", margin, 0)
			end
		end
		Bar:UpdateFontSize(button, fontSize)
	end

	local column = min(num, perRow)
	local rows = ceil(num/perRow)
	frame:SetWidth(column*size + (column-1)*margin + 2*padding)
	frame:SetHeight(size*rows + (rows-1)*margin + 2*padding)
	frame.mover:SetSize(size, size)
end

function Bar:CreateStancebar()
	if not C.db["Actionbar"]["ShowStance"] then return end

	local buttonList = {}
	local frame = CreateFrame("Frame", "NDui_ActionBarStance", UIParent, "SecureHandlerStateTemplate")
	frame.mover = B.Mover(frame, L["StanceBar"], "StanceBar", {"BOTTOMLEFT", _G.NDui_ActionBar2, "TOPLEFT", 0, margin})
	Bar.movers[8] = frame.mover

	-- StanceBar
	StanceBar:SetParent(frame)
	StanceBar:EnableMouse(false)
	StanceBar:UnregisterAllEvents()

	for i = 1, num do
		local button = _G["StanceButton"..i]
		button:SetParent(frame)
		tinsert(buttonList, button)
		tinsert(Bar.buttons, button)
	end

	-- PossessBar
	PossessActionBar:SetParent(frame)
	PossessActionBar:EnableMouse(false)

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