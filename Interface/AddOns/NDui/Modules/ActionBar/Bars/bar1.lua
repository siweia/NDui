local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:RegisterModule("Actionbar")
local cfg = C.bars.bar1

local function UpdateActionbarScale(bar)
	local frame = _G["NDui_Action"..bar]
	frame:SetScale(NDuiDB["Actionbar"]["Scale"])
	frame.mover:SetScale(NDuiDB["Actionbar"]["Scale"])
end

function Bar:UpdateAllScale()
	if not NDuiDB["Actionbar"]["Enable"] then return end

	UpdateActionbarScale("Bar1")
	UpdateActionbarScale("Bar2")
	UpdateActionbarScale("Bar3")
	UpdateActionbarScale("Bar4")
	UpdateActionbarScale("Bar5")

	UpdateActionbarScale("BarExtra")
	UpdateActionbarScale("BarZone")
	UpdateActionbarScale("BarExit")
	UpdateActionbarScale("BarPet")
	UpdateActionbarScale("BarStance")
end

function Bar:OnLogin()
	if not NDuiDB["Actionbar"]["Enable"] then return end

	local padding, margin = 2, 2
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}
	local layout = NDuiDB["Actionbar"]["Style"]

	--create the frame to hold the buttons
	local frame = CreateFrame("Frame", "NDui_ActionBar1", UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(num*cfg.size + (num-1)*margin + 2*padding)
	frame:SetHeight(cfg.size + 2*padding)
	if layout == 5 then
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", -108, 24}
	else
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 24}
	end

	for i = 1, num do
		local button = _G["ActionButton"..i]
		table.insert(buttonList, button) --add the button object to the list
		button:SetParent(frame)
		button:SetSize(cfg.size, cfg.size)
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("BOTTOMLEFT", frame, padding, padding)
		else
			local previous = _G["ActionButton"..i-1]
			button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
		end
	end

	--show/hide the frame on a given state driver
	frame.frameVisibility = "[petbattle] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	--create drag frame and drag functionality
	if C.bars.userplaced then
		frame.mover = B.Mover(frame, L["Main Actionbar"], "Bar1", frame.Pos)
	end

	--create the mouseover functionality
	if cfg.fader then
		Bar.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end

	--_onstate-page state driver
	local actionPage = "[bar:6]6;[bar:5]5;[bar:4]4;[bar:3]3;[bar:2]2;[overridebar]14;[shapeshift]13;[vehicleui]12;[possessbar]12;[bonusbar:5]11;[bonusbar:4]10;[bonusbar:3]9;[bonusbar:2]8;[bonusbar:1]7;1"
	local buttonName = "ActionButton"
	for i, button in next, buttonList do
		frame:SetFrameRef(buttonName..i, button)
	end

	frame:Execute(([[
		buttons = table.new()
		for i = 1, %d do
			table.insert(buttons, self:GetFrameRef("%s"..i))
		end
	]]):format(num, buttonName))

	frame:SetAttribute("_onstate-page", [[
		for _, button in next, buttons do
			button:SetAttribute("actionpage", newstate)
		end
	]])
	RegisterStateDriver(frame, "page", actionPage)

	--add elements
	self:CreateBar2()
	self:CreateBar3()
	self:CreateBar4()
	self:CreateBar5()
	self:CreateExtrabar()
	self:CreateLeaveVehicle()
	self:CreatePetbar()
	self:CreateStancebar()
	self:HideBlizz()
	self:ReskinBars()
	self:UpdateAllScale()
	self:CreateBackground()
	self:MicroMenu()

	--vehicle fix
	local function getActionTexture(button)
		return GetActionTexture(button.action)
	end

	B:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR", function()
		for _, button in next, buttonList do
			local icon = button.icon
			local texture = getActionTexture(button)
			if texture then
				icon:SetTexture(texture)
				icon:Show()
			else
				icon:Hide()
			end
		end
	end)
end

function Bar:CreateBackground()
	if not NDuiDB["Skins"]["BarLine"] then return end
	if NDuiDB["Actionbar"]["Scale"] ~= 1 then return end

	local cr, cg, cb = 0, 0, 0
	if NDuiDB["Skins"]["ClassLine"] then cr, cg, cb = DB.r, DB.g, DB.b end

	local basic = 94
	if NDuiDB["Actionbar"]["Style"] == 4 then basic = 130 end

	local MactionbarL = CreateFrame("Frame", nil, UIParent)
	MactionbarL:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", 0, 4)
	B.CreateGF(MactionbarL, 250, basic, "Horizontal", 0, 0, 0, 0, .5)
	local MactionbarL1 = CreateFrame("Frame", nil, MactionbarL)
	MactionbarL1:SetPoint("BOTTOMRIGHT", MactionbarL, "TOPRIGHT")
	B.CreateGF(MactionbarL1, 230, C.mult, "Horizontal", cr, cg, cb, 0, .7)
	RegisterStateDriver(MactionbarL, "visibility", "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists] hide; show")

	local MactionbarR = CreateFrame("Frame", nil, UIParent)
	MactionbarR:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", 0, 4)
	B.CreateGF(MactionbarR, 250, basic, "Horizontal", 0, 0, 0, .5, 0)
	local MactionbarR1 = CreateFrame("Frame", nil, MactionbarR)
	MactionbarR1:SetPoint("BOTTOMLEFT", MactionbarR, "TOPLEFT")
	B.CreateGF(MactionbarR1, 230, C.mult, "Horizontal", cr, cg, cb, .7, 0)
	RegisterStateDriver(MactionbarR, "visibility", "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists] hide; show")

	-- OVERRIDEBAR
	local OverbarL = CreateFrame("Frame", nil, UIParent)
	OverbarL:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", 0, 4)
	B.CreateGF(OverbarL, 200, 57, "Horizontal", 0, 0, 0, 0, .5)
	local OverbarL1 = CreateFrame("Frame", nil, OverbarL)
	OverbarL1:SetPoint("BOTTOMRIGHT", OverbarL, "TOPRIGHT")
	B.CreateGF(OverbarL1, 200, C.mult, "Horizontal", cr, cg, cb, 0, .7)
	RegisterStateDriver(OverbarL, "visibility", "[petbattle]hide; [overridebar][vehicleui][possessbar,@vehicle,exists] show; hide")

	local OverbarR = CreateFrame("Frame", nil, UIParent)
	OverbarR:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", 0, 4)
	B.CreateGF(OverbarR, 200, 57, "Horizontal", 0, 0, 0, .5, 0)
	local OverbarR1 = CreateFrame("Frame", nil, OverbarR)
	OverbarR1:SetPoint("BOTTOMLEFT", OverbarR, "TOPLEFT")
	B.CreateGF(OverbarR1, 200, C.mult, "Horizontal", cr, cg, cb, .7, 0)
	RegisterStateDriver(OverbarR, "visibility", "[petbattle]hide; [overridebar][vehicleui][possessbar,@vehicle,exists] show; hide")
end