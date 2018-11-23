local _, ns = ...
local B, C, L, DB = unpack(ns)

local AuraList, Aura, UnitIDTable, IntTable, IntCD, statTable = {}, {}, {}, {}, {}, {}
local MaxFrame = 12	-- Max Tracked Auras
local pairs, tinsert, tremove = pairs, table.insert, table.remove
local max, wipe, sort = math.max, table.wipe, table.sort
local GetCombatRating = GetCombatRating
local CR_HASTE_MELEE, CR_MASTERY, CR_VERSATILITY_DAMAGE_DONE = CR_HASTE_MELEE, CR_MASTERY, CR_VERSATILITY_DAMAGE_DONE
local CR_CRIT_SPELL, CR_CRIT_RANGED, CR_CRIT_MELEE = CR_CRIT_SPELL, CR_CRIT_RANGED, CR_CRIT_MELEE

-- Init
local function ConvertTable()
	local function DataAnalyze(v)
		local newTable = {}
		if type(v[1]) == "number" then
			newTable.IntID = v[1]
			newTable.Duration = v[2]
			if v[3] == "OnCastSuccess" then newTable.OnSuccess = true end
			newTable.UnitID = v[4]
			newTable.ItemID = v[5]
		else
			newTable[v[1]] = v[2]
			newTable.UnitID = v[3]
			newTable.Caster = v[4]
			newTable.Stack = v[5]
			newTable.Value = v[6]
			newTable.Timeless = v[7]
			newTable.Combat = v[8]
			newTable.Text = v[9]
			newTable.Flash = v[10]
		end

		return newTable
	end

	local myTable = {}
	for i = 1, 10 do
		myTable[i] = {}
		if i < 10 then
			if NDuiDB["AuraWatchList"][i] then
				for _, v in pairs(NDuiDB["AuraWatchList"][i]) do
					tinsert(myTable[i], DataAnalyze(v))
				end
			end
		else
			if NDuiDB["InternalCD"] then
				for _, v in pairs(NDuiDB["InternalCD"]) do
					tinsert(myTable[i], DataAnalyze(v))
				end
			end
		end
	end

	local function InsertData(index, target)
		if NDuiDB["AuraWatchList"]["Switcher"..index] then
			wipe(target)
		else
			for _, v in pairs(myTable[index]) do
				for _, list in pairs(target) do
					if list.AuraID and v.AuraID and list.AuraID == v.AuraID then
						wipe(list)
					end
				end
				tinsert(target, v)
			end
		end
	end

	for _, v in pairs(C.AuraWatchList[DB.MyClass]) do
		if v.Name == "Player Aura" then
			InsertData(1, v.List)
		elseif v.Name == "Target Aura" then
			InsertData(3, v.List)
		elseif v.Name == "Special Aura" then
			InsertData(2, v.List)
		elseif v.Name == "Focus Aura" then
			InsertData(5, v.List)
		elseif v.Name == "Spell Cooldown" then
			InsertData(6, v.List)
		end
	end

	for i, v in pairs(C.AuraWatchList["ALL"]) do
		if v.Name == "Enchant Aura" then
			InsertData(7, v.List)
		elseif v.Name == "Raid Buff" then
			InsertData(8, v.List)
		elseif v.Name == "Raid Debuff" then
			InsertData(9, v.List)
		elseif v.Name == "Warning" then
			InsertData(4, v.List)
		elseif v.Name == "InternalCD" then
			InsertData(10, v.List)
			IntCD = v
			tremove(C.AuraWatchList["ALL"], i)
		end
	end
end

local function BuildAuraList()
	AuraList = C.AuraWatchList["ALL"] or {}
	for class in pairs(C.AuraWatchList) do
		if class == DB.MyClass then
			for _, value in pairs(C.AuraWatchList[class]) do
				tinsert(AuraList, value)
			end
		end
	end
	wipe(C.AuraWatchList)
