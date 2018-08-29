local _, ns = ...
local B, C, L, DB = unpack(ns)

local r, g, b = DB.cc.r, DB.cc.g, DB.cc.b
local f

local function CreatePanel()
	if f then f:Show() return end

	-- Structure
	f = CreateFrame("Frame", "NDui_AWConfig", UIParent)
	f:SetPoint("CENTER")
	f:SetSize(800, 500)
	B.CreateBD(f)
	B.CreateSD(f)
	B.CreateTex(f)
	B.CreateMF(f)
	B.CreateFS(f, 17, L["AWConfig Title"], true, "TOP", 0, -10)
	B.CreateFS(f, 15, L["Groups"], true, "TOPLEFT", 30, -50)
	f:SetFrameStrata("HIGH")
	tinsert(UISpecialFrames, "NDui_AWConfig")

	f.Close = B.CreateButton(f, 80, 25, CLOSE)
	f.Close:SetPoint("BOTTOMRIGHT", -20, 15)
	f.Close:SetScript("OnClick", function()
		f:Hide()
	end)

	f.Complete = B.CreateButton(f, 80, 25, OKAY)
	f.Complete:SetPoint("RIGHT", f.Close, "LEFT", -10, 0)
	f.Complete:SetScript("OnClick", function()
		f:Hide()
		StaticPopup_Show("RELOAD_NDUI")
	end)

	f.Reset = B.CreateButton(f, 120, 25, L["NDui Reset"])
	f.Reset:SetPoint("BOTTOMLEFT", 25, 15)
	StaticPopupDialogs["RESET_NDUI_AWLIST"] = {
		text = L["Reset your AuraWatch List?"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			NDuiDB["AuraWatchList"] = {}
			NDuiDB["InternalCD"] = {}
			NDuiADB["RaidDebuffs"] = {}
			NDuiDB["RaidClickSets"] = {}
			ReloadUI()
		end,
		whileDead = 1,
	}
	f.Reset:SetScript("OnClick", function()
		StaticPopup_Show("RESET_NDUI_AWLIST")
	end)

	-- Elements
	local function CreateLabel(parent, text, tip)
		local label = B.CreateFS(parent, 14, text, false, "CENTER", 0, 25)
		label:SetTextColor(1, .8, 0)
		local frame = CreateFrame("Frame", nil, parent)
		frame:SetAllPoints(label)
		frame:SetScript("OnEnter", function()
			GameTooltip:ClearLines()
			GameTooltip:SetOwner(parent, "ANCHOR_RIGHT", 0, 3)
			GameTooltip:AddLine(text)
			GameTooltip:AddLine(tip, .6,.8,1)
			GameTooltip:Show()
		end)
		frame:SetScript("OnLeave", GameTooltip_Hide)
	end

	local function CreateEditbox(parent, text, x, y, tip, width, height)
		local eb = B.CreateEditBox(parent, width or 90, height or 30)
		eb:SetPoint("TOPLEFT", x, y)
		eb:SetMaxLetters(255)
		CreateLabel(eb, text, tip)

		return eb
	end

	local function CreateCheckBox(parent, text, x, y, tip)
		local cb = B.CreateCheckBox(parent)
		cb:SetPoint("TOPLEFT", x, y)
		cb:SetHitRectInsets(-5, -5, -5, -5)
		CreateLabel(cb, text, tip)

		return cb
	end

	local function CreateDropdown(parent, text, x, y, data, tip, width, height)
		local dd = B.CreateDropDown(parent, width or 90, height or 30, data)
		dd:SetPoint("TOPLEFT", x, y)
		CreateLabel(dd, text, tip)

		return dd
	end

	local function ClearEdit(element)
		if element.Type == "EditBox" then
			element:ClearFocus()
			element:SetText("")
		elseif element.Type == "CheckBox" then
			element:SetChecked(false)
		elseif element.Type == "DropDown" then
			element.Text:SetText("")
			for i = 1, #element.options do
				element.options[i].selected = false
			end
		end
	end

	local function CreatePage(name)
		local p = CreateFrame("Frame", nil, f)
		p:SetPoint("TOPLEFT", 160, -70)
		p:SetSize(620, 380)
		B.CreateBD(p, .2)
		B.CreateFS(p, 15, name, false, "TOPLEFT", 5, 20)
		p:Hide()
		return p
	end

	local function CreateScroll(parent)
		local scroll = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
		scroll:SetSize(575, 200)
		scroll:SetPoint("BOTTOMLEFT", 10, 10)
		B.CreateBD(scroll, .2)
		B.CreateFS(scroll, 15, L["AuraWatch List"], false, "TOPLEFT", 5, 20)
		if IsAddOnLoaded("AuroraClassic") then
			local F = unpack(AuroraClassic)
			F.ReskinScroll(scroll.ScrollBar)
		end

		scroll.Child = CreateFrame("Frame", nil, scroll)
		scroll.Child:SetSize(585, 1)
		scroll:SetScrollChild(scroll.Child)
		return scroll
	end

	local barTable = {}
	local function SortBars(index)
		local num, onLeft, onRight = 1, 1, 1
		for k in pairs(barTable[index]) do
			if (index < 10 and NDuiDB["AuraWatchList"][index][k]) or (index == 10 and NDuiDB["InternalCD"][k]) or (index == 11 and NDuiADB["RaidDebuffs"][k]) or (index == 12 and NDuiDB["RaidClickSets"][k]) then
				local bar = barTable[index][k]
				if num == 1 then
					bar:SetPoint("TOPLEFT", 10, -10)
				elseif num > 1 and num/2 ~= floor(num/2) then
					bar:SetPoint("TOPLEFT", 10, -10 - 35*onLeft)
					onLeft = onLeft + 1
				elseif num == 2 then
					bar:SetPoint("TOPLEFT", 295, -10)
				elseif num > 2 and num/2 == floor(num/2) then
					bar:SetPoint("TOPLEFT", 295, -10 - 35*onRight)
					onRight = onRight + 1
				end
				num = num + 1
			end
		end
	end

	local slotIndex = {
		[6] = INVTYPE_WAIST,
		[11] = INVTYPE_FINGER.."1",
		[12] = INVTYPE_FINGER.."2",
		[13] = INVTYPE_TRINKET.."1",
		[14] = INVTYPE_TRINKET.."2",
		[15] = INVTYPE_CLOAK,
	}
	local function AddAura(parent, index, data)
		local typeID, spellID, _, _, _, _, _, _, text = unpack(data)
		local name, _, texture = GetSpellInfo(spellID)
		if typeID == "SlotID" then
			texture = GetInventoryItemTexture("player", spellID)
			name = slotIndex[spellID]
		elseif typeID == "TotemID" then
			texture = "Interface\\ICONS\\INV_Misc_QuestionMark"
			name = L["TotemSlot"]..spellID
		end

		local bar = CreateFrame("Frame", nil, parent)
		bar:SetSize(280, 30)
		B.CreateBD(bar, .3)
		barTable[index][spellID] = bar

		local icon = CreateFrame("Frame", nil, bar)
		icon:SetSize(20, 20)
		icon:SetPoint("LEFT", 5, 0)
		B.CreateIF(icon, true)
		icon.Icon:SetTexture(texture)
		if typeID ~= "TotemID" then
			icon:SetScript("OnEnter", function()
				GameTooltip:ClearLines()
				GameTooltip:SetOwner(icon, "ANCHOR_RIGHT", 0, 3)
				if typeID == "SlotID" then
					GameTooltip:SetInventoryItem("player", spellID)
				else
					GameTooltip:SetSpellByID(spellID)
				end
				GameTooltip:Show()
			end)
			icon:SetScript("OnLeave", GameTooltip_Hide)
		end

		local close = CreateFrame("Button", nil, bar)
		close:SetSize(20, 20)
		close:SetPoint("RIGHT", -5, 0)
		close.Icon = close:CreateTexture(nil, "ARTWORK")
		close.Icon:SetAllPoints()
		close.Icon:SetTexture("Interface\\BUTTONS\\UI-GroupLoot-Pass-Up")
		close:SetHighlightTexture(close.Icon:GetTexture())
		close:SetScript("OnClick", function()
			bar:Hide()
			NDuiDB["AuraWatchList"][index][spellID] = nil
			barTable[index][spellID] = nil
			SortBars(index)
		end)
		local spellName = B.CreateFS(bar, 14, name, false, "LEFT", 30, 0)
		spellName:SetWidth(180)
		spellName:SetJustifyH("LEFT")
		B.CreateFS(bar, 14, text, false, "RIGHT", -30, 0)

		SortBars(index)
	end

	local function AddInternal(parent, index, data)
		local intID, duration, trigger, unit, itemID = unpack(data)
		local name, _, texture = GetSpellInfo(intID)
		if itemID then
			name = GetItemInfo(itemID)
		end

		local bar = CreateFrame("Frame", nil, parent)
		bar:SetSize(280, 30)
		B.CreateBD(bar, .3)
		barTable[index][intID] = bar

		local icon = CreateFrame("Frame", nil, bar)
		icon:SetSize(20, 20)
		icon:SetPoint("LEFT", 5, 0)
		B.CreateIF(icon, true)
		icon.Icon:SetTexture(texture)
		B.AddTooltip(icon, "ANCHOR_RIGHT", intID)

		local close = CreateFrame("Button", nil, bar)
		close:SetSize(20, 20)
		close:SetPoint("RIGHT", -5, 0)
		close.Icon = close:CreateTexture(nil, "ARTWORK")
		close.Icon:SetAllPoints()
		close.Icon:SetTexture("Interface\\BUTTONS\\UI-GroupLoot-Pass-Up")
		close:SetHighlightTexture(close.Icon:GetTexture())
		close:SetScript("OnClick", function()
			bar:Hide()
			NDuiDB["InternalCD"][intID] = nil
			barTable[index][intID] = nil
			SortBars(index)
		end)
		local spellName = B.CreateFS(bar, 14, name, false, "LEFT", 30, 0)
		spellName:SetWidth(180)
		spellName:SetJustifyH("LEFT")
		B.CreateFS(bar, 14, duration, false, "RIGHT", -30, 0)
		B.AddTooltip(bar, "ANCHOR_TOP", L["Trigger"]..trigger.." - "..unit, "system")

		SortBars(index)
	end

	local function AddRaidDebuffs(parent, index, data)
		local instName, spellID, priority = unpack(data)
		local name, _, texture = GetSpellInfo(spellID)

		local bar = CreateFrame("Frame", nil, parent)
		bar:SetSize(280, 30)
		B.CreateBD(bar, .3)
		barTable[index][spellID] = bar

		local icon = CreateFrame("Frame", nil, bar)
		icon:SetSize(20, 20)
		icon:SetPoint("LEFT", 5, 0)
		B.CreateIF(icon, true)
		icon.Icon:SetTexture(texture)
		B.AddTooltip(icon, "ANCHOR_RIGHT", spellID)

		local close = CreateFrame("Button", nil, bar)
		close:SetSize(20, 20)
		close:SetPoint("RIGHT", -5, 0)
		close.Icon = close:CreateTexture(nil, "ARTWORK")
		close.Icon:SetAllPoints()
		close.Icon:SetTexture("Interface\\BUTTONS\\UI-GroupLoot-Pass-Up")
		close:SetHighlightTexture(close.Icon:GetTexture())
		close:SetScript("OnClick", function()
			bar:Hide()
			NDuiADB["RaidDebuffs"][spellID] = nil
			barTable[index][spellID] = nil
			SortBars(index)
		end)

		local prioString = B.CreateFS(bar, 14, priority, false, "LEFT", 30, 0)
		prioString:SetTextColor(0, 1, 0)
		local spellName = B.CreateFS(bar, 14, name, false, "LEFT", 40, 0)
		spellName:SetWidth(120)
		spellName:SetJustifyH("LEFT")
		local instance = B.CreateFS(bar, 14, instName, false, "RIGHT", -35, 0)
		instance:SetTextColor(.6, .8, 1)

		SortBars(index)
	end

	local textIndex = {
		["target"] = TARGET,
		["focus"] = SET_FOCUS,
		["follow"] = FOLLOW,
	}
	local function AddRaidClickSets(parent, index, data)
		local key, modKey, value = unpack(data)
		local clickSet = modKey..key
		local name, texture, _
		if tonumber(value) then
			name, _, texture = GetSpellInfo(value)
		else
			name = textIndex[value] or MACRO
			texture = 136243
		end

		local bar = CreateFrame("Frame", nil, parent)
		bar:SetSize(280, 30)
		B.CreateBD(bar, .3)
		barTable[index][clickSet] = bar

		local icon = CreateFrame("Frame", nil, bar)
		icon:SetSize(20, 20)
		icon:SetPoint("LEFT", 5, 0)
		B.CreateIF(icon, true)
		icon.Icon:SetTexture(texture)
		B.AddTooltip(icon, "ANCHOR_RIGHT", value, "system")

		local close = CreateFrame("Button", nil, bar)
		close:SetSize(20, 20)
		close:SetPoint("RIGHT", -5, 0)
		close.Icon = close:CreateTexture(nil, "ARTWORK")
		close.Icon:SetAllPoints()
		close.Icon:SetTexture("Interface\\BUTTONS\\UI-GroupLoot-Pass-Up")
		close:SetHighlightTexture(close.Icon:GetTexture())
		close:SetScript("OnClick", function()
			bar:Hide()
			NDuiDB["RaidClickSets"][clickSet] = nil
			barTable[index][clickSet] = nil
			SortBars(index)
		end)

		local spellName = B.CreateFS(bar, 14, name, false, "LEFT", 30, 0)
		spellName:SetWidth(120)
		spellName:SetJustifyH("LEFT")
		local key1 = B.CreateFS(bar, 14, key, false, "RIGHT", -35, 0)
		key1:SetTextColor(.6, .8, 1)
		local key2 = B.CreateFS(bar, 14, modKey, false, "RIGHT", -35, 0)
		key2:SetPoint("RIGHT", key1, "LEFT", -5, 0)
		key2:SetTextColor(0, 1, 0)

		SortBars(index)
	end

	local function CreateGroupSwitcher(parent, index)
		local bu = B.CreateCheckBox(parent)
		bu:SetHitRectInsets(-100, 0, 0, 0)
		bu:SetPoint("TOPRIGHT", -40, -145)
		bu:SetChecked(NDuiDB["AuraWatchList"]["Switcher"..index])
		bu:SetScript("OnClick", function()
			NDuiDB["AuraWatchList"]["Switcher"..index] = bu:GetChecked()
		end)
		B.CreateFS(bu, 15, "|cffff0000"..L["AW Switcher"], false, "RIGHT", -25, 0)
	end

	-- Main
	local groups = {
		L["Player Aura"],			-- 1 PlayerBuff
		L["Special Aura"],			-- 2 SPECIAL
		L["Target Aura"],			-- 3 TargetDebuff
		L["Warning"],				-- 4 Warning
		L["Focus Aura"],			-- 5 FOCUS
		L["Spell Cooldown"],		-- 6 CD
		L["Enchant Aura"],			-- 7 Enchant
		L["Raid Buff"],				-- 8 RaidBuff
		L["Raid Debuff"],			-- 9 RaidDebuff
		L["InternalCD"],			-- 10 InternalCD
		L["RaidFrame Debuffs"],		-- 11 RaidFrame Debuffs
		L["RaidFrame ClickSets"],	-- 12 RaidFrame ClickSets
	}
	local instList = {
		[1] = EJ_GetInstanceInfo(768),
		[2] = EJ_GetInstanceInfo(861),
		[3] = EJ_GetInstanceInfo(786),
		[4] = EJ_GetInstanceInfo(875),
		[5] = EJ_GetInstanceInfo(946),
		[6] = EJ_GetInstanceInfo(1031),
	}
	local preSet = {
		[1] = {1, true},
		[2] = {1, true},
		[3] = {2, true},
		[4] = {2, false},
		[5] = {3, false},
		[6] = {1, false},
		[7] = {1, false},
		[8] = {1, false},
		[9] = {1, false},
	}
	local tabs = {}
	local function tabOnClick(self)
		for i = 1, #tabs do
			if self == tabs[i] then
				tabs[i].Page:Show()
				tabs[i]:SetBackdropColor(r, g, b, .3)
				tabs[i].selected = true
			else
				tabs[i].Page:Hide()
				tabs[i]:SetBackdropColor(0, 0, 0, .3)
				tabs[i].selected = false
			end
		end
	end
	local function tabOnEnter(self)
		if self.selected then return end
		self:SetBackdropColor(r, g, b, .3)
	end
	local function tabOnLeave(self)
		if self.selected then return end
		self:SetBackdropColor(0, 0, 0, .3)
	end

	for i, group in pairs(groups) do
		if not NDuiDB["AuraWatchList"][i] then NDuiDB["AuraWatchList"][i] = {} end
		barTable[i] = {}

		tabs[i] = CreateFrame("Button", "$parentTab"..i, f)
		tabs[i]:SetPoint("TOPLEFT", 20, -40 - i*30)
		tabs[i]:SetSize(130, 28)
		B.CreateBD(tabs[i], .3)
		local label = B.CreateFS(tabs[i], 15, group, true, "LEFT", 10, 0)
		if i < 11 then
			label:SetTextColor(1, .8, 0)
		else
			label:SetTextColor(.6, .8, 1)
		end
		tabs[i].Page = CreatePage(group)
		tabs[i].List = CreateScroll(tabs[i].Page)

		local Option = {}
		if i < 10 then
			for _, v in pairs(NDuiDB["AuraWatchList"][i]) do
				AddAura(tabs[i].List.Child, i, v)
			end
			Option[1] = CreateDropdown(tabs[i].Page, L["Type*"], 20, -30, {"AuraID", "SpellID", "SlotID", "TotemID"}, L["Type Intro"])
			Option[2] = CreateEditbox(tabs[i].Page, "ID*", 140, -30, L["ID Intro"])
			Option[3] = CreateDropdown(tabs[i].Page, L["Unit*"], 260, -30, {"player", "target", "focus", "pet"}, L["Unit Intro"])
			Option[4] = CreateDropdown(tabs[i].Page, L["Caster"], 380, -30, {"player", "target", "pet"}, L["Caster Intro"])
			Option[5] = CreateEditbox(tabs[i].Page, L["Stack"], 500, -30, L["Stack Intro"])
			Option[6] = CreateCheckBox(tabs[i].Page, L["Value"], 40, -95, L["Value Intro"])
			Option[7] = CreateCheckBox(tabs[i].Page, L["Timeless"], 120, -95, L["Timeless Intro"])
			Option[8] = CreateCheckBox(tabs[i].Page, L["Combat"], 200, -95, L["Combat Intro"])
			Option[9] = CreateEditbox(tabs[i].Page, L["Text"], 260, -90, L["Text Intro"])
			Option[10] = CreateDropdown(tabs[i].Page, L["Slot*"], 140, -30, {slotIndex[6], slotIndex[11], slotIndex[12], slotIndex[13], slotIndex[14], slotIndex[15]}, L["Slot Intro"])
			Option[11] = CreateDropdown(tabs[i].Page, L["Totem*"], 140, -30, {L["TotemSlot"].."1", L["TotemSlot"].."2", L["TotemSlot"].."3", L["TotemSlot"].."4"}, L["Totem Intro"])

			for j = 2, 11 do Option[j]:Hide() end

			for j = 1, #Option[1].options do
				Option[1].options[j]:HookScript("OnClick", function()
					for k = 2, 11 do
						Option[k]:Hide()
						ClearEdit(Option[k])
					end

					if Option[1].Text:GetText() == "AuraID" then
						for k = 2, 9 do Option[k]:Show() end
						Option[3].options[preSet[i][1]]:Click()
						if preSet[i][2] then Option[4].options[1]:Click() end
					elseif Option[1].Text:GetText() == "SpellID" then
						Option[2]:Show()
					elseif Option[1].Text:GetText() == "SlotID" then
						Option[10]:Show()
					elseif Option[1].Text:GetText() == "TotemID" then
						Option[11]:Show()
					end
				end)
			end
		elseif i == 10 then
			for _, v in pairs(NDuiDB["InternalCD"]) do
				AddInternal(tabs[i].List.Child, i, v)
			end
			Option[12] = CreateEditbox(tabs[i].Page, L["IntID*"], 20, -30, L["IntID Intro"])
			Option[13] = CreateEditbox(tabs[i].Page, L["Duration*"], 140, -30, L["Duration Intro"])
			Option[14] = CreateDropdown(tabs[i].Page, L["Trigger"].."*", 260, -30, {"OnAuraGain", "OnCastSuccess"}, L["Trigger Intro"], 130, 30)
			Option[15] = CreateDropdown(tabs[i].Page, L["Unit*"], 420, -30, {"Player", "All"}, L["Trigger Unit Intro"])
			Option[16] = CreateEditbox(tabs[i].Page, L["ItemID"], 20, -95, L["ItemID Intro"])
		elseif i == 11 then
			for _, v in pairs(NDuiADB["RaidDebuffs"]) do
				AddRaidDebuffs(tabs[i].List.Child, i, v)
			end
			local instTable = {}
			for _, inst in ipairs(instList) do
				tinsert(instTable, inst)
			end
			Option[17] = CreateDropdown(tabs[i].Page, L["Instance*"], 20, -30, instTable, L["Instance Intro"], 200, 30)
			Option[18] = CreateEditbox(tabs[i].Page, "ID*", 250, -30, L["ID Intro"])
			Option[19] = CreateEditbox(tabs[i].Page, L["Priority"], 370, -30, L["Priority Intro"])
		elseif i == 12 then
			for _, v in pairs(NDuiDB["RaidClickSets"]) do
				AddRaidClickSets(tabs[i].List.Child, i, v)
			end
			Option[20] = CreateEditbox(tabs[i].Page, L["Action*"], 20, -30, L["Action Intro"], 200, 30)
			Option[21] = CreateDropdown(tabs[i].Page, L["Key*"], 250, -30, {KEY_BUTTON1, KEY_BUTTON2, KEY_BUTTON3, KEY_BUTTON4, KEY_BUTTON5}, L["Key Intro"], 110, 30)
			Option[22] = CreateDropdown(tabs[i].Page, L["Modified Key"], 390, -30, {NONE, "ALT", "CTRL", "SHIFT"}, L["ModKey Intro"], 110, 30)

			local reset = B.CreateButton(tabs[i].Page, 70, 25, RESET)
			reset:SetPoint("TOPRIGHT", -200, -90)
			StaticPopupDialogs["RESET_NDUI_CLICKSETS"] = {
				text = L["Reset your click sets?"],
				button1 = YES,
				button2 = NO,
				OnAccept = function()
					NDuiDB["RaidClickSets"] = nil
					ReloadUI()
				end,
				whileDead = 1,
			}
			reset:SetScript("OnClick", function()
				StaticPopup_Show("RESET_NDUI_CLICKSETS")
			end)
		end

		local clear = B.CreateButton(tabs[i].Page, 70, 25, KEY_NUMLOCK_MAC)
		clear:SetPoint("TOPRIGHT", -120, -90)
		clear:SetScript("OnClick", function()
			if i < 10 then
				for j = 1, 11 do ClearEdit(Option[j]) end
				for j = 2, 11 do Option[j]:Hide() end
			elseif i == 10 then
				for j = 12, 16 do ClearEdit(Option[j]) end
			elseif i == 11 then
				for j = 17, 19 do ClearEdit(Option[j]) end
			elseif i== 12 then
				for j = 20, 22 do ClearEdit(Option[j]) end
			end
		end)

		local slotTable = {6, 11, 12, 13, 14, 15}
		local add = B.CreateButton(tabs[i].Page, 70, 25, ADD)
		add:SetPoint("TOPRIGHT", -40, -90)
		add:SetScript("OnClick", function()
			if i < 10 then
				local typeID, spellID, unitID, slotID, totemID = Option[1].Text:GetText(), tonumber(Option[2]:GetText()), Option[3].Text:GetText()
				for i = 1, #Option[10].options do
					if Option[10].options[i].selected then slotID = slotTable[i] break end
				end
				for i = 1, #Option[11].options do
					if Option[11].options[i].selected then totemID = i break end
				end

				if not typeID then UIErrorsFrame:AddMessage(DB.InfoColor..L["Choose a Type"]) return end
				if (typeID == "AuraID" and (not spellID or not unitID)) or (typeID == "SpellID" and not spellID) or (typeID == "SlotID" and not slotID) or (typeID == "TotemID" and not totemID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incomplete Input"]) return end
				if (typeID == "AuraID" or typeID == "SpellID") and not GetSpellInfo(spellID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incorrect SpellID"]) return end

				local realID = spellID or slotID or totemID
				if NDuiDB["AuraWatchList"][i][realID] then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ID"]) return end

				NDuiDB["AuraWatchList"][i][realID] = {typeID, realID, unitID, Option[4].Text:GetText(), tonumber(Option[5]:GetText()), Option[6]:GetChecked(), Option[7]:GetChecked(), Option[8]:GetChecked(), Option[9]:GetText()}
				AddAura(tabs[i].List.Child, i, NDuiDB["AuraWatchList"][i][realID])
				for i = 1, 11 do ClearEdit(Option[i]) end
			elseif i == 10 then
				local intID, duration, trigger, unit, itemID = tonumber(Option[12]:GetText()), tonumber(Option[13]:GetText()), Option[14].Text:GetText(), Option[15].Text:GetText(), tonumber(Option[16]:GetText())
				if not intID or not duration or not trigger or not unit then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incomplete Input"]) return end
				if intID and not GetSpellInfo(intID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incorrect SpellID"]) return end
				if NDuiDB["InternalCD"][intID] then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ID"]) return end

				NDuiDB["InternalCD"][intID] = {intID, duration, trigger, unit, itemID}
				AddInternal(tabs[i].List.Child, i, NDuiDB["InternalCD"][intID])
				for i = 12, 16 do ClearEdit(Option[i]) end
			elseif i == 11 then
				local instName, spellID, priority = Option[17].Text:GetText(), tonumber(Option[18]:GetText()), tonumber(Option[19]:GetText())
				if not instName or not spellID then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incomplete Input"]) return end
				if spellID and not GetSpellInfo(spellID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incorrect SpellID"]) return end
				if NDuiADB["RaidDebuffs"][spellID] then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ID"]) return end

				priority = (priority and priority < 0 and 0) or (not priority and 2)
				NDuiADB["RaidDebuffs"][spellID] = {instName, spellID, priority}
				AddRaidDebuffs(tabs[i].List.Child, i, NDuiADB["RaidDebuffs"][spellID])
				for i = 17, 19 do ClearEdit(Option[i]) end
			elseif i == 12 then
				local value, key, modKey = Option[20]:GetText(), Option[21].Text:GetText(), Option[22].Text:GetText()
				if not value or not key then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incomplete Input"]) return end
				if tonumber(value) and not GetSpellInfo(value) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incorrect SpellID"]) return end
				if (not tonumber(value)) and value ~= "target" and value ~= "focus" and value ~= "follow" and not value:match("/") then UIErrorsFrame:AddMessage(DB.InfoColor..L["Invalid Input"]) return end
				if not modKey or modKey == NONE then modKey = "" end
				local clickSet = modKey..key
				if NDuiDB["RaidClickSets"][clickSet] then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ClickSet"]) return end

				NDuiDB["RaidClickSets"][clickSet] = {key, modKey, value}
				AddRaidClickSets(tabs[i].List.Child, i, NDuiDB["RaidClickSets"][clickSet])
				for i = 20, 22 do ClearEdit(Option[i]) end
			end
		end)

		tabs[i]:SetScript("OnClick", tabOnClick)
		tabs[i]:SetScript("OnEnter", tabOnEnter)
		tabs[i]:SetScript("OnLeave", tabOnLeave)
	end

	for i = 1, 10 do
		CreateGroupSwitcher(tabs[i].Page, i)
	end

	tabs[1]:Click()

	local function showLater(event)
		if event == "PLAYER_REGEN_DISABLED" then
			if f:IsShown() then
				f:Hide()
				B:RegisterEvent("PLAYER_REGEN_ENABLED", showLater)
			end
		else
			f:Show()
			B:UnregisterEvent(event, showLater)
		end
	end
	B:RegisterEvent("PLAYER_REGEN_DISABLED", showLater)
end

SlashCmdList["NDUI_AWCONFIG"] = function()
	if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end
	CreatePanel()
end
SLASH_NDUI_AWCONFIG1 = "/ww"