local _, ns = ...
local B, C, L, DB = unpack(ns)
local A = B:GetModule("Auras")

local maxFrames = 12 -- Max Tracked Auras
local hasCentralize
local updater = CreateFrame("Frame")
local AuraList, FrameList, UnitIDTable, IntTable, IntCD, myTable, cooldownTable = {}, {}, {}, {}, {}, {}, {}
local pairs, select, tinsert, tremove, wipe, strfind = pairs, select, table.insert, table.remove, table.wipe, strfind
local InCombatLockdown, UnitAura, GetPlayerInfoByGUID, UnitInRaid, UnitInParty = InCombatLockdown, UnitAura, GetPlayerInfoByGUID, UnitInRaid, UnitInParty
local GetTime, GetSpellInfo, GetSpellCooldown, GetSpellCharges, GetTotemInfo, IsPlayerSpell = GetTime, GetSpellInfo, GetSpellCooldown, GetSpellCharges, GetTotemInfo, IsPlayerSpell
local GetItemCooldown, GetItemInfo, GetInventoryItemLink, GetInventoryItemCooldown = GetItemCooldown, GetItemInfo, GetInventoryItemLink, GetInventoryItemCooldown

-- DataConvert
local function DataAnalyze(v)
	local newTable = {}
	if type(v[1]) == "number" then
		newTable.IntID = v[1]
		newTable.Duration = v[2]
		if v[3] == "OnCastSuccess" then
			newTable.OnSuccess = true
		elseif v[3] == "UnitCastSucceed" then
			newTable.CastSucceed = true
		end
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

local function InsertData(index, target)
	if C.db["AuraWatchList"]["Switcher"][index] then
		wipe(target)
	end

	for spellID, v in pairs(myTable[index]) do
		local value = target[spellID]
		if value and value.AuraID == v.AuraID then
			value = nil
		end
		target[spellID] = v
	end
end

local function ConvertTable()
	for i = 1, 10 do
		myTable[i] = {}
		if i < 10 then
			local value = C.db["AuraWatchList"][i]
			if value and next(value) then
				for spellID, v in pairs(value) do
					myTable[i][spellID] = DataAnalyze(v)
				end
			end
		else
			if next(C.db["InternalCD"]) then
				for spellID, v in pairs(C.db["InternalCD"]) do
					myTable[i][spellID] = DataAnalyze(v)
				end
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
			local flag = true
			for _, v in pairs(UnitIDTable) do
				if value.UnitID == v then flag = false end
			end
			if flag then tinsert(UnitIDTable, value.UnitID) end
		end
	end
end

local function BuildCooldownTable()
	wipe(cooldownTable)

	for KEY, VALUE in pairs(AuraList) do
		for spellID, value in pairs(VALUE.List) do
			if value.SpellID and IsPlayerSpell(value.SpellID) or value.ItemID or value.SlotID or value.TotemID then
				if not cooldownTable[KEY] then cooldownTable[KEY] = {} end
				cooldownTable[KEY][spellID] = true
			end
		end
	end
end

local function MakeMoveHandle(frame, text, value, anchor)
	local mover = B.Mover(frame, DB.InfoColor..text, value, anchor, nil, nil, true)
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", mover)
	frame.__width = mover:GetWidth()

	return mover
end

-- Aurawatch style
local PetBattleFrameHider = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
PetBattleFrameHider:SetAllPoints()
PetBattleFrameHider:SetFrameStrata("LOW")
RegisterStateDriver(PetBattleFrameHider, "visibility", "[petbattle] hide; show")
A.PetBattleFrameHider = PetBattleFrameHider

local function tooltipOnEnter(self)
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 3)
	if self.type == 1 then
		GameTooltip:SetSpellByID(self.spellID)
	elseif self.type == 2 then
		GameTooltip:SetHyperlink(select(2, GetItemInfo(self.spellID)))
	elseif self.type == 3 then
		GameTooltip:SetInventoryItem("player", self.spellID)
	elseif self.type == 4 then
		GameTooltip:SetUnitAura(self.unit, self.index, self.filter)
	elseif self.type == 5 then
		GameTooltip:SetTotem(self.spellID)
	end
	GameTooltip:Show()
end