end

local function BuildUnitIDTable()
	for _, VALUE in pairs(AuraList) do
		for _, value in pairs(VALUE.List) do
			local Flag = true
			for _, v in pairs(UnitIDTable) do
				if value.UnitID == v then Flag = false end
			end
			if Flag then tinsert(UnitIDTable, value.UnitID) end
		end
	end
end

local function MakeMoveHandle(frame, text, value, anchor)
	local mover = B.Mover(frame, text, value, anchor, nil, nil, true)
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", mover)

	return mover
end

-----> STYLED CODE START
-- BuildICON
local function updateTooltip(self)
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 3)
	if self.type == 1 then
		GameTooltip:SetSpellByID(self.spellID)
	elseif self.type == 2 then
		GameTooltip:SetHyperlink(select(2, GetItemInfo(self.spellID)))
	elseif self.type == 3 then
		GameTooltip:SetInventoryItem("player", self.spellID)
	elseif self.type == 4 then
		GameTooltip:SetUnitAura(self.unitID, self.id, self.filter)
	end
	GameTooltip:Show()
end

local function enableTooltip(self)
	self:EnableMouse(true)
	self.HL = self:CreateTexture(nil, "HIGHLIGHT")
	self.HL:SetColorTexture(1, 1, 1, .25)
	self.HL:SetAllPoints(self.Icon)
	self:SetScript("OnEnter", updateTooltip)
	self:SetScript("OnLeave", GameTooltip_Hide)
end

local function BuildICON(iconSize)
	iconSize = iconSize * NDuiDB["AuraWatch"]["IconScale"]

	local Frame = CreateFrame("Frame", nil, UIParent)
	Frame:SetSize(iconSize, iconSize)
	B.CreateSD(Frame, 3, 3)

	Frame.Icon = Frame:CreateTexture(nil, "ARTWORK")
	Frame.Icon:SetAllPoints()
	Frame.Icon:SetTexCoord(unpack(DB.TexCoord))

	Frame.Cooldown = CreateFrame("Cooldown", nil, Frame, "CooldownFrameTemplate")
	Frame.Cooldown:SetAllPoints()
	Frame.Cooldown:SetReverse(true)

	local parentFrame = CreateFrame("Frame", nil, Frame)
	parentFrame:SetAllPoints()
	parentFrame:SetFrameLevel(Frame:GetFrameLevel() + 5)

	Frame.Spellname = B.CreateFS(parentFrame, 13, "", false, "TOP", 0, 5)
	Frame.Count = B.CreateFS(parentFrame, iconSize*.55, "", false, "BOTTOMRIGHT", 6, -3)
	Frame.glowFrame = B.CreateBG(Frame, 4)
	Frame.glowFrame:SetSize(iconSize+8, iconSize+8)
	if not NDuiDB["AuraWatch"]["ClickThrough"] then enableTooltip(Frame) end

	Frame.isAuraWatch = true
	Frame:Hide()
	return Frame
end

-- BuildBAR
local function BuildBAR(barWidth, iconSize)
	local Frame = CreateFrame("Frame", nil, UIParent)
	Frame:SetSize(iconSize, iconSize)
	B.CreateSD(Frame, 2, 2)

	Frame.Icon = Frame:CreateTexture(nil, "ARTWORK")
	Frame.Icon:SetAllPoints()
	Frame.Icon:SetTexCoord(unpack(DB.TexCoord))

	Frame.Statusbar = CreateFrame("StatusBar", nil, Frame)
	Frame.Statusbar:SetSize(barWidth, iconSize/2.5)
	Frame.Statusbar:SetPoint("BOTTOMLEFT", Frame, "BOTTOMRIGHT", 5, 0)
	Frame.Statusbar:SetMinMaxValues(0, 1)
	Frame.Statusbar:SetValue(0)
	B.CreateSB(Frame.Statusbar, true)

	Frame.Count = B.CreateFS(Frame, 14, "", false, "BOTTOMRIGHT", 3, -1)
	Frame.Time = B.CreateFS(Frame.Statusbar, 14, "", false, "RIGHT", 0, 8)
	Frame.Spellname = B.CreateFS(Frame.Statusbar, 14, "", false, "LEFT", 2, 8)
	Frame.Spellname:SetWidth(Frame.Statusbar:GetWidth()*.6)
	Frame.Spellname:SetJustifyH("LEFT")
	if not NDuiDB["AuraWatch"]["ClickThrough"] then enableTooltip(Frame) end

	Frame.isAuraWatch = true
	Frame:Hide()
	return Frame
