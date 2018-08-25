local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:RegisterModule("Actionbar")
local cfg = C.bars.bar1

function module:OnLogin()
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
	frame:SetScale(NDuiDB["Actionbar"]["Scale"])

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
		B.Mover(frame, L["Main Actionbar"], "Bar1", frame.Pos)
	end

	--create the mouseover functionality
	if cfg.fader then
		B.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end

	--fix stupid blizzard
	local function ToggleButtonGrid()
		if InCombatLockdown() then return end
		local showgrid = tonumber(GetCVar("alwaysShowActionBars"))
		for _, button in next, buttonList do
			button:SetAttribute("showgrid", showgrid)
			ActionButton_ShowGrid(button)
		end
	end
	hooksecurefunc("MultiActionBar_UpdateGridVisibility", ToggleButtonGrid)

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
		for i, button in next, buttons do
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
end