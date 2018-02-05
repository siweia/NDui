local B, C, L, DB = unpack(select(2, ...))
if not C.Infobar.Memory then return end

local module = NDui:GetModule("Infobar")
local info = module:RegisterInfobar(C.Infobar.MemoryPos)

local function formatMemory(value, color)
	color = color and DB.MyColor or " "
	if value > 1024 then
		return format("%.1f"..color.."MB", value / 1024)
	else
		return format("%.0f"..color.."KB", value)
	end
end

local memoryTable = {}
local function updateMemory()
	wipe(memoryTable)
	UpdateAddOnMemoryUsage()

	local total, count = 0, 0
	for i = 1, GetNumAddOns() do
		if IsAddOnLoaded(i) then
			local usage = GetAddOnMemoryUsage(i)
			count = count + 1
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
		UpdateAddOnMemoryUsage()

		local total = 0
		for i = 1, GetNumAddOns() do
			if IsAddOnLoaded(i) then
				local usage = GetAddOnMemoryUsage(i)
				total = total + usage
			end
		end
		info.text:SetText(formatMemory(total, true))

		self.timer = 0
	end
end

info.onMouseUp = function(self, button)
	if button == "LeftButton" then
		local before = gcinfo()
		collectgarbage("collect")
		print(format("|cff66C6FF%s:|r %s", L["Collect Memory"], formatMemory(before - gcinfo())))
		updateMemory()
	elseif button == "RightButton" then
		NDuiADB["AutoCollect"] = not NDuiADB["AutoCollect"]
	end
	self:GetScript("OnEnter")(self)
end

info.onEnter = function(self)
	local totalMemory = updateMemory()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -15)
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine(ADDONS, formatMemory(totalMemory), 0,.6,1, .6,.8,1)
	GameTooltip:AddLine(" ")

	local maxAddOns = math.min(C.Infobar.MaxAddOns, #memoryTable)
	if IsShiftKeyDown() then
		maxAddOns = #memoryTable
	end

	for i = 1, maxAddOns do
		local usage = memoryTable[i][2]
		local color = usage <= 102.4 and {0,1} -- 0 - 100
			or usage <= 512 and {.75,1} -- 100 - 512
			or usage <= 1024 and {1,1} -- 512 - 1mb
			or usage <= 2560 and {1,.75} -- 1mb - 2.5mb
			or usage <= 5120 and {1,.5} -- 2.5mb - 5mb
			or {1,.1} -- 5mb +
		GameTooltip:AddDoubleLine(memoryTable[i][1], formatMemory(usage), 1, 1, 1, color[1], color[2], 0)
	end

	local hiddenMemory = 0
	if not IsShiftKeyDown() then
		for i = (C.Infobar.MaxAddOns + 1), #memoryTable do
			hiddenMemory = hiddenMemory + memoryTable[i][2]
		end
		if #memoryTable > C.Infobar.MaxAddOns then
			local numHidden = #memoryTable - C.Infobar.MaxAddOns
			GameTooltip:AddDoubleLine(format("%d %s (%s)", numHidden, L["Hidden"], L["Shift"]), formatMemory(hiddenMemory), .6,.8,1, .6,.8,1)
		end
	end
	GameTooltip:AddLine(" ")

	GameTooltip:AddDoubleLine(L["Default UI Memory Usage:"], formatMemory(gcinfo() - totalMemory), .6,.8,1, 1,1,1)
	GameTooltip:AddDoubleLine(L["Total Memory Usage:"], formatMemory(collectgarbage("count")), .6,.8,1, 1,1,1)
	GameTooltip:AddDoubleLine(" ", "--------------", 1,1,1, .5,.5,.5)
	GameTooltip:AddDoubleLine(" ", DB.LeftButton..L["Collect Memory"], 1,1,1, .6,.8,1)
	GameTooltip:AddDoubleLine(" ", DB.RightButton..L["Auto Collect"]..": "..(NDuiADB["AutoCollect"] and "|cff55ff55"..VIDEO_OPTIONS_ENABLED or "|cffff5555"..VIDEO_OPTIONS_DISABLED), 1,1,1, .6,.8,1)
	GameTooltip:Show()
end

info.onLeave = function() GameTooltip:Hide() end

local eventCount = 0
info:RegisterAllEvents()
info:SetScript("OnEvent", function(_, event)
	if not NDuiADB["AutoCollect"] then return end
	eventCount = eventCount + 1
	if InCombatLockdown() then return end
	if eventCount > 6000 or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_REGEN_ENABLED" then
		collectgarbage("collect")
		eventCount = 0
	end
end)