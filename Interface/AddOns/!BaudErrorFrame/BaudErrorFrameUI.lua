local _, BEF = ...
local ROW_HEIGHT = 22
local selectionColor = {1, .82, 0}

local frame = CreateFrame("Frame", "BaudErrorFrame", UIParent, "DefaultPanelTemplate")
frame:Hide()
frame:SetSize(600, 520)
frame:SetPoint("CENTER")
frame:SetFrameStrata("DIALOG")
frame:SetToplevel(true)
frame:EnableMouse(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
tinsert(UISpecialFrames, frame:GetName())
frame.TitleContainer.TitleText:SetText(SHOW_LUA_ERRORS)
frame.CloseButton = CreateFrame("Button", nil, frame, "UIPanelCloseButtonDefaultAnchors")

local function CreateLabel(parent, text)
	local label = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	label:SetText(text)
	label:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", 0, 3)
	return label
end

local function CreateScrollBar(name, parent)
	local scrollBar = CreateFrame("EventFrame", name, parent, "MinimalScrollBar")
	scrollBar:SetPoint("TOPRIGHT", -10, -2)
	scrollBar:SetPoint("BOTTOMRIGHT", -10, 2)
	return scrollBar
end

local list = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
list:SetHeight(162)
list:SetPoint("TOPLEFT", 16, -50)
list:SetPoint("TOPRIGHT", -16, -50)
CreateLabel(list, ERRORS)

local listScroll = CreateFrame("Frame", "BaudErrorFrameListScrollBox", list, "WowScrollBoxList")
listScroll:SetPoint("TOPLEFT", 4, -4)
listScroll:SetPoint("BOTTOMRIGHT", -30, 4)
local listScrollBar = CreateScrollBar("BaudErrorFrameListScrollBar", list)
local dataProvider = CreateDataProvider()

local detail = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
detail:SetPoint("TOPLEFT", 16, -242)
detail:SetPoint("BOTTOMRIGHT", -16, 48)
CreateLabel(detail, QUEST_DESCRIPTION)

local detailScroll = CreateFrame("Frame", "BaudErrorFrameDetailScrollBox", detail, "WowScrollBox")
detailScroll:SetPoint("TOPLEFT", 4, -4)
detailScroll:SetPoint("BOTTOMRIGHT", -30, 4)
local detailScrollBar = CreateScrollBar("BaudErrorFrameDetailScrollBar", detail)

local editBox = CreateFrame("EditBox", "BaudErrorFrameEditBox", detailScroll)
editBox:SetSize(526, 1)
editBox:SetAutoFocus(false)
editBox:SetMultiLine(true)
editBox:SetFontObject(ChatFontNormal)
editBox:SetTextInsets(4, 4, 4, 4)
editBox.TextShown = ""
editBox.scrollable = true
local detailView = CreateScrollBoxLinearView(0, 8, 0, 0, 0)
detailView:SetPanExtent(ROW_HEIGHT)
ScrollUtil.InitScrollBoxWithScrollBar(detailScroll, detailScrollBar, detailView)

editBox:SetScript("OnEscapePressed", editBox.ClearFocus)
editBox:SetScript("OnTextChanged", function(self, userInput)
	-- GetText() can return a secret; never read it back for comparison.
	if userInput then
		self:SetText(self.TextShown)
		self:ClearFocus()
	end
	detailScroll:FullUpdate(ScrollBoxConstants.UpdateImmediately)
end)
editBox:SetScript("OnCursorChanged", function(_, _, y, _, height)
	local range = detailScroll:GetDerivedScrollRange()
	if range <= 0 then return end
	local offset = detailScroll:GetDerivedScrollOffset()
	local cursorTop, cursorBottom = -y, -y + height
	local visibleHeight = detailScroll:GetVisibleExtent()
	if cursorTop < offset then
		detailScroll:SetScrollPercentage(math.max(0, cursorTop / range), ScrollBoxConstants.NoScrollInterpolation)
	elseif cursorBottom > offset + visibleHeight then
		detailScroll:SetScrollPercentage(math.min(1, (cursorBottom - visibleHeight) / range), ScrollBoxConstants.NoScrollInterpolation)
	end
end)
frame:SetScript("OnHide", function() editBox:ClearFocus() end)

local function UpdateDetails()
	local entry = BEF.errors[BEF.selected]
	local text = entry and BEF.GetDetail(entry) or ""
	if editBox.TextShown ~= text then
		editBox.TextShown = text
		editBox:SetText(text)
		editBox:SetCursorPosition(0)
		detailScroll:ScrollToBegin(ScrollBoxConstants.NoScrollInterpolation)
	end
end

local function SelectError(self)
	BEF.selected = dataProvider:FindIndex(self:GetElementData())
	listScroll:ReinitializeFrames()
	UpdateDetails()
	detailScroll:ScrollToBegin(ScrollBoxConstants.NoScrollInterpolation)
end

local view = CreateScrollBoxListLinearView()
view:SetElementExtent(ROW_HEIGHT)
view:SetElementInitializer("Button", function(row, entry)
	if not row.Text then
		row.Text = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		row.Text:SetPoint("LEFT", 6, 0)
		row.Text:SetPoint("RIGHT", -6, 0)
		row.Text:SetJustifyH("LEFT")
		row.Text:SetWordWrap(false)
		row.Selection = row:CreateTexture(nil, "BACKGROUND")
		row.Selection:SetAllPoints()
		local highlight = row:CreateTexture(nil, "HIGHLIGHT")
		highlight:SetAllPoints()
		highlight:SetColorTexture(1, 1, 1, .08)
		row:SetScript("OnClick", SelectError)
	end
	row.Text:SetText(BEF.GetSummary(entry))
	row.Selection:SetColorTexture(selectionColor[1], selectionColor[2], selectionColor[3], .25)
	row.Selection:SetShown(entry == BEF.errors[BEF.selected])
end)
ScrollUtil.InitScrollBoxListWithScrollBar(listScroll, listScrollBar, view)
listScroll:SetDataProvider(dataProvider)

local function UpdateList()
	if dataProvider:Find(1) ~= BEF.errors[1] then
		dataProvider:Flush()
		listScroll:ScrollToBegin(ScrollBoxConstants.NoScrollInterpolation)
	end
	dataProvider:InsertTableRange(BEF.errors, dataProvider:GetSize() + 1, #BEF.errors)
	listScroll:ReinitializeFrames()
	UpdateDetails()
end
frame:SetScript("OnShow", UpdateList)

local function CreateButton(name, text, onClick)
	local button = CreateFrame("Button", name, frame, "UIPanelButtonTemplate")
	button:SetSize(100, 22)
	button:SetText(text)
	button:SetScript("OnClick", onClick)
	return button
end

local reloadButton = CreateButton("BaudErrorFrameReloadUIButton", RELOADUI, ReloadUI)
reloadButton:SetPoint("BOTTOMLEFT", 16, 12)
local closeButton = CreateButton("BaudErrorFrameCloseButton", CLOSE, function() frame:Hide() end)
closeButton:SetPoint("BOTTOMRIGHT", -16, 12)
local clearButton = CreateButton("BaudErrorFrameClearButton", CLEAR_ALL, function()
	BEF.Clear()
	UpdateList()
	frame:Hide()
end)
clearButton:SetPoint("RIGHT", closeButton, "LEFT", -5, 0)

local function HideTooltip()
	GameTooltip:Hide()
end

local minimapButton = CreateFrame("Button", "BaudErrorFrameMinimapButton", UIParent)
minimapButton:Hide()
minimapButton:SetSize(22, 22)
minimapButton:SetFrameStrata("DIALOG")
minimapButton:RegisterForClicks("LeftButtonUp")
local minimapCount = minimapButton:CreateFontString("BaudErrorFrameMinimapCount", "OVERLAY", "ChatFontNormal")
local font, _, flags = minimapCount:GetFont()
minimapCount:SetFont(font, 18, flags)
minimapCount:SetTextColor(1, 0, 0, .8)
minimapCount:SetPoint("CENTER", -1, 2)
minimapButton:SetScript("OnClick", function() frame:Show() end)
minimapButton:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
	GameTooltip:AddLine(SHOW_LUA_ERRORS)
	if L_ERRORFRAME_L then GameTooltip:AddLine(L_ERRORFRAME_L, 1, 1, 1) end
	GameTooltip:Show()
end)
minimapButton:SetScript("OnLeave", HideTooltip)

local function UpdateMinimapAnchor()
	minimapButton:ClearAllPoints()
	if C_AddOns.IsAddOnLoaded("NDui") then
		minimapButton:SetPoint("BOTTOMRIGHT", UIParent)
	else
		minimapButton:SetPoint("TOPRIGHT", Minimap)
	end
end
minimapButton:SetScript("OnShow", UpdateMinimapAnchor)

local soundButton = CreateFrame("Button", nil, frame)
soundButton:SetSize(25, 25)
soundButton:SetPoint("TOPRIGHT", -30, -24)
local soundIcon = soundButton:CreateTexture(nil, "ARTWORK")
soundIcon:SetAllPoints()
soundIcon:SetTexture([[Interface\COMMON\VOICECHAT-SPEAKER]])
local function UpdateSoundColor()
	if BEF.GetConfig().enableSound then
		soundIcon:SetVertexColor(1, 1, 0)
	else
		soundIcon:SetVertexColor(1, 0, 0)
	end
end
local function ShowSoundTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
	GameTooltip:AddLine(SOUND..": "..(BEF.GetConfig().enableSound and "|cff00ff00"..ENABLE or "|cffff0000"..DISABLE))
	GameTooltip:Show()
end
soundButton:SetScript("OnShow", UpdateSoundColor)
soundButton:SetScript("OnEnter", ShowSoundTooltip)
soundButton:SetScript("OnLeave", HideTooltip)
soundButton:SetScript("OnClick", function(self)
	local config = BEF.GetConfig()
	config.enableSound = not config.enableSound
	UpdateSoundColor()
	PlaySound(48942, "Master")
	ShowSoundTooltip(self)
end)

local displayedCount
function BEF.Refresh()
	local total = #BEF.errors
	if total ~= displayedCount then
		displayedCount = total
		minimapCount:SetText(total)
	end
	minimapButton:SetShown(total > 0)
	if frame:IsShown() then UpdateList() end
end

local taintMessages = {
	ADDON_ACTION_BLOCKED = "%s blocked from using %s",
	MACRO_ACTION_BLOCKED = "Macro blocked from using %s",
	ADDON_ACTION_FORBIDDEN = "%s forbidden from using %s (Only usable by Blizzard)",
	MACRO_ACTION_FORBIDDEN = "Macro forbidden from using %s (Only usable by Blizzard)",
}

local function ApplyNDuiSkin()
	if not C_AddOns.IsAddOnLoaded("NDui") then return end
	local B, _, _, DB = unpack(NDui)
	if DB.isDeveloper then
		for event in pairs(taintMessages) do
			frame:RegisterEvent(event)
			UIParent:UnregisterEvent(event)
		end
	end
	B.CreateMF(frame)
	B.StripTextures(frame)
	frame.NineSlice:Hide()
	B.SetBD(frame)
	B.ReskinClose(frame.CloseButton)
	B.StripTextures(list)
	list.NineSlice:Hide()
	B.CreateBDFrame(list, .25)
	B.StripTextures(detail)
	detail.NineSlice:Hide()
	B.CreateBDFrame(detail, .25)
	selectionColor = {DB.r, DB.g, DB.b}
	listScroll:ReinitializeFrames()
	B.ReskinTrimScroll(detailScrollBar)
	B.ReskinTrimScroll(listScrollBar)
	B.Reskin(clearButton)
	B.Reskin(closeButton)
	B.Reskin(reloadButton)
end

frame:RegisterEvent("VARIABLES_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self, event, ...)
	if event == "VARIABLES_LOADED" then
		BEF.GetConfig()
		self:UnregisterEvent(event)
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent(event)
		ApplyNDuiSkin()
		UpdateMinimapAnchor()
	else
		local message = taintMessages[event]
		if message then
			local addon, action = ...
			BaudErrorFrameAdd(message:format(BEF.PrepareText(addon, "unknown"), BEF.PrepareText(action, "unknown")), 4)
		end
	end
end)

SlashCmdList["BaudErrorFrame"] = function() frame:SetShown(not frame:IsShown()) end
SLASH_BaudErrorFrame1 = "/bauderror"
SLASH_BaudErrorFrame2 = "/bef"
BEF.Refresh()
