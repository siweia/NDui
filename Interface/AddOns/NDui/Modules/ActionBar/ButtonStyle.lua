local _, ns = ...
local B, C, L, DB = unpack(ns)
---------------------------
-- rButtonTemplate, zork
---------------------------
local Bar = B:GetModule("Actionbar")
local _G = getfenv(0)

local function CallButtonFunctionByName(button, func, ...)
	if button and func and button[func] then
		button[func](button, ...)
	end
end

local function ResetNormalTexture(self, file)
	if not self.__normalTextureFile then return end
	if file == self.__normalTextureFile then return end
	self:SetNormalTexture(self.__normalTextureFile)
end

local function ResetTexture(self, file)
	if not self.__textureFile then return end
	if file == self.__textureFile then return end
	self:SetTexture(self.__textureFile)
end

local function ResetVertexColor(self, r, g, b, a)
	if not self.__vertexColor then return end
	local r2, g2, b2, a2 = unpack(self.__vertexColor)
	if not a2 then a2 = 1 end
	if r ~= r2 or g ~= g2 or b ~= b2 or a ~= a2 then
		self:SetVertexColor(r2, g2, b2, a2)
	end
end

local function ApplyPoints(self, points)
	if not points then return end
	self:ClearAllPoints()
	for _, point in next, points do
		self:SetPoint(unpack(point))
	end
end

local function ApplyTexCoord(texture, texCoord)
	if not texCoord then return end
	texture:SetTexCoord(unpack(texCoord))
end

local function ApplyVertexColor(texture, color)
	if not color then return end
	texture.__vertexColor = color
	texture:SetVertexColor(unpack(color))
	hooksecurefunc(texture, "SetVertexColor", ResetVertexColor)
end

local function ApplyAlpha(region, alpha)
	if not alpha then return end
	region:SetAlpha(alpha)
end

local function ApplyFont(fontString, font)
	if not font then return end
	fontString:SetFont(unpack(font))
end

local function ApplyHorizontalAlign(fontString, align)
	if not align then return end
	fontString:SetJustifyH(align)
end

local function ApplyVerticalAlign(fontString, align)
	if not align then return end
	fontString:SetJustifyV(align)
end

local function ApplyTexture(texture, file)
	if not file then return end
	texture.__textureFile = file
	texture:SetTexture(file)
	hooksecurefunc(texture, "SetTexture", ResetTexture)
end

local function ApplyNormalTexture(button, file)
	if not file then return end
	button.__normalTextureFile = file
	button:SetNormalTexture(file)
	hooksecurefunc(button, "SetNormalTexture", ResetNormalTexture)
end

local function SetupTexture(texture, cfg, func, button)
	if not texture or not cfg then return end
	ApplyTexCoord(texture, cfg.texCoord)
	ApplyPoints(texture, cfg.points)
	ApplyVertexColor(texture, cfg.color)
	ApplyAlpha(texture, cfg.alpha)
	if func == "SetTexture" then
		ApplyTexture(texture, cfg.file)
	elseif func == "SetNormalTexture" then
		ApplyNormalTexture(button, cfg.file)
	elseif cfg.file then
		CallButtonFunctionByName(button, func, cfg.file)
	end
end

local function SetupFontString(fontString, cfg)
	if not fontString or not cfg then return end
	ApplyPoints(fontString, cfg.points)
	ApplyFont(fontString, cfg.font)
	ApplyAlpha(fontString, cfg.alpha)
	ApplyHorizontalAlign(fontString, cfg.halign)
	ApplyVerticalAlign(fontString, cfg.valign)
end

local function SetupCooldown(cooldown, cfg)
	if not cooldown or not cfg then return end
	ApplyPoints(cooldown, cfg.points)
end

local function SetupBackdrop(button)
	local bg = B.CreateBG(button, 0)
	B.CreateBD(bg)
	B.CreateSD(bg)
	B.CreateTex(bg)
	if NDuiDB["Actionbar"]["Classcolor"] then
		bg:SetBackdropColor(DB.cc.r, DB.cc.g, DB.cc.b, .25)
	else
		bg:SetBackdropColor(.2, .2, .2, .25)
	end
end