function A:RemoveSpellFromAuraList()
	if IsAltKeyDown() and IsControlKeyDown() and self.type == 4 and self.spellID then
		C.db["AuraWatchList"]["IgnoreSpells"][self.spellID] = true
		print(format(L["AddToIgnoreList"], DB.NDuiString, self.spellID))
	end
end

local function enableTooltip(self)
	self:EnableMouse(true)
	self.HL = self:CreateTexture(nil, "HIGHLIGHT")
	self.HL:SetColorTexture(1, 1, 1, .25)
	self.HL:SetAllPoints(self.Icon)
	self:SetScript("OnEnter", tooltipOnEnter)
	self:SetScript("OnLeave", B.HideTooltip)
	self:SetScript("OnMouseDown", A.RemoveSpellFromAuraList)
end

-- Icon mode
local function BuildICON(iconSize)
	iconSize = iconSize * C.db["AuraWatch"]["IconScale"]

	local frame = CreateFrame("Frame", nil, PetBattleFrameHider)
	frame:SetSize(iconSize, iconSize)
	frame.bg = B.SetBD(frame)

	frame.Icon = frame:CreateTexture(nil, "ARTWORK")
	frame.Icon:SetInside(frame.bg)
	frame.Icon:SetTexCoord(unpack(DB.TexCoord))

	frame.Cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
	frame.Cooldown:SetInside(frame.bg)
	frame.Cooldown:SetReverse(true)

	local parentFrame = CreateFrame("Frame", nil, frame)
	parentFrame:SetAllPoints()
	parentFrame:SetFrameLevel(frame:GetFrameLevel() + 6)

	frame.Spellname = B.CreateFS(parentFrame, 13, "", false, "TOP", 0, 5)
	frame.Count = B.CreateFS(parentFrame, iconSize*.55, "", false, "BOTTOMRIGHT", 6, -3)

	frame.glowFrame = B.CreateGlowFrame(frame, iconSize)

	if not C.db["AuraWatch"]["ClickThrough"] then enableTooltip(frame) end

	frame:Hide()
	return frame
end

-- Bar mode
local function BuildBAR(barWidth, iconSize)
	local frame = CreateFrame("Frame", nil, PetBattleFrameHider)
	frame:SetSize(iconSize, iconSize)
	B.SetBD(frame)

	frame.Icon = frame:CreateTexture(nil, "ARTWORK")
	frame.Icon:SetAllPoints()
	frame.Icon:SetTexCoord(unpack(DB.TexCoord))

	frame.Statusbar = CreateFrame("StatusBar", nil, frame)
	frame.Statusbar:SetSize(barWidth, iconSize/2.5)
	frame.Statusbar:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 5, 0)
	frame.Statusbar:SetMinMaxValues(0, 1)
	frame.Statusbar:SetValue(0)
	B.CreateSB(frame.Statusbar, true)

	frame.Count = B.CreateFS(frame, 14, "", false, "BOTTOMRIGHT", 3, -1)
	frame.Time = B.CreateFS(frame.Statusbar, 14, "", false, "RIGHT", 0, 8)
	frame.Spellname = B.CreateFS(frame.Statusbar, 14, "", false, "LEFT", 2, 8)
	frame.Spellname:SetWidth(frame.Statusbar:GetWidth()*.6)
	frame.Spellname:SetJustifyH("LEFT")
	if not C.db["AuraWatch"]["ClickThrough"] then enableTooltip(frame) end

	frame:Hide()
	return frame
end

-- List and anchor
local function BuildAura()
	for key, value in pairs(AuraList) do
		local frameTable = {}
		for i = 1, maxFrames do
			if value.Mode == "ICON" then
				local frame = BuildICON(value.IconSize)
				if i == 1 then frame.MoveHandle = MakeMoveHandle(frame, L[value.Name], key, value.Pos) end
				tinsert(frameTable, frame)
			elseif value.Mode == "BAR" then
				local frame = BuildBAR(value.BarWidth, value.IconSize)
				if i == 1 then frame.MoveHandle = MakeMoveHandle(frame, L[value.Name], key, value.Pos) end
				tinsert(frameTable, frame)
			end
		end
		frameTable.Index = 1
		tinsert(FrameList, frameTable)
	end
end

