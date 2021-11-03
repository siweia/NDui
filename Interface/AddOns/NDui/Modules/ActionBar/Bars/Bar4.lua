local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local _G = _G
local tinsert = tinsert
local cfg = C.Bars.bar4
local margin, padding = C.Bars.margin, C.Bars.padding

local function SetFrameSize(frame, size, num)
	size = size or frame.buttonSize
	num = num or frame.numButtons

	local layout = C.db["Actionbar"]["Style"]
	if layout == 2 then
		frame:SetWidth(25*size + 25*margin + 2*padding)
		frame:SetHeight(2*size + margin + 2*padding)

		local button = _G["MultiBarRightButton7"]
		button:SetPoint("TOPRIGHT", frame, -2*(size+margin) - padding, -padding)
	elseif layout == 3 then
		frame:SetWidth(4*size + 3*margin + 2*padding)
		frame:SetHeight(3*size + 2*margin + 2*padding)
	else
		frame:SetWidth(size + 2*padding)
		frame:SetHeight(num*size + (num-1)*margin + 2*padding)
	end

	if not frame.mover then
		frame.mover = B.Mover(frame, SHOW_MULTIBAR3_TEXT, "Bar4", frame.Pos)
	else
		frame.mover:SetSize(frame:GetSize())
	end

	if not frame.SetFrameSize then
		frame.buttonSize = size
		frame.numButtons = num
		frame.SetFrameSize = SetFrameSize
	end
end

local function updateVisibility(event)
	if InCombatLockdown() then
		B:RegisterEvent("PLAYER_REGEN_ENABLED", updateVisibility)
	else
		InterfaceOptions_UpdateMultiActionBars()
		B:UnregisterEvent(event, updateVisibility)
	end
end

function Bar:FixSizebarVisibility()
	B:RegisterEvent("PET_BATTLE_OVER", updateVisibility)
	B:RegisterEvent("PET_BATTLE_CLOSE", updateVisibility)
	B:RegisterEvent("UNIT_EXITED_VEHICLE", updateVisibility)
	B:RegisterEvent("UNIT_EXITING_VEHICLE", updateVisibility)
end

function Bar:ToggleBarFader(name)
	local frame = _G["NDui_Action"..name]
	if not frame then return end

	frame.isDisable = not C.db["Actionbar"][name.."Fader"]
	if frame.isDisable then
		Bar:StartFadeIn(frame)
	else
		Bar:StartFadeOut(frame)
	end
end

function Bar:CreateBar4()
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}
	local layout = C.db["Actionbar"]["Style"]

	local frame = CreateFrame("Frame", "NDui_ActionBar4", UIParent, "SecureHandlerStateTemplate")
	if layout == 2 then
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 26}
	elseif layout == 3 then
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 395, 26}
	else
		frame.Pos = {"RIGHT", UIParent, "RIGHT", -1, 0}
	end

	MultiBarRight:SetParent(frame)
	MultiBarRight:EnableMouse(false)
	MultiBarRight.QuickKeybindGlow:SetTexture("")

	for i = 1, num do
		local button = _G["MultiBarRightButton"..i]
		tinsert(buttonList, button)
		tinsert(Bar.buttons, button)
		button:ClearAllPoints()
		if layout == 2 then
			if i == 1 then
				button:SetPoint("TOPLEFT", frame, padding, -padding)
			elseif i == 4 then
				local previous = _G["MultiBarRightButton1"]
				button:SetPoint("TOP", previous, "BOTTOM", 0, -margin)
			elseif i == 7 then
				button:SetPoint("TOPRIGHT", frame, -2*(cfg.size+margin) - padding, -padding)
			elseif i == 10 then
				local previous = _G["MultiBarRightButton7"]
				button:SetPoint("TOP", previous, "BOTTOM", 0, -margin)
			else
				local previous = _G["MultiBarRightButton"..i-1]
				button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
			end
		elseif layout == 3 then
			if i == 1 then
				button:SetPoint("TOPLEFT", frame, padding, -padding)
			elseif i == 5 or i == 9 then
				local previous = _G["MultiBarRightButton"..i-4]
				button:SetPoint("TOP", previous, "BOTTOM", 0, -margin)
			else
				local previous = _G["MultiBarRightButton"..i-1]
				button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
			end
		else
			if i == 1 then
				button:SetPoint("TOPRIGHT", frame, -padding, -padding)
			else
				local previous = _G["MultiBarRightButton"..i-1]
				button:SetPoint("TOP", previous, "BOTTOM", 0, -margin)
			end
		end
	end

	frame.buttonList = buttonList
	SetFrameSize(frame, cfg.size, num)

	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	if cfg.fader then
		frame.isDisable = not C.db["Actionbar"]["Bar4Fader"]
		Bar.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end

	-- Fix visibility when leaving vehicle or petbattle
	Bar:FixSizebarVisibility()
end