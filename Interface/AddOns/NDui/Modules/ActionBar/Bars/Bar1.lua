local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:RegisterModule("Actionbar")

local _G = _G
local tinsert, next = tinsert, next
local GetActionTexture = GetActionTexture
local cfg = C.Bars.bar1
local margin, padding = C.Bars.margin, C.Bars.padding

function Bar:UpdateAllScale()
	if not C.db["Actionbar"]["Enable"] then return end
	Bar:UpdateActionSize("Bar1")
	Bar:UpdateActionSize("Bar2")
	Bar:UpdateActionSize("Bar3")
	Bar:UpdateActionSize("Bar4")
	Bar:UpdateActionSize("Bar5")
	Bar:UpdateActionSize("Bar6")
	Bar:UpdateActionSize("Bar7")
	Bar:UpdateActionSize("Bar8")
	Bar:UpdateActionSize("BarPet")
	Bar:UpdateStanceBar()
	Bar:UpdateVehicleButton()
end

function Bar:UpdateFontSize(button, fontSize)
	B.SetFontSize(button.Name, fontSize)
	B.SetFontSize(button.Count, fontSize)
	B.SetFontSize(button.HotKey, fontSize)
end

function Bar:UpdateActionSize(name)
	local frame = _G["NDui_Action"..name]
	if not frame then return end

	local size = C.db["Actionbar"][name.."Size"]
	local fontSize = C.db["Actionbar"][name.."Font"]
	local num = C.db["Actionbar"][name.."Num"]
	local perRow = C.db["Actionbar"][name.."PerRow"]

	if num == 0 then
		local column = 3
		local rows = 2
		frame:SetWidth(3*size + (column-1)*margin + 2*padding)
		frame:SetHeight(size*rows + (rows-1)*margin + 2*padding)
		frame.mover:SetSize(frame:GetSize())
		frame.child:SetSize(frame:GetSize())
		frame.child.mover:SetSize(frame:GetSize())
		frame.child.mover.isDisable = false
		for i = 1, 12 do
			local button = frame.buttons[i]
			button:SetSize(size, size)
			button:ClearAllPoints()
			if i == 1 then
				button:SetPoint("TOPLEFT", frame, padding, -padding)
			elseif i == 7 then
				button:SetPoint("TOPLEFT", frame.child, padding, -padding)
			elseif mod(i-1, 3) ==  0 then
				button:SetPoint("TOP", frame.buttons[i-3], "BOTTOM", 0, -margin)
			else
				button:SetPoint("LEFT", frame.buttons[i-1], "RIGHT", margin, 0)
			end
			button:SetAttribute("statehidden", false)
			button:Show()
			Bar:UpdateFontSize(button, fontSize)
		end
	else
		for i = 1, num do
			local button = frame.buttons[i]
			button:SetSize(size, size)
			button:ClearAllPoints()
			if i == 1 then
				button:SetPoint("TOPLEFT", frame, padding, -padding)
			elseif mod(i-1, perRow) ==  0 then
				button:SetPoint("TOP", frame.buttons[i-perRow], "BOTTOM", 0, -margin)
			else
				button:SetPoint("LEFT", frame.buttons[i-1], "RIGHT", margin, 0)
			end
			if name == "BarPet" then
				button.SetPoint = B.Dummy
			end
			button:SetAttribute("statehidden", false)
			button:Show()
			Bar:UpdateFontSize(button, fontSize)
		end

		for i = num+1, 12 do
			local button = frame.buttons[i]
			if not button then break end
			button:SetAttribute("statehidden", true)
			button:Hide()
		end

		local column = min(num, perRow)
		local rows = ceil(num/perRow)
		frame:SetWidth(column*size + (column-1)*margin + 2*padding)
		frame:SetHeight(size*rows + (rows-1)*margin + 2*padding)
		frame.mover:SetSize(frame:GetSize())
		if frame.child then frame.child.mover.isDisable = true end
	end
end

function Bar:CreateBar1()
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}

	local frame = CreateFrame("Frame", "NDui_ActionBar1", UIParent, "SecureHandlerStateTemplate")
	frame.mover = B.Mover(frame, L["Actionbar"].."1", "Bar1", {"BOTTOM", UIParent, "BOTTOM", 0, 24})
	Bar.movers[1] = frame.mover

	for i = 1, num do
		local button = _G["ActionButton"..i]
		tinsert(buttonList, button)
		tinsert(Bar.buttons, button)
		button:SetParent(frame)
	end
	frame.buttons = buttonList

	frame.frameVisibility = "[petbattle] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	if cfg.fader then
		Bar.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end

	local actionPage = "[bar:6]6;[bar:5]5;[bar:4]4;[bar:3]3;[bar:2]2;[possessbar]16;[overridebar]18;[shapeshift]17;[vehicleui]16;[bonusbar:5]11;[bonusbar:4]10;[bonusbar:3]9;[bonusbar:2]8;[bonusbar:1]7;1"
	local buttonName = "ActionButton"
	for i, button in next, buttonList do
		frame:SetFrameRef(buttonName..i, button)
	end

	frame:Execute(([[
		buttons = table.new()
		for i = 1, %d do
			tinsert(buttons, self:GetFrameRef("%s"..i))
		end
	]]):format(num, buttonName))

	frame:SetAttribute("_onstate-page", [[
		for _, button in next, buttons do
			button:SetAttribute("actionpage", newstate)
		end
	]])
	RegisterStateDriver(frame, "page", actionPage)

	-- Fix button texture
	local function FixActionBarTexture()
		for _, button in next, buttonList do
			local action = button.action
			if action < 120 then break end

			local icon = button.icon
			local texture = GetActionTexture(action)
			if texture then
				icon:SetTexture(texture)
				icon:Show()
			else
				icon:Hide()
			end
			Bar.UpdateButtonStatus(button)
		end
	end
	B:RegisterEvent("SPELL_UPDATE_ICON", FixActionBarTexture)
	B:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR", FixActionBarTexture)
	B:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR", FixActionBarTexture)
end

function Bar:OnLogin()
	Bar.buttons = {}
	Bar:MicroMenu()

	if C.db["Actionbar"]["Enable"] then
		Bar.movers = {}
		Bar:CreateBar1()
		Bar:CreateBar2()
		Bar:CreateBar3()
		Bar:CreateBar4()
		Bar:CreateBar5()
		Bar:CreateBar678()
		Bar:CustomBar()
		Bar:CreateExtrabar()
		Bar:CreateLeaveVehicle()
		Bar:CreatePetbar()
		Bar:CreateStancebar()
		Bar:HideBlizz()
		Bar:ReskinBars()

		local function delaySize(event)
			Bar:UpdateAllScale()
			B:UnregisterEvent(event, delaySize)
		end
		B:RegisterEvent("PLAYER_ENTERING_WORLD", delaySize)
	end
end