local function SetupAnchor()
	for key, VALUE in pairs(FrameList) do
		local value = AuraList[key]
		local direction, interval = value.Direction, value.Interval
		-- check whether using CENTER direction
		if value.Mode == "BAR" and direction == "CENTER" then
			direction = "UP" -- sorry, no "CENTER" for bars mode
		end
		if not hasCentralize then
			hasCentralize = direction == "CENTER"
		end

		local previous
		for i = 1, #VALUE do
			local frame = VALUE[i]
			if i == 1 then
				frame:SetPoint("CENTER", frame.MoveHandle)
				frame.__direction = direction
				frame.__interval = interval
			elseif (value.Name == "Target Aura" or value.Name == "Enchant Aura") and i == 7 and direction ~= "CENTER" then
				frame:SetPoint("BOTTOM", VALUE[1], "TOP", 0, interval)
			else
				if direction == "RIGHT" or direction == "CENTER" then
					frame:SetPoint("LEFT", previous, "RIGHT", interval, 0)
				elseif direction == "LEFT" then
					frame:SetPoint("RIGHT", previous, "LEFT", -interval, 0)
				elseif direction == "UP" then
					frame:SetPoint("BOTTOM", previous, "TOP", 0, interval)
				elseif direction == "DOWN" then
					frame:SetPoint("TOP", previous, "BOTTOM", 0, -interval)
				end
			end
			previous = frame
		end
	end
end

local function InitSetup()
	ConvertTable()
	BuildAuraList()
	BuildUnitIDTable()
	BuildCooldownTable()
	B:RegisterEvent("PLAYER_TALENT_UPDATE", BuildCooldownTable)
	BuildAura()
	SetupAnchor()
end

-- Update timer
function A:AuraWatch_UpdateTimer()
	if self.expires then
		self.elapsed = self.expires - GetTime()
	else
		self.elapsed = self.start + self.duration - GetTime()
	end

	local timer = self.elapsed
	if timer < 0 then
		if self.Time then self.Time:SetText("N/A") end
		self.Statusbar:SetMinMaxValues(0, 1)
		self.Statusbar:SetValue(0)
		self.Statusbar.Spark:Hide()
	elseif timer < 60 then
		if self.Time then self.Time:SetFormattedText("%.1f", timer) end
		self.Statusbar:SetMinMaxValues(0, self.duration)
		self.Statusbar:SetValue(timer)
		self.Statusbar.Spark:Show()
	else
		if self.Time then self.Time:SetFormattedText("%d:%.2d", timer/60, timer%60) end
		self.Statusbar:SetMinMaxValues(0, self.duration)
		self.Statusbar:SetValue(timer)
		self.Statusbar.Spark:Show()
	end
end

-- Update cooldown
function A:AuraWatch_SetupCD(index, name, icon, start, duration, _, type, id, charges)
	local frames = FrameList[index]
	local frame = frames[frames.Index]
	if frame then frame:Show() end
	if frame.Icon then frame.Icon:SetTexture(icon) end
	if frame.Cooldown then
		frame.Cooldown:SetReverse(false)
		frame.Cooldown:SetCooldown(start, duration)
		frame.Cooldown:Show()
	end
	if frame.Count then frame.Count:SetText(charges) end
	if frame.Spellname then frame.Spellname:SetText(name) end
	if frame.Statusbar then
		frame.duration = duration
		frame.start = start
		frame.elapsed = 0
		frame:SetScript("OnUpdate", A.AuraWatch_UpdateTimer)
	end
	frame.type = type
	frame.spellID = id

	frames.Index = (frames.Index + 1 > maxFrames) and maxFrames or frames.Index + 1
end

A.IgnoredItems = {
	[193757] = true, -- 红玉雏龙蛋壳
}

