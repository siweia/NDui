local F, C = unpack(select(2, ...))

-- [[ Localizations ]]

local locale, L = GetLocale(), {}
if locale == "zhCN" then
	L["Features"] = "模块"
	L["Bags"] = "背包"
	L["ChatBubbles"] = "聊天泡泡"
	L["ChatBubblesColor"] = "聊天泡泡边框染色"
	L["Loot"] = "拾取框"
	L["Tooltips"] = "鼠标提示框"
	L["Shadow Border"] = "阴影边框"
	L["Appearance"] = "外观"
	L["Replace default game fonts"] = "全局字体黑色描边"
	L["Custom Color"] = "自定义按键高亮颜色"
	L["Change"] = "点击修改"
	L["Button Gradient"] = "按键颜色渐变"
	L["Opacity"] = "背景透明度*"
	L["Reload Text"] = "不带星号(*)的设置需要重载插件后生效。"
	L["FontScale"] = "字体缩放"
elseif locale == "zhTW" then
	L["Features"] = "模塊"
	L["Bags"] = "背包"
	L["ChatBubbles"] = "聊天泡泡"
	L["ChatBubblesColor"] = "聊天泡泡邊框染色"
	L["Loot"] = "拾取框"
	L["Tooltips"] = "滑鼠提示框"
	L["Shadow Border"] = "陰影邊框"
	L["Appearance"] = "外觀"
	L["Replace default game fonts"] = "全局字體黑色描邊"
	L["Custom Color"] = "自定義按键高亮顏色"
	L["Change"] = "點擊修改"
	L["Button Gradient"] = "按鍵顏色漸變"
	L["Opacity"] = "背景透明度*"
	L["Reload Text"] = "不帶星標(*)的設置需要重載插件後生效。"
	L["FontScale"] = "字體縮放"
else
	L["Features"] = "Features"
	L["Bags"] = "Bags"
	L["ChatBubbles"] = "Chat Bubbles"
	L["ChatBubblesColor"] = "Colored Chat Bubbles"
	L["Loot"] = "Loot Frame"
	L["Tooltips"] = "Tooltips"
	L["Shadow Border"] = "Shadow Border"
	L["Appearance"] = "Appearance"
	L["Replace default game fonts"] = "Global Font Outline"
	L["Custom Color"] = "Custom Highlight Color"
	L["Change"] = "Change..."
	L["Button Gradient"] = "Button Gradient Color"
	L["Opacity"] = "Backdrop Opactiy*"
	L["Reload Text"] = "Settings not marked with an asterisk (*) require a UI reload."
	L["FontScale"] = "Font Scale"
end

-- [[ Options UI ]]

-- these variables are loaded on init and updated only on gui.okay. Calling gui.cancel resets the saved vars to these
local old, checkboxes = {}, {}

-- function to copy table contents and inner table
local function copyTable(source, target)
	for key, value in pairs(source) do
		if type(value) == "table" then
			target[key] = {}
			for k in pairs(value) do
				target[key][k] = value[k]
			end
		else
			target[key] = value
		end
	end
end

local function addSubCategory(parent, name)
	local header = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	header:SetText(name)

	local line = parent:CreateTexture(nil, "ARTWORK")
	line:SetSize(610, 1)
	line:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -4)
	line:SetColorTexture(1, 1, 1, .2)

	return header
end

local function toggle(f)
	AuroraConfig[f.value] = f:GetChecked()
end

local function createToggleBox(parent, value, text, disable)
	local f = CreateFrame("CheckButton", "$parent"..value, parent, "InterfaceOptionsCheckButtonTemplate")
	f.value = value
	f.Text:SetText(text)
	f:SetScript("OnClick", toggle)
	if disable then
		f:Disable()
		f.Text:SetTextColor(.5, .5, .5)
	end

	tinsert(checkboxes, f)
	return f
end

-- create frames/widgets

local oncall = CreateFrame("Frame", "AuroraCallingFrame", UIParent)
oncall.name = "AuroraClassic"
InterfaceOptions_AddCategory(oncall)

local header = oncall:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
header:SetPoint("TOPLEFT", 20, -26)
header:SetText("|cff0080ffAuroraClassic|r "..GetAddOnMetadata("AuroraClassic", "Version"))

local bu = CreateFrame("Button", nil, oncall, "UIPanelButtonTemplate")
bu:SetSize(120, 25)
bu:SetPoint("TOPLEFT", 20, -56)
bu:SetText(SETTINGS)
bu:SetScript("OnClick", function()
	while CloseWindows() do end
	SlashCmdList.AURORA()
end)

