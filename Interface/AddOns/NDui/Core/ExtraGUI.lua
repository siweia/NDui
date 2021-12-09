local _, ns = ...
local B, C, L, DB = unpack(ns)
local G = B:GetModule("GUI")

local _G = _G
local unpack, pairs, ipairs, tinsert = unpack, pairs, ipairs, tinsert
local min, max, strmatch, strfind, tonumber = min, max, strmatch, strfind, tonumber
local GetSpellInfo, GetSpellTexture = GetSpellInfo, GetSpellTexture
local GetInstanceInfo, EJ_GetInstanceInfo = GetInstanceInfo, EJ_GetInstanceInfo
local IsControlKeyDown = IsControlKeyDown

local function sortBars(barTable)
	local num = 1
	for _, bar in pairs(barTable) do
		bar:SetPoint("TOPLEFT", 10, -10 - 35*(num-1))
		num = num + 1
	end
end

local extraGUIs = {}
local function toggleExtraGUI(guiName)
	for name, frame in pairs(extraGUIs) do
		if name == guiName then
			B:TogglePanel(frame)
		else
			frame:Hide()
		end
	end
end

local function hideExtraGUIs()
	for _, frame in pairs(extraGUIs) do
		frame:Hide()
	end
end

local function createExtraGUI(parent, name, title, bgFrame)
	local frame = CreateFrame("Frame", name, parent)
	frame:SetSize(300, 600)
	frame:SetPoint("TOPLEFT", parent:GetParent(), "TOPRIGHT", 3, 0)
	B.SetBD(frame)

	if title then
		B.CreateFS(frame, 14, title, "system", "TOPLEFT", 20, -25)
	end

	if bgFrame then
		frame.bg = CreateFrame("Frame", nil, frame, "BackdropTemplate")
		frame.bg:SetSize(280, 540)
		frame.bg:SetPoint("TOPLEFT", 10, -50)
		B.CreateBD(frame.bg, .25)
	end

	if not parent.extraGUIHook then
		parent:HookScript("OnHide", hideExtraGUIs)
		parent.extraGUIHook = true
	end
	extraGUIs[name] = frame

	return frame
end

local function clearEdit(options)
	for i = 1, #options do
		G:ClearEdit(options[i])
	end
end

local function updateRaidDebuffs()
	B:GetModule("UnitFrames"):UpdateRaidDebuffs()
end

local function AddNewDungeon(dungeons, dungeonID)
	local name = EJ_GetInstanceInfo(dungeonID)
	if name then
		tinsert(dungeons, name)
	end
end

