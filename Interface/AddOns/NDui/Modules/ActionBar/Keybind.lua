local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local _G = _G
local tonumber, print, strfind, strupper = tonumber, print, strfind, strupper
local EnumerateFrames = EnumerateFrames
local InCombatLockdown = InCombatLockdown
local GetSpellBookItemName, GetMacroInfo = GetSpellBookItemName, GetMacroInfo
local IsAltKeyDown, IsControlKeyDown, IsShiftKeyDown = IsAltKeyDown, IsControlKeyDown, IsShiftKeyDown
local GetBindingKey, SetBinding, SaveBindings, LoadBindings = GetBindingKey, SetBinding, SaveBindings, LoadBindings

-- Button types
local function hookActionButton(self)
	Bar:Bind_Update(self)
end
local function hookStanceButton(self)
	Bar:Bind_Update(self, "STANCE")
end
local function hookPetButton(self)
	Bar:Bind_Update(self, "PET")
end
local function hookMacroButton(self)
	Bar:Bind_Update(self, "MACRO")
end
local function hookSpellButton(self)
	Bar:Bind_Update(self, "SPELL")
end

function Bar:Bind_RegisterButton(button)
	local action = ActionButton1:GetScript("OnClick")
	local stance = StanceButton1:GetScript("OnClick")
	local pet = PetActionButton1:GetScript("OnClick")

	if button.IsProtected and button.IsObjectType and button.GetScript and button:IsObjectType("CheckButton") and button:IsProtected() then
		local script = button:GetScript("OnClick")
		if script == action then
			button:HookScript("OnEnter", hookActionButton)
		elseif script == stance then
			button:HookScript("OnEnter", hookStanceButton)
		elseif script == pet then
			button:HookScript("OnEnter", hookPetButton)
		end
	end
end

function Bar:Bind_RegisterMacro()
	if self ~= "Blizzard_MacroUI" then return end

	for i = 1, MAX_ACCOUNT_MACROS do
		local button = _G["MacroButton"..i]
		button:HookScript("OnEnter", hookMacroButton)
	end
end

function Bar:Bind_Create()
	if Bar.keybindFrame then return end

	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetFrameStrata("DIALOG")
	frame:EnableMouse(true)
	frame:EnableKeyboard(true)
	frame:EnableMouseWheel(true)
	B.CreateBD(frame, .5)
	frame:Hide()

	frame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(frame, "ANCHOR_NONE")
		GameTooltip:SetPoint("BOTTOM", frame, "TOP", 0, 2)
		GameTooltip:AddLine(frame.name, 1,1,1)

		if #frame.bindings == 0 then
			GameTooltip:AddLine(L["No key set"], .6,.6,.6)
		else
			GameTooltip:AddDoubleLine(L["KeyIndex"], L["KeyBinding"], .6,.6,.6, .6,.6,.6)
			for i = 1, #frame.bindings do
				GameTooltip:AddDoubleLine(i, frame.bindings[i])
			end
		end
		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", Bar.Bind_HideFrame)
	frame:SetScript("OnKeyUp", function(_, key) Bar:Bind_Listener(key) end)
	frame:SetScript("OnMouseUp", function(_, key) Bar:Bind_Listener(key) end)
	frame:SetScript("OnMouseWheel", function(_, delta)
		if delta > 0 then
			Bar:Bind_Listener("MOUSEWHEELUP")
		else
			Bar:Bind_Listener("MOUSEWHEELDOWN")
		end
	end)

	local button = EnumerateFrames()
	while button do
		Bar:Bind_RegisterButton(button)
		button = EnumerateFrames(button)
	end

	for i = 1, 12 do
		local button = _G["SpellButton"..i]
		button:HookScript("OnEnter", hookSpellButton)
	end

	if not IsAddOnLoaded("Blizzard_MacroUI") then
		hooksecurefunc("LoadAddOn", Bar.Bind_RegisterMacro)
	else
		Bar.Bind_RegisterMacro("Blizzard_MacroUI")
	end

	Bar.keybindFrame = frame
end

function Bar:Bind_Update(button, spellmacro)
	local frame = Bar.keybindFrame
	if not frame.enabled or InCombatLockdown() then return end

	frame.button = button
	frame.spellmacro = spellmacro
	frame:ClearAllPoints()
	frame:SetAllPoints(button)
	frame:Show()

	if spellmacro == "SPELL" then
		frame.id = SpellBook_GetSpellBookSlot(frame.button)
		frame.name = GetSpellBookItemName(frame.id, SpellBookFrame.bookType)
		frame.bindings = {GetBindingKey(spellmacro.." "..frame.name)}
	elseif spellmacro == "MACRO" then
		frame.id = frame.button:GetID()
		local colorIndex = B:Round(select(2, MacroFrameTab1Text:GetTextColor()), 1)
		if colorIndex == .8 then frame.id = frame.id + 36 end
		frame.name = GetMacroInfo(frame.id)
		frame.bindings = {GetBindingKey(spellmacro.." "..frame.name)}
	elseif spellmacro == "STANCE" or spellmacro == "PET" then
		frame.name = button:GetName()
		if not frame.name then return end

		frame.id = tonumber(button:GetID())
		if not frame.id or frame.id < 1 or frame.id > (spellmacro == "STANCE" and 10 or 12) then
			frame.bindstring = "CLICK "..frame.name..":LeftButton"
		else
			frame.bindstring = (spellmacro=="STANCE" and "SHAPESHIFTBUTTON" or "BONUSACTIONBUTTON")..frame.id
		end
		frame.bindings = {GetBindingKey(frame.bindstring)}
	else
		frame.name = button:GetName()
		if not frame.name then return end

		frame.action = tonumber(button.action)
		if not frame.action or frame.action < 1 or frame.action > 132 then
			frame.bindstring = "CLICK "..frame.name..":LeftButton"
		else
			local modact = 1+(frame.action-1)%12
			if frame.name == "ExtraActionButton1" then
				frame.bindstring = "EXTRAACTIONBUTTON1"
			elseif frame.action < 25 or frame.action > 72 then
				frame.bindstring = "ACTIONBUTTON"..modact
			elseif frame.action < 73 and frame.action > 60 then
				frame.bindstring = "MULTIACTIONBAR1BUTTON"..modact
			elseif frame.action < 61 and frame.action > 48 then
				frame.bindstring = "MULTIACTIONBAR2BUTTON"..modact
			elseif frame.action < 49 and frame.action > 36 then
				frame.bindstring = "MULTIACTIONBAR4BUTTON"..modact
			elseif frame.action < 37 and frame.action > 24 then
				frame.bindstring = "MULTIACTIONBAR3BUTTON"..modact
			end
		end
		frame.bindings = {GetBindingKey(frame.bindstring)}
	end
