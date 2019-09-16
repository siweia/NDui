local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:RegisterModule("Infobar")
local tinsert, pairs, unpack = table.insert, pairs, unpack

local GOLD_AMOUNT_SYMBOL = format("|cffffd700%s|r", GOLD_AMOUNT_SYMBOL)
local SILVER_AMOUNT_SYMBOL = format("|cffb0b0b0%s|r", SILVER_AMOUNT_SYMBOL)
local COPPER_AMOUNT_SYMBOL = format("|cffc77050%s|r", COPPER_AMOUNT_SYMBOL)

function module:GetMoneyString(money, full)
	if money >= 1e6 and not full then
		return format("%.0f%s", money / 1e4, GOLD_AMOUNT_SYMBOL)
	else
		if money > 0 then
			local moneyString = ""
			local gold = floor(money / 1e4)
			if gold > 0 then
				moneyString = " "..gold..GOLD_AMOUNT_SYMBOL
			end
			local silver = floor((money - (gold * 1e4)) / 100)
			if silver > 0 then
				moneyString = moneyString.." "..silver..SILVER_AMOUNT_SYMBOL
			end
			local copper = mod(money, 100)
			if copper > 0 then
				moneyString = moneyString.." "..copper..COPPER_AMOUNT_SYMBOL
			end
			return moneyString
		else
			return " 0"..COPPER_AMOUNT_SYMBOL
		end
	end
end

function module:RegisterInfobar(name, point)
	if not self.modules then self.modules = {} end

	local info = CreateFrame("Frame", nil, UIParent)
	info:SetHitRectInsets(0, 0, -10, -10)
	info.text = info:CreateFontString(nil, "OVERLAY")
	info.text:SetFont(DB.Font[1], C.Infobar.FontSize, DB.Font[3])
	if C.Infobar.AutoAnchor then
		info.point = point
	else
		info.text:SetPoint(unpack(point))
	end
	info:SetAllPoints(info.text)
	info.name = name
	tinsert(self.modules, info)

	return info
end

function module:LoadInfobar(info)
	if info.eventList then
		for _, event in pairs(info.eventList) do
			info:RegisterEvent(event)
		end
		info:SetScript("OnEvent", info.onEvent)
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

function module:OnLogin()
	if not self.modules then return end
	for _, info in pairs(self.modules) do
		self:LoadInfobar(info)
	end

	self.loginTime = GetTime()

	if not C.Infobar.AutoAnchor then return end
	for index, info in pairs(self.modules) do
		if index == 1 or index == 6 then
			info.text:SetPoint(unpack(info.point))
		elseif index < 6 then
			info.text:SetPoint("LEFT", self.modules[index-1], "RIGHT", 20, 0)
		else
			info.text:SetPoint("RIGHT", self.modules[index-1], "LEFT", -30, 0)
		end
	end
end