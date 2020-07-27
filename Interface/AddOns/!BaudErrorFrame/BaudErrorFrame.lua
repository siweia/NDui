local SelectedError = 1
local ErrorList = {}
local SoundTime = 0
local enableTaint = false
BaudErrorFrameConfig = BaudErrorFrameConfig or {}

local function RegisterTaintEvents(self)
	self:RegisterEvent("ADDON_ACTION_BLOCKED")
	self:RegisterEvent("MACRO_ACTION_BLOCKED")
	self:RegisterEvent("ADDON_ACTION_FORBIDDEN")
	self:RegisterEvent("MACRO_ACTION_FORBIDDEN")
end

function BaudErrorFrame_OnLoad(self)
	self:RegisterEvent("VARIABLES_LOADED")
	if enableTaint then
		RegisterTaintEvents(self)
	end

	UIParent:UnregisterEvent("MACRO_ACTION_BLOCKED")
	UIParent:UnregisterEvent("ADDON_ACTION_BLOCKED")
	UIParent:UnregisterEvent("MACRO_ACTION_FORBIDDEN")
	UIParent:UnregisterEvent("ADDON_ACTION_FORBIDDEN")

	tinsert(UISpecialFrames, self:GetName())
	SlashCmdList["BaudErrorFrame"] = function()
		if BaudErrorFrame:IsShown() then
			BaudErrorFrame:Hide()
		else
			BaudErrorFrame:Show()
		end
	end
	SLASH_BaudErrorFrame1 = "/bauderror"
	SLASH_BaudErrorFrame2 = "/bef"
	seterrorhandler(BaudErrorFrameHandler)

	local soundButton = CreateFrame("Frame", nil, BaudErrorFrame)
	soundButton:SetSize(25, 25)
	soundButton:SetPoint("TOPRIGHT", -10, -10)
	local icon = soundButton:CreateTexture(nil, "ARTWORK")
	icon:SetAllPoints()
	icon:SetTexture([[Interface\COMMON\VOICECHAT-SPEAKER]])

	local function updateColor()
		if BaudErrorFrameConfig.enableSound then
			icon:SetVertexColor(1, 1, 0)
		else
			icon:SetVertexColor(1, 0, 0)
		end
	end

	soundButton:SetScript("OnMouseUp", function(self)
		BaudErrorFrameConfig.enableSound = not BaudErrorFrameConfig.enableSound
		updateColor()
		PlaySound(48942, "Master")
		self:GetScript("OnEnter")(self)
	end)
	soundButton:SetScript("OnShow", updateColor)
	soundButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
		GameTooltip:AddLine(SOUND..": "..(BaudErrorFrameConfig.enableSound and "|cff00ff00"..ENABLE or "|cffff0000"..DISABLE))
		GameTooltip:Show()
	end)
	soundButton:SetScript("OnLeave", BaudErrorFrameMinimapButton_OnLeave)
end

function BaudErrorFrame_OnEvent(self, event, ...)
	local arg1, arg2 = ...
	if event == "VARIABLES_LOADED" then
		if type(BaudErrorFrameConfig) ~= "table" then
			BaudErrorFrameConfig = {}
		end
	elseif event == "ADDON_ACTION_BLOCKED" then
		BaudErrorFrameAdd(arg1.." blocked from using "..arg2, 4)
	elseif event == "MACRO_ACTION_BLOCKED" then
		BaudErrorFrameAdd("Macro blocked from using "..arg1, 4)
	elseif event == "ADDON_ACTION_FORBIDDEN" then
		BaudErrorFrameAdd(arg1.." forbidden from using "..arg2.." (Only usable by Blizzard)", 4)
	elseif event == "MACRO_ACTION_FORBIDDEN" then
		BaudErrorFrameAdd("Macro forbidden from using "..arg1.." (Only usable by Blizzard)", 4)
	end
end

function BaudErrorFrameMinimapButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
	GameTooltip:AddLine(SHOW_LUA_ERRORS)
	GameTooltip:AddLine(L_ERRORFRAME_L, 1, 1, 1)
	GameTooltip:Show()
end

function BaudErrorFrameMinimapButton_OnLeave()
	GameTooltip:Hide()
end

function BaudErrorFrameMinimapButton_OnUpdate(self)
	self:ClearAllPoints()
	if IsAddOnLoaded("NDui") then
		self:SetPoint("BOTTOMRIGHT", UIParent)
	else
		self:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 0, 0)
	end
end

function BaudErrorFrameHandler(Error)
	BaudErrorFrameAdd(Error, 3)
end

function BaudErrorFrameShowError(Error)
	if not BaudErrorFrameConfig.enableSound then return end

	if GetTime() > SoundTime then
		PlaySound(48942, "Master")
		SoundTime = GetTime() + 1
	end
end

function BaudErrorFrameAdd(Error, Retrace)
	if Error:match("script ran too long") then return end

	for _, Value in pairs(ErrorList) do
		if Value.Error == Error then
			if Value.Count < 99 then
				Value.Count = Value.Count + 1
				BaudErrorFrameEditBoxUpdate()
			end
			return
		end
	end

	BaudErrorFrameShowError(Error)
	tinsert(ErrorList, {Error = Error, Count = 1, Stack = debugstack(Retrace)})
	BaudErrorFrameMinimapCount:SetText(getn(ErrorList))
	BaudErrorFrameMinimapButton:Show()
	BaudErrorFrameScrollBar_Update()