end
-----> STYLED CODE END

local function BuildAura()
	for key, value in pairs(AuraList) do
		local FrameTable = {}
		for i = 1, MaxFrame do
			if value.Mode:lower() == "icon" then
				local Frame = BuildICON(value.IconSize)
				if i == 1 then Frame.MoveHandle = MakeMoveHandle(Frame, L[value.Name], key, value.Pos) end
				tinsert(FrameTable, Frame)
			elseif value.Mode:lower() == "bar" then
				local Frame = BuildBAR(value.BarWidth, value.IconSize)
				if i == 1 then Frame.MoveHandle = MakeMoveHandle(Frame, L[value.Name], key, value.Pos) end
				tinsert(FrameTable, Frame)
			end
		end
		FrameTable.Index = 1
		tinsert(Aura, FrameTable)
	end
end

local function Pos()
	for key, VALUE in pairs(Aura) do
		local value = AuraList[key]
		local Pre = nil
		for i = 1, #VALUE do
			local Frame = VALUE[i]
			if i == 1 then
				Frame:SetPoint("CENTER", Frame.MoveHandle)
			elseif value.Name == "Target Aura" and i == 7 then
				Frame:SetPoint("BOTTOM", VALUE[1], "TOP", 0, value.Interval)
			else
				if value.Direction:lower() == "right" then
					Frame:SetPoint("LEFT", Pre, "RIGHT", value.Interval, 0)
				elseif value.Direction:lower() == "left" then
					Frame:SetPoint("RIGHT", Pre, "LEFT", -value.Interval, 0)
				elseif value.Direction:lower() == "up" then
					Frame:SetPoint("BOTTOM", Pre, "TOP", 0, value.Interval)
				elseif value.Direction:lower() == "down" then
					Frame:SetPoint("TOP", Pre, "BOTTOM", 0, -value.Interval)
				end
			end
			Pre = Frame
		end
	end
end

local function Init()
	ConvertTable()
	BuildAuraList()
	BuildUnitIDTable()
	BuildAura()
	Pos()
end

local function updateBarTimer(self)
	if self.expires then
		self.Timer = self.expires - GetTime()
	else
		self.Timer = self.start + self.duration - GetTime()
	end

	if self.Timer < 0 then
		if self.Time then self.Time:SetText("N/A") end
		self.Statusbar:SetMinMaxValues(0, 1)
		self.Statusbar:SetValue(0)
		self.Statusbar.Spark:Hide()
	elseif self.Timer < 60 then
		if self.Time then self.Time:SetFormattedText("%.1f", self.Timer) end
		self.Statusbar:SetMinMaxValues(0, self.duration)
		self.Statusbar:SetValue(self.Timer)
		self.Statusbar.Spark:Show()
	else
		if self.Time then self.Time:SetFormattedText("%d:%.2d", self.Timer/60, self.Timer%60) end
		self.Statusbar:SetMinMaxValues(0, self.duration)
		self.Statusbar:SetValue(self.Timer)
		self.Statusbar.Spark:Show()
	end
end

