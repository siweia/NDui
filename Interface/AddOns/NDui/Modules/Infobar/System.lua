local _, ns = ...
local B, C, L, DB = unpack(ns)
if not C.Infobar.System then return end

local module = B:GetModule("Infobar")
local info = module:RegisterInfobar("System", C.Infobar.SystemPos)

local format, floor, wipe, select, sort, min, max = format, floor, wipe, select, sort, min, max
local GetFramerate, GetTime = GetFramerate, GetTime
local GetNumAddOns, GetAddOnInfo, GetCVarBool, SetCVar = GetNumAddOns, GetAddOnInfo, GetCVarBool, SetCVar
local UpdateAddOnCPUUsage, GetAddOnCPUUsage = UpdateAddOnCPUUsage, GetAddOnCPUUsage
local UpdateAddOnMemoryUsage, GetAddOnMemoryUsage = UpdateAddOnMemoryUsage, GetAddOnMemoryUsage
local IsShiftKeyDown, IsAddOnLoaded = IsShiftKeyDown, IsAddOnLoaded
local ResetCPUUsage, collectgarbage, gcinfo = ResetCPUUsage, collectgarbage, gcinfo
local VIDEO_OPTIONS_ENABLED, VIDEO_OPTIONS_DISABLED = VIDEO_OPTIONS_ENABLED, VIDEO_OPTIONS_DISABLED

local usageTable, memoryTable = {}, {}
local usageString = "%.3f ms"
local scriptProfileStatus = GetCVarBool("scriptProfile")
local showMemoryUsage, entered

local function formatMemory(value)
	if value > 1024 then
		return format("%.1f mb", value / 1024)
	else
		return format("%.0f kb", value)
	end
end

local function memoryColor(value, times)
	if not times then times = 1 end

	if value <= 1024*times then
		return 0, 1, 0
	elseif value <= 2048*times then
		return .75, 1, 0
	elseif value <= 4096*times then
		return 1, 1, 0
	elseif value <= 8192*times then
		return 1, .75, 0
	elseif value <= 16384*times then
		return 1, .5, 0
	else
		return 1, .1, 0
	end
end

local function colorFPS(fps)
	if fps < 15 then
		return "|cffD80909"..fps
	elseif fps < 30 then
		return "|cffE8DA0F"..fps
	else
		return "|cff0CD809"..fps
	end
end

local function setFrameRate(self)
	local fps = floor(GetFramerate())
	self.text:SetText(L["FPS"]..": "..colorFPS(fps))
end

local function updateAddOnTable()
	local numAddons = GetNumAddOns()
	if numAddons == #usageTable then return end

	wipe(usageTable)
	wipe(memoryTable)
	for i = 1, numAddons do
		usageTable[i] = {i, select(2, GetAddOnInfo(i)), 0}
		memoryTable[i] = {i, select(2, GetAddOnInfo(i)), 0}
	end
end

local function sortUsage(a, b)
	if a and b then
		return a[3] > b[3]
	end
end

local function updateUsage()
	UpdateAddOnCPUUsage()

	local total = 0
	for i = 1, #usageTable do
		local value = usageTable[i]
		value[3] = GetAddOnCPUUsage(value[1])
		total = total + value[3]
	end
	sort(usageTable, sortUsage)

	return total
end

local function updateMemory()
	UpdateAddOnMemoryUsage()

	local total = 0
	for i = 1, #memoryTable do
		local value = memoryTable[i]
		value[3] = GetAddOnMemoryUsage(value[1])
		total = total + value[3]
	end
	sort(memoryTable, sortUsage)

	return total
end

info.onUpdate = function(self, elapsed)
	-- Framerate
	self.timer = (self.timer or 0) + elapsed
	if self.timer > 1 then
		setFrameRate(self)
		if entered then self:onEnter() end
		self.timer = 0
	end

	-- Rebuild addon list
	self.elapsed = (self.elapsed or 10) + elapsed
	if self.elapsed > 10 then
		updateAddOnTable()
		self.elapsed = 0
	end
end

