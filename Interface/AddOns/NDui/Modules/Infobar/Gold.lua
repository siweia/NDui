local _, ns = ...
local B, C, L, DB = unpack(ns)
if not C.Infobar.Gold then return end

local module = B:GetModule("Infobar")
local info = module:RegisterInfobar("Gold", C.Infobar.GoldPos)

local format, pairs, wipe, unpack = string.format, pairs, table.wipe, unpack
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
local GetMoney, GetNumWatchedTokens, Ambiguate = GetMoney, GetNumWatchedTokens, Ambiguate
local GetContainerNumSlots, GetContainerItemInfo, UseContainerItem = GetContainerNumSlots, GetContainerItemInfo, UseContainerItem
local GetContainerItemEquipmentSetInfo = GetContainerItemEquipmentSetInfo
local C_Timer_After, IsControlKeyDown, IsShiftKeyDown = C_Timer.After, IsControlKeyDown, IsShiftKeyDown
local C_CurrencyInfo_GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
local C_CurrencyInfo_GetBackpackCurrencyInfo = C_CurrencyInfo.GetBackpackCurrencyInfo
local CalculateTotalNumberOfFreeBagSlots = CalculateTotalNumberOfFreeBagSlots
local slotString = L["Bags"]..": %s%d"

local profit, spent, oldMoney = 0, 0, 0
local myName, myRealm = DB.MyName, DB.MyRealm

local crossRealms = GetAutoCompleteRealms()
if not crossRealms or #crossRealms == 0 then
	crossRealms = {[1]=myRealm}
end

StaticPopupDialogs["RESETGOLD"] = {
	text = L["Are you sure to reset the gold count?"],
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		for _, realm in pairs(crossRealms) do
			if NDuiADB["totalGold"][realm] then
				wipe(NDuiADB["totalGold"][realm])
			end
		end
		NDuiADB["totalGold"][myRealm][myName] = {GetMoney(), DB.MyClass}
	end,
	whileDead = 1,
}

local menuList = {
	{text = B.HexRGB(1, .8, 0)..REMOVE_WORLD_MARKERS.."!!!", notCheckable = true, func = function() StaticPopup_Show("RESETGOLD") end},
}

local function getClassIcon(class)
	local c1, c2, c3, c4 = unpack(CLASS_ICON_TCOORDS[class])
	c1, c2, c3, c4 = (c1+.03)*50, (c2-.03)*50, (c3+.03)*50, (c4-.03)*50
	local classStr = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:13:15:0:-1:50:50:"..c1..":"..c2..":"..c3..":"..c4.."|t "
	return classStr or ""
end

local function getSlotString()
	local num = CalculateTotalNumberOfFreeBagSlots()
	if num < 10 then
		return format(slotString, "|cffff0000", num)
	else
		return format(slotString, "|cff00ff00", num)
	end
end

info.eventList = {
	"PLAYER_MONEY",
	"SEND_MAIL_MONEY_CHANGED",
	"SEND_MAIL_COD_CHANGED",
	"PLAYER_TRADE_MONEY",
	"TRADE_MONEY_CHANGED",
	"PLAYER_ENTERING_WORLD",
}

info.onEvent = function(self, event, arg1)
	if event == "PLAYER_ENTERING_WORLD" then
		oldMoney = GetMoney()
		self:UnregisterEvent(event)

		if NDuiADB["ShowSlots"] then
			self:RegisterEvent("BAG_UPDATE")
		end
	elseif event == "BAG_UPDATE" then
		if arg1 < 0 or arg1 > 4 then return end
	end

	local newMoney = GetMoney()
	local change = newMoney - oldMoney	-- Positive if we gain money
	if oldMoney > newMoney then			-- Lost Money
		spent = spent - change
	else								-- Gained Moeny
		profit = profit + change
	end
	if NDuiADB["ShowSlots"] then
		self.text:SetText(getSlotString())
	else
		self.text:SetText(module:GetMoneyString(newMoney))
	end

	if not NDuiADB["totalGold"][myRealm] then NDuiADB["totalGold"][myRealm] = {} end
	if not NDuiADB["totalGold"][myRealm][myName] then NDuiADB["totalGold"][myRealm][myName] = {} end
	NDuiADB["totalGold"][myRealm][myName][1] = GetMoney()
	NDuiADB["totalGold"][myRealm][myName][2] = DB.MyClass

	oldMoney = newMoney
end

local RebuildCharList

local function clearCharGold(_, realm, name)
	NDuiADB["totalGold"][realm][name] = nil
	DropDownList1:Hide()
	RebuildCharList()
end

function RebuildCharList()
	for i = 2, #menuList do
		if menuList[i] then wipe(menuList[i]) end
	end

	local index = 1
	for _, realm in pairs(crossRealms) do
		if NDuiADB["totalGold"][realm] then
			for name, value in pairs(NDuiADB["totalGold"][realm]) do
				if not (realm == myRealm and name == myName) then
					index = index + 1
					if not menuList[index] then menuList[index] = {} end
					menuList[index].text = B.HexRGB(B.ClassColor(value[2]))..Ambiguate(name.."-"..realm, "none")
					menuList[index].notCheckable = true
					menuList[index].arg1 = realm
					menuList[index].arg2 = name
					menuList[index].func = clearCharGold
				end
			end
		end
	end
end

