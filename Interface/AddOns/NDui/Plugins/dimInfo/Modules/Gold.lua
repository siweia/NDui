local _, ns = ...
local cfg = ns.cfg
local init = ns.init

if cfg.Gold == true then
	local Stat = CreateFrame("Frame", nil, UIParent)
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetFrameLevel(3)
	Stat:SetHitRectInsets(0, 0, -10, 0)
	local Text = Stat:CreateFontString(nil, "OVERLAY")
	Text:SetFont(unpack(cfg.Fonts))
	Text:SetPoint(unpack(cfg.GoldPoint))
	Stat:SetAllPoints(Text)

	local Profit, Spent, OldMoney = 0, 0, 0
	local myRealm = GetRealmName()
	local myName = UnitName("player")
	local myClass = select(2, UnitClass("player"))

	local function formatTextMoney(money)
		return format("%.0f|cffffd700%s|r", money * .0001, GOLD_AMOUNT_SYMBOL)
	end

	local function GetClassIcon(class)
		local c1, c2, c3, c4 = unpack(CLASS_ICON_TCOORDS[class])
		c1, c2, c3, c4 = (c1+.03)*50, (c2-.03)*50, (c3+.03)*50, (c4-.03)*50
		local classStr = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:13:15:0:-1:50:50:"..c1..":"..c2..":"..c3..":"..c4.."|t "
		return classStr or ""
	end

	local function OnEvent(self, event)
		if (diminfo.AutoSell == nil) then diminfo.AutoSell = true end
		if event == "PLAYER_LOGIN" then
			OldMoney = GetMoney()
		end

		local NewMoney = GetMoney()
		local Change = NewMoney - OldMoney	-- Positive if we gain money
		if OldMoney > NewMoney then			-- Lost Money
			Spent = Spent - Change
		else								-- Gained Moeny
			Profit = Profit + Change
		end
		Text:SetText(formatTextMoney(NewMoney))

		if not diminfo.totalGold then diminfo.totalGold = {} end
		if not diminfo.totalGold[myRealm] then diminfo.totalGold[myRealm] = {} end
		diminfo.totalGold[myRealm][myName] = {GetMoney(), myClass}

		OldMoney = NewMoney
	end

	-- reset gold diminfo
	local function RESETGOLD()
		diminfo.totalGold = {}
		diminfo.totalGold[myRealm] = {}
		diminfo.totalGold[myRealm][myName] = {GetMoney(), myClass}
	end
	StaticPopupDialogs["RESETGOLD"] = {
		text = ns.infoL["Are you sure to reset the gold count?"],
		button1 = YES,
		button2 = NO,
		OnAccept = RESETGOLD,
		whileDead = 1,
	}

	Stat:RegisterEvent("PLAYER_MONEY")
	Stat:RegisterEvent("SEND_MAIL_MONEY_CHANGED")
	Stat:RegisterEvent("SEND_MAIL_COD_CHANGED")
	Stat:RegisterEvent("PLAYER_TRADE_MONEY")
	Stat:RegisterEvent("TRADE_MONEY_CHANGED")
	Stat:RegisterEvent("PLAYER_LOGIN")
	Stat:SetScript("OnEvent", OnEvent)
	Stat:SetScript("OnMouseUp", function(self, button)
		if IsControlKeyDown() and button == "RightButton" then
			StaticPopup_Show("RESETGOLD")
		elseif button == "RightButton" then
			diminfo.AutoSell = not diminfo.AutoSell
			self:GetScript("OnEnter")(self)
		else
			ToggleCharacter("TokenFrame")
		end
	end)

	local function GetGoldString(number)
		local money = format("%d", number/1e4)
		return GetMoneyString(money*1e4)
	end

	Stat:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint("BOTTOMRIGHT", UIParent, -15, 30)
		GameTooltip:ClearLines()
		GameTooltip:AddLine(CURRENCY, 0,.6,1)
		GameTooltip:AddLine(" ")

		GameTooltip:AddLine(ns.infoL["Session"], .6,.8,1)
		GameTooltip:AddDoubleLine(ns.infoL["Earned:"], GetMoneyString(Profit), 1,1,1, 1,1,1)
		GameTooltip:AddDoubleLine(ns.infoL["Spent:"], GetMoneyString(Spent), 1,1,1, 1,1,1)
		if Profit < Spent then
			GameTooltip:AddDoubleLine(ns.infoL["Deficit:"], GetMoneyString(Spent-Profit), 1,0,0, 1,1,1)
		elseif Profit > Spent then
			GameTooltip:AddDoubleLine(ns.infoL["Profit:"], GetMoneyString(Profit-Spent), 0,1,0, 1,1,1)
		end
		GameTooltip:AddLine(" ")

		local totalGold = 0
		GameTooltip:AddLine(ns.infoL["Character"]..": ", .6,.8,1)
		local thisRealmList = diminfo.totalGold[myRealm]
		for k, v in pairs(thisRealmList) do
			local gold, class = unpack(v)
			GameTooltip:AddDoubleLine(GetClassIcon(class)..k, GetGoldString(gold), 1,1,1, 1,1,1)
			totalGold = totalGold + gold
		end
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(ns.infoL["Server"]..": ", .6,.8,1)
		GameTooltip:AddDoubleLine(TOTAL..": ", GetGoldString(totalGold), 1,1,1, 1,1,1)

		for i = 1, GetNumWatchedTokens() do
			local name, count, icon, currencyID = GetBackpackCurrencyInfo(i)
			if name and i == 1 then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(CURRENCY,.6,.8,1)
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
		GameTooltip:AddDoubleLine(" ", "--------------", 1,1,1, .5,.5,.5)
		GameTooltip:AddDoubleLine(" ", init.LeftButton..ns.infoL["CurrencyPanel"], 1,1,1, .6,.8,1)
		GameTooltip:AddDoubleLine(" ", init.RightButton..ns.infoL["AutoSell Junk"]..": "..(diminfo.AutoSell and "|cff55ff55"..VIDEO_OPTIONS_ENABLED or "|cffff5555"..VIDEO_OPTIONS_DISABLED), 1,1,1, .6,.8,1)
		GameTooltip:AddDoubleLine(" ", "CTRL+"..init.RightButton..ns.infoL["Reset Gold"], 1,1,1, .6,.8,1)
		GameTooltip:Show()
	end)
	Stat:SetScript("OnLeave", GameTooltip_Hide)

	-- autosell junk function
	local f = CreateFrame("Frame")
	local sellJunkTicker

	local function StopSelling()
		if sellJunkTicker then
			sellJunkTicker:Cancel()
			sellJunkTicker = nil
		end
		f:UnregisterEvent("UI_ERROR_MESSAGE")
	end

	local function StartSelling()
		local c = 0
		local saved
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
							StopSelling()
							return
						end
					end
				end
			end
		end

		local firstRun = sellJunkTicker and sellJunkTicker._remainingIterations == 200
		if firstRun and c > 0 then
			print(format("|cff99CCFF"..ns.infoL["Selljunk Calculate"]..":|r %s", GetMoneyString(c)))
		elseif c == 0 then
			StopSelling()
		end
	end

	f:RegisterEvent("MERCHANT_SHOW")
	f:RegisterEvent("MERCHANT_CLOSED")
	f:SetScript("OnEvent", function(self, event, _, arg1)
		if not diminfo.AutoSell then return end
		if event == "MERCHANT_SHOW" then
			if IsShiftKeyDown() then return end
			sellJunkTicker = C_Timer.NewTicker(.2, StartSelling, 200)
			f:RegisterEvent("UI_ERROR_MESSAGE")
		elseif event == "UI_ERROR_MESSAGE" and arg1 == ERR_VENDOR_DOESNT_BUY then
			StopSelling()
		elseif event == "MERCHANT_CLOSED" then
			StopSelling()
		end
	end)
end