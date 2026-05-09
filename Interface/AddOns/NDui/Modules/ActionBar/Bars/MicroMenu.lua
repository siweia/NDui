local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

-- Texture credit: 胡里胡涂
local _G = getfenv(0)
local tinsert, pairs, type = table.insert, pairs, type
local buttonList, menubar = {}

function Bar:MicroButton_SetupTexture(icon, texture)
	local r, g, b = DB.r, DB.g, DB.b
	if not C.db["Skins"]["ClassLine"] then r, g, b = 0, 0, 0 end

	icon:SetOutside(nil, 3, 3)
	icon:SetTexture(DB.MicroTex..texture)
	icon:SetVertexColor(r, g, b)
end

local function ResetButtonParent(button, parent)
	if parent ~= button.__owner then
		button:SetParent(button.__owner)
	end
end

local function ResetButtonAnchor(button)
	button:ClearAllPoints()
	button:SetAllPoints()
end

local function ShowNewHighlight(self)
	self.newHL:Show()
end

local function HideNewHighlight(self)
	self.newHL:Hide()
end

local function ToggleSocialMicroMenu()
	-- NDui这里只保留一个图标入口
	if CVarCallbackRegistry:GetCVarValueBool("useClassicGuildUI") then
		ToggleFriendsFrame()
	else
		ToggleGuildFrame()
	end
end

local function TogglePVPMicroMenu()
	-- 直接调用暴雪PvP微型按钮原本执行的入口，避免原生按钮隐藏后丢失点击区域
	TogglePVPFrame()
end

local function ToggleLFGMicroMenu()
	-- 直接调用暴雪组队查找器入口，不可用状态由暴雪函数自身处理。
	PVEFrame_ToggleFrame()
end

function Bar:MicroButton_Create(parent, data, exclude)
	local texture, method, tooltip = unpack(data)

	local bu = CreateFrame("Frame", nil, parent)
	if not exclude then
		tinsert(buttonList, bu)
	end
	bu:SetSize(22, 22)

	local icon = bu:CreateTexture(nil, "ARTWORK")
	Bar:MicroButton_SetupTexture(icon, texture)

	if type(method) == "string" then
		local button = _G[method]
		button:SetHitRectInsets(0, 0, 0, 0)
		button:SetParent(bu)
		button.__owner = bu
		hooksecurefunc(button, "SetParent", ResetButtonParent)
		ResetButtonAnchor(button)
		hooksecurefunc(button, "SetPoint", ResetButtonAnchor)
		--button:UnregisterAllEvents() -- needs to update guild button visibility
		button:SetNormalTexture(0)
		button:SetPushedTexture(0)
		button:SetDisabledTexture(0)
		if tooltip then
			button.title = "|cffffffff"..tooltip
			B.AddTooltip(button, "ANCHOR_RIGHT", button.newbieText, "system")
		end

		button:GetHighlightTexture():SetAlpha(0)
		-- add a new highlight texture
		local newHL = button:CreateTexture(nil, "ARTWORK")
		newHL:SetBlendMode("ADD")
		newHL:Hide()
		Bar:MicroButton_SetupTexture(newHL, texture)
		if not C.db["Skins"]["ClassLine"] then newHL:SetVertexColor(1, 1, 1) end
		button.newHL = newHL
		button:HookScript("OnEnter", ShowNewHighlight)
		button:HookScript("OnLeave", HideNewHighlight)

		local flash = button.Flash
		Bar:MicroButton_SetupTexture(flash, texture)
		if not C.db["Skins"]["ClassLine"] then flash:SetVertexColor(1, 1, 1) end
	else
		-- 函数型按钮没有暴雪Button子框架，需要由外层框架直接接收鼠标点击。
		bu:EnableMouse(true)
		bu:SetScript("OnMouseUp", method)
		B.AddTooltip(bu, "ANCHOR_RIGHT", tooltip)

		local hl = bu:CreateTexture(nil, "HIGHLIGHT")
		hl:SetBlendMode("ADD")
		Bar:MicroButton_SetupTexture(hl, texture)
		if not C.db["Skins"]["ClassLine"] then hl:SetVertexColor(1, 1, 1) end
	end
end