function A:AuraWatch_UpdateCD()
	for KEY, VALUE in pairs(cooldownTable) do
		for spellID in pairs(VALUE) do
			local group = AuraList[KEY]
			local value = group.List[spellID]
			if value then
				if value.SpellID then
					local name, _, icon = GetSpellInfo(value.SpellID)
					local start, duration = GetSpellCooldown(value.SpellID)
					local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(value.SpellID)
					if group.Mode == "ICON" then name = nil end
					if charges and maxCharges and maxCharges > 1 and charges < maxCharges then
						A:AuraWatch_SetupCD(KEY, name, icon, chargeStart, chargeDuration, true, 1, value.SpellID, charges)
					elseif start and duration > 3 then
						A:AuraWatch_SetupCD(KEY, name, icon, start, duration, true, 1, value.SpellID)
					end
				elseif value.ItemID then
					local start, duration = GetItemCooldown(value.ItemID)
					if start and duration > 3 then
						local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(value.ItemID)
						if group.Mode == "ICON" then name = nil end
						A:AuraWatch_SetupCD(KEY, name, icon, start, duration, false, 2, value.ItemID)
					end
				elseif value.SlotID then
					local link = GetInventoryItemLink("player", value.SlotID)
					if link then
						local itemID = GetItemInfoFromHyperlink(link)
						if not A.IgnoredItems[itemID] then
							local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(link)
							local start, duration = GetInventoryItemCooldown("player", value.SlotID)
							if duration > 1.5 then
								if group.Mode == "ICON" then name = nil end
								A:AuraWatch_SetupCD(KEY, name, icon, start, duration, false, 3, value.SlotID)
							end
						end
					end
				elseif value.TotemID then
					local haveTotem, name, start, duration, icon = GetTotemInfo(value.TotemID)
					if haveTotem then
						if group.Mode == "ICON" then name = nil end
						A:AuraWatch_SetupCD(KEY, name, icon, start, duration, false, 5, value.TotemID)
					end
				end
			end
		end
	end
end

-- UpdateAura
local replacedTexture = {
	[336892] = 135130, -- 无懈警戒换成瞄准射击图标
	[378770] = 236174, -- 夺命打击换成夺命射击图标
	[389020] = 132330, -- 子弹风暴换成多重射击
	[378747] = 132176, -- 凶暴兽群换成杀戮命令
}
function A:AuraWatch_SetupAura(KEY, unit, index, filter, name, icon, count, duration, expires, spellID, flash)
	if not KEY then return end

	local frames = FrameList[KEY]
	local frame = frames[frames.Index]
	if frame then frame:Show() end
	if frame.Icon then
		frame.Icon:SetTexture(replacedTexture[spellID] or icon)
	end
	if frame.Count then frame.Count:SetText(count > 1 and count or "") end
	if frame.Cooldown then
		frame.Cooldown:SetReverse(true)
		frame.Cooldown:SetCooldown(expires-duration, duration)
	end
	if frame.Spellname then frame.Spellname:SetText(name) end
	if frame.Statusbar then
		frame.duration = duration
		frame.expires = expires
		frame.elapsed = 0
		frame:SetScript("OnUpdate", A.AuraWatch_UpdateTimer)
	end
	if frame.glowFrame then
		if flash then
			B.ShowOverlayGlow(frame.glowFrame)
		else
			B.HideOverlayGlow(frame.glowFrame)
		end
	end
	frame.type = 4
	frame.unit = unit
	frame.index = index
	frame.filter = filter
	frame.spellID = spellID

	frames.Index = (frames.Index + 1 > maxFrames) and maxFrames or frames.Index + 1
end

function A:AuraWatch_UpdateAura(unit, index, filter, name, icon, count, duration, expires, caster, spellID, number, inCombat)
	if C.db["AuraWatchList"]["IgnoreSpells"][spellID] then return end -- ignore spells

	for KEY, VALUE in pairs(AuraList) do
		local value = VALUE.List[spellID]
		if value and value.AuraID and value.UnitID == unit then
			if value.Combat and not inCombat then return end
			if value.Caster and value.Caster ~= caster then return end
			if value.Stack and count and value.Stack > count then return end
			if value.Value and number then
				if VALUE.Mode == "ICON" then
					name = B.Numb(number)
				elseif VALUE.Mode == "BAR" then
					name = name..":"..B.Numb(number)
				end
			else
				if VALUE.Mode == "ICON" then
					name = value.Text or nil
				elseif VALUE.Mode == "BAR" then
					name = name
				end
			end
			if value.Timeless then duration, expires = 0, 0 end

			A:AuraWatch_SetupAura(KEY, unit, index, filter, name, icon, count, duration, expires, spellID, value.Flash)
			return
		end
	end