local gui = CreateFrame("Frame", "AuroraOptions", UIParent)
gui.name = "AuroraClassic"
gui:SetSize(640, 550)
gui:SetPoint("CENTER")
gui:Hide()
tinsert(UISpecialFrames, "AuroraOptions")

local cancel = CreateFrame("Button", nil, gui, "UIPanelButtonTemplate")
cancel:SetSize(100, 20)
cancel:SetPoint("BOTTOMRIGHT", -10, 10)
cancel:SetText(CANCEL)

local okay = CreateFrame("Button", nil, gui, "UIPanelButtonTemplate")
okay:SetSize(100, 22)
okay:SetPoint("RIGHT", cancel, "LEFT", -5, 0)
okay:SetText(OKAY)

local default = CreateFrame("Button", nil, gui, "UIPanelButtonTemplate")
default:SetSize(100, 22)
default:SetPoint("BOTTOMLEFT", 10, 10)
default:SetText(DEFAULTS)

local title = gui:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 36, -26)
title:SetText("|cff0080ffAuroraClassic|r "..GetAddOnMetadata("AuroraClassic", "Version").." |cffffffff("..COMMAND.." /ac)")

local features = addSubCategory(gui, L["Features"])
features:SetPoint("TOPLEFT", 16, -80)

local shadowBox = createToggleBox(gui, "shadow", L["Shadow Border"])
shadowBox:SetPoint("TOPLEFT", features, "BOTTOMLEFT", 0, -20)

local chatBubbleBox = createToggleBox(gui, "chatBubbles", L["ChatBubbles"])
chatBubbleBox:SetPoint("LEFT", shadowBox, "RIGHT", 110, 0)

local bubbleColorBox = createToggleBox(gui, "bubbleColor", L["ChatBubblesColor"])
bubbleColorBox:SetPoint("LEFT", chatBubbleBox, "RIGHT", 110, 0)

local lootBox = createToggleBox(gui, "loot", L["Loot"])
lootBox:SetPoint("TOPLEFT", shadowBox, "BOTTOMLEFT", 0, -8)

local bagsBox = createToggleBox(gui, "bags", L["Bags"])
bagsBox:SetPoint("LEFT", lootBox, "RIGHT", 110, 0)

local tooltipsBox = createToggleBox(gui, "tooltips", L["Tooltips"])
tooltipsBox:SetPoint("LEFT", bagsBox, "RIGHT", 110, 0)

local appearance = addSubCategory(gui, L["Appearance"])
appearance:SetPoint("TOPLEFT", lootBox, "BOTTOMLEFT", 0, -30)

local useButtonGradientColourBox = createToggleBox(gui, "useButtonGradientColour", L["Button Gradient"])
useButtonGradientColourBox:SetPoint("TOPLEFT", appearance, "BOTTOMLEFT", 0, -20)

local colourBox = createToggleBox(gui, "useCustomColour", L["Custom Color"])
colourBox:SetPoint("TOPLEFT", useButtonGradientColourBox, "BOTTOMLEFT", 0, -8)

local colourButton = CreateFrame("Button", nil, gui, "UIPanelButtonTemplate")
colourButton:SetPoint("LEFT", colourBox.Text, "RIGHT", 20, 0)
colourButton:SetSize(128, 25)
colourButton:SetText(L["Change"])

local fontBox = createToggleBox(gui, "reskinFont", L["Replace default game fonts"])
fontBox:SetPoint("TOPLEFT", colourBox, "BOTTOMLEFT", 0, -8)

local fontSlider = CreateFrame("Slider", "AuroraOptionsfontSlider", gui, "OptionsSliderTemplate")
fontSlider:SetPoint("TOPLEFT", fontBox, "BOTTOMLEFT", 20, -30)
fontSlider:SetMinMaxValues(.5, 1)
fontSlider:SetValueStep(0.1)
AuroraOptionsfontSliderText:SetText(L["FontScale"])
AuroraOptionsfontSliderLow:SetText(.5)
AuroraOptionsfontSliderHigh:SetText(1)

local fontValue = fontSlider:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
fontValue:SetPoint("TOP", fontSlider, "BOTTOM", 0, 4)

local alphaSlider = CreateFrame("Slider", "AuroraOptionsAlpha", gui, "OptionsSliderTemplate")
alphaSlider:SetPoint("LEFT", fontSlider, "RIGHT", 100, 0)
alphaSlider:SetMinMaxValues(0, 1)
alphaSlider:SetValueStep(0.1)
AuroraOptionsAlphaText:SetText(L["Opacity"])

local line = gui:CreateTexture(nil, "ARTWORK")
line:SetSize(610, 1)
line:SetPoint("TOPLEFT", fontSlider, "BOTTOMLEFT", -20, -30)
line:SetColorTexture(1, 1, 1, .2)

