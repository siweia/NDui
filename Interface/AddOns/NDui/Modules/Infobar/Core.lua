local _, ns = ...
local B, C, L, DB = unpack(ns)
local INFO = B:RegisterModule("Infobar")
local tinsert, pairs, unpack = table.insert, pairs, unpack

local GOLD_AMOUNT_SYMBOL = format("|cffffd700%s|r", GOLD_AMOUNT_SYMBOL)
local SILVER_AMOUNT_SYMBOL = format("|cffd0d0d0%s|r", SILVER_AMOUNT_SYMBOL)
local COPPER_AMOUNT_SYMBOL = format("|cffc77050%s|r", COPPER_AMOUNT_SYMBOL)

INFO.Modules = {}

function INFO:GetMoneyString(money, full)
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

function INFO:RegisterInfobar(name, point)
	if not self.modules then self.modules = {} end

	local info = CreateFrame("Frame", nil, UIParent)
	info:SetHitRectInsets(0, 0, -10, -10)
	info.text = B.CreateFS(info, C.Infobar.FontSize)
	info.text:ClearAllPoints()
	if C.Infobar.AutoAnchor then
		info.point = point
	else
		info.text:SetPoint(unpack(point))
	end
	info:SetAllPoints(info.text)
	info.name = name
	tinsert(self.modules, info)

	self.Modules[strlower(name)] = info

	return info
end

function INFO:LoadInfobar(info)
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
		B.Mover(frame, v[5], v[5], {v[1], parent, v[1], 0, v[2]})

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

function INFO:OnLogin()
	if NDuiADB["DisableInfobars"] then return end

	if not self.modules then return end
	for _, info in pairs(self.modules) do
		self:LoadInfobar(info)
	end

	self:BackgroundLines()
	self.loginTime = GetTime()

	Infobar_UpdateAnchor()

	if not C.Infobar.Auto2Anchor then return end
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

local leftModules, rightModules = {}, {}

function Infobar_UpdateValues()
	wipe(leftModules)
	for name in gmatch(C.db["Misc"]["LeftInfoStr"], "%[(%w+)%]") do
		if INFO.Modules[name] then
			tinsert(leftModules, name) -- left to right
		end
	end

	wipe(rightModules)
	for name in gmatch(C.db["Misc"]["RightInfoStr"], "%[(%w+)%]") do
		if INFO.Modules[name] then
			tinsert(rightModules, 1, name) -- right to left
		end
	end
end

function Infobar_UpdateAnchor()
	Infobar_UpdateValues()

	local previousLeft
	for index, name in pairs(leftModules) do
		local info = INFO.Modules[name]
		info.text:ClearAllPoints()
		if index == 1 then
			info.text:SetPoint("LEFT", _G["NDuiLeftInfobar"], 15, 0)
		else
			info.text:SetPoint("LEFT", previousLeft, "RIGHT", 30, 0)
		end
		previousLeft = info
	end

	local previousRight
	for index, name in pairs(rightModules) do
		local info = INFO.Modules[name]
		info.text:ClearAllPoints()
		if index == 1 then
			info.text:SetPoint("RIGHT", _G["NDuiRightInfobar"], -15, 0)
		else
			info.text:SetPoint("RIGHT", previousRight, "LEFT", -30, 0)
		end
		previousRight = info
	end
end