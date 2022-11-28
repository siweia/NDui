local _, ns = ...
local B, C, L, DB = unpack(ns)
local INFO = B:RegisterModule("Infobar")

local tinsert, pairs, unpack = table.insert, pairs, unpack
local GOLD_AMOUNT_SYMBOL = format("|cffffd700%s|r", GOLD_AMOUNT_SYMBOL)
local SILVER_AMOUNT_SYMBOL = format("|cffd0d0d0%s|r", SILVER_AMOUNT_SYMBOL)
local COPPER_AMOUNT_SYMBOL = format("|cffc77050%s|r", COPPER_AMOUNT_SYMBOL)

INFO.modules = {}
INFO.leftModules, INFO.rightModules = {}, {}

function INFO:GetMoneyString(money, full)
	if money >= 1e6 and not full then
		return BreakUpLargeNumbers(format("%d", money / 1e4))..GOLD_AMOUNT_SYMBOL
	else
		if money > 0 then
			local moneyString = ""
			local gold, silver, copper = floor(money/1e4), floor(money/100) % 100, money % 100
			if gold > 0 then
				moneyString = " "..gold..GOLD_AMOUNT_SYMBOL
			end
			if silver > 0 then
				moneyString = moneyString.." "..silver..SILVER_AMOUNT_SYMBOL
			end
			if copper > 0 then
				moneyString = moneyString.." "..copper..COPPER_AMOUNT_SYMBOL
			end
			return moneyString
		else
			return " 0"..COPPER_AMOUNT_SYMBOL
		end
	end
end

function INFO:RegisterInfobar(name, point)
	local info = CreateFrame("Frame", nil, UIParent)
	info:SetHitRectInsets(0, 0, -10, -10)
	info.text = B.CreateFS(info, 12)
	info.text:ClearAllPoints()
	if C.Infobar.CustomAnchor then
		info.text:SetPoint(unpack(point))
		info.isActive = true
	end
	info:SetAllPoints(info.text)

	INFO.modules[strlower(name)] = info

	return info
end

function INFO:UpdateInfobarSize()
	for _, info in pairs(INFO.modules) do
		B.SetFontSize(info.text, C.db["Misc"]["InfoSize"])
	end
end

local function info_OnEvent(self, ...)
	if not self.isActive then return end
	self:onEvent(...)
end

function INFO:LoadInfobar(info)
	if info.eventList then
		for _, event in pairs(info.eventList) do
			info:RegisterEvent(event)
		end
		info:SetScript("OnEvent", info_OnEvent)
	end
	if info.onEnter then
		info:SetScript("OnEnter", info.onEnter)
	end
	if info.onLeave then
		info:SetScript("OnLeave", info.onLeave)
	end
	if info.onMouseUp then
		info:SetScript("OnMouseUp", info.onMouseUp)
	end
	if info.onUpdate then
		info:SetScript("OnUpdate", info.onUpdate)
	end
end

function INFO:BackgroundLines()
	local cr, cg, cb = 0, 0, 0
	if C.db["Skins"]["ClassLine"] then cr, cg, cb = DB.r, DB.g, DB.b end

	local parent = UIParent
	local width, height = 450, 18
	local anchors = {
		[1] = {"TOPLEFT", -3, .5, 0, "LeftInfobar"},
		[2] = {"BOTTOMRIGHT", 3, 0, .5, "RightInfobar"},
	}
	for _, v in pairs(anchors) do
		local frame = CreateFrame("Frame", "NDui"..v[5], parent)
		frame:SetSize(width, height)
		frame:SetFrameStrata("BACKGROUND")
		B.Mover(frame, L[v[5]], v[5], {v[1], parent, v[1], 0, v[2]})

		if C.db["Skins"]["InfobarLine"] then
			local tex = B.SetGradient(frame, "H", 0, 0, 0, v[3], v[4], width, height)
			tex:SetPoint("CENTER")
			local bottomLine = B.SetGradient(frame, "H", cr, cg, cb, v[3], v[4], width, C.mult)
			bottomLine:SetPoint("TOP", frame, "BOTTOM")
			local topLine = B.SetGradient(frame, "H", cr, cg, cb, v[3], v[4], width, C.mult)
			topLine:SetPoint("BOTTOM", frame, "TOP")
		end
	end
end

function INFO:Infobar_UpdateValues()
	local modules = INFO.modules

	wipe(INFO.leftModules)
	for name in gmatch(C.db["Misc"]["InfoStrLeft"], "%[(%w+)%]") do
		if modules[name] and not modules[name].isActive then
			modules[name].isActive = true
			tinsert(INFO.leftModules, name) -- left to right
		end
	end

	wipe(INFO.rightModules)
	for name in gmatch(C.db["Misc"]["InfoStrRight"], "%[(%w+)%]") do
		if modules[name] and not modules[name].isActive then
			modules[name].isActive = true
			tinsert(INFO.rightModules, 1, name) -- right to left
		end
	end
end

function INFO:Infobar_UpdateAnchor()
	if C.Infobar.CustomAnchor then return end

	for _, info in pairs(INFO.modules) do
		info:Hide()
		info.isActive = false
	end

	INFO:Infobar_UpdateValues()

	local previousLeft
	for index, name in pairs(INFO.leftModules) do
		local info = INFO.modules[name]
		info.text:ClearAllPoints()
		if index == 1 then
			info.text:SetPoint("LEFT", _G["NDuiLeftInfobar"], 15, 0)
		else
			info.text:SetPoint("LEFT", previousLeft, "RIGHT", 30, 0)
		end
		previousLeft = info

		info:Show()
		if info.onEvent then info:onEvent("PLAYER_ENTERING_WORLD") end
	end

	local previousRight
	for index, name in pairs(INFO.rightModules) do
		local info = INFO.modules[name]
		info.text:ClearAllPoints()
		if index == 1 then
			info.text:SetPoint("RIGHT", _G["NDuiRightInfobar"], -15, 0)
		else
			info.text:SetPoint("RIGHT", previousRight, "LEFT", -30, 0)
		end
		previousRight = info

		info:Show()
		if info.onEvent then info:onEvent("PLAYER_ENTERING_WORLD") end
	end
end

function INFO:GetTooltipAnchor(info)
	local _, height = info:GetCenter()
	if height and height > GetScreenHeight()/2 then
		return "TOP", "BOTTOM", -15
	else
		return "BOTTOM", "TOP", 15
	end
end

function INFO:OnLogin()
	if NDuiADB["DisableInfobars"] then return end

	for _, info in pairs(INFO.modules) do
		INFO:LoadInfobar(info)
	end

	INFO.loginTime = GetTime()
	INFO:BackgroundLines()
	INFO:UpdateInfobarSize()
	INFO:Infobar_UpdateAnchor()
end