info.onEnter = function(self)
	entered = true

	local totalMemory = updateMemory()
	local maxAddOns = C.Infobar.MaxAddOns
	local isShiftKeyDown = IsShiftKeyDown()

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -15)
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine(L["System"], formatMemory(totalMemory), 0,.6,1, .6,.8,1)
	GameTooltip:AddLine(" ")

	if showMemoryUsage or not scriptProfileStatus then
		local maxShown = isShiftKeyDown and #memoryTable or min(maxAddOns, #memoryTable)
		local numEnabled = 0
		for i = 1, #memoryTable do
			local value = memoryTable[i]
			if value and IsAddOnLoaded(value[1]) then
				numEnabled = numEnabled + 1
				if numEnabled <= maxShown then
					GameTooltip:AddDoubleLine(value[2], formatMemory(value[3]), 1,1,1, memoryColor(value[3], 5))
				end
			end
		end
	
		if not isShiftKeyDown and (numEnabled > maxAddOns) then
			local hiddenMemory = 0
			for i = (maxAddOns + 1), numEnabled do
				hiddenMemory = hiddenMemory + memoryTable[i][3]
			end
			GameTooltip:AddDoubleLine(format("%d %s (%s)", numEnabled - maxAddOns, L["Hidden"], L["Hold Shift"]), formatMemory(hiddenMemory), .6,.8,1, .6,.8,1)
		end

		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(L["Default UI Memory Usage:"], formatMemory(gcinfo() - totalMemory), .6,.8,1, 1,1,1)
		GameTooltip:AddDoubleLine(L["Total Memory Usage:"], formatMemory(collectgarbage("count")), .6,.8,1, 1,1,1)
	else
		local totalCPU = updateUsage()
		if totalCPU > 0 then
			local maxShown = isShiftKeyDown and #usageTable or min(maxAddOns, #usageTable)
			local numEnabled = 0
			for i = 1, #usageTable do
				local value = usageTable[i]
				if value and IsAddOnLoaded(value[1]) then
					numEnabled = numEnabled + 1
					if numEnabled <= maxShown then
						local r = value[3] / totalCPU
						local g = 1.5 - r
						GameTooltip:AddDoubleLine(value[2], format(usageString, value[3] / max(1, GetTime() - module.loginTime)), 1,1,1, r,g,0)
					end
				end
			end

			if not isShiftKeyDown and (numEnabled > maxAddOns) then
				local hiddenUsage = 0
				for i = (maxAddOns + 1), numEnabled do
					hiddenUsage = hiddenUsage + usageTable[i][3]
				end
				GameTooltip:AddDoubleLine(format("%d %s (%s)", numEnabled - maxAddOns, L["Hidden"], L["Hold Shift"]), format(usageString, hiddenUsage), .6,.8,1, .6,.8,1)
			end
		end
	end

	GameTooltip:AddDoubleLine(" ", DB.LineString)
	GameTooltip:AddDoubleLine(" ", DB.LeftButton..L["Collect Memory"].." ", 1,1,1, .6,.8,1)
	if scriptProfileStatus then
		GameTooltip:AddDoubleLine(" ", DB.RightButton..L["SwitchSystemInfo"].." ", 1,1,1, .6,.8,1)
	end
	GameTooltip:AddDoubleLine(" ", DB.ScrollButton..L["CPU Usage"]..": "..(GetCVarBool("scriptProfile") and "|cff55ff55"..VIDEO_OPTIONS_ENABLED or "|cffff5555"..VIDEO_OPTIONS_DISABLED).." ", 1,1,1, .6,.8,1)
	GameTooltip:Show()
end

info.onLeave = function()
	entered = false
	GameTooltip:Hide()
end

StaticPopupDialogs["CPUUSAGE"] = {
	text = L["ReloadUI Required"],
	button1 = APPLY,
	button2 = CLASS_TRIAL_THANKS_DIALOG_CLOSE_BUTTON,
	OnAccept = function() ReloadUI() end,
	whileDead = 1,
}

info.onMouseUp = function(self, btn)
	local scriptProfile = GetCVarBool("scriptProfile")
	if btn == "LeftButton" then
		if scriptProfileStatus then
			ResetCPUUsage()
			module.loginTime = GetTime()
		end
		local before = gcinfo()
		collectgarbage("collect")
		print(format("|cff66C6FF%s:|r %s", L["Collect Memory"], formatMemory(before - gcinfo())))
		self:onEnter()
	elseif btn == "RightButton" and scriptProfileStatus then
		showMemoryUsage = not showMemoryUsage
		self:onEnter()
	elseif btn == "MiddleButton" then
		if scriptProfile then
			SetCVar("scriptProfile", 0)
		else
			SetCVar("scriptProfile", 1)
		end

		if GetCVarBool("scriptProfile") == scriptProfileStatus then
			StaticPopup_Hide("CPUUSAGE")
		else
			StaticPopup_Show("CPUUSAGE")
		end
		self:onEnter()
	end
end