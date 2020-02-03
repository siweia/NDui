local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

-- Texture credit: 胡里胡涂
local _G = getfenv(0)
local tinsert, pairs, type = table.insert, pairs, type
local buttonList = {}

function Bar:MicroButton_SetupTexture(icon, texture)
	local r, g, b = DB.r, DB.g, DB.b
	if not NDuiDB["Skins"]["ClassLine"] then r, g, b = 0, 0, 0 end

	icon:SetOutside(nil, 3, 3)
	icon:SetTexture(DB.MicroTex..texture)
	icon:SetVertexColor(r, g, b)
end

function Bar:MicroButton_Create(parent, data)
	local texture, method, tooltip = unpack(data)

	local bu = CreateFrame("Frame", nil, parent)
	tinsert(buttonList, bu)
	bu:SetSize(22, 22)

	local icon = bu:CreateTexture(nil, "ARTWORK")
	Bar:MicroButton_SetupTexture(icon, texture)

	if type(method) == "string" then
		local button = _G[method]
		button:SetHitRectInsets(0, 0, 0, 0)
		button:SetParent(bu)
		button:ClearAllPoints(bu)
		button:SetAllPoints(bu)
		button.SetPoint = B.Dummy
		button:UnregisterAllEvents()
		button:SetNormalTexture(nil)
		button:SetPushedTexture(nil)
		button:SetDisabledTexture(nil)
		if tooltip then B.AddTooltip(button, "ANCHOR_RIGHT", tooltip) end

		local hl = button:GetHighlightTexture()
		Bar:MicroButton_SetupTexture(hl, texture)
		if not NDuiDB["Skins"]["ClassLine"] then hl:SetVertexColor(1, 1, 1) end

		local flash = button.Flash
		Bar:MicroButton_SetupTexture(flash, texture)
		if not NDuiDB["Skins"]["ClassLine"] then flash:SetVertexColor(1, 1, 1) end
	else
		bu:SetScript("OnMouseUp", method)
		B.AddTooltip(bu, "ANCHOR_RIGHT", tooltip)

		local hl = bu:CreateTexture(nil, "HIGHLIGHT")
		hl:SetBlendMode("ADD")
		Bar:MicroButton_SetupTexture(hl, texture)
		if not NDuiDB["Skins"]["ClassLine"] then hl:SetVertexColor(1, 1, 1) end
	end
end

function Bar:MicroMenu_Lines()
	if not NDuiDB["Skins"]["MenuLine"] then return end

	local cr, cg, cb = 0, 0, 0
	if NDuiDB["Skins"]["ClassLine"] then cr, cg, cb = DB.r, DB.g, DB.b end

	-- MICROMENU
	local mmbottomL = CreateFrame("Frame", nil, UIParent)
	mmbottomL:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", 0, 3)
	B.CreateGF(mmbottomL, 210, C.mult, "Horizontal", cr, cg, cb, 0, .7)
	local mmbottomR = CreateFrame("Frame", nil, UIParent)
	mmbottomR:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", 0, 3)
	B.CreateGF(mmbottomR, 210, C.mult, "Horizontal", cr, cg, cb, .7, 0)

	local mmtopL = CreateFrame("Frame", nil, UIParent)
	mmtopL:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", 0, 24)
	B.CreateGF(mmtopL, 230, C.mult, "Horizontal", cr, cg, cb, 0, .7)
	local mmtopR = CreateFrame("Frame", nil, UIParent)
	mmtopR:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", 0, 24)
	B.CreateGF(mmtopR, 230, C.mult, "Horizontal", cr, cg, cb, .7, 0)
end

function Bar:MicroMenu()
	if not NDuiDB["Actionbar"]["MicroMenu"] then return end

	local menubar = CreateFrame("Frame", nil, UIParent)
	menubar:SetSize(323, 22)
	B.Mover(menubar, L["Menubar"], "Menubar", C.Skins.MicroMenuPos)
	Bar:MicroMenu_Lines()

	-- Generate Buttons
	local buttonInfo = {
		{"player", "CharacterMicroButton"},
		{"spellbook", "SpellbookMicroButton"},
		{"talents", "TalentMicroButton"},
		{"achievements", "AchievementMicroButton"},
		{"quests", "QuestLogMicroButton"},
		{"guild", "GuildMicroButton"},
		{"LFG", "LFDMicroButton"},
		{"encounter", "EJMicroButton"},
		{"collections", "CollectionsMicroButton"},
		{"store", "StoreMicroButton"},
		{"help", "MainMenuMicroButton", MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU")},
		{"bags", function() ToggleAllBags() end, MicroButtonTooltipText(BAGSLOT, "OPENALLBAGS")},
	}
	for _, info in pairs(buttonInfo) do
		Bar:MicroButton_Create(menubar, info)
	end

	-- Order Positions
	for i = 1, #buttonList do
		if i == 1 then
			buttonList[i]:SetPoint("LEFT")
		else
			buttonList[i]:SetPoint("LEFT", buttonList[i-1], "RIGHT", 5, 0)
		end
	end

	-- Default elements
	B.HideObject(MicroButtonPortrait)
	B.HideObject(GuildMicroButtonTabard)
	B.HideObject(MainMenuBarDownload)
	B.HideObject(HelpOpenWebTicketButton)
	B.HideObject(MainMenuBarPerformanceBar)
	MainMenuMicroButton:SetScript("OnUpdate", nil)

	CharacterMicroButtonAlert:EnableMouse(false)
	B.HideOption(CharacterMicroButtonAlert)
end