end

function A:UpdateAuraWatchByFilter(unit, filter, inCombat)
	local index = 1

	while true do
		local name, icon, count, _, duration, expires, caster, _, _, spellID, _, _, _, _, _, number1, number2 = UnitAura(unit, index, filter)
		if not name then break end
		A:AuraWatch_UpdateAura(unit, index, filter, name, icon, count, duration, expires, caster, spellID, (number1 == 0 and tonumber(number2) or tonumber(number1)), inCombat)

		index = index + 1
	end
end

function A:UpdateAuraWatch(unit, inCombat)
	A:UpdateAuraWatchByFilter(unit, "HELPFUL", inCombat)
	A:UpdateAuraWatchByFilter(unit, "HARMFUL", inCombat)
end

-- Update InternalCD
function A:AuraWatch_SortBars()
	if not IntCD.MoveHandle then
		IntCD.MoveHandle = MakeMoveHandle(IntTable[1], L[IntCD.Name], "InternalCD", IntCD.Pos)
	end

	for i = 1, #IntTable do
		IntTable[i]:ClearAllPoints()
		if i == 1 then
			IntTable[i]:SetPoint("CENTER", IntCD.MoveHandle)
		elseif IntCD.Direction == "RIGHT" then
			IntTable[i]:SetPoint("LEFT", IntTable[i-1], "RIGHT", IntCD.Interval, 0)
		elseif IntCD.Direction == "LEFT" then
			IntTable[i]:SetPoint("RIGHT", IntTable[i-1], "LEFT", -IntCD.Interval, 0)
		elseif IntCD.Direction == "UP" then
			IntTable[i]:SetPoint("BOTTOM", IntTable[i-1], "TOP", 0, IntCD.Interval)
		elseif IntCD.Direction == "DOWN" then
			IntTable[i]:SetPoint("TOP", IntTable[i-1], "BOTTOM", 0, -IntCD.Interval)
		end
		IntTable[i].ID = i
	end
end

function A:AuraWatch_IntTimer(elapsed)
	self.elapsed = self.elapsed + elapsed
	local timer = self.duration - self.elapsed
	if timer < 0 then
		self:SetScript("OnUpdate", nil)
		self:Hide()
		tremove(IntTable, self.ID)
		A:AuraWatch_SortBars()
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

function A:AuraWatch_SetupInt(intID, itemID, duration, unitID, guid, sourceName)
	if not PetBattleFrameHider:IsShown() then return end

	local frame = BuildBAR(IntCD.BarWidth, IntCD.IconSize)
	if frame then
		frame:Show()
		tinsert(IntTable, frame)
		A:AuraWatch_SortBars()
	end
	local name, icon, _, class
	if itemID then
		name, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
		frame.type = 2
		frame.spellID = itemID
	else
		name, _, icon = GetSpellInfo(intID)
		frame.type = 1
		frame.spellID = intID
	end
	if unitID:lower() == "all" then
		class = select(2, GetPlayerInfoByGUID(guid))
		name = "*"..sourceName
	else
		class = DB.MyClass
	end
	if frame.Icon then frame.Icon:SetTexture(icon) end
	if frame.Count then frame.Count:SetText("") end
	if frame.Cooldown then
		frame.Cooldown:SetReverse(true)
		frame.Cooldown:SetCooldown(GetTime(), duration)
	end
	if frame.Spellname then frame.Spellname:SetText(name) end
	if frame.Statusbar then
		frame.Statusbar:SetStatusBarColor(B.ClassColor(class))
		frame.Statusbar:SetMinMaxValues(0, duration)
		frame.elapsed = 0
		frame.duration = duration
		frame:SetScript("OnUpdate", A.AuraWatch_IntTimer)
	end
end

local eventList = {
	["SPELL_AURA_APPLIED"] = true,
	["SPELL_AURA_REFRESH"] = true,
}

local function checkPetFlags(sourceFlags, all)
	if DB:IsMyPet(sourceFlags) or (all and (sourceFlags == DB.PartyPetFlags or sourceFlags == DB.RaidPetFlags)) then
		return true
	end
end