-- UpdateCD
local function UpdateCDFrame(index, name, icon, start, duration, _, type, id, charges)
	local Frame = Aura[index][Aura[index].Index]
	if Frame then Frame:Show() end
	if Frame.Icon then Frame.Icon:SetTexture(icon) end
	if Frame.Cooldown then
		Frame.Cooldown:SetReverse(false)
		Frame.Cooldown:SetCooldown(start, duration)
		Frame.Cooldown:Show()
	end
	if Frame.Count then Frame.Count:SetText(charges) end
	if Frame.Spellname then Frame.Spellname:SetText(name) end
	if Frame.Statusbar then
		Frame.duration = duration
		Frame.start = start
		Frame.Timer = 0
		Frame:SetScript("OnUpdate", updateBarTimer)
	end
	Frame.type = type
	Frame.spellID = id

	Aura[index].Index = (Aura[index].Index + 1 > MaxFrame) and MaxFrame or Aura[index].Index + 1
end

local function UpdateCD()
	for KEY, VALUE in pairs(AuraList) do
		for _, value in pairs(VALUE.List) do
			if value.SpellID then
				local name, _, icon = GetSpellInfo(value.SpellID)
				local start, duration = GetSpellCooldown(value.SpellID)
				local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(value.SpellID)
				if VALUE.Mode:lower() == "icon" then name = nil end
				if charges and maxCharges and maxCharges > 1 and charges < maxCharges then
					UpdateCDFrame(KEY, name, icon, chargeStart, chargeDuration, true, 1, value.SpellID, charges)
				elseif start and duration > 1.5 then
					UpdateCDFrame(KEY, name, icon, start, duration, true, 1, value.SpellID)
				end
			elseif value.ItemID then
				if select(2, GetItemCooldown(value.ItemID)) > 1.5 then
					local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(value.ItemID)
					local start, duration = GetItemCooldown(value.ItemID)
					if VALUE.Mode:lower() == "icon" then name = nil end
					UpdateCDFrame(KEY, name, icon, start, duration, false, 2, value.ItemID)
				end
			elseif value.SlotID then
				local link = GetInventoryItemLink("player", value.SlotID)
				if link then
					local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(link)
					local start, duration = GetInventoryItemCooldown("player", value.SlotID)
					if duration > 1.5 then
						if VALUE.Mode:lower() == "icon" then name = nil end
						UpdateCDFrame(KEY, name, icon, start, duration, false, 3, value.SlotID)
					end
				end
			elseif value.TotemID then
				local haveTotem, name, start, duration, icon = GetTotemInfo(value.TotemID)
				local id = select(7, GetSpellInfo(name))
				if haveTotem then
					if VALUE.Mode:lower() == "icon" then name = nil end
					UpdateCDFrame(KEY, name, icon, start, duration, false, 1, id)
				end
			end
		end
	end
end

-- UpdateAura
local function UpdateAuraFrame(index, UnitID, name, icon, count, duration, expires, id, filter, flash)
	if not index then return end

	local Frame = Aura[index][Aura[index].Index]
	if Frame then Frame:Show() end
	if Frame.Icon then Frame.Icon:SetTexture(icon) end
	if Frame.Count then Frame.Count:SetText(count > 1 and count or nil) end
	if Frame.Cooldown then
		Frame.Cooldown:SetReverse(true)
		Frame.Cooldown:SetCooldown(expires-duration, duration)
	end
	if Frame.Spellname then Frame.Spellname:SetText(name) end
	if Frame.Statusbar then
		Frame.duration = duration
		Frame.expires = expires
		Frame.Timer = 0
		Frame:SetScript("OnUpdate", updateBarTimer)
	end
	if Frame.glowFrame then
		if flash then
			B.ShowOverlayGlow(Frame.glowFrame)
		else
			B.HideOverlayGlow(Frame.glowFrame)
		end
	end
	Frame.type = 4
	Frame.unitID = UnitID
	Frame.id = id
	Frame.filter = filter

	Aura[index].Index = (Aura[index].Index + 1 > MaxFrame) and MaxFrame or Aura[index].Index + 1
