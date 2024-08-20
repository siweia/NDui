local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local _G = _G
local tinsert, mod, min, ceil = tinsert, mod, min, ceil
local margin, padding = C.Bars.margin, C.Bars.padding

local num = NUM_STANCE_SLOTS or 10

function Bar:UpdateStanceBar()
	if InCombatLockdown() then return end

	local frame = _G["NDui_ActionBarStance"]
	if not frame then return end

	local size = C.db["Actionbar"]["BarStanceSize"]
	local fontSize = C.db["Actionbar"]["BarStanceFont"]
	local perRow = C.db["Actionbar"]["BarStancePerRow"]

	for i = 1, num do
		local button = frame.buttons[i]
		button:SetSize(size, size)
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("TOPLEFT", frame, padding, -padding)
		elseif mod(i-1, perRow) == 0 then
			button:SetPoint("TOP", frame.buttons[i-perRow], "BOTTOM", 0, -margin)
		else
			button:SetPoint("LEFT", frame.buttons[i-1], "RIGHT", margin, 0)
		end
		Bar:UpdateFontSize(button, fontSize)
	end

	local column = min(num, perRow)
	local rows = ceil(num/perRow)
	frame:SetWidth(column*size + (column-1)*margin + 2*padding)
	frame:SetHeight(size*rows + (rows-1)*margin + 2*padding)
	frame.mover:SetSize(size+2*padding, size+2*padding)
end

function Bar:UpdateStance()
	local inCombat = InCombatLockdown()
	local numForms = GetNumShapeshiftForms();
	local texture, isActive, isCastable;
	local icon, cooldown;
	local start, duration, enable;

	for i, button in pairs(self.actionButtons) do
		if not inCombat then button:Hide() end
		icon = button.icon;
		if ( i <= numForms ) then
			texture, isActive, isCastable = GetShapeshiftFormInfo(i);
			icon:SetTexture(texture);

			--Cooldown stuffs
			cooldown = button.cooldown;
			if ( texture ) then
				if not inCombat then button:Show() end
				cooldown:Show();
			else
				cooldown:Hide();
			end
			start, duration, enable = GetShapeshiftFormCooldown(i);
			CooldownFrame_Set(cooldown, start, duration, enable);

			if ( isActive ) then
				button:SetChecked(true);
			else
				button:SetChecked(false);
			end

			if ( isCastable ) then
				icon:SetVertexColor(1.0, 1.0, 1.0);
			else
				icon:SetVertexColor(0.4, 0.4, 0.4);
			end
		end
	end
end

function Bar:StanceBarOnEvent()
	Bar:UpdateStanceBar()
	Bar.UpdateStance(StanceBar)
end

function Bar:CreateStancebar()
	local buttonList = {}
	local frame = CreateFrame("Frame", "NDui_ActionBarStance", UIParent, "SecureHandlerStateTemplate")
	frame.mover = B.Mover(frame, L["StanceBar"], "StanceBar", {"BOTTOMLEFT", _G.NDui_ActionBar2, "TOPLEFT", 0, margin})
	Bar.movers[11] = frame.mover

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
	frame.buttons = buttonList

	-- Fix stance bar updating
	Bar:StanceBarOnEvent()
	B:RegisterEvent("UPDATE_SHAPESHIFT_FORM", Bar.StanceBarOnEvent)
	B:RegisterEvent("UPDATE_SHAPESHIFT_FORMS", Bar.StanceBarOnEvent)
	B:RegisterEvent("UPDATE_SHAPESHIFT_USABLE", Bar.StanceBarOnEvent)
	B:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN", Bar.StanceBarOnEvent)

	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", not C.db["Actionbar"]["ShowStance"] and "hide" or frame.frameVisibility)
end