local reloadText = gui:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
reloadText:SetPoint("TOPLEFT", line, "BOTTOMLEFT", 0, -40)
reloadText:SetText(L["Reload Text"])

local reloadButton = CreateFrame("Button", nil, gui, "UIPanelButtonTemplate")
reloadButton:SetPoint("LEFT", reloadText, "RIGHT", 20, 0)
reloadButton:SetSize(128, 25)
reloadButton:SetText(RELOADUI)

local credits = gui:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
credits:SetText("AuroraClassic by Lightsword, Haleth, Siweia.")
credits:SetPoint("BOTTOM", 0, 40)

-- add event handlers

local guiRefresh = function()
	alphaSlider:SetValue(AuroraConfig.alpha)
	fontSlider:SetValue(AuroraConfig.fontScale)
	fontValue:SetText(AuroraConfig.fontScale)
	if AuroraConfig.reskinFont then
		fontSlider:Enable()
		AuroraOptionsfontSliderText:SetTextColor(1, 1, 1)
	else
		fontSlider:Disable()
		AuroraOptionsfontSliderText:SetTextColor(.5, .5, .5)
	end

	for i = 1, #checkboxes do
		checkboxes[i]:SetChecked(AuroraConfig[checkboxes[i].value] == true)
	end

	if not colourBox:GetChecked() then
		colourButton:Disable()
	end
end

gui:RegisterEvent("ADDON_LOADED")
gui:SetScript("OnEvent", function(self, _, addon)
	if addon ~= "AuroraClassic" then return end

	-- fill 'old' table
	copyTable(AuroraConfig, old)

	F.CreateBD(gui)
	F.CreateSD(gui)
	F.Reskin(bu)
	F.Reskin(okay)
	F.Reskin(cancel)
	F.Reskin(default)
	F.Reskin(reloadButton)
	F.Reskin(colourButton)
	F.ReskinSlider(alphaSlider)
	F.ReskinSlider(fontSlider)

	for i = 1, #checkboxes do
		F.ReskinCheck(checkboxes[i])
	end

	guiRefresh()
	self:UnregisterEvent("ADDON_LOADED")
end)

local function updateFrames()
	for i = 1, #C.frames do
		F.CreateBD(C.frames[i], AuroraConfig.alpha)
	end
end

local guiOkay = function()
	copyTable(AuroraConfig, old)
	gui:Hide()
end

local guiCancel = function()
	copyTable(old, AuroraConfig)

	updateFrames()
	guiRefresh()
	gui:Hide()
end

local guiDefault = function()
	copyTable(C.defaults, AuroraConfig)

	updateFrames()
	guiRefresh()
end

reloadButton:SetScript("OnClick", ReloadUI)
okay:SetScript("OnClick", guiOkay)
cancel:SetScript("OnClick", guiCancel)
default:SetScript("OnClick", guiDefault)

alphaSlider:SetScript("OnValueChanged", function(_, value)
	AuroraConfig.alpha = value
	updateFrames()
end)

fontBox:HookScript("OnClick", function(self)
	if self:GetChecked() then
		fontSlider:Enable()
		AuroraOptionsfontSliderText:SetTextColor(1, 1, 1)
	else
		fontSlider:Disable()
		AuroraOptionsfontSliderText:SetTextColor(.5, .5, .5)
	end
end)

fontSlider:SetScript("OnValueChanged", function(_, value)
	value = tonumber(format("%.1f", value))
	AuroraConfig.fontScale = value
	fontValue:SetText(value)
end)

colourBox:SetScript("OnClick", function(self)
	if self:GetChecked() then
		AuroraConfig.useCustomColour = true
		colourButton:Enable()
	else
		AuroraConfig.useCustomColour = false
		colourButton:Disable()
	end
end)

local function setColour()
	AuroraConfig.customColour.r, AuroraConfig.customColour.g, AuroraConfig.customColour.b = ColorPickerFrame:GetColorRGB()
end

local function resetColour(restore)
	AuroraConfig.customColour.r, AuroraConfig.customColour.g, AuroraConfig.customColour.b = restore.r, restore.g, restore.b
end

colourButton:SetScript("OnClick", function()
	local r, g, b = AuroraConfig.customColour.r, AuroraConfig.customColour.g, AuroraConfig.customColour.b
	ColorPickerFrame:SetColorRGB(r, g, b)
	ColorPickerFrame.previousValues = {r = r, g = g, b = b}
	ColorPickerFrame.func = setColour
	ColorPickerFrame.cancelFunc = resetColour
	ColorPickerFrame:Hide()
	ColorPickerFrame:Show()
end)

-- easy slash command

SlashCmdList.AURORA = function()
	ToggleFrame(gui)
end
SLASH_AURORA1 = "/ac"