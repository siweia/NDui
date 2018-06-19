local _, ns = ...
local B, C, L, DB = unpack(ns)
if not C.Infobar.System then return end

local module = B:GetModule("Infobar")
local info = module:RegisterInfobar(C.Infobar.SystemPos)

local function colorLatency(latency)
	if latency < 250 then
		return "|cff0CD809"..latency
	elseif latency < 500 then
		return "|cffE8DA0F"..latency
	else
		return "|cffD80909"..latency
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

info.onUpdate = function(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer > 1 then
		if NDuiADB["ShowFPS"] then
			local fps = floor(GetFramerate())
			self.text:SetText(L["FPS"]..": "..colorFPS(fps))
		else
			local _, _, latencyHome, latencyWorld = GetNetStats()
			local latency = math.max(latencyHome, latencyWorld)
			self.text:SetText(L["Latency"]..": "..colorLatency(latency))
		end

		self.timer = 0
	end
end

local usageTable, startTime = {}
local function retrieveUsage()
	wipe(usageTable)
	UpdateAddOnCPUUsage()

	local count = 0
	local passTime = max(GetTime() - startTime, .01)
	for i = 1, GetNumAddOns() do
		if IsAddOnLoaded(i) then
			count = count + 1
			local usage = format("%.2f", GetAddOnCPUUsage(i)/passTime)
			usageTable[count] = {select(2, GetAddOnInfo(i)), usage}
		end
	end

	sort(usageTable, function(a, b)
		if a and b then
			return a[2] > b[2]
		end
	end)
end

info.eventList = {
	"PLAYER_ENTERING_WORLD"
}

info.onEvent = function(self, event, arg1)
	if event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent(event)
		C_Timer.After(.25, function()
			startTime = GetTime() - .01
		end)
	elseif event == "MODIFIER_STATE_CHANGED" and arg1 == "LSHIFT" then
		self:GetScript("OnEnter")(self)
	end
end

info.onEnter = function(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -15)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(L["System"], 0,.6,1)
	GameTooltip:AddLine(" ")

	if GetCVarBool("scriptProfile") then
		retrieveUsage()

		local maxAddOns = IsShiftKeyDown() and #usageTable or min(C.Infobar.MaxAddOns, #usageTable)
		for i = 1, maxAddOns do
			GameTooltip:AddDoubleLine(usageTable[i][1], usageTable[i][2].." MS/s", 1,1,1, 0,1,0)
		end

		local hiddenUsage = 0
		if not IsShiftKeyDown() then
			for i = (C.Infobar.MaxAddOns + 1), #usageTable do
				hiddenUsage = hiddenUsage + usageTable[i][2]
			end
			if #usageTable > C.Infobar.MaxAddOns then
				local numHidden = #usageTable - C.Infobar.MaxAddOns
				GameTooltip:AddDoubleLine(format("%d %s (%s)", numHidden, L["Hidden"], L["Hold Shift"]), hiddenUsage.." MS/s", .6,.8,1, .6,.8,1)
			end
		end
		GameTooltip:AddLine(" ")
	end

	local _, _, latencyHome, latencyWorld = GetNetStats()
	local fps = floor(GetFramerate())
	GameTooltip:AddDoubleLine(L["Home Latency"]..":", colorLatency(latencyHome).."|r MS", .6,.8,1, 1,1,1)
	GameTooltip:AddDoubleLine(L["World Latency"]..":", colorLatency(latencyWorld).."|r MS", .6,.8,1, 1,1,1)
	GameTooltip:AddDoubleLine(FRAMERATE_LABEL, colorFPS(fps).."|r FPS", .6,.8,1, 1,1,1)
	GameTooltip:AddDoubleLine(" ", DB.LineString)
	GameTooltip:AddDoubleLine(" ", DB.LeftButton..(NDuiADB["ShowFPS"] and L["Show Latency"] or L["Show FPS"]).." ", 1,1,1, .6,.8,1)
	GameTooltip:AddDoubleLine(" ", DB.RightButton..L["CPU Usage"]..": "..(GetCVarBool("scriptProfile") and "|cff55ff55"..VIDEO_OPTIONS_ENABLED or "|cffff5555"..VIDEO_OPTIONS_DISABLED).." ", 1,1,1, .6,.8,1)
	GameTooltip:Show()

	self:RegisterEvent("MODIFIER_STATE_CHANGED")
end

info.onLeave = function(self)
	GameTooltip:Hide()
	self:UnregisterEvent("MODIFIER_STATE_CHANGED")
end

StaticPopupDialogs["CPUUSAGE"] = {
	text = L["ReloadUI Required"],
	button1 = APPLY,
	button2 = CLASS_TRIAL_THANKS_DIALOG_CLOSE_BUTTON,
	OnAccept = function() ReloadUI() end,
	whileDead = 1,
}

local status = GetCVarBool("scriptProfile")
info.onMouseUp = function(self, btn)
	if btn == "LeftButton" then
		NDuiADB["ShowFPS"] = not NDuiADB["ShowFPS"]
	elseif btn == "RightButton" then
		if GetCVarBool("scriptProfile") then
			SetCVar("scriptProfile", 0)
		else
			SetCVar("scriptProfile", 1)
		end

		if GetCVarBool("scriptProfile") == status then
			StaticPopup_Hide("CPUUSAGE")
		else
			StaticPopup_Show("CPUUSAGE")
		end
	end
	self:GetScript("OnEnter")(self)
end