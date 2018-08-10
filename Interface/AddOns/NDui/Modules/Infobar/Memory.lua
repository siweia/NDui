local _, ns = ...
local B, C, L, DB = unpack(ns)
if not C.Infobar.Memory then return end

local module = B:GetModule("Infobar")
local info = module:RegisterInfobar(C.Infobar.MemoryPos)

local function formatMemory(value)
	if value > 1024 then
		return format("%.1f MB", value / 1024)
	else
		return format("%.0f KB", value)
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

local memoryTable, totalMemory = {}

local function updateMemory()
	wipe(memoryTable)
	UpdateAddOnMemoryUsage()

	local total, count = 0, 0
	for i = 1, GetNumAddOns() do
		if IsAddOnLoaded(i) then
			count = count + 1
			local usage = GetAddOnMemoryUsage(i)
			memoryTable[count] = {select(2, GetAddOnInfo(i)), usage}
			total = total + usage
		end
	end

	sort(memoryTable, function(a, b)
		if a and b then
			return a[2] > b[2]
		end
	end)

	return total
end

info.onUpdate = function(self, elapsed)
	self.timer = (self.timer or 5) + elapsed
	if self.timer > 5 then
		totalMemory = updateMemory()
		self.text:SetText(ADDONS..": "..B.HexRGB(memoryColor(totalMemory, 10))..format("%.1f", totalMemory/1024))

		self.timer = 0
	end
end

info.onMouseUp = function(self, btn)
	if btn == "LeftButton" then
		local before = gcinfo()
		collectgarbage()
		print(format("|cff66C6FF%s:|r %s", L["Collect Memory"], formatMemory(before - gcinfo())))
		updateMemory()
		self:GetScript("OnEnter")(self)
	end
end

info.onEnter = function(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -15)
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine(ADDONS, formatMemory(totalMemory), 0,.6,1, .6,.8,1)
	GameTooltip:AddLine(" ")

	local maxAddOns = IsShiftKeyDown() and #memoryTable or min(C.Infobar.MaxAddOns, #memoryTable)
	for i = 1, maxAddOns do
		local usage = memoryTable[i][2]
		GameTooltip:AddDoubleLine(memoryTable[i][1], formatMemory(usage), 1,1,1, memoryColor(usage))
	end

	local hiddenMemory = 0
	if not IsShiftKeyDown() then
		for i = (C.Infobar.MaxAddOns + 1), #memoryTable do
			hiddenMemory = hiddenMemory + memoryTable[i][2]
		end
		if #memoryTable > C.Infobar.MaxAddOns then
			local numHidden = #memoryTable - C.Infobar.MaxAddOns
			GameTooltip:AddDoubleLine(format("%d %s (%s)", numHidden, L["Hidden"], L["Hold Shift"]), formatMemory(hiddenMemory), .6,.8,1, .6,.8,1)
		end
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(L["Default UI Memory Usage:"], formatMemory(gcinfo() - totalMemory), .6,.8,1, 1,1,1)
	GameTooltip:AddDoubleLine(L["Total Memory Usage:"], formatMemory(collectgarbage("count")), .6,.8,1, 1,1,1)
	GameTooltip:AddDoubleLine(" ", DB.LineString)
	GameTooltip:AddDoubleLine(" ", DB.LeftButton..L["Collect Memory"].." ", 1,1,1, .6,.8,1)
	GameTooltip:Show()

	self:RegisterEvent("MODIFIER_STATE_CHANGED")
end

info.onLeave = function(self)
	GameTooltip:Hide()
	self:UnregisterEvent("MODIFIER_STATE_CHANGED")
end

info.eventList = {
	"PLAYER_ENTERING_WORLD"
}

info.onEvent = function(self, event, arg1)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	if event == "MODIFIER_STATE_CHANGED" and arg1 == "LSHIFT" then
		self:GetScript("OnEnter")(self)
	end
end

local f = CreateFrame("Frame")
f:RegisterAllEvents()
f:SetScript("OnEvent", function(_, event)
	if InCombatLockdown() then return end
	f.events = (f.events or 0) + 1
	if f.events > 6000 or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_REGEN_ENABLED" then
		collectgarbage()
		f.events = 0
	end
end)