function G:SetupRaidDebuffs(parent)
	local guiName = "NDuiGUI_RaidDebuffs"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["RaidFrame Debuffs"].."*", true)
	panel:SetScript("OnHide", updateRaidDebuffs)

	local setupBars
	local frame = panel.bg
	local bars, options = {}, {}

	local iType = G:CreateDropdown(frame, L["Type*"], 10, -30, {DUNGEONS, RAID}, L["Instance Type"])
	for i = 1, 2 do
		iType.options[i]:HookScript("OnClick", function()
			for j = 1, 2 do
				G:ClearEdit(options[j])
				if i == j then
					options[j]:Show()
				else
					options[j]:Hide()
				end
			end

			for k = 1, #bars do
				bars[k]:Hide()
			end
		end)
	end

	local dungeons = {}
	for dungeonID = 1182, 1189 do
		AddNewDungeon(dungeons, dungeonID)
	end
	AddNewDungeon(dungeons, 1194)

	local raids = {
		[1] = EJ_GetInstanceInfo(1190),
		[2] = EJ_GetInstanceInfo(1193),
	}
	if DB.isNewPatch then
		raids[3] = EJ_GetInstanceInfo(1195)
	end

	options[1] = G:CreateDropdown(frame, DUNGEONS.."*", 120, -30, dungeons, L["Dungeons Intro"], 130, 30)
	options[1]:Hide()
	options[2] = G:CreateDropdown(frame, RAID.."*", 120, -30, raids, L["Raid Intro"], 130, 30)
	options[2]:Hide()

	options[3] = G:CreateEditbox(frame, "ID*", 10, -90, L["ID Intro"])
	options[4] = G:CreateEditbox(frame, L["Priority"], 120, -90, L["Priority Intro"])

	local function analyzePrio(priority)
		priority = priority or 2
		priority = min(priority, 6)
		priority = max(priority, 1)
		return priority
	end

	local function isAuraExisted(instName, spellID)
		local localPrio = C.RaidDebuffs[instName][spellID]
		local savedPrio = NDuiADB["RaidDebuffs"][instName] and NDuiADB["RaidDebuffs"][instName][spellID]
		if (localPrio and savedPrio and savedPrio == 0) or (not localPrio and not savedPrio) then
			return false
		end
		return true
	end

	local function addClick(options)
		local dungeonName, raidName, spellID, priority = options[1].Text:GetText(), options[2].Text:GetText(), tonumber(options[3]:GetText()), tonumber(options[4]:GetText())
		local instName = dungeonName or raidName
		if not instName or not spellID then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incomplete Input"]) return end
		if spellID and not GetSpellInfo(spellID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incorrect SpellID"]) return end
		if isAuraExisted(instName, spellID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ID"]) return end

		priority = analyzePrio(priority)
		if not NDuiADB["RaidDebuffs"][instName] then NDuiADB["RaidDebuffs"][instName] = {} end
		NDuiADB["RaidDebuffs"][instName][spellID] = priority
		setupBars(instName)
		G:ClearEdit(options[3])
		G:ClearEdit(options[4])
	end

	local scroll = G:CreateScroll(frame, 240, 350)
	scroll.reset = B.CreateButton(frame, 70, 25, RESET)
	scroll.reset:SetPoint("TOPLEFT", 10, -140)
	StaticPopupDialogs["RESET_NDUI_RAIDDEBUFFS"] = {
		text = L["Reset your raiddebuffs list?"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			NDuiADB["RaidDebuffs"] = {}
			ReloadUI()
		end,
		whileDead = 1,
	}
	scroll.reset:SetScript("OnClick", function()
		StaticPopup_Show("RESET_NDUI_RAIDDEBUFFS")
	end)
	scroll.add = B.CreateButton(frame, 70, 25, ADD)
	scroll.add:SetPoint("TOPRIGHT", -10, -140)
	scroll.add:SetScript("OnClick", function()
		addClick(options)
	end)
	scroll.clear = B.CreateButton(frame, 70, 25, KEY_NUMLOCK_MAC)
	scroll.clear:SetPoint("RIGHT", scroll.add, "LEFT", -10, 0)
	scroll.clear:SetScript("OnClick", function()
		clearEdit(options)
	end)

	local function iconOnEnter(self)
		local spellID = self:GetParent().spellID
		if not spellID then return end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:ClearLines()
		GameTooltip:SetSpellByID(spellID)
		GameTooltip:Show()
	end

	local function createBar(index, texture)
		local bar = CreateFrame("Frame", nil, scroll.child, "BackdropTemplate")
		bar:SetSize(220, 30)
		B.CreateBD(bar, .25)
		bar.index = index

		local icon, close = G:CreateBarWidgets(bar, texture)
		icon:SetScript("OnEnter", iconOnEnter)
		icon:SetScript("OnLeave", B.HideTooltip)
		bar.icon = icon

		close:SetScript("OnClick", function()
			bar:Hide()
			if C.RaidDebuffs[bar.instName][bar.spellID] then
				if not NDuiADB["RaidDebuffs"][bar.instName] then NDuiADB["RaidDebuffs"][bar.instName] = {} end
				NDuiADB["RaidDebuffs"][bar.instName][bar.spellID] = 0
			else
				NDuiADB["RaidDebuffs"][bar.instName][bar.spellID] = nil
			end
			setupBars(bar.instName)
		end)

		local spellName = B.CreateFS(bar, 14, "", false, "LEFT", 30, 0)
		spellName:SetWidth(120)
		spellName:SetJustifyH("LEFT")
		bar.spellName = spellName

		local prioBox = B.CreateEditBox(bar, 30, 24)
		prioBox:SetPoint("RIGHT", close, "LEFT", -15, 0)
		prioBox:SetTextInsets(10, 0, 0, 0)
		prioBox:SetMaxLetters(1)
		prioBox:SetTextColor(0, 1, 0)
		prioBox.bg:SetBackdropColor(1, 1, 1, .2)
		prioBox:HookScript("OnEscapePressed", function(self)
			self:SetText(bar.priority)
		end)
		prioBox:HookScript("OnEnterPressed", function(self)
			local prio = analyzePrio(tonumber(self:GetText()))
			if not NDuiADB["RaidDebuffs"][bar.instName] then NDuiADB["RaidDebuffs"][bar.instName] = {} end
			NDuiADB["RaidDebuffs"][bar.instName][bar.spellID] = prio
			self:SetText(prio)
		end)
		B.AddTooltip(prioBox, "ANCHOR_TOPRIGHT", L["Prio Editbox"], "info", true)
		bar.prioBox = prioBox

		return bar
	end

	local function applyData(index, instName, spellID, priority)
		local name, _, texture = GetSpellInfo(spellID)
		if not bars[index] then
			bars[index] = createBar(index, texture)
		end
		bars[index].instName = instName
		bars[index].spellID = spellID
		bars[index].priority = priority
		bars[index].spellName:SetText(name)
		bars[index].prioBox:SetText(priority)
		bars[index].icon.Icon:SetTexture(texture)
		bars[index]:Show()
	end

	function setupBars(self)
		local instName = self.text or self
		local index = 0

		if C.RaidDebuffs[instName] then
			for spellID, priority in pairs(C.RaidDebuffs[instName]) do
				if not (NDuiADB["RaidDebuffs"][instName] and NDuiADB["RaidDebuffs"][instName][spellID]) then
					index = index + 1
					applyData(index, instName, spellID, priority)
				end
			end
		end

		if NDuiADB["RaidDebuffs"][instName] then
			for spellID, priority in pairs(NDuiADB["RaidDebuffs"][instName]) do
				if priority > 0 then
					index = index + 1
					applyData(index, instName, spellID, priority)
				end
			end
		end

		for i = 1, #bars do
			if i > index then
				bars[i]:Hide()
			end
		end

		for i = 1, index do
			bars[i]:SetPoint("TOPLEFT", 10, -10 - 35*(i-1))
		end
	end

	for i = 1, 2 do
		for j = 1, #options[i].options do
			options[i].options[j]:HookScript("OnClick", setupBars)
		end
	end

	local function autoSelectInstance()
		local instName, instType = GetInstanceInfo()
		if instType == "none" then return end
		for i = 1, 2 do
			local option = options[i]
			for j = 1, #option.options do
				local name = option.options[j].text
				if instName == name then
					iType.options[i]:Click()
					options[i].options[j]:Click()
				end
			end
		end
	end
	autoSelectInstance()
	panel:HookScript("OnShow", autoSelectInstance)
end

function G:SetupClickCast(parent)
	local guiName = "NDuiGUI_ClickCast"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["Add ClickSets"], true)

	local textIndex, barTable = {
		["target"] = TARGET,
		["focus"] = SET_FOCUS,
		["follow"] = FOLLOW,
	}, {}

	local function createBar(parent, data)
		local key, modKey, value = unpack(data)
		local clickSet = modKey..key
		local texture
		if tonumber(value) then
			texture = GetSpellTexture(value)
		else
			value = textIndex[value] or value
			texture = 136243
		end

		local bar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
		bar:SetSize(220, 30)
		B.CreateBD(bar, .25)
		barTable[clickSet] = bar

		local icon, close = G:CreateBarWidgets(bar, texture)
		B.AddTooltip(icon, "ANCHOR_RIGHT", value, "system")
		close:SetScript("OnClick", function()
			bar:Hide()
			NDuiADB["RaidClickSets"][DB.MyClass][clickSet] = nil
			barTable[clickSet] = nil
			sortBars(barTable)
		end)

		local key1 = B.CreateFS(bar, 14, key, false, "LEFT", 35, 0)
		key1:SetTextColor(.6, .8, 1)
		modKey = modKey ~= "" and "+ "..modKey or ""
		local key2 = B.CreateFS(bar, 14, modKey, false, "LEFT", 130, 0)
		key2:SetTextColor(0, 1, 0)

		sortBars(barTable)
	end

	local frame = panel.bg
	local keyList, options = {
		KEY_BUTTON1,
		KEY_BUTTON2,
		KEY_BUTTON3,
		KEY_BUTTON4,
		KEY_BUTTON5,
		L["WheelUp"],
		L["WheelDown"],
	}, {}

	options[1] = G:CreateEditbox(frame, L["Action*"], 10, -30, L["Action Intro"], 260, 30)
	options[2] = G:CreateDropdown(frame, L["Key*"], 10, -90, keyList, L["Key Intro"], 120, 30)
	options[3] = G:CreateDropdown(frame, L["Modified Key"], 170, -90, {NONE, "ALT", "CTRL", "SHIFT"}, L["ModKey Intro"], 85, 30)

	local scroll = G:CreateScroll(frame, 240, 350)
	scroll.reset = B.CreateButton(frame, 70, 25, RESET)
	scroll.reset:SetPoint("TOPLEFT", 10, -140)
	StaticPopupDialogs["RESET_NDUI_CLICKSETS"] = {
		text = L["Reset your click sets?"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			wipe(NDuiADB["RaidClickSets"][DB.MyClass])
			ReloadUI()
		end,
		whileDead = 1,
	}
	scroll.reset:SetScript("OnClick", function()
		StaticPopup_Show("RESET_NDUI_CLICKSETS")
	end)

	local function addClick(scroll, options)
		local value, key, modKey = options[1]:GetText(), options[2].Text:GetText(), options[3].Text:GetText()
		if not value or not key then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incomplete Input"]) return end
		if tonumber(value) and not GetSpellInfo(value) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incorrect SpellID"]) return end
		if (not tonumber(value)) and value ~= "target" and value ~= "focus" and value ~= "follow" and not strmatch(value, "/") then UIErrorsFrame:AddMessage(DB.InfoColor..L["Invalid Input"]) return end
		if not modKey or modKey == NONE then modKey = "" end
		local clickSet = modKey..key
		if NDuiADB["RaidClickSets"][DB.MyClass][clickSet] then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ClickSet"]) return end

		NDuiADB["RaidClickSets"][DB.MyClass][clickSet] = {key, modKey, value}
		createBar(scroll.child, NDuiADB["RaidClickSets"][DB.MyClass][clickSet])
		clearEdit(options)
	end

	scroll.add = B.CreateButton(frame, 70, 25, ADD)
	scroll.add:SetPoint("TOPRIGHT", -10, -140)
	scroll.add:SetScript("OnClick", function()
		addClick(scroll, options)
	end)

	scroll.clear = B.CreateButton(frame, 70, 25, KEY_NUMLOCK_MAC)
	scroll.clear:SetPoint("RIGHT", scroll.add, "LEFT", -10, 0)
	scroll.clear:SetScript("OnClick", function()
		clearEdit(options)
	end)

	for _, v in pairs(NDuiADB["RaidClickSets"][DB.MyClass]) do
		createBar(scroll.child, v)
	end
end

local function updatePartyWatcherSpells()
	B:GetModule("UnitFrames"):UpdatePartyWatcherSpells()
end

function G:SetupPartyWatcher(parent)
	local guiName = "NDuiGUI_PartyWatcher"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["AddPartyWatcher"].."*", true)
	panel:SetScript("OnHide", updatePartyWatcherSpells)

	local barTable = {}
	local ARCANE_TORRENT = GetSpellInfo(25046)

	local function createBar(parent, spellID, duration)
		local spellName = GetSpellInfo(spellID)
		if spellName == ARCANE_TORRENT then return end
		local texture = GetSpellTexture(spellID)

		local bar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
		bar:SetSize(220, 30)
		B.CreateBD(bar, .25)
		barTable[spellID] = bar

		local icon, close = G:CreateBarWidgets(bar, texture)
		B.AddTooltip(icon, "ANCHOR_RIGHT", spellID, "system")
		close:SetScript("OnClick", function()
			bar:Hide()
			if C.PartySpells[spellID] then
				NDuiADB["PartySpells"][spellID] = 0
			else
				NDuiADB["PartySpells"][spellID] = nil
			end
			barTable[spellID] = nil
			sortBars(barTable)
		end)

		local name = B.CreateFS(bar, 14, spellName, false, "LEFT", 30, 0)
		name:SetWidth(120)
		name:SetJustifyH("LEFT")

		local timer = B.CreateFS(bar, 14, duration, false, "RIGHT", -30, 0)
		timer:SetWidth(60)
		timer:SetJustifyH("RIGHT")
		timer:SetTextColor(0, 1, 0)

		sortBars(barTable)
	end

	local frame = panel.bg
	local options = {}

	options[1] = G:CreateEditbox(frame, "ID*", 10, -30, L["ID Intro"])
	options[2] = G:CreateEditbox(frame, L["Cooldown*"], 120, -30, L["Cooldown Intro"])

	local scroll = G:CreateScroll(frame, 240, 410)
	scroll.reset = B.CreateButton(frame, 55, 25, RESET)
	scroll.reset:SetPoint("TOPLEFT", 10, -80)
	scroll.reset.text:SetTextColor(1, 0, 0)
	StaticPopupDialogs["RESET_NDUI_PARTYWATCHER"] = {
		text = L["Reset your raiddebuffs list?"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			wipe(NDuiADB["PartySpells"])
			ReloadUI()
		end,
		whileDead = 1,
	}
	scroll.reset:SetScript("OnClick", function()
		StaticPopup_Show("RESET_NDUI_PARTYWATCHER")
	end)

	local function addClick(scroll, options)
		local spellID, duration = tonumber(options[1]:GetText()), tonumber(options[2]:GetText())
		if not spellID or not duration then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incomplete Input"]) return end
		if not GetSpellInfo(spellID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incorrect SpellID"]) return end
		local modDuration = NDuiADB["PartySpells"][spellID]
		if modDuration and modDuration ~= 0 or C.PartySpells[spellID] and not modDuration then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ID"]) return end

		NDuiADB["PartySpells"][spellID] = duration
		createBar(scroll.child, spellID, duration)
		clearEdit(options)
	end

	scroll.add = B.CreateButton(frame, 55, 25, ADD)
	scroll.add:SetPoint("TOPRIGHT", -10, -80)
	scroll.add:SetScript("OnClick", function()
		addClick(scroll, options)
	end)

	scroll.clear = B.CreateButton(frame, 55, 25, KEY_NUMLOCK_MAC)
	scroll.clear:SetPoint("RIGHT", scroll.add, "LEFT", -5, 0)
	scroll.clear:SetScript("OnClick", function()
		clearEdit(options)
	end)

	local menuList = {}
	local function AddSpellFromPreset(_, spellID, duration)
		options[1]:SetText(spellID)
		options[2]:SetText(duration)
		DropDownList1:Hide()
	end

	local index = 1
	for class, value in pairs(C.PartySpellsDB) do
		local color = B.HexRGB(B.ClassColor(class))
		local localClassName = LOCALIZED_CLASS_NAMES_MALE[class]
		menuList[index] = {text = color..localClassName, notCheckable = true, hasArrow = true, menuList = {}}

		for spellID, duration in pairs(value) do
			local spellName, _, texture = GetSpellInfo(spellID)
			if spellName then
				tinsert(menuList[index].menuList, {
					text = spellName,
					icon = texture,
					tCoordLeft = .08,
					tCoordRight = .92,
					tCoordTop = .08,
					tCoordBottom = .92,
					arg1 = spellID,
					arg2 = duration,
					func = AddSpellFromPreset,
					notCheckable = true,
				})
			end
		end
		index = index + 1
	end
	scroll.preset = B.CreateButton(frame, 55, 25, L["Preset"])
	scroll.preset:SetPoint("RIGHT", scroll.clear, "LEFT", -5, 0)
	scroll.preset.text:SetTextColor(1, .8, 0)
	scroll.preset:SetScript("OnClick", function(self)
		EasyMenu(menuList, B.EasyMenu, self, -100, 100, "MENU", 1)
	end)

	local UF = B:GetModule("UnitFrames")
	for spellID, duration in pairs(UF.PartyWatcherSpells) do
		createBar(scroll.child, spellID, duration)
	end
end

function G:SetupNameplateFilter(parent)
	local guiName = "NDuiGUI_NameplateFilter"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName)

	local frameData = {
		[1] = {text = L["WhiteList"].."*", offset = -25, barList = {}},
		[2] = {text = L["BlackList"].."*", offset = -315, barList = {}},
	}

	local function createBar(parent, index, spellID)
		local name, _, texture = GetSpellInfo(spellID)
		local bar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
		bar:SetSize(220, 30)
		B.CreateBD(bar, .25)
		frameData[index].barList[spellID] = bar

		local icon, close = G:CreateBarWidgets(bar, texture)
		B.AddTooltip(icon, "ANCHOR_RIGHT", spellID)
		close:SetScript("OnClick", function()
			bar:Hide()
			NDuiADB["NameplateFilter"][index][spellID] = nil
			frameData[index].barList[spellID] = nil
			sortBars(frameData[index].barList)
		end)

		local spellName = B.CreateFS(bar, 14, name, false, "LEFT", 30, 0)
		spellName:SetWidth(180)
		spellName:SetJustifyH("LEFT")
		if index == 2 then spellName:SetTextColor(1, 0, 0) end

		sortBars(frameData[index].barList)
	end

	local function addClick(parent, index)
		local spellID = tonumber(parent.box:GetText())
		if not spellID or not GetSpellInfo(spellID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incorrect SpellID"]) return end
		if NDuiADB["NameplateFilter"][index][spellID] then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ID"]) return end

		NDuiADB["NameplateFilter"][index][spellID] = true
		createBar(parent.child, index, spellID)
		parent.box:SetText("")
	end

	for index, value in ipairs(frameData) do
		B.CreateFS(panel, 14, value.text, "system", "TOPLEFT", 20, value.offset)
		local frame = CreateFrame("Frame", nil, panel, "BackdropTemplate")
		frame:SetSize(280, 250)
		frame:SetPoint("TOPLEFT", 10, value.offset - 25)
		B.CreateBD(frame, .25)

		local scroll = G:CreateScroll(frame, 240, 200)
		scroll.box = B.CreateEditBox(frame, 185, 25)
		scroll.box:SetPoint("TOPLEFT", 10, -10)
		B.AddTooltip(scroll.box, "ANCHOR_TOPRIGHT", L["ID Intro"], "info", true)
		scroll.add = B.CreateButton(frame, 70, 25, ADD)
		scroll.add:SetPoint("TOPRIGHT", -8, -10)
		scroll.add:SetScript("OnClick", function()
			addClick(scroll, index)
		end)

		for spellID in pairs(NDuiADB["NameplateFilter"][index]) do
			createBar(scroll.child, index, spellID)
		end
	end
end

local function updateCornerSpells()
	B:GetModule("UnitFrames"):UpdateCornerSpells()
end

function G:SetupBuffIndicator(parent)
	local guiName = "NDuiGUI_BuffIndicator"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName)
	panel:SetScript("OnHide", updateCornerSpells)

	local frameData = {
		[1] = {text = L["RaidBuffWatch"].."*", offset = -25, width = 160, barList = {}},
		[2] = {text = L["BuffIndicator"].."*", offset = -315, width = 50, barList = {}},
	}
	local decodeAnchor = {
		["TL"] = "TOPLEFT",
		["T"] = "TOP",
		["TR"] = "TOPRIGHT",
		["L"] = "LEFT",
		["R"] = "RIGHT",
		["BL"] = "BOTTOMLEFT",
		["B"] = "BOTTOM",
		["BR"] = "BOTTOMRIGHT",
	}
	local anchors = {"TL", "T", "TR", "L", "R", "BL", "B", "BR"}

	local function createBar(parent, index, spellID, anchor, r, g, b, showAll)
		local name, _, texture = GetSpellInfo(spellID)
		local bar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
		bar:SetSize(220, 30)
		B.CreateBD(bar, .25)
		frameData[index].barList[spellID] = bar

		local icon, close = G:CreateBarWidgets(bar, texture)
		B.AddTooltip(icon, "ANCHOR_RIGHT", spellID)
		close:SetScript("OnClick", function()
			bar:Hide()
			if index == 1 then
				NDuiADB["RaidAuraWatch"][spellID] = nil
			else
				local value = C.CornerBuffs[DB.MyClass][spellID]
				if value then
					NDuiADB["CornerSpells"][DB.MyClass][spellID] = {}
				else
					NDuiADB["CornerSpells"][DB.MyClass][spellID] = nil
				end
			end
			frameData[index].barList[spellID] = nil
			sortBars(frameData[index].barList)
		end)

		name = L[anchor] or name
		local text = B.CreateFS(bar, 14, name, false, "LEFT", 30, 0)
		text:SetWidth(180)
		text:SetJustifyH("LEFT")
		if anchor then text:SetTextColor(r, g, b) end
		if showAll then B.CreateFS(bar, 14, "ALL", false, "RIGHT", -30, 0) end

		sortBars(frameData[index].barList)
	end

	local function addClick(parent, index)
		local spellID = tonumber(parent.box:GetText())
		if not spellID or not GetSpellInfo(spellID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incorrect SpellID"]) return end
		local anchor, r, g, b, showAll
		if index == 1 then
			if NDuiADB["RaidAuraWatch"][spellID] then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ID"]) return end
			NDuiADB["RaidAuraWatch"][spellID] = true
		else
			anchor, r, g, b = parent.dd.Text:GetText(), parent.swatch.tex:GetColor()
			showAll = parent.showAll:GetChecked() or nil
			local modValue = NDuiADB["CornerSpells"][DB.MyClass][spellID]
			if (modValue and next(modValue)) or (C.CornerBuffs[DB.MyClass][spellID] and not modValue) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ID"]) return end
			anchor = decodeAnchor[anchor]
			NDuiADB["CornerSpells"][DB.MyClass][spellID] = {anchor, {r, g, b}, showAll}
		end
		createBar(parent.child, index, spellID, anchor, r, g, b, showAll)
		parent.box:SetText("")
	end

	local currentIndex
	StaticPopupDialogs["RESET_NDUI_RaidAuraWatch"] = {
		text = L["Reset your raiddebuffs list?"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			if currentIndex == 1 then
				NDuiADB["RaidAuraWatch"] = nil
			else
				wipe(NDuiADB["CornerSpells"][DB.MyClass])
			end
			ReloadUI()
		end,
		whileDead = 1,
	}

	local function optionOnEnter(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(L[decodeAnchor[self.text]], 1, 1, 1)
		GameTooltip:Show()
	end

	local UF = B:GetModule("UnitFrames")

	for index, value in ipairs(frameData) do
		B.CreateFS(panel, 14, value.text, "system", "TOPLEFT", 20, value.offset)

		local frame = CreateFrame("Frame", nil, panel, "BackdropTemplate")
		frame:SetSize(280, 250)
		frame:SetPoint("TOPLEFT", 10, value.offset - 25)
		B.CreateBD(frame, .25)

		local scroll = G:CreateScroll(frame, 240, 200)
		scroll.box = B.CreateEditBox(frame, value.width, 25)
		scroll.box:SetPoint("TOPLEFT", 10, -10)
		scroll.box:SetMaxLetters(6)
		B.AddTooltip(scroll.box, "ANCHOR_TOPRIGHT", L["ID Intro"], "info", true)

		scroll.add = B.CreateButton(frame, 45, 25, ADD)
		scroll.add:SetPoint("TOPRIGHT", -8, -10)
		scroll.add:SetScript("OnClick", function()
			addClick(scroll, index)
		end)

		scroll.reset = B.CreateButton(frame, 45, 25, RESET)
		scroll.reset:SetPoint("RIGHT", scroll.add, "LEFT", -5, 0)
		scroll.reset:SetScript("OnClick", function()
			currentIndex = index
			StaticPopup_Show("RESET_NDUI_RaidAuraWatch")
		end)
		if index == 1 then
			for spellID in pairs(NDuiADB["RaidAuraWatch"]) do
				createBar(scroll.child, index, spellID)
			end
		else
			scroll.dd = B.CreateDropDown(frame, 60, 25, anchors)
			scroll.dd:SetPoint("TOPLEFT", 10, -10)
			scroll.dd.options[1]:Click()

			for i = 1, 8 do
				scroll.dd.options[i]:HookScript("OnEnter", optionOnEnter)
				scroll.dd.options[i]:HookScript("OnLeave", B.HideTooltip)
			end
			scroll.box:SetPoint("TOPLEFT", scroll.dd, "TOPRIGHT", 5, 0)

			local swatch = B.CreateColorSwatch(frame, "")
			swatch:SetPoint("LEFT", scroll.box, "RIGHT", 5, 0)
			scroll.swatch = swatch

			local showAll = B.CreateCheckBox(frame)
			showAll:SetPoint("LEFT", swatch, "RIGHT", 2, 0)
			showAll:SetHitRectInsets(0, 0, 0, 0)
			showAll.bg:SetBackdropBorderColor(1, .8, 0, .5)
			B.AddTooltip(showAll, "ANCHOR_TOPRIGHT", L["ShowAllTip"], "info", true)
			scroll.showAll = showAll

			for spellID, value in pairs(UF.CornerSpells) do
				local r, g, b = unpack(value[2])
				createBar(scroll.child, index, spellID, value[1], r, g, b, value[3])
			end
		end
	end
end

local function createOptionTitle(parent, title, offset)
	B.CreateFS(parent, 14, title, "system", "TOP", 0, offset)
	local line = B.SetGradient(parent, "H", 1, 1, 1, .25, .25, 200, C.mult)
	line:SetPoint("TOPLEFT", 30, offset-20)
end

local function toggleOptionCheck(self)
	local value = C.db[self.__key][self.__value]
	value = not value
	self:SetChecked(value)
	C.db[self.__key][self.__value] = value
	if self.__callback then self:__callback() end
end

local function createOptionCheck(parent, offset, text, key, value, callback, tooltip)
	local box = B.CreateCheckBox(parent)
	box:SetPoint("TOPLEFT", 10, offset)
	box:SetChecked(C.db[key][value])
	box.__key = key
	box.__value = value
	box.__callback = callback
	B.CreateFS(box, 14, text, nil, "LEFT", 30, 0)
	box:SetScript("OnClick", toggleOptionCheck)
	if tooltip then
		B.AddTooltip(box, "ANCHOR_RIGHT", tooltip, "info", true)
	end

	return box
end

local function sliderValueChanged(self, v)
	local current = tonumber(format("%.0f", v))
	self.value:SetText(current)
	C.db[self.__key][self.__value] = current
	if self.__update then self.__update() end
end

local function createOptionSlider(parent, title, minV, maxV, defaultV, yOffset, value, func, key)
	local slider = B.CreateSlider(parent, title, minV, maxV, 1, 30, yOffset)
	if not key then key = "UFs" end
	slider:SetValue(C.db[key][value])
	slider.value:SetText(C.db[key][value])
	slider.__key = key
	slider.__value = value
	slider.__update = func
	slider.__default = defaultV
	slider:SetScript("OnValueChanged", sliderValueChanged)
end

local function updateDropdownHighlight(self)
	local dd = self.__owner
	for i = 1, #dd.__options do
		local option = dd.options[i]
		if i == C.db[dd.__key][dd.__value] then
			option:SetBackdropColor(1, .8, 0, .3)
			option.selected = true
		else
			option:SetBackdropColor(0, 0, 0, .3)
			option.selected = false
		end
	end
end

local function updateDropdownState(self)
	local dd = self.__owner
	C.db[dd.__key][dd.__value] = self.index
	if dd.__func then dd.__func() end
end

local function createOptionDropdown(parent, title, yOffset, options, tooltip, key, value, default, func)
	local dd = G:CreateDropdown(parent, title, 40, yOffset, options, nil, 180, 28)
	dd.__key = key
	dd.__value = value
	dd.__default = default
	dd.__options = options
	dd.__func = func
	dd.Text:SetText(options[C.db[key][value]])

	if tooltip then
		B.AddTooltip(dd, "ANCHOR_TOP", tooltip, "info", true)
	end

	dd.button.__owner = dd
	dd.button:HookScript("OnClick", updateDropdownHighlight)

	for i = 1, #options do
		dd.options[i]:HookScript("OnClick", updateDropdownState)
	end
end

local function SetUnitFrameSize(self, unit)
	local width = C.db["UFs"][unit.."Width"]
	local healthHeight = C.db["UFs"][unit.."Height"]
	local powerHeight = C.db["UFs"][unit.."PowerHeight"]
	local height = healthHeight + powerHeight + C.mult
	self:SetSize(width, height)
	self.Health:SetHeight(healthHeight)
	self.Power:SetHeight(powerHeight)
	if self.powerText then
		self.powerText:SetPoint("RIGHT", -3, C.db["UFs"][unit.."PowerOffset"])
	end
end

function G:SetupUnitFrame(parent)
	local guiName = "NDuiGUI_UnitFrameSetup"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["UnitFrame Size"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)

	local sliderRange = {
		["Player"] = {150, 400},
		["Focus"] = {150, 400},
		["Pet"] = {100, 300},
		["Boss"] = {100, 400},
	}

	local defaultValue = { -- healthWidth, healthHeight, powerHeight, healthTag, powerTag, powerOffset
		["Player"] = {245, 24, 4, 2, 4, 2},
		["Focus"] = {200, 22, 3, 2, 4, 2},
		["Pet"] = {120, 18, 2, 5},
		["Boss"] = {150, 22, 2, 5, 5},
	}

	local function createOptionGroup(parent, title, offset, value, func)
		createOptionTitle(parent, title, offset)
		createOptionDropdown(parent, L["HealthValueType"], offset-50, G.HealthValues, L["100PercentTip"], "UFs", value.."HPTag", defaultValue[value][4], func)
		local mult = 0
		if value ~= "Pet" then
			mult = 60
			createOptionDropdown(parent, L["PowerValueType"], offset-50-mult, G.HealthValues, L["100PercentTip"], "UFs", value.."MPTag", defaultValue[value][4], func)
		end
		createOptionSlider(parent, L["Width"], sliderRange[value][1], sliderRange[value][2], defaultValue[value][1], offset-110-mult, value.."Width", func)
		createOptionSlider(parent, L["Height"], 15, 50, defaultValue[value][2], offset-180-mult, value.."Height", func)
		createOptionSlider(parent, L["Power Height"], 2, 30, defaultValue[value][3], offset-250-mult, value.."PowerHeight", func)
		if defaultValue[value][6] then
			createOptionSlider(parent, L["Power Offset"], -20, 20, defaultValue[value][4], offset-320-mult, value.."PowerOffset", func)
		end
	end

	local UF = B:GetModule("UnitFrames")
	local mainFrames = {_G.oUF_Player, _G.oUF_Target}
	local function updatePlayerSize()
		for _, frame in pairs(mainFrames) do
			SetUnitFrameSize(frame, "Player")
			UF.UpdateFrameHealthTag(frame)
			UF.UpdateFramePowerTag(frame)
		end
		UF:UpdateUFAuras()
	end
	createOptionGroup(scroll.child, L["Player&Target"], -10, "Player", updatePlayerSize)

	local function updateFocusSize()
		local frame = _G.oUF_Focus
		if frame then
			SetUnitFrameSize(frame, "Focus")
			UF.UpdateFrameHealthTag(frame)
			UF.UpdateFramePowerTag(frame)
		end
	end
	createOptionGroup(scroll.child, L["FocusUF"], -480, "Focus", updateFocusSize)

	local subFrames = {_G.oUF_Pet, _G.oUF_ToT, _G.oUF_FocusTarget}
	local function updatePetSize()
		for _, frame in pairs(subFrames) do
			SetUnitFrameSize(frame, "Pet")
			UF.UpdateFrameHealthTag(frame)
		end
	end
	createOptionGroup(scroll.child, L["Pet&*Target"], -950, "Pet", updatePetSize)

	local function updateBossSize()
		for _, frame in pairs(ns.oUF.objects) do
			if frame.mystyle == "boss" or frame.mystyle == "arena" then
				SetUnitFrameSize(frame, "Boss")
				UF.UpdateFrameHealthTag(frame)
				UF.UpdateFramePowerTag(frame)
			end
		end
	end
	createOptionGroup(scroll.child, L["Boss&Arena"], -1290, "Boss", updateBossSize)
end

function G:SetupRaidFrame(parent)
	local guiName = "NDuiGUI_RaidFrameSetup"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["RaidFrame Size"])
	local scroll = G:CreateScroll(panel, 260, 540)

	local minRange = {
		["Party"] = {80, 25},
		["Raid"] = {60, 25},
	}

	local defaultValue = {
		["Party"] = {100, 32, 2},
		["Raid"] = {80, 32, 2},
	}

	local function createOptionGroup(parent, title, offset, value, func)
		createOptionTitle(parent, title, offset)
		createOptionSlider(parent, L["Width"], minRange[value][1], 200, defaultValue[value][1], offset-60, value.."Width", func)
		createOptionSlider(parent, L["Height"], minRange[value][2], 60, defaultValue[value][2], offset-130, value.."Height", func)
		createOptionSlider(parent, L["Power Height"], 2, 30, defaultValue[value][3], offset-200, value.."PowerHeight", func)
	end

	local function resizeRaidFrame()
		for _, frame in pairs(ns.oUF.objects) do
			if frame.mystyle == "raid" and not frame.isPartyFrame and not frame.isPartyPet and not frame.isSimpleMode then
				SetUnitFrameSize(frame, "Raid")
			end
		end
	end
	createOptionGroup(scroll.child, L["RaidFrame"], -10, "Raid", resizeRaidFrame)

	local function resizePartyFrame()
		for _, frame in pairs(ns.oUF.objects) do
			if frame.isPartyFrame then
				SetUnitFrameSize(frame, "Party")
			end
		end
	end
	createOptionGroup(scroll.child, L["PartyFrame"], -300, "Party", resizePartyFrame)
end

function G:SetupSimpleRaidFrame(parent)
	local guiName = "NDuiGUI_SimpleRaidFrameSetup"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["SimpleRaidFrame"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)
	local UF = B:GetModule("UnitFrames")

	local function updateSimpleModeGroupBy()
		if UF.UpdateSimpleModeHeader then
			UF:UpdateSimpleModeHeader()
		end
	end
	createOptionDropdown(scroll.child, L["SimpleMode GroupBy"], -30, {GROUP, CLASS, ROLE}, nil, "UFs", "SMRGroupBy", 1, updateSimpleModeGroupBy)
	createOptionSlider(scroll.child, L["UnitsPerColumn"], 5, 40, 20, -100, "SMRPerCol", updateSimpleModeGroupBy)
	createOptionSlider(scroll.child, L["Num Groups"], 1, 8, 6, -180, "SMRGroups", updateSimpleModeGroupBy)

	local function resizeSimpleRaidFrame()
		for _, frame in pairs(ns.oUF.objects) do
			if frame.isSimpleMode then
				local scale = C.db["UFs"]["SMRScale"]/10
				local frameWidth = 100*scale
				local frameHeight = 20*scale
				local powerHeight = 2*scale
				local healthHeight = frameHeight - powerHeight
				frame:SetSize(frameWidth, frameHeight)
				frame.Health:SetHeight(healthHeight)
				frame.Power:SetHeight(powerHeight)
				frame.Auras.size = 18*scale/10
				UF:UpdateAuraContainer(frame, frame.Auras, 1)
			end
		end

		updateSimpleModeGroupBy()
	end
	createOptionSlider(scroll.child, L["SimpleMode Scale"], 8, 15, 10, -260, "SMRScale", resizeSimpleRaidFrame)
end

function G:SetupPartyPetFrame(parent)
	local guiName = "NDuiGUI_PartyPetFrameSetup"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["PartyPetFrame"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)

	local UF = B:GetModule("UnitFrames")

	local function updatePartyPetHeader()
		if UF.UpdatePartyPetHeader then
			UF:UpdatePartyPetHeader()
		end
	end

	local function resizePartyPetFrame()
		for _, frame in pairs(ns.oUF.objects) do
			if frame.isPartyPet then
				SetUnitFrameSize(frame, "PartyPet")
			end
		end

		updatePartyPetHeader()
	end

	createOptionDropdown(scroll.child, L["Visibility"], -30, {L["ShowInParty"], L["ShowInRaid"], L["ShowInGroup"]}, nil, "UFs", "PartyPetVsby", 1, UF.UpdateAllHeaders)
	createOptionSlider(scroll.child, L["Width"], 60, 200, 100, -90, "PartyPetWidth", resizePartyPetFrame)
	createOptionSlider(scroll.child, L["Height"], 20, 60, 22, -160, "PartyPetHeight", resizePartyPetFrame)
	createOptionSlider(scroll.child, L["Power Height"], 2, 30, 2, -230, "PartyPetPowerHeight", resizePartyPetFrame)
	createOptionSlider(scroll.child, L["UnitsPerColumn"], 5, 40, 5, -300, "PartyPetPerCol", updatePartyPetHeader)
	createOptionSlider(scroll.child, L["MaxColumns"], 1, 5, 1, -370, "PartyPetMaxCol", updatePartyPetHeader)
end

local function createOptionSwatch(parent, name, key, value, x, y)
	local swatch = B.CreateColorSwatch(parent, name, C.db[key][value])
	swatch:SetPoint("TOPLEFT", x, y)
	swatch.__default = G.DefaultSettings[key][value]
end

function G:SetupCastbar(parent)
	local guiName = "NDuiGUI_CastbarSetup"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["Castbar Settings"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)

	createOptionTitle(scroll.child, L["Castbar Colors"], -10)
	createOptionSwatch(scroll.child, L["PlayerCastingColor"], "UFs", "OwnCastColor", 40, -40)
	createOptionSwatch(scroll.child, L["Interruptible Color"], "UFs", "CastingColor", 40, -70)
	createOptionSwatch(scroll.child, L["NotInterruptible Color"], "UFs", "NotInterruptColor", 40, -100)

	local defaultValue = {
		["Player"] = {300, 20},
		["Target"] = {280, 20},
		["Focus"] = {320, 20},
	}

	local UF = B:GetModule("UnitFrames")

	local function toggleCastbar(self)
		local value = self.__value.."CB"
		C.db["UFs"][value] = not C.db["UFs"][value]
		self:SetChecked(C.db["UFs"][value])
		UF.ToggleCastBar(_G["oUF_"..self.__value], self.__value)
	end

	local function createOptionGroup(parent, title, offset, value, func)
		local box = B.CreateCheckBox(parent)
		box:SetPoint("TOPLEFT", parent, 30, offset + 6)
		box:SetChecked(C.db["UFs"][value.."CB"])
		box.__value = value
		box:SetScript("OnClick", toggleCastbar)
		B.AddTooltip(box, "ANCHOR_RIGHT", L["ToggleCastbarTip"], "info", true)

		createOptionTitle(parent, title, offset)
		createOptionSlider(parent, L["Width"], 100, 800, defaultValue[value][1], offset-60, value.."CBWidth", func)
		createOptionSlider(parent, L["Height"], 10, 50, defaultValue[value][2], offset-130, value.."CBHeight", func)
	end

	local function updatePlayerCastbar()
		if _G.oUF_Player then
			local width, height = C.db["UFs"]["PlayerCBWidth"], C.db["UFs"]["PlayerCBHeight"]
			_G.oUF_Player.Castbar:SetSize(width, height)
			_G.oUF_Player.Castbar.Icon:SetSize(height, height)
			_G.oUF_Player.Castbar.mover:Show()
			_G.oUF_Player.Castbar.mover:SetSize(width+height+5, height+5)
			if _G.oUF_Player.QuakeTimer then
				_G.oUF_Player.QuakeTimer:SetSize(width, height)
				_G.oUF_Player.QuakeTimer.Icon:SetSize(height, height)
				_G.oUF_Player.QuakeTimer.mover:Show()
				_G.oUF_Player.QuakeTimer.mover:SetSize(width+height+5, height+5)
			end
			if _G.oUF_Player.Swing then
				_G.oUF_Player.Swing:SetWidth(width-height-5)
			end
		end
	end
	createOptionGroup(scroll.child, L["Player Castbar"], -170, "Player", updatePlayerCastbar)

	local function updateTargetCastbar()
		if _G.oUF_Target then
			local width, height = C.db["UFs"]["TargetCBWidth"], C.db["UFs"]["TargetCBHeight"]
			_G.oUF_Target.Castbar:SetSize(width, height)
			_G.oUF_Target.Castbar.Icon:SetSize(height, height)
			_G.oUF_Target.Castbar.mover:Show()
			_G.oUF_Target.Castbar.mover:SetSize(width+height+5, height+5)
		end
	end
	createOptionGroup(scroll.child, L["Target Castbar"], -390, "Target", updateTargetCastbar)

	local function updateFocusCastbar()
		if _G.oUF_Focus then
			local width, height = C.db["UFs"]["FocusCBWidth"], C.db["UFs"]["FocusCBHeight"]
			_G.oUF_Focus.Castbar:SetSize(width, height)
			_G.oUF_Focus.Castbar.Icon:SetSize(height, height)
			_G.oUF_Focus.Castbar.mover:Show()
			_G.oUF_Focus.Castbar.mover:SetSize(width+height+5, height+5)
		end
	end
	createOptionGroup(scroll.child, L["Focus Castbar"], -610, "Focus", updateFocusCastbar)

	panel:HookScript("OnHide", function()
		if _G.oUF_Player then
			_G.oUF_Player.Castbar.mover:Hide()
			if _G.oUF_Player.QuakeTimer then _G.oUF_Player.QuakeTimer.mover:Hide() end
		end
		if _G.oUF_Target then _G.oUF_Target.Castbar.mover:Hide() end
		if _G.oUF_Focus then _G.oUF_Focus.Castbar.mover:Hide() end
	end)
end

function G:SetupBagFilter(parent)
	local guiName = "NDuiGUI_BagFilterSetup"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["BagFilterSetup"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)

	local filterOptions = {
		[1] = "FilterJunk",
		[2] = "FilterConsumable",
		[3] = "FilterAzerite",
		[4] = "FilterEquipment",
		[5] = "FilterEquipSet",
		[6] = "FilterLegendary",
		[7] = "FilterCollection",
		[8] = "FilterFavourite",
		[9] = "FilterGoods",
		[10] = "FilterQuest",
		[11] = "FilterAnima",
		[12] = "FilterRelic",
	}

	local BAG = B:GetModule("Bags")
	local function updateAllBags()
		BAG:UpdateAllBags()
	end

	local offset = 10
	for _, value in ipairs(filterOptions) do
		createOptionCheck(scroll, -offset, L[value], "Bags", value, updateAllBags)
		offset = offset + 35
	end
end

local function refreshMajorSpells()
	B:GetModule("UnitFrames"):RefreshMajorSpells()
end

function G:PlateCastbarGlow(parent)
	local guiName = "NDuiGUI_PlateCastbarGlow"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["PlateCastbarGlow"].."*", true)
	panel:SetScript("OnHide", refreshMajorSpells)

	local barTable = {}

	local function createBar(parent, spellID)
		local spellName = GetSpellInfo(spellID)
		local texture = GetSpellTexture(spellID)

		local bar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
		bar:SetSize(220, 30)
		B.CreateBD(bar, .25)
		barTable[spellID] = bar

		local icon, close = G:CreateBarWidgets(bar, texture)
		B.AddTooltip(icon, "ANCHOR_RIGHT", spellID, "system")
		close:SetScript("OnClick", function()
			bar:Hide()
			barTable[spellID] = nil
			if C.MajorSpells[spellID] then
				NDuiADB["MajorSpells"][spellID] = false
			else
				NDuiADB["MajorSpells"][spellID] = nil
			end
			sortBars(barTable)
		end)

		local name = B.CreateFS(bar, 14, spellName, false, "LEFT", 30, 0)
		name:SetWidth(120)
		name:SetJustifyH("LEFT")

		sortBars(barTable)
	end

	local frame = panel.bg
	local scroll = G:CreateScroll(frame, 240, 450)
	scroll.box = G:CreateEditbox(frame, "ID*", 10, -30, L["ID Intro"], 100, 30)

	local function addClick(button)
		local parent = button.__owner
		local spellID = tonumber(parent.box:GetText())
		if not spellID or not GetSpellInfo(spellID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incorrect SpellID"]) return end
		local modValue = NDuiADB["MajorSpells"][spellID]
		if modValue or modValue == nil and C.MajorSpells[spellID] then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ID"]) return end
		NDuiADB["MajorSpells"][spellID] = true
		createBar(parent.child, spellID)
		parent.box:SetText("")
	end
	scroll.add = B.CreateButton(frame, 70, 25, ADD)
	scroll.add:SetPoint("LEFT", scroll.box, "RIGHT", 10, 0)
	scroll.add.__owner = scroll
	scroll.add:SetScript("OnClick", addClick)

	scroll.reset = B.CreateButton(frame, 70, 25, RESET)
	scroll.reset:SetPoint("LEFT", scroll.add, "RIGHT", 10, 0)
	StaticPopupDialogs["RESET_NDUI_MAJORSPELLS"] = {
		text = L["Reset your raiddebuffs list?"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			NDuiADB["MajorSpells"] = {}
			ReloadUI()
		end,
		whileDead = 1,
	}
	scroll.reset:SetScript("OnClick", function()
		StaticPopup_Show("RESET_NDUI_MAJORSPELLS")
	end)

	local UF = B:GetModule("UnitFrames")
	for spellID, value in pairs(UF.MajorSpells) do
		if value then
			createBar(scroll.child, spellID)
		end
	end
end

function G:SetupNameplateSize(parent)
	local guiName = "NDuiGUI_PlateSizeSetup"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["NameplateSize"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)

	local optionValues = {
		["enemy"] = {"PlateWidth", "PlateHeight", "NameTextSize", "HealthTextSize", "HealthTextOffset", "PlateCBHeight", "CBTextSize", "PlateCBOffset"},
		["friend"] = {"FriendPlateWidth", "FriendPlateHeight", "FriendNameSize", "FriendHealthSize", "FriendHealthOffset", "FriendPlateCBHeight", "FriendCBTextSize", "FriendPlateCBOffset"},
	}
	local function createOptionGroup(parent, title, offset, value, func)
		createOptionTitle(parent, title, offset)
		createOptionSlider(parent, L["Width"], 50, 500, 190, offset-60, optionValues[value][1], func, "Nameplate")
		createOptionSlider(parent, L["Height"], 5, 50, 8, offset-130, optionValues[value][2], func, "Nameplate")
		createOptionSlider(parent, L["NameTextSize"], 10, 50, 14, offset-200, optionValues[value][3], func, "Nameplate")
		createOptionSlider(parent, L["HealthTextSize"], 10, 50, 16, offset-270, optionValues[value][4], func, "Nameplate")
		createOptionSlider(parent, L["Health Offset"], -50, 50, 5, offset-340, optionValues[value][5], func, "Nameplate")
		createOptionSlider(parent, L["Castbar Height"], 5, 50, 8, offset-410, optionValues[value][6], func, "Nameplate")
		createOptionSlider(parent, L["CastbarTextSize"], 10, 50, 14, offset-480, optionValues[value][7], func, "Nameplate")
		createOptionSlider(parent, L["CastbarTextOffset"], -50, 50, -1, offset-550, optionValues[value][8], func, "Nameplate")
	end

	local UF = B:GetModule("UnitFrames")
	createOptionGroup(scroll.child, L["HostileNameplate"], -10, "enemy", UF.RefreshAllPlates)
	createOptionGroup(scroll.child, L["FriendlyNameplate"], -650, "friend", UF.RefreshAllPlates)
end

function G:SetupActionBar(parent)
	local guiName = "NDuiGUI_ActionBarSetup"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["ActionbarSetup"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)

	local Bar = B:GetModule("Actionbar")
	local defaultValues = {
		-- defaultSize, minButtons, maxButtons, defaultButtons, defaultPerRow 
		["Bar1"] = {34, 6, 12, 12, 12},
		["Bar2"] = {34, 1, 12, 12, 12},
		["Bar3"] = {32, 0, 12, 0, 12},
		["Bar4"] = {32, 1, 12, 12, 1},
		["Bar5"] = {32, 1, 12, 12, 1},
		["BarPet"] = {26, 1, 10, 10, 10},
	}
	local function createOptionGroup(parent, title, offset, value, color)
		color = color or ""
		local data = defaultValues[value]
		local function updateBarScale()
			Bar:UpdateActionSize(value)
		end
		createOptionTitle(parent, title, offset)
		createOptionSlider(parent, L["ButtonSize"], 20, 80, data[1], offset-60, value.."Size", updateBarScale, "Actionbar")
		createOptionSlider(parent, color..L["MaxButtons"], data[2], data[3], data[4], offset-130, value.."Num", updateBarScale, "Actionbar")
		createOptionSlider(parent, L["ButtonsPerRow"], 1, data[3], data[5], offset-200, value.."PerRow", updateBarScale, "Actionbar")
		createOptionSlider(parent, L["ButtonFontSize"], 8, 20, 12, offset-270, value.."Font", updateBarScale, "Actionbar")
	end

	createOptionGroup(scroll.child, L["Actionbar"].."1", -10, "Bar1")
	createOptionGroup(scroll.child, L["Actionbar"].."2", -370, "Bar2")
	createOptionGroup(scroll.child, L["Actionbar"].."3", -730, "Bar3", "|cffff0000")
	createOptionGroup(scroll.child, L["Actionbar"].."4", -1090, "Bar4")
	createOptionGroup(scroll.child, L["Actionbar"].."5", -1450, "Bar5")
	createOptionGroup(scroll.child, L["Pet Actionbar"], -1810, "BarPet")

	createOptionTitle(scroll.child, L["LeaveVehicle"], -2170)
	createOptionSlider(scroll.child, L["ButtonSize"], 20, 80, 34, -2230, "VehButtonSize", Bar.UpdateVehicleButton, "Actionbar")
end

function G:SetupStanceBar(parent)
	local guiName = "NDuiGUI_StanceBarSetup"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["ActionbarSetup"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)

	local Bar = B:GetModule("Actionbar")
	local parent, offset = scroll.child, -10
	createOptionTitle(parent, L["StanceBar"], offset)
	createOptionSlider(parent, L["ButtonSize"], 20, 80, 30, offset-60, "BarStanceSize", Bar.UpdateStanceBar, "Actionbar")
	createOptionSlider(parent, L["ButtonsPerRow"], 1, 10, 10, offset-130, "BarStancePerRow", Bar.UpdateStanceBar, "Actionbar")
	createOptionSlider(parent, L["ButtonFontSize"], 8, 20, 12, offset-200, "BarStanceFont", Bar.UpdateStanceBar, "Actionbar")
end

function G:SetupUFClassPower(parent)
	local guiName = "NDuiGUI_ClassPowerSetup"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["UFs ClassPower"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)

	local UF = B:GetModule("UnitFrames")
	local parent, offset = scroll.child, -10

	createOptionCheck(parent, offset, L["UFs RuneTimer"], "UFs", "RuneTimer")
	createOptionSlider(parent, L["Width"], 100, 400, 150, offset-70, "CPWidth", UF.UpdateUFClassPower)
	createOptionSlider(parent, L["Height"], 2, 30, 5, offset-140, "CPHeight", UF.UpdateUFClassPower)
	createOptionSlider(parent, L["xOffset"], -20, 200, 12, offset-210, "CPxOffset", UF.UpdateUFClassPower)
	createOptionSlider(parent, L["yOffset"], -200, 20, -2, offset-280, "CPyOffset", UF.UpdateUFClassPower)
end

function G:SetupUFAuras(parent)
	local guiName = "NDuiGUI_UnitFrameAurasSetup"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["ShowAuras"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)

	local UF = B:GetModule("UnitFrames")
	local parent, offset = scroll.child, -10

	local defaultData = {
		["Player"] = {1, 1, 9, 20, 20},
		["Target"] = {2, 2, 9, 20, 20},
		["Focus"] = {3, 2, 9, 20, 20},
		["ToT"] = {1, 1, 5, 6, 6},
		["Boss"] = {2, 3, 6, 6, 6},
	}
	local buffOptions = {DISABLE, L["ShowAll"], L["ShowDispell"]}
	local debuffOptions = {DISABLE, L["ShowAll"], L["BlockOthers"]}

	local function createOptionGroup(parent, title, offset, value, func, isBoss)
		local default = defaultData[value]
		createOptionTitle(parent, title, offset)
		createOptionDropdown(parent, L["BuffType"], offset-50, buffOptions, nil, "UFs", value.."BuffType", default[1], func)
		createOptionDropdown(parent, L["DebuffType"], offset-110, debuffOptions, nil, "UFs", value.."DebuffType", default[2], func)
		createOptionSlider(parent, L["MaxBuffs"], 1, 40, default[4], offset-180, value.."NumBuff", func)
		createOptionSlider(parent, L["MaxDebuffs"], 1, 40, default[5], offset-250, value.."NumDebuff", func)
		if isBoss then
			createOptionSlider(parent, "Buff "..L["IconsPerRow"], 5, 20, default[3], offset-320, value.."BuffPerRow", func)
			createOptionSlider(parent, "Debuff "..L["IconsPerRow"], 5, 20, default[3], offset-390, value.."DebuffPerRow", func)
		else
			createOptionSlider(parent, L["IconsPerRow"], 5, 20, default[3], offset-320, value.."AurasPerRow", func)
		end
	end

	createOptionTitle(parent, GENERAL, offset)
	createOptionCheck(parent, offset-35, L["DesaturateIcon"], "UFs", "Desaturate", UF.UpdateUFAuras, L["DesaturateIconTip"])
	createOptionCheck(parent, offset-70, L["DebuffColor"], "UFs", "DebuffColor", UF.UpdateUFAuras, L["DebuffColorTip"])

	createOptionGroup(parent, L["PlayerUF"], offset-140, "Player", UF.UpdateUFAuras)
	createOptionGroup(parent, L["TargetUF"], offset-550, "Target", UF.UpdateUFAuras)
	createOptionGroup(parent, L["TotUF"], offset-960, "ToT", UF.UpdateUFAuras)
	createOptionGroup(parent, L["FocusUF"], offset-1370, "Focus", UF.UpdateUFAuras)
	createOptionGroup(parent, L["BossFrame"], offset-1780, "Boss", UF.UpdateUFAuras, true)
end

function G:SetupActionbarStyle(parent)
	local size, padding = 30, 3

	local frame = CreateFrame("Frame", "NDuiActionbarStyleFrame", parent.child)
	frame:SetSize((size+padding)*5 + padding, size + 2*padding)
	frame:SetPoint("TOPRIGHT", -100, -15)
	B.CreateBDFrame(frame, .25)

	local Bar = B:GetModule("Actionbar")

	local styleString = {
		[1] = "NAB:34:12:12:12:34:12:12:12:32:12:0:12:32:12:12:1:32:12:12:1:26:12:10:10:30:12:10:0B24:0B60:-271B26:271B26:-1BR336:-35BR336:0B100:-202B100",
		[2] = "NAB:34:12:12:12:34:12:12:12:34:12:12:12:32:12:12:1:32:12:12:1:26:12:10:10:30:12:10:0B24:0B60:0B96:271B26:-1BR336:-35BR336:0B134:-200B138",
		[3] = "NAB:34:12:12:12:34:12:12:12:34:12:12:6:32:12:12:1:32:12:12:1:26:12:10:10:30:12:10:-108B24:-108B60:216B24:271B26:-1TR-336:-35TR-336:0B98:-310B100",
	}
	local styleName = {
		[1] = _G.DEFAULT,
		[2] = "3X12",
		[3] = "2X18",
		[4] = L["Export"],
		[5] = L["Import"],
	}
	local tooltips = {
		[4] = L["ExportActionbarStyle"],
		[5] = L["ImportActionbarStyle"],
	}

	local function applyBarStyle(self)
		if not IsControlKeyDown() then return end
		local str = styleString[self.index]
		if not str then return end
		Bar:ImportActionbarStyle(str)
	end

	StaticPopupDialogs["NDUI_BARSTYLE_EXPORT"] = {
		text = L["Export"],
		button1 = OKAY,
		OnShow = function(self)
			self.editBox:SetText(Bar:ExportActionbarStyle())
			self.editBox:HighlightText()
		end,
		EditBoxOnEscapePressed = function(self)
			self:GetParent():Hide()
		end,
		whileDead = 1,
		hasEditBox = 1,
		editBoxWidth = 250,
	}

	StaticPopupDialogs["NDUI_BARSTYLE_IMPORT"] = {
		text = L["Import"],
		button1 = OKAY,
		button2 = CANCEL,
		OnShow = function(self)
			self.button1:Disable()
		end,
		OnAccept = function(self)
			Bar:ImportActionbarStyle(self.editBox:GetText())
		end,
		EditBoxOnTextChanged = function(self)
			local button1 = self:GetParent().button1
			local text = self:GetText()
			local found = text and strfind(text, "^NAB:")
			if found then
				button1:Enable()
			else
				button1:Disable()
			end
		end,
		EditBoxOnEscapePressed = function(self)
			self:GetParent():Hide()
		end,
		whileDead = 1,
		showAlert = 1,
		hasEditBox = 1,
		editBoxWidth = 250,
	}

	local function exportBarStyle()
		StaticPopup_Hide("NDUI_BARSTYLE_IMPORT")
		StaticPopup_Show("NDUI_BARSTYLE_EXPORT")
	end

	local function importBarStyle()
		StaticPopup_Hide("NDUI_BARSTYLE_EXPORT")
		StaticPopup_Show("NDUI_BARSTYLE_IMPORT")
	end

	B:RegisterEvent("PLAYER_REGEN_DISABLED", function()
		StaticPopup_Hide("NDUI_BARSTYLE_EXPORT")
		StaticPopup_Hide("NDUI_BARSTYLE_IMPORT")
	end)

	local function styleOnEnter(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(self.title)
		GameTooltip:AddLine(self.tip, .6,.8,1,1)
		GameTooltip:Show()
	end

	local function GetButtonText(i)
		if i == 4 then
			return "|T"..DB.ArrowUp..":18|t"
		elseif i == 5 then
			return "|T"..DB.ArrowUp..":18:18:0:0:1:1:0:1:1:0|t"
		else
			return i
		end
	end

	for i = 1, 5 do
		local bu = B.CreateButton(frame, size, size, GetButtonText(i))
		bu:SetPoint("LEFT", (i-1)*(size + padding) + padding, 0)
		bu.index = i
		bu.title = styleName[i]
		bu.tip = tooltips[i] or L["ApplyBarStyle"]
		if i == 4 then
			bu:SetScript("OnClick", exportBarStyle)
		elseif i == 5 then
			bu:SetScript("OnClick", importBarStyle)
		else
			bu:SetScript("OnClick", applyBarStyle)
		end
		bu:HookScript("OnEnter", styleOnEnter)
		bu:HookScript("OnLeave", B.HideTooltip)
	end
end

function G:SetupBuffFrame(parent)
	local guiName = "NDuiGUI_BuffFrameSetup"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["BuffFrame"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)

	local A = B:GetModule("Auras")
	local parent, offset = scroll.child, -10
	local defaultSize, defaultPerRow = 30, 16

	local function updateBuffFrame()
		if not A.settings then return end
		A:UpdateOptions()
		A:UpdateHeader(A.BuffFrame)
		A.BuffFrame.mover:SetSize(A.BuffFrame:GetSize())
	end
	
	local function updateDebuffFrame()
		if not A.settings then return end
		A:UpdateOptions()
		A:UpdateHeader(A.DebuffFrame)
		A.DebuffFrame.mover:SetSize(A.DebuffFrame:GetSize())
	end

	local function createOptionGroup(parent, title, offset, value, func)
		createOptionTitle(parent, title, offset)
		createOptionCheck(parent, offset-35, L["ReverseGrow"], "Auras", "Reverse"..value, func)
		createOptionSlider(parent, L["Auras Size"], 20, 60, defaultSize, offset-100, value.."Size", func, "Auras")
		createOptionSlider(parent, L["IconsPerRow"], 10, 40, defaultPerRow, offset-170, value.."sPerRow", func, "Auras")
	end

	createOptionGroup(parent, "Buffs", offset, "Buff", updateBuffFrame)
	createOptionGroup(parent, "Debuffs", offset-260, "Debuff", updateDebuffFrame)
end