function Bar:MicroMenu_Lines(parent)
	if not C.db["Skins"]["MenuLine"] then return end

	local cr, cg, cb = 0, 0, 0
	if C.db["Skins"]["ClassLine"] then cr, cg, cb = DB.r, DB.g, DB.b end

	local width, height = 200, 20
	local anchors = {
		["LEFT"] = {.5, 0},
		["RIGHT"] = {0, .5}
	}
	for anchor, v in pairs(anchors) do
		local frame = CreateFrame("Frame", nil, parent)
		frame:SetPoint(anchor, parent, "CENTER", 0, 0)
		frame:SetSize(width, height)
		frame:SetFrameStrata("BACKGROUND")

		local tex = B.SetGradient(frame, "H", 0, 0, 0, v[1], v[2], width, height)
		tex:SetPoint("CENTER")
		local bottomLine = B.SetGradient(frame, "H", cr, cg, cb, v[1], v[2], width-25, C.mult)
		bottomLine:SetPoint("TOP"..anchor, frame, "BOTTOM"..anchor, 0, 0)
		local topLine = B.SetGradient(frame, "H", cr, cg, cb, v[1], v[2], width+25, C.mult)
		topLine:SetPoint("BOTTOM"..anchor, frame, "TOP"..anchor, 0, 0)
	end
end

function Bar:MicroMenu_Setup()
	if not menubar then return end

	local size = C.db["Actionbar"]["MBSize"]
	local perRow = C.db["Actionbar"]["MBPerRow"]
	local margin = C.db["Actionbar"]["MBSpacing"]

	for i = 1, #buttonList do
		local button = buttonList[i]
		button:SetSize(size, size)
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("TOPLEFT")
		elseif mod(i-1, perRow) == 0 then
			button:SetPoint("TOP", buttonList[i-perRow], "BOTTOM", 0, -margin)
		else
			button:SetPoint("LEFT", buttonList[i-1], "RIGHT", margin, 0)
		end
	end

	local maxButtons = 12 -- total buttons
	local column = min(maxButtons, perRow)
	local rows = ceil(maxButtons/perRow)
	local width = column*size + (column-1)*margin
	local height = size*rows + (rows-1)*margin
	menubar:SetSize(width, height)
	menubar.mover:SetSize(width, height)
end

function Bar:MicroMenu()
	if not C.db["Actionbar"]["MicroMenu"] then return end

	menubar = CreateFrame("Frame", nil, UIParent)
	menubar:SetSize(323, 22)
	menubar.mover = B.Mover(menubar, L["Menubar"], "Menubar", C.Skins.MicroMenuPos)
	Bar:MicroMenu_Lines(menubar)

	StoreMicroButton:ClearAllPoints()
	StoreMicroButton:SetPoint("CENTER")
	StoreMicroButton:Show()

	-- Generate Buttons
	local buttonInfo = {
		{"player", "CharacterMicroButton", MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0")},
		{"spellbook", "SpellbookMicroButton", MicroButtonTooltipText(SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK")},
		{"talents", "TalentMicroButton", MicroButtonTooltipText(TALENTS, "TOGGLETALENTS")},
		{"achievements", "AchievementMicroButton", MicroButtonTooltipText(ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT")},
		{"quests", "QuestLogMicroButton", MicroButtonTooltipText(QUESTLOG_BUTTON, "TOGGLEQUESTLOG")},
		{"guild", ToggleSocialMicroMenu, MicroButtonTooltipText(SOCIAL_BUTTON, "TOGGLESOCIAL")},
		{"encounter", TogglePVPMicroMenu, MicroButtonTooltipText(PLAYER_V_PLAYER, "TOGGLECHARACTER4")},
		{"LFG", ToggleLFGMicroMenu, MicroButtonTooltipText(LFG_BUTTON, "TOGGLEGROUPFINDER")},
		{"collections", "CollectionsMicroButton", MicroButtonTooltipText(COLLECTIONS, "TOGGLECOLLECTIONS")},
		{"store", "StoreMicroButton", BLIZZARD_STORE},
		{"help", "MainMenuMicroButton", MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU")},
		{"bags", function() ToggleAllBags() end, MicroButtonTooltipText(BAGSLOT, "OPENALLBAGS")},
	}

	for _, info in pairs(buttonInfo) do
		Bar:MicroButton_Create(menubar, info)
	end

	-- Order Positions
	Bar:MicroMenu_Setup()

	-- Default elements
	B.HideObject(MicroButtonPortrait)
	B.HideOption(HelpMicroButton)
	B.HideObject(HelpOpenWebTicketButton)
	B.HideObject(MainMenuBarPerformanceBar)
	B.HideObject(MainMenuMicroButton.PerformanceIndicator)
	MainMenuMicroButton:SetScript("OnUpdate", nil)
	MicroMenuContainer:KillEditMode()
	MicroMenu.GetEdgeButton = B.Dummy
	PVPMicroButtonTexture:SetAlpha(0)
end