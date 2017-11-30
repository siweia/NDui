local _, ns = ...
local cfg = ns.cfg
local init = ns.init

if cfg.Memory == true then
	local Stat = CreateFrame("Frame", nil, UIParent)
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetFrameLevel(3)
	Stat:EnableMouse(true)
	Stat:SetHitRectInsets(0, 0, 0, -10)
	local Text = Stat:CreateFontString(nil, "OVERLAY")
	Text:SetFont(unpack(cfg.Fonts))
	Text:SetPoint(unpack(cfg.MemoryPoint))
	Stat:SetAllPoints(Text)

	local function formatMem(memory)
		local mult = 10^1
		if memory > 999 then
			local mem = floor((memory/1024) * mult + .5) / mult
			if mem % 1 == 0 then
				return mem..".0 mb"
			else
				return mem.." mb"
			end
		else
			local mem = floor(memory * mult + .5) / mult
			if mem % 1 == 0 then
				return mem..".0 kb"
			else
				return mem.." kb"
			end
		end
	end

	local memoryTable
	local function RefreshMemory()
		memoryTable = {}
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

		table.sort(memoryTable, function(a, b)
			if a and b then
				return a[2] > b[2]
			end
		end)
		return total
	end
	
	local function RefreshText()
		UpdateAddOnMemoryUsage()
		local total = 0
		for i = 1, GetNumAddOns() do
			if IsAddOnLoaded(i) then
				local usage = GetAddOnMemoryUsage(i)
				total = total + usage
			end
		end
		return total
	end

	local function formatTotal(number)
		if number >= 1024 then
			return format("%.1f"..init.Colored.."mb|r", number / 1024)
		else
			return format("%.1f"..init.Colored.."kb|r", number)
		end
	end

	local int, Total = 5
	local function Update(self, t)
		int = int - t
		if int < 0 then
			Total = RefreshText()
			int = 5
		end
		Text:SetText(formatTotal(Total))
	end

	if not diminfo.AutoCollect then diminfo.AutoCollect = true end

	Stat:SetScript("OnMouseUp", function(self, btn)
		if btn == "LeftButton" then
			local before = gcinfo()
			collectgarbage("collect")
			print(format("|cff66C6FF%s:|r %s", ns.infoL["Garbage collected"], formatMem(before - gcinfo())))
			RefreshMemory()
		elseif btn == "RightButton" then
			diminfo.AutoCollect = not diminfo.AutoCollect
		end
		self:GetScript("OnEnter")(self)
	end)

	Stat:SetScript("OnEnter", function(self)
		local totalMemory = RefreshMemory()
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -15)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(format("%s:", ADDONS), formatMem(totalMemory), 0,.6,1, .6,.8,1)
		GameTooltip:AddLine(" ")

		local maxAddOns = math.min(cfg.MaxAddOns, #memoryTable)
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
			GameTooltip:AddDoubleLine(memoryTable[i][1], formatMem(usage), 1, 1, 1, color[1], color[2], 0)
		end

		local hiddenMemory = 0
		if not IsShiftKeyDown() then
			for i = (cfg.MaxAddOns + 1), #memoryTable do
				hiddenMemory = hiddenMemory + memoryTable[i][2]
			end
			if #memoryTable > cfg.MaxAddOns then
				local numHidden = #memoryTable - cfg.MaxAddOns
				GameTooltip:AddDoubleLine(format("%d %s (%s)", numHidden, ns.infoL["Hidden"], ns.infoL["Shift"]), formatMem(hiddenMemory), .6,.8,1, .6,.8,1)
			end
		end
		GameTooltip:AddLine(" ")

		GameTooltip:AddDoubleLine(ns.infoL["Default UI Memory Usage:"], formatMem(gcinfo() - totalMemory), .6,.8,1, 1,1,1)
		GameTooltip:AddDoubleLine(ns.infoL["Total Memory Usage:"], formatMem(collectgarbage("count")), .6,.8,1, 1,1,1)
		GameTooltip:AddDoubleLine(" ", "--------------", 1,1,1, .5,.5,.5)
		GameTooltip:AddDoubleLine(" ", init.LeftButton..ns.infoL["ManulCollect"], 1,1,1, .6,.8,1)
		GameTooltip:AddDoubleLine(" ", init.RightButton..ns.infoL["AutoCollect"]..": "..(diminfo.AutoCollect and "|cff55ff55"..VIDEO_OPTIONS_ENABLED or "|cffff5555"..VIDEO_OPTIONS_DISABLED), 1,1,1, .6,.8,1)
		GameTooltip:Show()
	end)

	Stat:SetScript("OnLeave", GameTooltip_Hide)
	Stat:SetScript("OnUpdate", Update)
	Update(Stat, 20)
	
	-- AutoCollect
	local eventcount = 0
	local a = CreateFrame("Frame")
	a:RegisterAllEvents()
	a:SetScript("OnEvent", function(self, event)
		if diminfo.AutoCollect == true then
			eventcount = eventcount + 1
			if InCombatLockdown() then return end
			if eventcount > 6000 or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_REGEN_ENABLED" then
				collectgarbage("collect")
				eventcount = 0
			end
		end
	end)
end