function A:IsUnitWeNeed(value, guid, name, flags)
	if not value.UnitID then value.UnitID = "Player" end
	if value.UnitID:lower() == "all" then
		if name and (UnitInRaid(name) or UnitInParty(name) or checkPetFlags(flags, true) or not GetPlayerInfoByGUID(guid)) then
			return true
		end
	elseif value.UnitID:lower() == "player" then
		if name and name == DB.MyName or checkPetFlags(flags) then
			return true
		end
	end
end

function A:IsAuraTracking(value, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags)
	if value.OnSuccess and eventType == "SPELL_CAST_SUCCESS" and A:IsUnitWeNeed(value, sourceGUID, sourceName, sourceFlags) then
		return true
	elseif not value.OnSuccess and eventList[eventType] and A:IsUnitWeNeed(value, destGUID, destName, destFlags) then
		return true
	end
end

local cache = {}
local soundKitID = SOUNDKIT.ALARM_CLOCK_WARNING_3

local playSoundSpells = {
	[396364] = true,
	[396369] = true,
	[240447] = true,
}

function A:AuraWatch_UpdateInt(event, ...)
	if not IntCD.List then return end

	if event == "UNIT_SPELLCAST_SUCCEEDED" then
		local unit, _, spellID = ...
		local value = IntCD.List[spellID]
		if value and value.CastSucceed and unit then
			local unitID = value.UnitID:lower()
			local guid = UnitGUID(unit)
			local isPassed
			if unitID == "all" and (unit == "player" or strfind(unit, "pet") or UnitInRaid(unit) or UnitInParty(unit) or not GetPlayerInfoByGUID(guid)) then
				isPassed = true
			elseif unitID == "player" and (unit == "player" or unit == "pet") then
				isPassed = true
			end
			if isPassed then
				A:AuraWatch_SetupInt(value.IntID, value.ItemID, value.Duration, value.UnitID, guid, UnitName(unit))
			end
		end
	else
		local timestamp, eventType, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellID = ...
		local value = IntCD.List[spellID]
		if value and cache[timestamp] ~= spellID and A:IsAuraTracking(value, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags) then
			local guid, name = destGUID, destName
			if value.OnSuccess then guid, name = sourceGUID, sourceName end

			A:AuraWatch_SetupInt(value.IntID, value.ItemID, value.Duration, value.UnitID, guid, name)

			cache[timestamp] = spellID
		end
		if C.db["AuraWatch"]["QuakeRing"] and eventList[eventType] and playSoundSpells[spellID] then PlaySound(soundKitID, "Master") end -- 'Ding' on quake

		if #cache > 666 then wipe(cache) end
	end
end

-- CleanUp
function A:AuraWatch_Cleanup()	-- FIXME: there should be a better way to do this
	for _, value in pairs(FrameList) do
		for i = 1, maxFrames do
			local frame = value[i]
			if not frame:IsShown() then break end
			if frame then
				frame:Hide()
				frame:SetScript("OnUpdate", nil)
			end
			if frame.Icon then frame.Icon:SetTexture(nil) end
			if frame.Count then frame.Count:SetText("") end
			if frame.Spellname then frame.Spellname:SetText("") end
		end
		value.Index = 1
	end
end

function A:AuraWatch_PreCleanup()
	for _, value in pairs(FrameList) do
		value.Index = 1
	end
end

function A:AuraWatch_PostCleanup()
	for _, value in pairs(FrameList) do
		local currentIndex = value.Index == maxFrames and maxFrames + 1 or value.Index
		for i = currentIndex, maxFrames do
			local frame = value[i]
			if not frame:IsShown() then break end
			if frame then
				frame:Hide()
				frame:SetScript("OnUpdate", nil)
			end
			if frame.Icon then frame.Icon:SetTexture(nil) end
			if frame.Count then frame.Count:SetText("") end
			if frame.Spellname then frame.Spellname:SetText("") end
			if frame.glowFrame then B.HideOverlayGlow(frame.glowFrame) end
		end
	end
end

