local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF
if not C.Infobar.System then return end

local module = B:GetModule("Infobar")
local info = module:RegisterInfobar("Fps", C.Infobar.SystemPos)

local ipairs, tinsert, wipe, sort = ipairs, tinsert, wipe, sort
local format, floor, min, max = format, floor, min, max
local GetFramerate, GetTime = GetFramerate, GetTime
local GetCVarBool, SetCVar = GetCVarBool, SetCVar
local UpdateAddOnMemoryUsage, GetAddOnMemoryUsage = UpdateAddOnMemoryUsage, GetAddOnMemoryUsage
local IsShiftKeyDown = IsShiftKeyDown
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local collectgarbage, gcinfo = collectgarbage, gcinfo

local showMoreString = "%d %s (%s)"
local entered

local function formatMemory(value)
	if value > 1024 then
		return format("%.1f mb", value / 1024)
	else
		return format("%.0f kb", value)
	end
end

local function sortByMemory(a, b)
	if a and b then
		return (a[3] == b[3] and a[2] < b[2]) or a[3] > b[3]
	end
end

local usageColor = {0, 1, 0, 1, 1, 0, 1, 0, 0}
local function smoothColor(cur, max)
	local r, g, b = oUF:RGBColorGradient(cur, max, unpack(usageColor))
	return r, g, b
end

local infoTable = {}
local function BuildAddonList()
	local numAddons = C_AddOns.GetNumAddOns()
	if numAddons == #infoTable then return end

	wipe(infoTable)
	for i = 1, numAddons do
		local _, title, _, loadable = C_AddOns.GetAddOnInfo(i)
		if loadable then
			tinsert(infoTable, {i, title, 0, 0})
		end
	end
end

local function UpdateMemory()
	UpdateAddOnMemoryUsage()

	local total = 0
	for _, data in ipairs(infoTable) do
		if IsAddOnLoaded(data[1]) then
			local mem = GetAddOnMemoryUsage(data[1])
			data[3] = mem
			total = total + mem
		end
	end
	sort(infoTable, sortByMemory)

	return total
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

info.onUpdate = function(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer > 1 then
		setFrameRate(self)
		if entered then self:onEnter() end

		self.timer = 0
	end
end

info.onEnter = function(self)
	entered = true

	if not next(infoTable) then BuildAddonList() end
	local isShiftKeyDown = IsShiftKeyDown()
	local maxAddOns = C.db["Misc"]["MaxAddOns"]
	local maxShown = isShiftKeyDown and #infoTable or min(maxAddOns, #infoTable)

	local _, anchor, offset = module:GetTooltipAnchor(info)
	GameTooltip:SetOwner(self, "ANCHOR_"..anchor, 0, offset)
	GameTooltip:ClearLines()

	local totalMemory = UpdateMemory()
	GameTooltip:AddDoubleLine(L["System"], formatMemory(totalMemory), 0,.6,1, .6,.8,1)
	GameTooltip:AddLine(" ")

	local numEnabled = 0
	for _, data in ipairs(infoTable) do
		if IsAddOnLoaded(data[1]) then
			numEnabled = numEnabled + 1
			if numEnabled <= maxShown then
				local r, g, b = smoothColor(data[3], totalMemory)
				GameTooltip:AddDoubleLine(data[2], formatMemory(data[3]), 1,1,1, r,g,b)
			end
		end
	end

	if not isShiftKeyDown and (numEnabled > maxAddOns) then
		local hiddenMemory = 0
		for i = (maxAddOns + 1), numEnabled do
			hiddenMemory = hiddenMemory + infoTable[i][3]
		end
		GameTooltip:AddDoubleLine(format(showMoreString, numEnabled - maxAddOns, L["Hidden"], L["Hold Shift"]), formatMemory(hiddenMemory), .6,.8,1, .6,.8,1)
	end

	GameTooltip:AddDoubleLine(" ", DB.LineString)
	GameTooltip:AddDoubleLine(" ", DB.LeftButton..L["Collect Memory"].." ", 1,1,1, .6,.8,1)
	GameTooltip:Show()
end

info.onLeave = function()
	entered = false
	GameTooltip:Hide()
end

info.onMouseUp = function(self, btn)
	if btn == "LeftButton" then
		local before = gcinfo()
		collectgarbage("collect")
		print(format("|cff66C6FF%s:|r %s", L["Collect Memory"], formatMemory(before - gcinfo())))
		self:onEnter()
	end
end