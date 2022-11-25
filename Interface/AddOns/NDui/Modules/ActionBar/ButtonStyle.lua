local _, ns = ...
local B, C, L, DB = unpack(ns)
---------------------------
-- rButtonTemplate, zork
---------------------------
local Bar = B:GetModule("Actionbar")


local function SetupBackdrop(icon)
	local bg = B.SetBD(icon, .25)
	if C.db["Actionbar"]["Classcolor"] then
		bg:SetBackdropColor(DB.r, DB.g, DB.b, .25)
	else
		bg:SetBackdropColor(.2, .2, .2, .25)
	end
	icon:GetParent().__bg = bg
end

local keyButton = gsub(KEY_BUTTON4, "%d", "")
local keyNumpad = gsub(KEY_NUMPAD1, "%d", "")

local replaces = {
	{"("..keyButton..")", "M"},
	{"("..keyNumpad..")", "N"},
	{"(a%-)", "a"},
	{"(c%-)", "c"},
	{"(s%-)", "s"},
	{KEY_BUTTON3, "M3"},
	{KEY_MOUSEWHEELUP, "MU"},
	{KEY_MOUSEWHEELDOWN, "MD"},
	{KEY_SPACE, "Sp"},
	{"CAPSLOCK", "CL"},
	{"BUTTON", "M"},
	{"NUMPAD", "N"},
	{"(ALT%-)", "a"},
	{"(CTRL%-)", "c"},
	{"(SHIFT%-)", "s"},
	{"MOUSEWHEELUP", "MU"},
	{"MOUSEWHEELDOWN", "MD"},
	{"SPACE", "Sp"},
}

function Bar:UpdateHotKey()
	local text = self:GetText()
	if not text then return end

	if text == RANGE_INDICATOR then
		text = ""
	else
		for _, value in pairs(replaces) do
			text = gsub(text, value[1], value[2])
		end
	end
	self:SetFormattedText("%s", text)
end

function Bar:HookHotKey(button)
	Bar.UpdateHotKey(button)
	if button.UpdateHotkeys then
		hooksecurefunc(button, "UpdateHotkeys", Bar.UpdateHotKey)
	end
	if button.SetHotkeys then
		hooksecurefunc(button, "SetHotkeys", Bar.UpdateHotKey)
	end
end

function Bar:UpdateEquipItemColor()
	if not self.__bg then return end

	if C.db["Actionbar"]["EquipColor"] and IsEquippedAction(self.action) then
		self.__bg:SetBackdropBorderColor(0, .7, .1)
	else
		self.__bg:SetBackdropBorderColor(0, 0, 0)
	end
end

function Bar:StyleActionButton(button)
	if not button then return end
	if button.__styled then return end

	local icon = button.icon
	local cooldown = button.cooldown
	local hotkey = button.HotKey
	local count = button.Count
	local name = button.Name
	local flash = button.Flash
	local border = button.Border
	local normal = button.NormalTexture
	local normal2 = button:GetNormalTexture()
	local slotbg = button.SlotBackground
	local pushed = button.PushedTexture
	local checked = button.CheckedTexture
	local highlight = button.HighlightTexture
	local NewActionTexture = button.NewActionTexture
	local spellHighlight = button.SpellHighlightTexture
	local iconMask = button.IconMask

	if normal then normal:SetAlpha(0) end
	if normal2 then normal2:SetAlpha(0) end
	if flash then flash:SetTexture(DB.textures.flash) end
	if NewActionTexture then NewActionTexture:SetTexture(nil) end
	if border then border:SetTexture(nil) end
	if iconMask then iconMask:Hide() end

	if icon then
		icon:SetInside()
		icon:SetTexCoord(unpack(DB.TexCoord))
		SetupBackdrop(icon)
	end
	if cooldown then
		cooldown:SetAllPoints()
	end
	if pushed then
		pushed:SetInside()
		pushed:SetTexture(DB.textures.pushed)
	end
	if checked then
		checked:SetInside()
		checked:SetColorTexture(1, .8, 0, .35)
	end
	if highlight then
		highlight:SetInside()
		highlight:SetColorTexture(1, 1, 1, .25)
	end
	if spellHighlight then
		spellHighlight:SetOutside()
	end
	if hotkey then
		Bar.UpdateHotKey(hotkey)
		hooksecurefunc(hotkey, "SetText", Bar.UpdateHotKey)
	end

	button.__styled = true
end

function Bar:StyleExtraActionButton(cfg)
	local button = ExtraActionButton1
	if button.__styled then return end


	button.__styled = true
end

function Bar:UpdateStanceHotKey()
	for i = 1, 10 do
		_G["StanceButton"..i.."HotKey"]:SetText(GetBindingKey("SHAPESHIFTBUTTON"..i))
		Bar:HookHotKey(_G["StanceButton"..i])
	end
