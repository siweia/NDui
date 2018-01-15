local B, C, L, DB = unpack(select(2, ...))
if not C.Infobar.System then return end

local module = NDui:GetModule("Infobar")
local info = module:RegisterInfobar(C.Infobar.SystemPos)

local function colorLatency(latency)
	if latency < 300 then
		return "|cff0CD809"..latency
	elseif latency >= 300 and latency < 500 then
		return "|cffE8DA0F"..latency
	else
		return "|cffD80909"..latency
	end
end

info.onUpdate = function(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer > 1 then
		local _, _, latencyHome, latencyWorld = GetNetStats()
		local latency = math.max(latencyHome, latencyWorld)
		local fps = floor(GetFramerate())
		local color
		if fps >= 30 then
			color = "|cff0CD809"
		elseif fps > 15 and fps < 30 then
			color = "|cffE8DA0F"
		else
			color = "|cffD80909"
		end
		self.text:SetText(color..fps.."|rFPS "..colorLatency(latency).."|rMS")

		self.timer = 0
	end
end

local usageTable = {}

local function retrieveUsage()
	wipe(usageTable)
	UpdateAddOnCPUUsage()

	local total, count = 0, 0
	for i = 1, GetNumAddOns() do
		if IsAddOnLoaded(i) then
			local usage = GetAddOnCPUUsage(i)
			count = count + 1
			usageTable[count] = {select(2, GetAddOnInfo(i)), usage}
			total = total + usage
		end
	end

	sort(usageTable, function(a, b)
		if a and b then
			return a[2] > b[2]
		end
	end)

	return total
end

info.onEnter = function(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -15)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(L["System"], 0,.6,1)
	GameTooltip:AddLine(" ")

	if GetCVar("scriptProfile") == "1" then
		local totalUsage = retrieveUsage() + .0001
		local maxAddOns = math.min(C.Infobar.MaxAddOns, #usageTable)
		if IsShiftKeyDown() then
			maxAddOns = #usageTable
		end

		for i = 1, maxAddOns do
			local percent = usageTable[i][2]/totalUsage * 100
			local color = percent <= 1 and {0, 1} -- 0 - 1
				or percent <= 5 and {.75, 1} -- 1 - 5
				or percent <= 10 and {1, 1} -- 5 - 10
				or percent <= 25 and {1, .75} -- 10 - 25
				or percent <= 50 and {1, .5} -- 25 - 50
				or {1, .1} -- 50 +
			GameTooltip:AddDoubleLine(usageTable[i][1], format("%.2f%s", percent, " %"), 1, 1, 1, color[1], color[2], 0)
		end

		local hiddenUsage = 0
		if not IsShiftKeyDown() then
			for i = (C.Infobar.MaxAddOns + 1), #usageTable do
				hiddenUsage = hiddenUsage + usageTable[i][2]
			end
			if #usageTable > C.Infobar.MaxAddOns then
				local numHidden = #usageTable - C.Infobar.MaxAddOns
				GameTooltip:AddDoubleLine(format("%d %s (%s)", numHidden, L["Hidden"], L["Shift"]), format("%.2f%s", hiddenUsage/totalUsage*100, " %"), .6,.8,1, .6,.8,1)
			end
		end
		GameTooltip:AddLine(" ")
	end

	local _, _, latencyHome, latencyWorld = GetNetStats()
	GameTooltip:AddDoubleLine(L["Home Latency"]..":", colorLatency(latencyHome).."|r MS", .6,.8,1, 1,1,1)
	GameTooltip:AddDoubleLine(L["World Latency"]..":", colorLatency(latencyWorld).."|r MS", .6,.8,1, 1,1,1)
	GameTooltip:AddDoubleLine(" ", "--------------", 1,1,1, .5,.5,.5)
	GameTooltip:AddDoubleLine(" ", DB.RightButton..L["CPU Usage"]..": "..(GetCVar("scriptProfile") == "1" and "|cff55ff55"..VIDEO_OPTIONS_ENABLED or "|cffff5555"..VIDEO_OPTIONS_DISABLED), 1,1,1, .6,.8,1)
	GameTooltip:Show()
end

info.onLeave = function() GameTooltip:Hide() end

StaticPopupDialogs["CPUUSAGE"] = {
	text = L["Toggle CPU Usage"],
	button1 = APPLY,
	button2 = CLASS_TRIAL_THANKS_DIALOG_CLOSE_BUTTON,
	OnAccept = function() ReloadUI() end,
	whileDead = 1,
}

local status = GetCVar("scriptProfile")
info.onMouseUp = function(self, button)
	if button ~= "RightButton" then return end

	if GetCVar("scriptProfile") == "0" then
		SetCVar("scriptProfile", 1)
	else
		SetCVar("scriptProfile", 0)
	end
	if GetCVar("scriptProfile") == status then
		StaticPopup_Hide("CPUUSAGE")
	else
		StaticPopup_Show("CPUUSAGE")
	end
	self:GetScript("OnEnter")(self)
end