end

local function sortStat(a, b)
	return a.num > b.num
end

local function getMaxStat()
	wipe(statTable)
	tinsert(statTable, {num = max(GetCombatRating(CR_CRIT_SPELL), GetCombatRating(CR_CRIT_RANGED), GetCombatRating(CR_CRIT_MELEE)), text = L["Crit"]})
	tinsert(statTable, {num = GetCombatRating(CR_HASTE_MELEE), text = L["Haste"]})
	tinsert(statTable, {num = GetCombatRating(CR_MASTERY), text = L["Mastery"]})
	tinsert(statTable, {num = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE), text = L["Versa"]})
	sort(statTable, sortStat)

	return statTable[1].text
end

local function AuraFilter(spellID, UnitID, index, bool)
	for KEY, VALUE in pairs(AuraList) do
		for _, value in pairs(VALUE.List) do
			if value.AuraID == spellID and value.UnitID == UnitID then
				local filter = bool and "HELPFUL" or "HARMFUL"
				local name, icon, count, _, duration, expires, caster, _, _, _, _, _, _, _, _, number = UnitAura(value.UnitID, index, filter)
				if value.Combat and not InCombatLockdown() then return false end
				if value.Caster and value.Caster:lower() ~= caster then return false end
				if value.Stack and count and value.Stack > count then return false end
				if value.Value and number then
					if VALUE.Mode:lower() == "icon" then
						name = B.Numb(number)
					elseif VALUE.Mode:lower() == "bar" then
						name = name..":"..B.Numb(number)
					end
				else
					if VALUE.Mode:lower() == "icon" then
						name = value.Text or nil
					elseif VALUE.Mode:lower() == "bar" then
						name = name
					end
				end
				if value.Timeless then duration, expires = 0, 0 end
				if spellID == 280573 then name = getMaxStat() end
				return KEY, value.UnitID, name, icon, count, duration, expires, index, filter, value.Flash
			end
		end
	end
	return false
end

local function UpdateAura(UnitID)
	local index = 1
    while true do
		local name, _, _, _, _, _, _, _, _, spellID = UnitBuff(UnitID, index)
		if not name then break end
		UpdateAuraFrame(AuraFilter(spellID, UnitID, index, true))
		index = index + 1
	end

	local index = 1
    while true do
		local name, _, _, _, _, _, _, _, _, spellID = UnitDebuff(UnitID, index)
		if not name then break end
		UpdateAuraFrame(AuraFilter(spellID, UnitID, index, false))
		index = index + 1
	end
end

-- Update InternalCD
local function SortBars()
	if not IntCD.MoveHandle then
		IntCD.MoveHandle = MakeMoveHandle(IntTable[1], L[IntCD.Name], "InternalCD", IntCD.Pos)
	end
	for i = 1, #IntTable do
		IntTable[i]:ClearAllPoints()
		if i == 1 then
			IntTable[i]:SetPoint("CENTER", IntCD.MoveHandle)
		elseif IntCD.Direction:lower() == "right" then
			IntTable[i]:SetPoint("LEFT", IntTable[i-1], "RIGHT", IntCD.Interval, 0)
		elseif IntCD.Direction:lower() == "left" then
			IntTable[i]:SetPoint("RIGHT", IntTable[i-1], "LEFT", -IntCD.Interval, 0)
		elseif IntCD.Direction:lower() == "up" then
			IntTable[i]:SetPoint("BOTTOM", IntTable[i-1], "TOP", 0, IntCD.Interval)
		elseif IntCD.Direction:lower() == "down" then
			IntTable[i]:SetPoint("TOP", IntTable[i-1], "BOTTOM", 0, -IntCD.Interval)
		end
		IntTable[i].ID = i
	end
end

