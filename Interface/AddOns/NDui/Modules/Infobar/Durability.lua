local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF
if not C.Infobar.Durability then return end

local module = B:GetModule("Infobar")
local info = module:RegisterInfobar("Dura", C.Infobar.DurabilityPos)

local format, sort, floor, select = string.format, table.sort, math.floor, select
local GetInventoryItemLink, GetInventoryItemDurability, GetInventoryItemTexture = GetInventoryItemLink, GetInventoryItemDurability, GetInventoryItemTexture
local GetMoney, GetRepairAllCost, RepairAllItems, CanMerchantRepair = GetMoney, GetRepairAllCost, RepairAllItems, CanMerchantRepair
local IsInGuild, CanGuildBankRepair, GetGuildBankWithdrawMoney = IsInGuild, CanGuildBankRepair, GetGuildBankWithdrawMoney
local C_Timer_After, IsShiftKeyDown = C_Timer.After, IsShiftKeyDown

local repairCostString = gsub(REPAIR_COST, HEADER_COLON, ":")
local lowDurabilityCap = .25

local localSlots = {
	[1] = {1, INVTYPE_HEAD, 1000},
	[2] = {3, INVTYPE_SHOULDER, 1000},
	[3] = {5, INVTYPE_CHEST, 1000},
	[4] = {6, INVTYPE_WAIST, 1000},
	[5] = {9, INVTYPE_WRIST, 1000},
	[6] = {10, L["Hands"], 1000},
	[7] = {7, INVTYPE_LEGS, 1000},
	[8] = {8, L["Feet"], 1000},
	[9] = {16, INVTYPE_WEAPONMAINHAND, 1000},
	[10] = {17, INVTYPE_WEAPONOFFHAND, 1000},
	[11] = {18, INVTYPE_RANGED, 1000}
}

local lastClick = 0

local function sortSlots(a, b)
	if a and b then
		return (a[3] == b[3] and a[1] < b[1]) or (a[3] < b[3])
	end
end

local function UpdateAllSlots()
	local numSlots = 0
	for i = 1, #localSlots do
		localSlots[i][3] = 1000
		local index = localSlots[i][1]
		if GetInventoryItemLink("player", index) then
			local current, max = GetInventoryItemDurability(index)
			if current then
				localSlots[i][3] = current/max
				numSlots = numSlots + 1
			end
			local iconTexture = GetInventoryItemTexture("player", index) or 134400
			localSlots[i][4] = "|T"..iconTexture..":13:15:0:0:50:50:4:46:4:46|t " or ""
		end
	end
	sort(localSlots, sortSlots)

	return numSlots
end

local function isLowDurability()
	for i = 1, #localSlots do
		if localSlots[i][3] < lowDurabilityCap then
			return true
		end
	end
end

local function getDurabilityColor(cur, max)
	local r, g, b = oUF:RGBColorGradient(cur, max, 1, 0, 0, 1, 1, 0, 0, 1, 0)
	return r, g, b
end

info.eventList = {
	"UPDATE_INVENTORY_DURABILITY", "PLAYER_ENTERING_WORLD"
}

local function SaveClickTime()
	lastClick = GetTime()
end

info.onEvent = function(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent(event)
	end

	if UpdateAllSlots() > 0 then
		local r, g, b = getDurabilityColor(floor(localSlots[1][3]*100), 100)
		self.text:SetFormattedText("%s%%|r"..L["D"], B.HexRGB(r, g, b)..floor(localSlots[1][3]*100))
	else
		self.text:SetText(L["D"]..": "..DB.MyColor..NONE)
	end

	if isLowDurability() and ((lastClick == 0) or (GetTime() - lastClick > 60*30)) then -- only half an hour
		B:ShowHelpTip(info, L["Low Durability"], "TOP", 0, 20, SaveClickTime, "Durability")
	else
		B:HideHelpTip("Durability")
	end
end

info.onMouseUp = function(self, btn)
	if btn == "MiddleButton" then
		--NDuiADB["RepairType"] = mod(NDuiADB["RepairType"] + 1, 3)
		NDuiADB["RepairType"] = mod(NDuiADB["RepairType"] + 1, 2)
		self:onEnter()
	else
		--if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end -- fix by LibShowUIPanel
		ToggleCharacter("PaperDollFrame")
	end
end

local repairlist = {
	[0] = "|cffff5555"..VIDEO_OPTIONS_DISABLED,
	[1] = "|cff55ff55"..VIDEO_OPTIONS_ENABLED,
	--[2] = "|cffffff55"..L["NFG"]
}

info.onEnter = function(self)
	local _, anchor, offset = module:GetTooltipAnchor(info)
	GameTooltip:SetOwner(self, "ANCHOR_"..anchor, 0, offset)
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine(DURABILITY, " ", 0,.6,1, 0,.6,1)
	GameTooltip:AddLine(" ")

	local totalCost = 0
	for i = 1, #localSlots do
		if localSlots[i][3] ~= 1000 then
			local slot = localSlots[i][1]
			local cur = floor(localSlots[i][3]*100)
			local slotIcon = localSlots[i][4]
			GameTooltip:AddDoubleLine(slotIcon..localSlots[i][2], cur.."%", 1,1,1, getDurabilityColor(cur, 100))

			B.ScanTip:SetOwner(UIParent, "ANCHOR_NONE")
			totalCost = totalCost + select(3, B.ScanTip:SetInventoryItem("player", slot))
		end
	end

	if totalCost > 0 then
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(repairCostString, module:GetMoneyString(totalCost), .6,.8,1, 1,1,1)
	end

	GameTooltip:AddDoubleLine(" ", DB.LineString)
	GameTooltip:AddDoubleLine(" ", DB.LeftButton..L["Player Panel"].." ", 1,1,1, .6,.8,1)
	GameTooltip:AddDoubleLine(" ", DB.ScrollButton..L["Auto Repair"]..": "..repairlist[NDuiADB["RepairType"]].." ", 1,1,1, .6,.8,1)
	GameTooltip:Show()
end

info.onLeave = B.HideTooltip

-- Auto repair
local isShown

local function autoRepair(override)
	if isShown and not override then return end
	isShown = true

	local myMoney = GetMoney()
	local repairAllCost, canRepair = GetRepairAllCost()

	if canRepair and repairAllCost > 0 then
		if myMoney > repairAllCost then
			RepairAllItems()
			print(format(DB.InfoColor.."%s|r%s", L["Repair cost"], module:GetMoneyString(repairAllCost)))
		else
			print(DB.InfoColor..L["Repair error"])
		end
	end
end

local function merchantClose()
	isShown = false
	B:UnregisterEvent("MERCHANT_CLOSED", merchantClose)
end

local function merchantShow()
	if IsShiftKeyDown() or NDuiADB["RepairType"] == 0 or not CanMerchantRepair() then return end
	autoRepair()
	B:RegisterEvent("MERCHANT_CLOSED", merchantClose)
end
B:RegisterEvent("MERCHANT_SHOW", merchantShow)