end

function Bar:StyleAllActionButtons(cfg)
	for i = 1, 8 do
		for j = 1, 12 do
			Bar:StyleActionButton(_G["NDui_ActionBar"..i.."Button"..j], cfg)
		end
	end
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		--Bar:StyleActionButton(_G["ActionButton"..i], cfg)
		--Bar:StyleActionButton(_G["MultiBarBottomLeftButton"..i], cfg)
		--Bar:StyleActionButton(_G["MultiBarBottomRightButton"..i], cfg)
		--Bar:StyleActionButton(_G["MultiBarRightButton"..i], cfg)
		--Bar:StyleActionButton(_G["MultiBarLeftButton"..i], cfg)
		Bar:StyleActionButton(_G["NDui_ActionBar1Button"..i], cfg)
		--Bar:StyleActionButton(_G["NDui_ActionBarXButton"..i], cfg)
		--Bar:StyleActionButton(_G["MultiBar5Button"..i], cfg)
		--Bar:StyleActionButton(_G["MultiBar6Button"..i], cfg)
		--Bar:StyleActionButton(_G["MultiBar7Button"..i], cfg)
	end
	for i = 1, 6 do
		Bar:StyleActionButton(_G["OverrideActionBarButton"..i], cfg)
	end
	--petbar buttons
	for i = 1, NUM_PET_ACTION_SLOTS do
		Bar:StyleActionButton(_G["PetActionButton"..i], cfg)
	end
	--stancebar buttons
	for i = 1, 10 do
		Bar:StyleActionButton(_G["StanceButton"..i], cfg)
	end
	--possess buttons
	for i = 1, NUM_POSSESS_SLOTS do
		Bar:StyleActionButton(_G["PossessButton"..i], cfg)
	end
	--leave vehicle
	Bar:StyleActionButton(_G["NDui_LeaveVehicleButton"], cfg)
	--extra action button
	Bar:StyleExtraActionButton(cfg)
	--spell flyout
	SpellFlyout.Background:SetAlpha(0)

	local function checkForFlyoutButtons()
		local i = 1
		local button = _G["SpellFlyoutButton"..i]
		while button and button:IsShown() do
			Bar:StyleActionButton(button, cfg)
			i = i + 1
			button = _G["SpellFlyoutButton"..i]
		end
	end
	SpellFlyout:HookScript("OnShow", checkForFlyoutButtons)
end

function Bar:ReskinBars()
	local cfg = {
		icon = {
			texCoord = DB.TexCoord,
			points = {
				{"TOPLEFT", C.mult, -C.mult},
				{"BOTTOMRIGHT", -C.mult, C.mult},
			},
		},
		flyoutBorder = {file = ""},
		flyoutBorderShadow = {file = ""},
		border = {file = ""},
		normalTexture = {
			file = DB.textures.normal,
			texCoord = DB.TexCoord,
			color = {.3, .3, .3},
			points = {
				{"TOPLEFT", C.mult, -C.mult},
				{"BOTTOMRIGHT", -C.mult, C.mult},
			},
		},
		flash = {file = DB.textures.flash},
		pushedTexture = {
			file = DB.textures.pushed,
			points = {
				{"TOPLEFT", C.mult, -C.mult},
				{"BOTTOMRIGHT", -C.mult, C.mult},
			},
		},
		checkedTexture = {
			file = 0,
			points = {
				{"TOPLEFT", C.mult, -C.mult},
				{"BOTTOMRIGHT", -C.mult, C.mult},
			},
		},
		highlightTexture = {
			file = 0,
			points = {
				{"TOPLEFT", C.mult, -C.mult},
				{"BOTTOMRIGHT", -C.mult, C.mult},
			},
		},
		cooldown = {
			points = {
				{"TOPLEFT", 0, 0},
				{"BOTTOMRIGHT", 0, 0},
			},
		},
		name = {
			font = DB.Font,
			points = {
				{"BOTTOMLEFT", 0, 0},
				{"BOTTOMRIGHT", 0, 0},
			},
		},
		hotkey = {
			font = DB.Font,
			points = {
				{"TOPRIGHT", 0, 0},
				{"TOPLEFT", 0, 0},
			},
		},
		count = {
			font = DB.Font,
			points = {
				{"BOTTOMRIGHT", 2, 0},
			},
		},
		buttonstyle = {file = ""},
	}

	Bar:StyleAllActionButtons(cfg)

	-- Update hotkeys
	Bar:UpdateStanceHotKey()
	B:RegisterEvent("UPDATE_BINDINGS", Bar.UpdateStanceHotKey)
end