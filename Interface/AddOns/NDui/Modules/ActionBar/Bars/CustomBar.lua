local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local tinsert = tinsert
local mod, min, ceil = mod, min, ceil
local cfg = C.Bars.bar4
local margin, padding = C.Bars.margin, C.Bars.padding

local prevPage = 8
local function ChangeActionPageForDruid()
	local page = IsPlayerSpell(33891) and 10 or 8
	if prevPage ~= page then
		RegisterStateDriver(_G["NDui_ActionBarX"], "page", page)
		for i = 1, 12 do
			local button = _G["NDui_ActionBarXButton"..i]
			button.id = (page-1)*12 + i
			button:SetAttribute("action", button.id)
		end

		prevPage = page
	end
end

local function UpdatePageBySpells()
	if InCombatLockdown() then
		B:RegisterEvent("PLAYER_REGEN_ENABLED", UpdatePageBySpells)
	else
		ChangeActionPageForDruid()
		B:UnregisterEvent("PLAYER_REGEN_ENABLED", UpdatePageBySpells)
	end
end

function Bar:CreateCustomBar(anchor)
	local num = 12
	local name = "NDui_ActionBarX"
	local page = DB.MyClass == "WARRIOR" and 10 or 8

	local frame = CreateFrame("Frame", name, UIParent, "SecureHandlerStateTemplate")
	frame.mover = B.Mover(frame, L[name], "CustomBar", anchor)

--	RegisterStateDriver(frame, "visibility", "[petbattle] hide; show")
	RegisterStateDriver(frame, "page", page)

	local buttonList = {}
	for i = 1, num do
		local button = CreateFrame("CheckButton", "$parentButton"..i, frame, "ActionBarButtonTemplate")
		button.id = (page-1)*12 + i
		button.isCustomButton = true
		button:SetAttribute("action", button.id)
		tinsert(buttonList, button)
		tinsert(Bar.buttons, button)
	end
	frame.buttons = buttonList

	if cfg.fader then
		frame.isDisable = not C.db["Actionbar"]["BarXFader"]
		Bar.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end

	Bar:UpdateCustomBar()
end

function Bar:UpdateCustomBar()
	local frame = _G.NDui_ActionBarX
	if not frame then return end

	local size = C.db["Actionbar"]["CustomBarButtonSize"]
	local scale = size/34
	local num = C.db["Actionbar"]["CustomBarNumButtons"]
	local perRow = C.db["Actionbar"]["CustomBarNumPerRow"]
	for i = 1, num do
		local button = frame.buttons[i]
		button:SetSize(size, size)
		button.Name:SetScale(scale)
		button.Count:SetScale(scale)
		button.HotKey:SetScale(scale)
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("TOPLEFT", frame, padding, -padding)
		elseif mod(i-1, perRow) ==  0 then
			button:SetPoint("TOP", frame.buttons[i-perRow], "BOTTOM", 0, -margin)
		else
			button:SetPoint("LEFT", frame.buttons[i-1], "RIGHT", margin, 0)
		end
		button:SetAttribute("statehidden", false)
		button:Show()
	end

	for i = num+1, 12 do
		local button = frame.buttons[i]
		button:SetAttribute("statehidden", true)
		button:Hide()
	end

	local column = min(num, perRow)
	local rows = ceil(num/perRow)
	frame:SetWidth(column*size + (column-1)*margin + 2*padding)
	frame:SetHeight(size*rows + (rows-1)*margin + 2*padding)
	frame.mover:SetSize(frame:GetSize())
end

function Bar:CustomBar()
	if not C.db["Actionbar"]["CustomBar"] then return end

	Bar:CreateCustomBar({"BOTTOM", UIParent, "BOTTOM", 0, 140})
	if DB.MyClass == "DRUID" then
		UpdatePageBySpells()
		B:RegisterEvent("LEARNED_SPELL_IN_TAB", UpdatePageBySpells)
	end
end