local replaces = {
	{"(Mouse Button )", "M"},
	{"(鼠标按键)", "M"},
	{"(滑鼠按鍵)", "M"},
	{"(a%-)", "a"},
	{"(c%-)", "c"},
	{"(s%-)", "s"},
	{KEY_BUTTON3, "M3"},
	{KEY_MOUSEWHEELUP, "MU"},
	{KEY_MOUSEWHEELDOWN, "MD"},
	{KEY_SPACE, "Sp"},
	{CAPSLOCK_KEY_TEXT, "CL"},
}

function B:UpdateHotKey()
	local hotkey = _G[self:GetName().."HotKey"]
	if hotkey and hotkey:IsShown() and not NDuiDB["Actionbar"]["Hotkeys"] then
		hotkey:Hide()
		return
	end

	local text = hotkey:GetText()
	if not text then return end

	for _, value in pairs(replaces) do
		text = gsub(text, value[1], value[2])
	end

	if text == RANGE_INDICATOR then
		hotkey:SetText("")
	else
		hotkey:SetText(text)
	end
end

function B:StyleActionButton(button, cfg)
	if not button then return end
	if button.__styled then return end

	local buttonName = button:GetName()
	local icon = _G[buttonName.."Icon"]
	local flash = _G[buttonName.."Flash"]
	local flyoutBorder = _G[buttonName.."FlyoutBorder"]
	local flyoutBorderShadow = _G[buttonName.."FlyoutBorderShadow"]
	local hotkey = _G[buttonName.."HotKey"]
	local count = _G[buttonName.."Count"]
	local name = _G[buttonName.."Name"]
	local border = _G[buttonName.."Border"]
	local NewActionTexture = button.NewActionTexture
	local cooldown = _G[buttonName.."Cooldown"]
	local normalTexture = button:GetNormalTexture()
	local pushedTexture = button:GetPushedTexture()
	local highlightTexture = button:GetHighlightTexture()
	--normal buttons do not have a checked texture, but checkbuttons do and normal actionbuttons are checkbuttons
	local checkedTexture = nil
	if button.GetCheckedTexture then checkedTexture = button:GetCheckedTexture() end
	local floatingBG = _G[buttonName.."FloatingBG"]

	--hide stuff
	if floatingBG then floatingBG:Hide() end
	if NewActionTexture then NewActionTexture:SetTexture(nil) end

	--backdrop
	SetupBackdrop(button)

	--textures
	SetupTexture(icon, cfg.icon, "SetTexture", icon)
	SetupTexture(flash, cfg.flash, "SetTexture", flash)
	SetupTexture(flyoutBorder, cfg.flyoutBorder, "SetTexture", flyoutBorder)
	SetupTexture(flyoutBorderShadow, cfg.flyoutBorderShadow, "SetTexture", flyoutBorderShadow)
	SetupTexture(border, cfg.border, "SetTexture", border)
	SetupTexture(normalTexture, cfg.normalTexture, "SetNormalTexture", button)
	SetupTexture(pushedTexture, cfg.pushedTexture, "SetPushedTexture", button)
	SetupTexture(highlightTexture, cfg.highlightTexture, "SetHighlightTexture", button)
	SetupTexture(checkedTexture, cfg.checkedTexture, "SetCheckedTexture", button)
	highlightTexture:SetColorTexture(1, 1, 1, .25)

	--cooldown
	SetupCooldown(cooldown, cfg.cooldown)

	--no clue why but blizzard created count and duration on background layer, need to fix that
	local overlay = CreateFrame("Frame", nil, button)
	overlay:SetAllPoints()
	if count then
		if NDuiDB["Actionbar"]["Count"] then
			count:SetParent(overlay)
			SetupFontString(count, cfg.count)
		else
			count:Hide()
		end
	end
	if hotkey then
		if NDuiDB["Actionbar"]["Hotkeys"] then
			hotkey:SetParent(overlay)
			B.UpdateHotKey(button)
			SetupFontString(hotkey, cfg.hotkey)
		else
			hotkey:Hide()
		end
	end
	if name then
		if NDuiDB["Actionbar"]["Macro"] then
			name:SetParent(overlay)
			SetupFontString(name, cfg.name)
		else
			name:Hide()
		end
	end

	button.__styled = true