local function updateIntTimer(self, elapsed)
	self.Timer = self.Timer + elapsed
	local timer = self.duration - self.Timer
	if timer < 0 then
		self:SetScript("OnUpdate", nil)
		self:Hide()
		tremove(IntTable, self.ID)
		SortBars()
	elseif timer < 60 then
		if self.Time then self.Time:SetFormattedText("%.1f", timer) end
		self.Statusbar:SetValue(timer)
		self.Statusbar.Spark:Show()
	else
		if self.Time then self.Time:SetFormattedText("%d:%.2d", timer/60, timer%60) end
		self.Statusbar:SetValue(timer)
		self.Statusbar.Spark:Show()
	end
end

local function UpdateIntFrame(intID, itemID, duration, unitID, guid, sourceName)
	if not UIParent:IsShown() then return end

	local Frame = BuildBAR(IntCD.BarWidth, IntCD.IconSize)
	if Frame then
		Frame:Show()
		tinsert(IntTable, Frame)
		SortBars()
	end
	local name, icon, _, class
	if itemID then
		name, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
		Frame.type = 2
		Frame.spellID = itemID
	else
		name, _, icon = GetSpellInfo(intID)
		Frame.type = 1
		Frame.spellID = intID
	end
	if unitID:lower() == "all" then
		class = select(2, GetPlayerInfoByGUID(guid))
		name = "*"..sourceName
	else
		class = DB.MyClass
	end
	if Frame.Icon then Frame.Icon:SetTexture(icon) end
	if Frame.Count then Frame.Count:SetText(nil) end
	if Frame.Cooldown then
		Frame.Cooldown:SetReverse(true)
		Frame.Cooldown:SetCooldown(GetTime(), duration)
	end
	if Frame.Spellname then Frame.Spellname:SetText(name) end
	if Frame.Statusbar then
		Frame.Statusbar:SetStatusBarColor(B.ClassColor(class))
		Frame.Statusbar:SetMinMaxValues(0, duration)
		Frame.Timer = 0
		Frame.duration = duration
		Frame:SetScript("OnUpdate", updateIntTimer)
	end
end

local eventList = {
	["SPELL_AURA_APPLIED"] = true,
	["SPELL_AURA_REFRESH"] = true,
}

local function checkPetFlags(sourceFlags, all)
	if sourceFlags == DB.MyPetFlags or (all and (sourceFlags == DB.PartyPetFlags or sourceFlags == DB.RaidPetFlags)) then
		return true
	end
end

local function isUnitWeNeed(value, name, flags)
	if not value.UnitID then value.UnitID = "Player" end
	if value.UnitID:lower() == "all" then
		if name and (UnitInRaid(name) or UnitInParty(name) or checkPetFlags(flags, true)) then
			return true
		end
	elseif value.UnitID:lower() == "player" then
		if name and name == DB.MyName or checkPetFlags(flags) then
			return true
		end
	end
end

local function isAuraTracking(value, eventType, sourceName, sourceFlags, destName, destFlags)
	if value.OnSuccess and eventType == "SPELL_CAST_SUCCESS" and isUnitWeNeed(value, sourceName, sourceFlags) then
		return true
	elseif not value.OnSuccess and eventList[eventType] and isUnitWeNeed(value, destName, destFlags) then
		return true
	end
end

local cache = {}
local function UpdateInt(_, ...)
	if not IntCD.List then return end
	for _, value in pairs(IntCD.List) do
		if value.IntID then
			local timestamp, eventType, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellID = ...
			if value.IntID == spellID and cache[timestamp] ~= spellID and isAuraTracking(value, eventType, sourceName, sourceFlags, destName, destFlags) then

				local guid, name = destGUID, destName
				if value.OnSuccess then guid, name = sourceGUID, sourceName end
				UpdateIntFrame(value.IntID, value.ItemID, value.Duration, value.UnitID, guid, name)

				cache[timestamp] = spellID
			end
		end
	end
	if #cache > 666 then wipe(cache) end