end

local ignoreKeys = {
	["LALT"] = true,
	["RALT"] = true,
	["LCTRL"] = true,
	["RCTRL"] = true,
	["LSHIFT"] = true,
	["RSHIFT"] = true,
	["UNKNOWN"] = true,
	["LeftButton"] = true,
	["MiddleButton"] = true,
}

function Bar:Bind_Listener(key)
	local frame = Bar.keybindFrame
	if key == "ESCAPE" or key == "RightButton" then
		if frame.bindings then
			for i = 1, #frame.bindings do
				SetBinding(frame.bindings[i])
			end
		end
		print(format(L["Clear binds"], frame.name))

		Bar:Bind_Update(frame.button, frame.spellmacro)
		if frame.spellmacro ~= "MACRO" and not GameTooltip:IsForbidden() then GameTooltip:Hide() end

		return
	end

	local isKeyIgnore = ignoreKeys[key]
	if isKeyIgnore then return end

	if key == "MiddleButton" then key = "BUTTON3" end
	if strfind(key, "Button%d") then key = strupper(key) end

	local alt = IsAltKeyDown() and "ALT-" or ""
	local ctrl = IsControlKeyDown() and "CTRL-" or ""
	local shift = IsShiftKeyDown() and "SHIFT-" or ""

	if not frame.spellmacro or frame.spellmacro == "PET" or frame.spellmacro == "STANCE" then
		SetBinding(alt..ctrl..shift..key, frame.bindstring)
	else
		SetBinding(alt..ctrl..shift..key, frame.spellmacro.." "..frame.name)
	end
	print(frame.name.." |cff00ff00"..L["KeyBoundTo"].."|r "..alt..ctrl..shift..key)

	Bar:Bind_Update(frame.button, frame.spellmacro)
	frame:GetScript("OnEnter")(self)
end

function Bar:Bind_HideFrame()
	local frame = Bar.keybindFrame
	frame:ClearAllPoints()
	frame:Hide()
	if not GameTooltip:IsForbidden() then GameTooltip:Hide() end
end

function Bar:Bind_Activate()
	Bar.keybindFrame.enabled = true
	B:RegisterEvent("PLAYER_REGEN_DISABLED", Bar.Bind_Deactivate)
end

function Bar:Bind_Deactivate(save)
	if save == true then
		SaveBindings(NDuiDB["Actionbar"]["BindType"])
		print("|cff0080ffNDui|r: |cff00ff00"..L["Save keybinds"].."|r")
	else
		LoadBindings(NDuiDB["Actionbar"]["BindType"])
		print("|cff0080ffNDui|r: |cffffff00"..L["Discard keybinds"].."|r")
	end

	Bar:Bind_HideFrame()
	Bar.keybindFrame.enabled = false
	B:UnregisterEvent("PLAYER_REGEN_DISABLED", Bar.Bind_Deactivate)
	Bar.keybindDialog:Hide()
end

function Bar:Bind_CreateDialog()
	local dialog = Bar.keybindDialog
	if dialog then dialog:Show() return end

	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetSize(320, 100)
	frame:SetPoint("TOP", 0, -135)
	B.SetBD(frame)
	B.CreateFS(frame, 16, KEY_BINDING, false, "TOP", 0, -10)

	local text = B.CreateFS(frame, 14, CHARACTER_SPECIFIC_KEYBINDINGS, "system", "TOP", 0, -40)

	local button1 = B.CreateButton(frame, 120, 25, APPLY, 14)
	button1:SetPoint("BOTTOMLEFT", 25, 10)
	button1:SetScript("OnClick", function()
		Bar:Bind_Deactivate(true)
	end)
	local button2 = B.CreateButton(frame, 120, 25, CANCEL, 14)
	button2:SetPoint("BOTTOMRIGHT", -25, 10)
	button2:SetScript("OnClick", function()
		Bar:Bind_Deactivate()
	end)
	local box = B.CreateCheckBox(frame)
	box:SetChecked(NDuiDB["Actionbar"]["BindType"] == 2)
	box:SetPoint("RIGHT", text, "LEFT", -5, -0)
	box:SetScript("OnClick", function(self)
		NDuiDB["Actionbar"]["BindType"] = self:GetChecked() and 2 or 1
	end)

	Bar.keybindDialog = frame
end

SlashCmdList["NDUI_KEYBIND"] = function(msg)
	if msg ~= "" then return end -- don't mess up with this
	if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end

	Bar:Bind_Create()
	Bar:Bind_Activate()
	Bar:Bind_CreateDialog()
end
SLASH_NDUI_KEYBIND1 = "/bb"