info.onMouseUp = function(self, btn)
	if btn == "RightButton" then
		if IsControlKeyDown() then
			if not menuList[1].created then
				RebuildCharList()
				menuList[1].created = true
			end
			EasyMenu(menuList, B.EasyMenu, self, -80, 100, "MENU", 1)
		else
			NDuiADB["ShowSlots"] = not NDuiADB["ShowSlots"]
			if NDuiADB["ShowSlots"] then
				self:RegisterEvent("BAG_UPDATE")
			else
				self:UnregisterEvent("BAG_UPDATE")
			end
			self:onEvent()
		end
	elseif btn == "MiddleButton" then
		NDuiADB["AutoSell"] = not NDuiADB["AutoSell"]
		self:onEnter()
	else
		--if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end -- fix by LibShowUIPanel
		ToggleCharacter("TokenFrame")
	end
end

info.onEnter = function(self)
	local _, anchor, offset = module:GetTooltipAnchor(info)
	GameTooltip:SetOwner(self, "ANCHOR_"..anchor, 0, offset)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(CURRENCY, 0,.6,1)
	GameTooltip:AddLine(" ")

	GameTooltip:AddLine(L["Session"], .6,.8,1)
	GameTooltip:AddDoubleLine(L["Earned"], module:GetMoneyString(profit, true), 1,1,1, 1,1,1)
	GameTooltip:AddDoubleLine(L["Spent"], module:GetMoneyString(spent, true), 1,1,1, 1,1,1)
	if profit < spent then
		GameTooltip:AddDoubleLine(L["Deficit"], module:GetMoneyString(spent-profit, true), 1,0,0, 1,1,1)
	elseif profit > spent then
		GameTooltip:AddDoubleLine(L["Profit"], module:GetMoneyString(profit-spent, true), 0,1,0, 1,1,1)
	end
	GameTooltip:AddLine(" ")

	local totalGold = 0
	GameTooltip:AddLine(L["RealmCharacter"], .6,.8,1)
	for _, realm in pairs(crossRealms) do
		local thisRealmList = NDuiADB["totalGold"][realm]
		if thisRealmList then
			for k, v in pairs(thisRealmList) do
				local name = Ambiguate(k.."-"..realm, "none")
				local gold, class = unpack(v)
				local r, g, b = B.ClassColor(class)
				GameTooltip:AddDoubleLine(getClassIcon(class)..name, module:GetMoneyString(gold), r,g,b, 1,1,1)
				totalGold = totalGold + gold
			end
		end
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(TOTAL..":", module:GetMoneyString(totalGold), .6,.8,1, 1,1,1)

	for i = 1, GetNumWatchedTokens() do
		local currencyInfo = C_CurrencyInfo_GetBackpackCurrencyInfo(i)
		if not currencyInfo then break end
		local name, count, icon, currencyID = currencyInfo.name, currencyInfo.quantity, currencyInfo.iconFileID, currencyInfo.currencyTypesID
		if name and i == 1 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(CURRENCY..":", .6,.8,1)
		end
		if name and count then
			local total = C_CurrencyInfo_GetCurrencyInfo(currencyID).maxQuantity
			local iconTexture = " |T"..icon..":13:15:0:0:50:50:4:46:4:46|t"
			if total > 0 then
				GameTooltip:AddDoubleLine(name, count.."/"..total..iconTexture, 1,1,1, 1,1,1)
			else
				GameTooltip:AddDoubleLine(name, count..iconTexture, 1,1,1, 1,1,1)
			end
		end
	end
	GameTooltip:AddDoubleLine(" ", DB.LineString)
	GameTooltip:AddDoubleLine(" ", DB.LeftButton..L["Currency Panel"].." ", 1,1,1, .6,.8,1)
	GameTooltip:AddDoubleLine(" ", DB.RightButton..L["Switch Mode"].." ", 1,1,1, .6,.8,1)
	GameTooltip:AddDoubleLine(" ", DB.ScrollButton..L["AutoSell Junk"]..": "..(NDuiADB["AutoSell"] and "|cff55ff55"..VIDEO_OPTIONS_ENABLED or "|cffff5555"..VIDEO_OPTIONS_DISABLED).." ", 1,1,1, .6,.8,1)
	GameTooltip:AddDoubleLine(" ", "CTRL +"..DB.RightButton..L["Reset Gold"].." ", 1,1,1, .6,.8,1)
	GameTooltip:Show()
end

info.onLeave = B.HideTooltip

-- Auto selljunk
local stop, cache = true, {}
local errorText = _G.ERR_VENDOR_DOESNT_BUY
local BAG = B:GetModule("Bags")

local function startSelling()
	if stop then return end
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			if stop then return end
			local _, _, _, quality, _, _, link, _, noValue, itemID = GetContainerItemInfo(bag, slot)
			local isInSet = GetContainerItemEquipmentSetInfo(bag, slot)
			if link and not noValue and not isInSet and not BAG:IsPetTrashCurrency(itemID) and (quality == 0 or NDuiADB["CustomJunkList"][itemID]) and not cache["b"..bag.."s"..slot] then
				cache["b"..bag.."s"..slot] = true
				UseContainerItem(bag, slot)
				C_Timer_After(.15, startSelling)
				return
			end
		end
	end
end

local function updateSelling(event, ...)
	if not NDuiADB["AutoSell"] then return end

	local _, arg = ...
	if event == "MERCHANT_SHOW" then
		if IsShiftKeyDown() then return end
		stop = false
		wipe(cache)
		startSelling()
		B:RegisterEvent("UI_ERROR_MESSAGE", updateSelling)
	elseif event == "UI_ERROR_MESSAGE" and arg == errorText or event == "MERCHANT_CLOSED" then
		stop = true
	end
end
B:RegisterEvent("MERCHANT_SHOW", updateSelling)
B:RegisterEvent("MERCHANT_CLOSED", updateSelling)