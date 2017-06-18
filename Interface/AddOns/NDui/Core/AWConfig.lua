local B, C, L, DB = unpack(select(2, ...))

local r, g, b = DB.cc.r, DB.cc.g, DB.cc.b
local f

local function CreatePanel()
	if f then f:Show() return end

	-- Structure
	f = CreateFrame("Frame", "NDui_AWConfig", UIParent)
	f:SetPoint("CENTER")
	f:SetSize(800, 500)
	B.CreateBD(f)
	B.CreateTex(f)
	B.CreateMF(f)
	B.CreateFS(f, 17, L["AWConfig Title"], true, "TOP", 0, -10)
	B.CreateFS(f, 15, L["Groups"], true, "TOPLEFT", 30, -50)
	f:SetFrameStrata("HIGH")
	tinsert(UISpecialFrames, "NDui_AWConfig")

	f.Close = CreateFrame("Button", nil, f)
	f.Close:SetPoint("BOTTOMRIGHT", -20, 15)
	f.Close:SetSize(80, 20)
	B.CreateBD(f.Close, .3)
	B.CreateBC(f.Close)
	B.CreateFS(f.Close, 14, CLOSE, true)
	f.Close:SetScript("OnClick", function()
		f:Hide()
	end)

	f.Complete = CreateFrame("Button", nil, f)
	f.Complete:SetPoint("RIGHT", f.Close, "LEFT", -10, 0)
	f.Complete:SetSize(80, 20)
	B.CreateBD(f.Complete, .3)
	B.CreateBC(f.Complete)
	B.CreateFS(f.Complete, 14, OKAY, true)
	f.Complete:SetScript("OnClick", function()
		f:Hide()
		StaticPopup_Show("RELOAD_NDUI")
	end)

	f.Reset = CreateFrame("Button", nil, f)
	f.Reset:SetPoint("BOTTOMLEFT", 25, 15)
	f.Reset:SetSize(120, 20)
	B.CreateBD(f.Reset, .3)
	B.CreateBC(f.Reset)
	B.CreateFS(f.Reset, 14, L["NDui Reset"], true)
	StaticPopupDialogs["RESET_NDUI_AWLIST"] = {
		text = L["Reset your AuraWatch List?"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			NDuiDB["AuraWatchList"] = {}
			NDuiDB["InternalCD"] = {}
			NDuiADB["RaidDebuffs"] = {}
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

	local function CreateEditbox(parent, text, x, y, tip)
		local eb = CreateFrame("EditBox", nil, parent)
		eb:SetAutoFocus(false)
		eb:SetSize(90, 30)
		eb:SetMaxLetters(8)
		eb:SetTextInsets(10, 10, 0, 0)
		eb:SetFontObject(GameFontHighlight)
		eb:SetPoint("TOPLEFT", x, y)
		B.CreateBD(eb, .3)
		CreateLabel(eb, text, tip)
		eb:SetScript("OnEscapePressed", function()
			eb:ClearFocus()
		end)
		eb:SetScript("OnEnterPressed", function()
			eb:ClearFocus()
		end)

		eb.Type = "EditBox"
		return eb
	end

	local function CreateCheckBox(parent, text, x, y, tip)
		local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
		cb:SetPoint("TOPLEFT", x, y)
		cb:SetHitRectInsets(-5, -5, -5, -5)
		B.CreateCB(cb)
		CreateLabel(cb, text, tip)

		cb.Type = "CheckBox"
		return cb
	end

	local function CreateDropdown(parent, text, x, y, options, tip)
		local dd = CreateFrame("Frame", nil, parent)
		dd:SetPoint("TOPLEFT", x, y)
		dd:SetSize(90, 30)
		B.CreateBD(dd, .3)
		dd.Text = B.CreateFS(dd, 14, "")
		dd.Selection = {}
		CreateLabel(dd, text, tip)

		local bu = CreateFrame("Button", nil, dd)
		bu:SetPoint("LEFT", dd, "RIGHT", -2, 0)
		bu:SetSize(22, 22)
		bu.Icon = bu:CreateTexture(nil, "ARTWORK")
		bu.Icon:SetAllPoints()
		bu.Icon:SetTexture(DB.gearTex)
		bu.Icon:SetTexCoord(0, .5, 0, .5)
		bu:SetHighlightTexture(DB.gearTex)
		bu:GetHighlightTexture():SetTexCoord(0, .5, 0, .5)
		local list = CreateFrame("Frame", nil, dd)
		list:SetPoint("TOP", dd, "BOTTOM")
		B.CreateBD(list, .7)
		bu:SetScript("OnShow", function() list:Hide() end)
		bu:SetScript("OnClick", function()
			PlaySound("gsTitleOptionOK")
			ToggleFrame(list)
		end)

		local opt, index = {}, 0
		for i, j in pairs(options) do
			opt[i] = CreateFrame("Button", nil, list)
			opt[i]:SetPoint("TOPLEFT", 5, -5 - (i-1)*30)
			opt[i]:SetSize(80, 30)
			B.CreateBD(opt[i], .3)
			B.CreateFS(opt[i], 14, j, false, "LEFT", 5, 0)
			opt[i]:SetScript("OnClick", function(self)
				PlaySound("gsTitleOptionOK")
				for index = 1, #opt do
					if index == i then
						opt[index]:SetBackdropColor(1, .8, 0, .3)
						opt[index].selected = true
					else
						opt[index]:SetBackdropColor(0, 0, 0, .3)
						opt[index].selected = false
					end
				end
				dd.Text:SetText(j)
				list:Hide()
			end)
			opt[i]:SetScript("OnEnter", function(self)
				if self.selected then return end
				self:SetBackdropColor(1, 1, 1, .3)
			end)
			opt[i]:SetScript("OnLeave", function(self)
				if self.selected then return end
				self:SetBackdropColor(0, 0, 0, .3)
			end)

			dd.Selection[i] = opt[i]
			index = index + 1
		end
		list:SetSize(90, index*30 + 10)

		dd.Type = "DropDown"
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
			for i = 1, #element.Selection do
				element.Selection[i].selected = false
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
		if IsAddOnLoaded("Aurora") then
			local F = unpack(Aurora)
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
			if (index < 10 and NDuiDB["AuraWatchList"][index][k] ~= nil) or (index == 10 and NDuiDB["InternalCD"][k] ~= nil) or (index == 11 and NDuiADB["RaidDebuffs"][k] ~= nil) then
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
		local intID, duration, itemID = unpack(data)
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
		icon:SetScript("OnEnter", function()
			GameTooltip:ClearLines()
			GameTooltip:SetOwner(icon, "ANCHOR_RIGHT", 0, 3)
			GameTooltip:SetSpellByID(intID)
			GameTooltip:Show()
		end)
		icon:SetScript("OnLeave", GameTooltip_Hide)

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
		icon:SetScript("OnEnter", function()
			GameTooltip:ClearLines()
			GameTooltip:SetOwner(icon, "ANCHOR_RIGHT", 0, 3)
			GameTooltip:SetSpellByID(spellID)
			GameTooltip:Show()
		end)
		icon:SetScript("OnLeave", GameTooltip_Hide)

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

	-- Main
	if not NDuiDB["AuraWatchList"] then NDuiDB["AuraWatchList"] = {} end
	if not NDuiDB["InternalCD"] then NDuiDB["InternalCD"] = {} end
	local groups = {
		L["Player Aura"],		-- 1 PlayerBuff
		L["Special Aura"],		-- 2 SPECIAL
		L["Target Aura"],		-- 3 TargetDebuff
		L["Warning"],			-- 4 Warning
		L["Focus Aura"],		-- 5 FOCUS
		L["Spell Cooldown"],	-- 6 CD
		L["Enchant Aura"],		-- 7 Enchant
		L["Raid Buff"],			-- 8 RaidBuff
		L["Raid Debuff"],		-- 9 RaidDebuff
		L["InternalCD"],		-- 10 InternalCD
		L["RaidFrame Debuffs"],	-- 11 RaidFrame Debuffs
	}
	local instList = {
		[1] = EJ_GetInstanceInfo(768),
		[2] = EJ_GetInstanceInfo(861),
		[3] = EJ_GetInstanceInfo(786),
		[4] = EJ_GetInstanceInfo(875),
	}
	local tabs = {}
	for i, group in pairs(groups) do
		if not NDuiDB["AuraWatchList"][i] then NDuiDB["AuraWatchList"][i] = {} end
		barTable[i] = {}

		tabs[i] = CreateFrame("Button", nil, f)
		tabs[i]:SetPoint("TOPLEFT", 20, -40 - i*30)
		tabs[i]:SetSize(130, 30)
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
			for k, _ in pairs(NDuiDB["AuraWatchList"][i]) do
				AddAura(tabs[i].List.Child, i, NDuiDB["AuraWatchList"][i][k])
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

			for i = 2, 11 do Option[i]:Hide() end

			for i = 1, #Option[1].Selection do
				Option[1].Selection[i]:HookScript("OnClick", function()
					for i = 2, 11 do
						Option[i]:Hide()
						ClearEdit(Option[i])
					end

					if Option[1].Text:GetText() == "AuraID" then
						for j = 2, 9 do Option[j]:Show() end
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
			for k, _ in pairs(NDuiDB["InternalCD"]) do
				AddInternal(tabs[i].List.Child, i, NDuiDB["InternalCD"][k])
			end
			Option[12] = CreateEditbox(tabs[i].Page, L["IntID*"], 20, -30, L["IntID Intro"])
			Option[13] = CreateEditbox(tabs[i].Page, L["Duration*"], 140, -30, L["Duration Intro"])
			Option[14] = CreateEditbox(tabs[i].Page, L["ItemID"], 260, -30, L["ItemID Intro"])
		elseif i == 11 then
			for k, _ in pairs(NDuiADB["RaidDebuffs"]) do
				AddRaidDebuffs(tabs[i].List.Child, i, NDuiADB["RaidDebuffs"][k])
			end
			Option[15] = CreateDropdown(tabs[i].Page, L["Instance*"], 20, -30, {instList[1], instList[2], instList[3], instList[4]}, L["Instance Intro"])
			Option[16] = CreateEditbox(tabs[i].Page, "ID*", 140, -30, L["ID Intro"])
			Option[17] = CreateEditbox(tabs[i].Page, L["Priority"], 260, -30, L["Priority Intro"])
		end

		local clear = CreateFrame("Button", nil, tabs[i].Page)
		clear:SetPoint("TOPRIGHT", -120, -90)
		clear:SetSize(70, 25)
		B.CreateBD(clear, .3)
		B.CreateBC(clear)
		B.CreateFS(clear, 14, KEY_NUMLOCK_MAC, true)
		clear:SetScript("OnClick", function()
			if i < 10 then
				for j = 1, 11 do ClearEdit(Option[j]) end
				for j = 2, 11 do Option[j]:Hide() end
			elseif i == 10 then
				for j = 12, 14 do ClearEdit(Option[j]) end
			elseif i == 11 then
				for j = 15, 17 do ClearEdit(Option[j]) end
			end
		end)

		local slotTable = {6, 11, 12, 13, 14, 15}
		local add = CreateFrame("Button", nil, tabs[i].Page)
		add:SetPoint("TOPRIGHT", -40, -90)
		add:SetSize(70, 25)
		B.CreateBD(add, .3)
		B.CreateBC(add)
		B.CreateFS(add, 14, ADD, true)
		add:SetScript("OnClick", function()
			if i < 10 then
				local typeID, spellID, unitID, slotID, totemID = Option[1].Text:GetText(), tonumber(Option[2]:GetText()), Option[3].Text:GetText()
				for i = 1, #Option[10].Selection do
					if Option[10].Selection[i].selected then slotID = slotTable[i] break end
				end
				for i = 1, #Option[11].Selection do
					if Option[11].Selection[i].selected then totemID = i break end
				end

				if not typeID then UIErrorsFrame:AddMessage(DB.InfoColor..L["Choose a Type"]) return end
				if (typeID == "AuraID" and (not spellID or not unitID)) or (typeID == "SpellID" and not spellID) or (typeID == "SlotID" and not slotID) or (typeID == "TotemID" and not totemID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incomplete Input"]) return end
				if (typeID == "AuraID" or typeID == "SpellID") and not GetSpellInfo(spellID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incorrect SpellID"]) return end

				local realID = spellID or slotID or totemID
				if NDuiDB["AuraWatchList"][i][realID] then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ID"]) return end

				NDuiDB["AuraWatchList"][i][realID] = {typeID, realID, unitID, Option[4].Text:GetText(), tonumber(Option[5]:GetText()), Option[6]:GetChecked(), Option[7]:GetChecked(), Option[7]:GetChecked(), Option[9]:GetText()}
				AddAura(tabs[i].List.Child, i, NDuiDB["AuraWatchList"][i][realID])
				for i = 1, 11 do ClearEdit(Option[i]) end
			elseif i == 10 then
				local intID, duration, itemID = tonumber(Option[12]:GetText()), tonumber(Option[13]:GetText()), tonumber(Option[14]:GetText())
				if not intID or not duration then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incomplete Input"]) return end
				if intID and not GetSpellInfo(intID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incorrect SpellID"]) return end
				if NDuiDB["InternalCD"][intID] then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ID"]) return end

				NDuiDB["InternalCD"][intID] = {intID, duration, itemID}
				AddInternal(tabs[i].List.Child, i, NDuiDB["InternalCD"][intID])
				for i = 12, 14 do ClearEdit(Option[i]) end
			elseif i == 11 then
				local instName, spellID, priority = Option[15].Text:GetText(), tonumber(Option[16]:GetText()), tonumber(Option[17]:GetText())
				if not instName or not spellID then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incomplete Input"]) return end
				if spellID and not GetSpellInfo(spellID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incorrect SpellID"]) return end
				if NDuiADB["RaidDebuffs"][spellID] then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ID"]) return end

				priority = (priority and priority < 0 and 0) or (not priority and 2)
				NDuiADB["RaidDebuffs"][spellID] = {instName, spellID, priority}
				AddRaidDebuffs(tabs[i].List.Child, i, NDuiADB["RaidDebuffs"][spellID])
				for i = 15, 17 do ClearEdit(Option[i]) end
			end
		end)

		tabs[i]:SetScript("OnClick", function()
			for index = 1, #tabs do
				if i == index then
					tabs[index].Page:Show()
					tabs[index]:SetBackdropColor(r, g, b, .3)
					tabs[index].selected = true
				else
					tabs[index].Page:Hide()
					tabs[index]:SetBackdropColor(0, 0, 0, .3)
					tabs[index].selected = false
				end
			end
		end)
		tabs[i]:SetScript("OnEnter", function(self)
			if self.selected then return end
			self:SetBackdropColor(r, g, b, .3)
		end)
		tabs[i]:SetScript("OnLeave", function(self)
			if self.selected then return end
			self:SetBackdropColor(0, 0, 0, .3)
		end)
	end
	
	tabs[1]:Click()

	NDui:EventFrame("PLAYER_REGEN_DISABLED"):SetScript("OnEvent", function(self, event)
		if event == "PLAYER_REGEN_DISABLED" then
			if f:IsShown() then
				f:Hide()
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
			end
		else
			f:Show()
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		end
	end)
end

SlashCmdList["NDUI_AWCONFIG"] = function()
	if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end
	CreatePanel()
end
SLASH_NDUI_AWCONFIG1 = "/awc"