end

function B:StyleExtraActionButton(cfg)
	local button = ExtraActionButton1
	if button.__styled then return end

	local buttonName = button:GetName()
	local icon = _G[buttonName.."Icon"]
	--local flash = _G[buttonName.."Flash"] --wierd the template has two textures of the same name
	local hotkey = _G[buttonName.."HotKey"]
	local count = _G[buttonName.."Count"]
	local buttonstyle = button.style --artwork around the button
	local cooldown = _G[buttonName.."Cooldown"]

	local normalTexture = button:GetNormalTexture()
	local pushedTexture = button:GetPushedTexture()
	local highlightTexture = button:GetHighlightTexture()
	local checkedTexture = button:GetCheckedTexture()

	--backdrop
	SetupBackdrop(button)

	--textures
	SetupTexture(icon, cfg.icon, "SetTexture", icon)
	SetupTexture(buttonstyle, cfg.buttonstyle, "SetTexture", buttonstyle)
	SetupTexture(normalTexture, cfg.normalTexture, "SetNormalTexture", button)
	SetupTexture(pushedTexture, cfg.pushedTexture, "SetPushedTexture", button)
	SetupTexture(highlightTexture, cfg.highlightTexture, "SetHighlightTexture", button)
	SetupTexture(checkedTexture, cfg.checkedTexture, "SetCheckedTexture", button)
	highlightTexture:SetColorTexture(1, 1, 1, .25)

	--cooldown
	SetupCooldown(cooldown, cfg.cooldown)

	--hotkey, count
	if NDuiDB["Actionbar"]["Hotkeys"] then
		B.UpdateHotKey(button)
		SetupFontString(hotkey, cfg.hotkey)
	else
		hotkey:Hide()
	end
	if NDuiDB["Actionbar"]["Count"] then
		SetupFontString(count, cfg.count)
	else
		count:Hide()
	end

	button.__styled = true
end

function B:StyleAllActionButtons(cfg)
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		B:StyleActionButton(_G["ActionButton"..i], cfg)
		B:StyleActionButton(_G["MultiBarBottomLeftButton"..i], cfg)
		B:StyleActionButton(_G["MultiBarBottomRightButton"..i], cfg)
		B:StyleActionButton(_G["MultiBarRightButton"..i], cfg)
		B:StyleActionButton(_G["MultiBarLeftButton"..i], cfg)
	end
	for i = 1, 6 do
		B:StyleActionButton(_G["OverrideActionBarButton"..i], cfg)
	end
	--petbar buttons
	for i = 1, NUM_PET_ACTION_SLOTS do
		B:StyleActionButton(_G["PetActionButton"..i], cfg)
	end
	--stancebar buttons
	for i = 1, NUM_STANCE_SLOTS do
		B:StyleActionButton(_G["StanceButton"..i], cfg)
	end
	--possess buttons
	for i = 1, NUM_POSSESS_SLOTS do
		B:StyleActionButton(_G["PossessButton"..i], cfg)
	end
	--extra action button
	B:StyleExtraActionButton(cfg)
	--spell flyout
	SpellFlyoutBackgroundEnd:SetTexture(nil)
	SpellFlyoutHorizontalBackground:SetTexture(nil)
	SpellFlyoutVerticalBackground:SetTexture(nil)
	local function checkForFlyoutButtons()
		local i = 1
		local button = _G["SpellFlyoutButton"..i]
		while button and button:IsShown() do
			B:StyleActionButton(button, cfg)
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
				{"TOPLEFT", 1, -1},
				{"BOTTOMRIGHT", -1, 1},
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
				{"TOPLEFT", 0, 0},
				{"BOTTOMRIGHT", 0, 0},
			},
		},
		flash = {file = DB.textures.flash},
		pushedTexture = {file = DB.textures.pushed},
		checkedTexture = {file = DB.textures.checked},
		highlightTexture = {
			file = "",
			points = {
				{"TOPLEFT", 1, -1},
				{"BOTTOMRIGHT", -1, 1},
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
		buttonstyle = { file = ""},
	}
	B:StyleAllActionButtons(cfg)
	hooksecurefunc("ActionButton_UpdateHotkeys", B.UpdateHotKey)
end