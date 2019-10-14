local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:RegisterModule("Infobar")
local tinsert, pairs, unpack = table.insert, pairs, unpack

local GOLD_AMOUNT_SYMBOL = format("|cffffd700%s|r", GOLD_AMOUNT_SYMBOL)
local SILVER_AMOUNT_SYMBOL = format("|cffd0d0d0%s|r", SILVER_AMOUNT_SYMBOL)
local COPPER_AMOUNT_SYMBOL = format("|cffc77050%s|r", COPPER_AMOUNT_SYMBOL)

function module:GetMoneyString(money, full)
	if money >= 1e6 and not full then
		return format(" %.0f%s", money / 1e4, GOLD_AMOUNT_SYMBOL)
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

function module:BackgroundLines()
	if not NDuiDB["Skins"]["InfobarLine"] then return end

	local cr, cg, cb = 0, 0, 0
	if NDuiDB["Skins"]["ClassLine"] then cr, cg, cb = DB.r, DB.g, DB.b end

	-- TOPLEFT
	local Tinfobar = CreateFrame("Frame", nil, UIParent)
	Tinfobar:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, -3)
	B.CreateGF(Tinfobar, 550, 18, "Horizontal", 0, 0, 0, .5, 0)
	local Tinfobar1 = CreateFrame("Frame", nil, Tinfobar)
	Tinfobar1:SetPoint("BOTTOM", Tinfobar, "TOP")
	B.CreateGF(Tinfobar1, 550, C.mult, "Horizontal", cr, cg, cb, .7, 0)
	local Tinfobar2 = CreateFrame("Frame", nil, Tinfobar)
	Tinfobar2:SetPoint("TOP", Tinfobar, "BOTTOM")
	B.CreateGF(Tinfobar2, 550, C.mult, "Horizontal", cr, cg, cb, .7, 0)

	-- BOTTOMRIGHT
	local Rinfobar = CreateFrame("Frame", nil, UIParent)
	Rinfobar:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 3)
	B.CreateGF(Rinfobar, 450, 18, "Horizontal", 0, 0, 0, 0, .5)
	local Rinfobar1 = CreateFrame("Frame", nil, Rinfobar)
	Rinfobar1:SetPoint("BOTTOM", Rinfobar, "TOP")
	B.CreateGF(Rinfobar1, 450, C.mult, "Horizontal", cr, cg, cb, 0, .7)
	local Rinfobar2 = CreateFrame("Frame", nil, Rinfobar)
	Rinfobar2:SetPoint("TOP", Rinfobar, "BOTTOM")
	B.CreateGF(Rinfobar2, 450, C.mult, "Horizontal", cr, cg, cb, 0, .7)
end

function module:OnLogin()
	if NDuiADB["DisableInfobars"] then return end

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

	self:BackgroundLines()
end