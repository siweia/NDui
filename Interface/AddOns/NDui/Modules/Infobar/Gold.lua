local B, C, L, DB = unpack(select(2, ...))
if not C.Infobar.Gold then return end

local module = NDui:GetModule("Infobar")
local info = module:RegisterInfobar(C.Infobar.GoldPos)

local profit, spent, oldMoney = 0, 0, 0
local myName, myRealm = UnitName("player"), GetRealmName()

local function formatTextMoney(money)
	return format("%.0f|cffffd700%s|r", money * .0001, GOLD_AMOUNT_SYMBOL)
end

local function getClassIcon(class)
	local c1, c2, c3, c4 = unpack(CLASS_ICON_TCOORDS[class])
	c1, c2, c3, c4 = (c1+.03)*50, (c2-.03)*50, (c3+.03)*50, (c4-.03)*50
	local classStr = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:13:15:0:-1:50:50:"..c1..":"..c2..":"..c3..":"..c4.."|t "
	return classStr or ""
end

info.eventList = {
	"PLAYER_MONEY",
	"SEND_MAIL_MONEY_CHANGED",
	"SEND_MAIL_COD_CHANGED",
	"PLAYER_TRADE_MONEY",
	"TRADE_MONEY_CHANGED",
	"PLAYER_ENTERING_WORLD",
}

info.onEvent = function(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		if NDuiADB["AutoSell"] == nil then NDuiADB["AutoSell"] = true end
		oldMoney = GetMoney()
		self:UnregisterEvent(event)
	end

	local newMoney = GetMoney()
	local change = newMoney - oldMoney	-- Positive if we gain money
	if oldMoney > newMoney then			-- Lost Money
		spent = spent - change
	else								-- Gained Moeny
		profit = profit + change
	end
	self.text:SetText(formatTextMoney(newMoney))

	if not NDuiADB["totalGold"] then NDuiADB["totalGold"] = {} end
	if not NDuiADB["totalGold"][myRealm] then NDuiADB["totalGold"][myRealm] = {} end
	NDuiADB["totalGold"][myRealm][myName] = {GetMoney(), DB.MyClass}

	oldMoney = newMoney
end

StaticPopupDialogs["RESETGOLD"] = {
	text = L["Are you sure to reset the gold count?"],
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		NDuiADB["totalGold"] = {}
		NDuiADB["totalGold"][myRealm] = {}
		NDuiADB["totalGold"][myRealm][myName] = {GetMoney(), DB.MyClass}
	end,
	whileDead = 1,
}

info.onMouseUp = function(self, btn)
	if IsControlKeyDown() and btn == "RightButton" then
		StaticPopup_Show("RESETGOLD")
	elseif btn == "RightButton" then
		NDuiADB["AutoSell"] = not NDuiADB["AutoSell"]
		self:GetScript("OnEnter")(self)
	else
		ToggleCharacter("TokenFrame")
	end
end

local function getGoldString(number)
	local money = format("%.0f", number/1e4)
	return GetMoneyString(money*1e4)
end

info.onEnter = function(self)
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("BOTTOMRIGHT", UIParent, -15, 30)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(CURRENCY, 0,.6,1)
	GameTooltip:AddLine(" ")

	GameTooltip:AddLine(L["Session"], .6,.8,1)
	GameTooltip:AddDoubleLine(L["Earned"], GetMoneyString(profit), 1,1,1, 1,1,1)
	GameTooltip:AddDoubleLine(L["Spent"], GetMoneyString(spent), 1,1,1, 1,1,1)
	if profit < spent then
		GameTooltip:AddDoubleLine(L["Deficit"], GetMoneyString(spent-profit), 1,0,0, 1,1,1)
	elseif profit > spent then
		GameTooltip:AddDoubleLine(L["Profit"], GetMoneyString(profit-spent), 0,1,0, 1,1,1)
	end
	GameTooltip:AddLine(" ")

	local totalGold = 0
	GameTooltip:AddLine(L["Character"], .6,.8,1)
	local thisRealmList = NDuiADB["totalGold"][myRealm]
	for k, v in pairs(thisRealmList) do
		local gold, class = unpack(v)
		GameTooltip:AddDoubleLine(getClassIcon(class)..k, getGoldString(gold), 1,1,1, 1,1,1)
		totalGold = totalGold + gold
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(TOTAL..":", getGoldString(totalGold), .6,.8,1, 1,1,1)

	for i = 1, GetNumWatchedTokens() do
		local name, count, icon, currencyID = GetBackpackCurrencyInfo(i)
		if name and i == 1 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(CURRENCY..":", .6,.8,1)
		end
		if name and count then
			local _, _, _, _, _, total = GetCurrencyInfo(currencyID)
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
	GameTooltip:AddDoubleLine(" ", DB.RightButton..L["AutoSell Junk"]..": "..(NDuiADB["AutoSell"] and "|cff55ff55"..VIDEO_OPTIONS_ENABLED or "|cffff5555"..VIDEO_OPTIONS_DISABLED).." ", 1,1,1, .6,.8,1)
	GameTooltip:AddDoubleLine(" ", "CTRL +"..DB.RightButton..L["Reset Gold"].." ", 1,1,1, .6,.8,1)
	GameTooltip:Show()
end

info.onLeave = function() GameTooltip:Hide() end

-- Auto sell junk
local f = NDui:EventFrame{"MERCHANT_SHOW", "MERCHANT_CLOSED"}
local sellJunkTicker

local function stopSelling()
	if sellJunkTicker then
		sellJunkTicker:Cancel()
		sellJunkTicker = nil
	end
	f:UnregisterEvent("UI_ERROR_MESSAGE")
end

local function startSelling()
	local c = 0
	for b = 0, 4 do
		for s = 1, GetContainerNumSlots(b) do
			local l = GetContainerItemLink(b, s)
			if l then
				local price = select(11, GetItemInfo(l))
				local _, count, _, quality = GetContainerItemInfo(b, s)
				if quality == 0 and price > 0 then
					c = c + price*count
					if MerchantFrame:IsShown() then
						UseContainerItem(b, s)
					else
						stopSelling()
						return
					end
				end
			end
		end
	end

	local firstRun = sellJunkTicker and sellJunkTicker._remainingIterations == 200
	if firstRun and c > 0 then
		print(format("|cff99CCFF"..L["Selljunk Calculate"]..":|r %s", GetMoneyString(c)))
	elseif c == 0 then
		stopSelling()
	end
end

f:SetScript("OnEvent", function(_, event, _, arg1)
	if not NDuiADB["AutoSell"] then return end
	if event == "MERCHANT_SHOW" then
		if IsShiftKeyDown() then return end
		sellJunkTicker = C_Timer.NewTicker(.2, startSelling, 200)
		f:RegisterEvent("UI_ERROR_MESSAGE")
	elseif event == "UI_ERROR_MESSAGE" and arg1 == ERR_VENDOR_DOESNT_BUY then
		stopSelling()
	elseif event == "MERCHANT_CLOSED" then
		stopSelling()
	end
end)