-- Event
function A.AuraWatch_OnEvent(event, ...)
	if not C.db["AuraWatch"]["Enable"] then
		B:UnregisterEvent("PLAYER_ENTERING_WORLD", A.AuraWatch_OnEvent)
		B:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", A.AuraWatch_OnEvent)
		B:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", A.AuraWatch_OnEvent)
		return
	end

	if event == "PLAYER_ENTERING_WORLD" then
		InitSetup()
		if not IntCD.MoveHandle then A:AuraWatch_SetupInt(2825, nil, 0, "player") end
		B:UnregisterEvent(event, A.AuraWatch_OnEvent)
	else
		A:AuraWatch_UpdateInt(event, ...)
	end
end
B:RegisterEvent("PLAYER_ENTERING_WORLD", A.AuraWatch_OnEvent)
B:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", A.AuraWatch_OnEvent)
B:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", A.AuraWatch_OnEvent)

function A:AuraWatch_Centralize(force)
	if not hasCentralize then return end

	for i = 1, #FrameList do
		local frames = FrameList[i]
		local frame1 = frames and frames[1]
		if frame1.__direction == "CENTER" and frame1:IsShown() then
			local numIndex = force and 7 or frames.Index
			local width = frame1.__width
			local interval = frame1.__interval
			frame1:ClearAllPoints()
			frame1:SetPoint("CENTER", frame1.MoveHandle, "CENTER",  - (width+interval)/2 * (numIndex-2), 0)
		end
	end
end

function A:AuraWatch_OnUpdate(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > .1 then
		self.elapsed = 0

		A:AuraWatch_PreCleanup()
		A:AuraWatch_UpdateCD()

		local inCombat = InCombatLockdown()
		for _, value in pairs(UnitIDTable) do
			A:UpdateAuraWatch(value, inCombat)
		end

		A:AuraWatch_PostCleanup()
		A:AuraWatch_Centralize()
	end
end
updater:SetScript("OnUpdate", A.AuraWatch_OnUpdate)

-- Mover
SlashCmdList.AuraWatch = function(msg)
	if msg:lower() == "move" then
		updater:SetScript("OnUpdate", nil)
		for _, value in pairs(FrameList) do
			for i = 1, 6 do
				if value[i] then
					value[i]:SetScript("OnUpdate", nil)
					value[i]:Show()
				end
				if value[i].Icon then value[i].Icon:SetColorTexture(0, 0, 0, .25) end
				if value[i].Count then value[i].Count:SetText("") end
				if value[i].Time then value[i].Time:SetText("59") end
				if value[i].Statusbar then value[i].Statusbar:SetValue(1) end
				if value[i].Spellname then value[i].Spellname:SetText("") end
				if value[i].glowFrame then B.HideOverlayGlow(value[i].glowFrame) end
			end
			A:AuraWatch_Centralize(true)
			value[1].MoveHandle:Show()
		end

		if IntCD.MoveHandle then
			IntCD.MoveHandle:Show()
			for i = 1, #IntTable do
				if IntTable[i] then IntTable[i]:Hide() end
			end
			wipe(IntTable)

			A:AuraWatch_SetupInt(2825, nil, 0, "player")
			A:AuraWatch_SetupInt(2825, nil, 0, "player")
			A:AuraWatch_SetupInt(2825, nil, 0, "player")
			A:AuraWatch_SetupInt(2825, nil, 0, "player")
			A:AuraWatch_SetupInt(2825, nil, 0, "player")
			A:AuraWatch_SetupInt(2825, nil, 0, "player")

			for i = 1, #IntTable do
				IntTable[i]:SetScript("OnUpdate", nil)
				IntTable[i]:Show()
				IntTable[i].Spellname:SetText("")
				IntTable[i].Time:SetText("59")
				IntTable[i].Statusbar:SetMinMaxValues(0, 1)
				IntTable[i].Statusbar:SetValue(1)
				IntTable[i].Icon:SetColorTexture(0, 0, 0, .25)
			end
		end
	elseif msg:lower() == "lock" then
		A:AuraWatch_Cleanup()
		for _, value in pairs(FrameList) do
			value[1].MoveHandle:Hide()
		end
		updater:SetScript("OnUpdate", A.AuraWatch_OnUpdate)

		if IntCD.MoveHandle then
			IntCD.MoveHandle:Hide()
			for i = 1, #IntTable do
				if IntTable[i] then IntTable[i]:Hide() end
			end
			wipe(IntTable)
		end
	end
end