end

-- CleanUp
local function CleanUp()
	for _, value in pairs(Aura) do
		for i = 1, MaxFrame do
			if value[i] then
				value[i]:Hide()
				value[i]:SetScript("OnUpdate", nil)
			end
			if value[i].Icon then value[i].Icon:SetTexture(nil) end
			if value[i].Count then value[i].Count:SetText(nil) end
			if value[i].Spellname then value[i].Spellname:SetText(nil) end
		end
		value.Index = 1
	end
end

-- Event
local function onEvent(event, ...)
	if not NDuiDB["AuraWatch"]["Enable"] then return end
	if event == "PLAYER_ENTERING_WORLD" then
		Init()
		if not IntCD.MoveHandle then UpdateIntFrame(2825, nil, 0, "player") end
		B:UnregisterEvent(event, onEvent)
	else
		UpdateInt(event, ...)
	end
end
B:RegisterEvent("PLAYER_ENTERING_WORLD", onEvent)
B:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", onEvent)

local function onUpdate(self, elapsed)
	self.Timer = (self.Timer or 0) + elapsed
	if self.Timer > .1 then
		self.Timer = 0
		CleanUp()
		UpdateCD()
		for _, value in pairs(UnitIDTable) do
			UpdateAura(value)
		end
	end
end
local f = CreateFrame("Frame")
f:SetScript("OnUpdate", onUpdate)

-- Mover
StaticPopupDialogs["RESET_AURAWATCH_MOVER"] = {
	text = L["Reset AuraWatch Mover Confirm"],
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		wipe(NDuiDB["AuraWatchMover"])
		ReloadUI()
	end,
}

local texture = GetSpellTexture(2825)
SlashCmdList.AuraWatch = function(msg)
	if msg:lower() == "move" then
		f:SetScript("OnUpdate", nil)
		for _, value in pairs(Aura) do
			for i = 1, 6 do
				if value[i] then
					value[i]:SetScript("OnUpdate", nil)
					value[i]:Show()
				end
				if value[i].Icon then value[i].Icon:SetTexture(texture) end
				if value[i].Count then value[i].Count:SetText("") end
				if value[i].Time then value[i].Time:SetText("59") end
				if value[i].Statusbar then value[i].Statusbar:SetValue(1) end
				if value[i].Spellname then value[i].Spellname:SetText("") end
				if value[i].glowFrame then B.HideOverlayGlow(value[i].glowFrame) end
			end
			value[1].MoveHandle:Show()
		end
		if IntCD.MoveHandle then
			IntCD.MoveHandle:Show()
			for i = 1, #IntTable do
				if IntTable[i] then IntTable[i]:Hide() end
			end
			wipe(IntTable)
			UpdateIntFrame(2825, nil, 0, "player")
			UpdateIntFrame(2825, nil, 0, "player")
			UpdateIntFrame(2825, nil, 0, "player")
			UpdateIntFrame(2825, nil, 0, "player")
			UpdateIntFrame(2825, nil, 0, "player")
			UpdateIntFrame(2825, nil, 0, "player")
			for i = 1, #IntTable do
				IntTable[i]:SetScript("OnUpdate", nil)
				IntTable[i]:Show()
				IntTable[i].Spellname:SetText("")
				IntTable[i].Time:SetText("59")
				IntTable[i].Statusbar:SetMinMaxValues(0, 1)
				IntTable[i].Statusbar:SetValue(1)
			end
		end
	elseif msg:lower() == "lock" then
		CleanUp()
		for _, value in pairs(Aura) do
			value[1].MoveHandle:Hide()
		end
		f:SetScript("OnUpdate", onUpdate)
		if IntCD.MoveHandle then
			IntCD.MoveHandle:Hide()
			for i = 1, #IntTable do
				if IntTable[i] then IntTable[i]:Hide() end
			end
			wipe(IntTable)
		end
	end
end