end

function BaudErrorFrame_Select(Index)
	SelectedError = Index
	BaudErrorFrameScrollBar_Update()
	BaudErrorFrameDetailScrollFrameScrollBar:SetValue(0)
end

function BaudErrorFrame_OnShow()
	BaudErrorFrameScrollBar_Update()
end

function BaudErrorFrame_OnHide() end

function BaudErrorFrameEntry_OnClick(self)
	BaudErrorFrame_Select(self:GetID())
end

function BaudErrorFrameClearButton_OnClick(self)
	wipe(ErrorList)
	BaudErrorFrameMinimapButton:Hide()
	self:GetParent():Hide()
end

function BaudErrorFrameScrollValue()
	if ErrorList and type(ErrorList) == "table" then
		local value = getn(ErrorList)
		return value
	end
end

local function colorStack(ret)
	ret = tostring(ret) or "" -- Yes, it gets called with nonstring from somewhere /mikk
	ret = ret:gsub("[%.I][%.n][%.t][%.e][%.r]face\\", "")
	ret = ret:gsub("|([^chHr])", "||%1"):gsub("|$", "||") -- Pipes
	ret = ret:gsub("<(.-)>", "|cffffd200<%1>|r") -- Things wrapped in <>
	ret = ret:gsub("%[(.-)%]", "|cffffd200[%1]|r") -- Things wrapped in []
	ret = ret:gsub("([\"`'])(.-)([\"`'])", "|cff82c5ff%1%2%3|r") -- Quotes
	ret = ret:gsub(":(%d+)([%S\n])", ":|cff7fff7f%1|r%2") -- Line numbers
	ret = ret:gsub("([^\\]+%.lua)", "|cffffffff%1|r") -- Lua files
	return ret
end

function BaudErrorFrameScrollBar_Update()
	if not BaudErrorFrame:IsShown() then return end

	local Index, Button, ButtonText, Text
	local Frame = BaudErrorFrameListScrollBox
	local FrameName = Frame:GetName()
	local ScrollBar = _G[FrameName.."ScrollBar"]
	local Highlight = _G[FrameName.."Highlight"]
	local Total = getn(ErrorList)

	FauxScrollFrame_Update(ScrollBar, Total, Frame.Entries, 16)
	Highlight:Hide()
	for Line = 1, Frame.Entries do
		Index = Line + FauxScrollFrame_GetOffset(ScrollBar)
		Button = _G[FrameName.."Entry"..Line]
		ButtonText = _G[FrameName.."Entry"..Line.."Text"]
		if Index <= Total then
			Button:SetID(Index)
			ButtonText:SetText(colorStack(ErrorList[Index].Error))
			Button:Show()
			if Index == SelectedError then
				Highlight:SetPoint("TOP", Button)
				Highlight:Show()
			end
		else
			Button:Hide()
		end
	end
	BaudErrorFrameEditBoxUpdate()
end

function BaudErrorFrameEditBoxUpdate()
	if ErrorList[SelectedError] then
		BaudErrorFrameEditBox.TextShown = colorStack(ErrorList[SelectedError].Error.."\nCount: "..ErrorList[SelectedError].Count.."\n\nCall Stack:\n"..ErrorList[SelectedError].Stack)
	else
		BaudErrorFrameEditBox.TextShown = ""
	end
	BaudErrorFrameEditBox:SetText(BaudErrorFrameEditBox.TextShown)
end

function BaudErrorFrameEditBox_OnTextChanged(self)
	if self:GetText() ~= self.TextShown then
		self:SetText(self.TextShown)
		self:ClearFocus()
		return
	end
	BaudErrorFrameDetailScrollFrame:UpdateScrollChildRect()
end

function BaudErrorFrameEditBox_OnTextSet() end

-- Reskin
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
	f:UnregisterEvent("PLAYER_ENTERING_WORLD")

	if IsAddOnLoaded("NDui") then
		local B, _, _, DB = unpack(NDui)
		if DB.isDeveloper then
			RegisterTaintEvents(BaudErrorFrame)
		end
		B.CreateMF(BaudErrorFrame)
		B.SetBD(BaudErrorFrame)

		BaudErrorFrameBackground:SetAlpha(0)
		BaudErrorFrameDetailScrollBoxBackground:SetAlpha(0)
		BaudErrorFrameListScrollBoxHighlightTexture:SetVertexColor(DB.r, DB.g, DB.b, .25)
		B.CreateBDFrame(BaudErrorFrameDetailScrollBox, .25)

		B.ReskinScroll(BaudErrorFrameListScrollBoxScrollBarScrollBar)
		B.ReskinScroll(BaudErrorFrameDetailScrollFrameScrollBar)
		B.Reskin(BaudErrorFrameClearButton)
		B.Reskin(BaudErrorFrameCloseButton)
		B.Reskin(BaudErrorFrameReloadUIButton)
	end
end)